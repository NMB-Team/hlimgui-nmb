#include "utils.h"
#include "clip_rect.h"

#include <algorithm>
#include <chrono>
#include <cstddef>
#include <cstring>

// Fix for casting void* -> vdynamic*
#define hl_call1fixed(ret, cl, t, v) (cl->hasValue ? ((ret (*)(vdynamic*, t))cl->fun)((vdynamic*)cl->value, v) : ((ret (*)(t))cl->fun)(v))

static_assert(offsetof(ImDrawVert, pos) == 0);
static_assert(offsetof(ImDrawVert, uv) == sizeof(ImVec2));
static_assert(offsetof(ImDrawVert, col) == sizeof(ImVec2) * 2);
static_assert(sizeof(ImDrawVert) == offsetof(ImDrawVert, col) + sizeof(ImU32));
static_assert(sizeof(ImDrawIdx) == sizeof(unsigned int));

static vclosure* s_render_function = nullptr;
static vclosure* s_texture_function = nullptr;
hl_type* hlt_imvec2;
hl_type* hlt_imvec4;
hl_type* hlt_rendercommand;
hl_type* hlt_renderdata;
hl_type* hlt_rendertexturedata;

typedef struct {
	hl_type* t;
	vdynamic* texture_id;
	int index_offset;
	int elem_count;

	int clip_left;
	int clip_top;
	int clip_width;
	int clip_height;

	bool reset_render_state;
	vclosure* callback;
	vdynamic* callback_data;
} vrendercommand;

typedef struct {
	hl_type* t;
	vbyte* vertex_buffer;
	int vertex_buffer_size;
	int vertex_count;
	int vertex_stride;
	int position_offset;
	int uv_offset;
	int color_offset;
	float display_pos_x;
	float display_pos_y;
	vbyte* index_buffer;
	int index_buffer_size;
	int index_count;
	int index_buffer_capacity;
	varray* commands;
	int command_count;
} vrenderdata;

typedef struct {
	hl_type* t;
	varray* lists;
	int size;
	int vertex_count;
	int vertex_bytes;
	int prepare_time_us;
	float framebuffer_scale_x;
	float framebuffer_scale_y;
	int framebuffer_width;
	int framebuffer_height;
} vrenderlist;

static vrenderlist* render_list = nullptr;

typedef struct {
	hl_type* t;
	ImTextureData* texture_data;
	int unique_id;
	int status;
	vdynamic* texture_id;
	vbyte* pixels;
	int width;
	int height;
	int bytes_per_pixel;
} vrendertexturedata;

typedef struct {
	hl_type* t;
	varray* updates;
	int size;
} vrendertexturelist;

static vrendertexturelist* render_texture_list = nullptr;

static void updateTextures(ImDrawData* draw_data) {
	if (s_texture_function == nullptr || render_texture_list == nullptr || draw_data->Textures == nullptr)
		return;

	int update_count = 0;
	for (ImTextureData* texture : *draw_data->Textures)
		if (texture->Status != ImTextureStatus_OK)
			update_count++;

	if (update_count == 0)
		return;

	if (render_texture_list->updates->size < update_count)
		render_texture_list->updates = hl_alloc_array(hlt_rendertexturedata, update_count);
	render_texture_list->size = update_count;

	vrendertexturedata** updates = hl_aptr(render_texture_list->updates, vrendertexturedata*);
	int update_index = 0;
	for (ImTextureData* texture : *draw_data->Textures) {
		if (texture->Status == ImTextureStatus_OK)
			continue;

		vrendertexturedata* update = updates[update_index];
		if (update == nullptr)
			update = updates[update_index] = (vrendertexturedata*)hl_alloc_obj(hlt_rendertexturedata);

		update->texture_data = texture;
		update->unique_id = texture->UniqueID;
		update->status = texture->Status;
		update->texture_id = (vdynamic*)(intptr_t)texture->TexID;
		update->width = texture->Width;
		update->height = texture->Height;
		update->bytes_per_pixel = texture->BytesPerPixel;
		if (texture->Status == ImTextureStatus_WantCreate || texture->Status == ImTextureStatus_WantUpdates) {
			const int data_size = texture->GetSizeInBytes();
			update->pixels = hl_copy_bytes((vbyte*)texture->GetPixels(), data_size);
		} else {
			update->pixels = nullptr;
		}
		update_index++;
	}

	hl_call1fixed(void, s_texture_function, vrendertexturelist*, render_texture_list);
}

void renderDrawLists(ImDrawData* draw_data) {
	if (s_render_function == nullptr || render_list == nullptr)
		return;
	updateTextures(draw_data);

#ifdef HLIMGUI_RENDER_BENCHMARK
	const auto prepare_start = std::chrono::steady_clock::now();
#endif

	const int cmd_lists_count = draw_data->CmdLists.Size;

	// Reallocate varray in case there's more draw lists than before.

	if (render_list->lists->size < cmd_lists_count) {
		varray* old = render_list->lists;
		render_list->lists = hl_alloc_array(hlt_renderdata, cmd_lists_count);
		// Copy over previously allocated data
		int size = hl_type_size(hlt_renderdata);
		memmove((vbyte*)hl_aptr(render_list->lists, vbyte), (vbyte*)hl_aptr(old, vbyte), old->size * size);
	}

	// Store the amount draw lists to render, as varray is grow type and can contain invalid data if amount of draw lists shrink.
	render_list->size = cmd_lists_count;
	render_list->vertex_count = 0;
	render_list->vertex_bytes = 0;
	render_list->framebuffer_scale_x = draw_data->FramebufferScale.x;
	render_list->framebuffer_scale_y = draw_data->FramebufferScale.y;
	render_list->framebuffer_width = std::max(0, int(draw_data->DisplaySize.x * draw_data->FramebufferScale.x));
	render_list->framebuffer_height = std::max(0, int(draw_data->DisplaySize.y * draw_data->FramebufferScale.y));
	vrenderdata** hl_cmd_list_ptr = hl_aptr(render_list->lists, vrenderdata*);

	for (int n = 0; n < cmd_lists_count; n++) {
		const ImDrawList* cmd_list = draw_data->CmdLists[n];

		// Allocate render data storage and command list if not allocated before.
		if (hl_cmd_list_ptr[n] == nullptr) {
			hl_cmd_list_ptr[n] = (vrenderdata*)hl_alloc_obj(hlt_renderdata);
			hl_cmd_list_ptr[n]->commands = hl_alloc_array(hlt_rendercommand, cmd_list->CmdBuffer.size());
		}
		vrenderdata* hl_cmd_list = hl_cmd_list_ptr[n];

		// The Haxe callback uploads synchronously while ImDrawData is alive, so this can be a zero-copy byte view.
		const int nb_vertex = cmd_list->VtxBuffer.size();
		const int vertex_buffer_size = int(sizeof(ImDrawVert) * nb_vertex);
		hl_cmd_list->vertex_buffer = reinterpret_cast<vbyte*>(cmd_list->VtxBuffer.Data);
		hl_cmd_list->vertex_buffer_size = vertex_buffer_size;
		hl_cmd_list->vertex_count = nb_vertex;
		hl_cmd_list->vertex_stride = sizeof(ImDrawVert);
		hl_cmd_list->position_offset = offsetof(ImDrawVert, pos);
		hl_cmd_list->uv_offset = offsetof(ImDrawVert, uv);
		hl_cmd_list->color_offset = offsetof(ImDrawVert, col);
		hl_cmd_list->display_pos_x = draw_data->DisplayPos.x;
		hl_cmd_list->display_pos_y = draw_data->DisplayPos.y;
		render_list->vertex_count += nb_vertex;
		render_list->vertex_bytes += vertex_buffer_size;

		// Keep a writable index copy so non-zero ImDrawCmd::VtxOffset values can be rebased for Heaps.
		const int index_buffer_size = cmd_list->IdxBuffer.size_in_bytes();
		if (hl_cmd_list->index_buffer_capacity < index_buffer_size) {
			const int capacity = std::max(index_buffer_size, hl_cmd_list->index_buffer_capacity + hl_cmd_list->index_buffer_capacity / 2);
			hl_cmd_list->index_buffer = hl_alloc_bytes(capacity);
			hl_cmd_list->index_buffer_capacity = capacity;
		}
		if (index_buffer_size > 0)
			memcpy(hl_cmd_list->index_buffer, cmd_list->IdxBuffer.Data, index_buffer_size);
		hl_cmd_list->index_buffer_size = index_buffer_size;
		hl_cmd_list->index_count = cmd_list->IdxBuffer.size();

		// create the array for command buffer
		int command_count = cmd_list->CmdBuffer.size();

		if (hl_cmd_list->commands->size < command_count) {
			varray* old = hl_cmd_list->commands;
			hl_cmd_list->commands = hl_alloc_array(hlt_rendercommand, command_count);
			// Copy over previously allocated data
			int size = hl_type_size(hlt_rendercommand);
			memmove(hl_aptr(hl_cmd_list->commands, vbyte), hl_aptr(old, vbyte), old->size * size);
		}
		hl_cmd_list->command_count = command_count;

		vrendercommand** hl_commands = hl_aptr(hl_cmd_list->commands, vrendercommand*);

		for (int cmd_i = 0; cmd_i < cmd_list->CmdBuffer.size(); cmd_i++) {
			const ImDrawCmd* pcmd = &cmd_list->CmdBuffer[cmd_i];
			if (pcmd->VtxOffset != 0) {
				ImDrawIdx* indices = reinterpret_cast<ImDrawIdx*>(hl_cmd_list->index_buffer);
				for (unsigned int index = pcmd->IdxOffset; index < pcmd->IdxOffset + pcmd->ElemCount; index++)
					indices[index] += pcmd->VtxOffset;
			}

			vrendercommand* hl_cmd_buffer = hl_commands[cmd_i] == nullptr ? (hl_commands[cmd_i] = (vrendercommand*)hl_alloc_obj(hlt_rendercommand)) : hl_commands[cmd_i];

			hl_cmd_buffer->texture_id = (vdynamic*)(intptr_t)pcmd->GetTexID();
			hl_cmd_buffer->index_offset = pcmd->IdxOffset;

			const FramebufferClipRect clip = makeFramebufferClipRect(
				pcmd->ClipRect.x,
				pcmd->ClipRect.y,
				pcmd->ClipRect.z,
				pcmd->ClipRect.w,
				draw_data->DisplayPos.x,
				draw_data->DisplayPos.y,
				draw_data->FramebufferScale.x,
				draw_data->FramebufferScale.y,
				render_list->framebuffer_width,
				render_list->framebuffer_height
			);
			hl_cmd_buffer->elem_count = pcmd->UserCallback == nullptr && !clip.visible ? 0 : pcmd->ElemCount;
			hl_cmd_buffer->clip_left = clip.left;
			hl_cmd_buffer->clip_top = clip.top;
			hl_cmd_buffer->clip_width = clip.width;
			hl_cmd_buffer->clip_height = clip.height;

			hl_cmd_buffer->reset_render_state = pcmd->UserCallback == ImDrawCallback_ResetRenderState;
			if (pcmd->UserCallback != nullptr && !hl_cmd_buffer->reset_render_state) {
				hl_cmd_buffer->callback = pcmd->UserCallback;
				hl_cmd_buffer->callback_data = (vdynamic*)pcmd->UserCallbackData;
				releaseRenderCallback(pcmd->UserCallback, (vdynamic*)pcmd->UserCallbackData);
			} else {
				hl_cmd_buffer->callback = NULL;
				hl_cmd_buffer->callback_data = NULL;
			}
		}
	}

#ifdef HLIMGUI_RENDER_BENCHMARK
	render_list->prepare_time_us = int(std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::steady_clock::now() - prepare_start).count());
#else
	render_list->prepare_time_us = 0;
#endif

	hl_call1fixed(void, s_render_function, vrenderlist*, render_list);
}

HL_PRIM void HL_NAME(set_render_callback)(vclosure* render_fn) {
	if (s_render_function != nullptr)
		hl_remove_root(&s_render_function);
	s_render_function = render_fn;
	if (render_fn != nullptr)
		hl_add_root(&s_render_function);
}

HL_PRIM void HL_NAME(set_texture_callback)(vclosure* texture_fn) {
	if (s_texture_function != nullptr)
		hl_remove_root(&s_texture_function);
	s_texture_function = texture_fn;
	if (texture_fn != nullptr)
		hl_add_root(&s_texture_function);
}

HL_PRIM void HL_NAME(imtexturedata_set_texture)(ImTextureData* texture_data, vdynamic* texture) {
	texture_data->SetTexID((ImTextureID)(intptr_t)texture);
	texture_data->SetStatus(ImTextureStatus_OK);
}

HL_PRIM void HL_NAME(imtexturedata_set_updated)(ImTextureData* texture_data) {
	texture_data->SetStatus(ImTextureStatus_OK);
}

HL_PRIM void HL_NAME(imtexturedata_set_destroyed)(ImTextureData* texture_data) {
	texture_data->BackendUserData = nullptr;
	texture_data->SetTexID(ImTextureID_Invalid);
	texture_data->SetStatus(ImTextureStatus_Destroyed);
}

HL_PRIM void HL_NAME(invalidate_renderer_textures)() {
	if (ImGui::GetCurrentContext() == nullptr)
		return;
	for (ImTextureData* texture : ImGui::GetPlatformIO().Textures) {
		texture->BackendUserData = nullptr;
		texture->SetTexID(ImTextureID_Invalid);
		texture->SetStatus(ImTextureStatus_Destroyed);
	}
}

HL_PRIM void HL_NAME(add_key_char)(int c) {
	ImGuiIO& io = ImGui::GetIO();
	io.AddInputCharacter(c);
}

HL_PRIM void HL_NAME(add_key_event)(ImGuiKey c, bool down) {
	ImGuiIO& io = ImGui::GetIO();
	io.AddKeyEvent(c, down);
}

HL_PRIM void HL_NAME(set_events)(float dt, float mouse_x, float mouse_y, float wheel, bool left_click, bool right_click) {
	ImGuiIO& io = ImGui::GetIO();
	io.MousePos = ImVec2(mouse_x, mouse_y);
	io.MouseWheel = wheel;
	io.MouseDown[0] = left_click;
	io.MouseDown[1] = right_click;
}

HL_PRIM void HL_NAME(set_display_size)(int display_width, int display_height) {
	ImGuiIO& io = ImGui::GetIO();

	io.DisplaySize = ImVec2(float(display_width), float(display_height));
}

HL_PRIM void HL_NAME(new_frame)() {
	clearPendingRenderCallbacks();
	ImGuiIO& io = ImGui::GetIO();
	if (io.DeltaTime <= 0.0f)
		io.DeltaTime = 1.0f / 60.0f;
	ImGui::NewFrame();
}

HL_PRIM void HL_NAME(end_frame)() {
	ImGui::EndFrame();
}

HL_PRIM void HL_NAME(render)() {
	ImGui::Render();

	ImDrawData* draw_data = ImGui::GetDrawData();
	renderDrawLists(draw_data);
}

/**
	Hack: Because we want to allocate ImVec2/4 classes on HL side, we need to hijack the hl_type of those classes somehow.
	And there's no API to obtain said classes. So we steal them from live instances.
**/
HL_PRIM void HL_NAME(initialize)(vimvec2* hl_vec2, vimvec4* hl_vec4, vrenderlist* renderlist, vrenderdata* renderdata, vrendercommand* rendercommand, vrendertexturelist* texturelist, vrendertexturedata* texturedata) {
	hlt_imvec2 = hl_vec2->t;
	hlt_imvec4 = hl_vec4->t;
	if (render_list == nullptr)
		hl_add_root(&render_list);
	render_list = renderlist;
	hlt_renderdata = renderdata->t;
	hlt_rendercommand = rendercommand->t;
	if (render_texture_list == nullptr)
		hl_add_root(&render_texture_list);
	render_texture_list = texturelist;
	hlt_rendertexturedata = texturedata->t;
}

DEFINE_PRIM(_VOID, initialize, _IMVEC2 _IMVEC4 _TRENDERLIST _TRENDERDATA _TRENDERCOMMAND _TRENDERTEXTURELIST _TRENDERTEXTUREDATA);
DEFINE_PRIM(_VOID, set_render_callback, _FUN(_VOID, _TRENDERLIST));
DEFINE_PRIM(_VOID, set_texture_callback, _RENDERTEXTURECALLBACK);
DEFINE_PRIM(_VOID, imtexturedata_set_texture, _TIMTEXTUREDATA _IMTEXID);
DEFINE_PRIM(_VOID, imtexturedata_set_updated, _TIMTEXTUREDATA);
DEFINE_PRIM(_VOID, imtexturedata_set_destroyed, _TIMTEXTUREDATA);
DEFINE_PRIM(_VOID, invalidate_renderer_textures, _NO_ARG);
DEFINE_PRIM(_VOID, add_key_char, _I32);
DEFINE_PRIM(_VOID, add_key_event, _I32 _BOOL);
DEFINE_PRIM(_VOID, set_events, _F32 _F32 _F32 _F32 _BOOL _BOOL);
DEFINE_PRIM(_VOID, set_display_size, _I32 _I32);

DEFINE_PRIM(_VOID, new_frame, _NO_ARG);
DEFINE_PRIM(_VOID, end_frame, _NO_ARG);
DEFINE_PRIM(_VOID, render, _NO_ARG);
