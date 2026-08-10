#include "utils.h"
#include "imgui_internal.h"

// #define _TVIEWPORT _ABSTRACT(imguiviewport)

struct HLImGuiPlatformClosures {
	vclosure* Platform_CreateWindow;
	vclosure* Platform_DestroyWindow;
	vclosure* Platform_ShowWindow;
	vclosure* Platform_SetWindowPos;
	vclosure* Platform_GetWindowPos;
	vclosure* Platform_SetWindowSize;
	vclosure* Platform_GetWindowSize;
	vclosure* Platform_SetWindowFocus;
	vclosure* Platform_GetWindowFocus;
	vclosure* Platform_GetWindowMinimized;
	vclosure* Platform_SetWindowTitle;
	vclosure* Platform_SetWindowAlpha;
	vclosure* Renderer_RenderWindow;
	vclosure* Renderer_SwapBuffers;
};

HLImGuiPlatformClosures HlClosures;
extern ImGuiContext* GImGui;

void HlPlatform_CreateWindow(ImGuiViewport* vp) {
	hl_call1(void, HlClosures.Platform_CreateWindow, ImGuiViewport*, vp);
	hl_add_root(&vp->PlatformHandle);
	hl_add_root(&vp->PlatformHandleRaw);
}

void HlPlatform_DestroyWindow(ImGuiViewport* vp) {
	hl_call1(void, HlClosures.Platform_DestroyWindow, ImGuiViewport*, vp);
	hl_remove_root(&vp->PlatformHandle);
	hl_remove_root(&vp->PlatformHandleRaw);
}

void HlPlatform_ShowWindow(ImGuiViewport* vp) {
	hl_call1(void, HlClosures.Platform_ShowWindow, ImGuiViewport*, vp);
}

void HlPlatform_SetWindowPos(ImGuiViewport* vp, ImVec2 pos) {
	hl_call2(void, HlClosures.Platform_SetWindowPos, ImGuiViewport*, vp, vimvec2*, (vimvec2*)pos);
}

ImVec2 HlPlatform_GetWindowPos(ImGuiViewport* vp) {
	ImVec2 pos;
	hl_call2(void, HlClosures.Platform_GetWindowPos, ImGuiViewport*, vp, ImVec2*, &pos);
	return pos;
}

void HlPlatform_SetWindowSize(ImGuiViewport* vp, ImVec2 size) {
	hl_call2(void, HlClosures.Platform_SetWindowSize, ImGuiViewport*, vp, vimvec2*, (vimvec2*)size);
}

ImVec2 HlPlatform_GetWindowSize(ImGuiViewport* vp) {
	ImVec2 size;
	// @todo: returning through hl_call doesn't appear to work?
	hl_call2(void, HlClosures.Platform_GetWindowSize, ImGuiViewport*, vp, ImVec2*, &size);
	return size;
}

void HlPlatform_SetWindowFocus(ImGuiViewport* vp) {
	hl_call1(void, HlClosures.Platform_SetWindowFocus, ImGuiViewport*, vp);
}

bool HlPlatform_GetWindowFocus(ImGuiViewport* vp) {
	return hl_call1(bool, HlClosures.Platform_GetWindowFocus, ImGuiViewport*, vp);
}

bool HlPlatform_GetWindowMinimized(ImGuiViewport* vp) {
	return hl_call1(bool, HlClosures.Platform_GetWindowMinimized, ImGuiViewport*, vp);
}

void HlPlatform_SetWindowTitle(ImGuiViewport* vp, const char* title) {
	hl_call2(bool, HlClosures.Platform_SetWindowTitle, ImGuiViewport*, vp, vbyte*, getVByteFromCStr(title));
}

void HlPlatform_SetWindowAlpha(ImGuiViewport* vp, float alpha) {
	hl_call2(bool, HlClosures.Platform_SetWindowAlpha, ImGuiViewport*, vp, float, alpha);
}

void HlRenderer_RenderWindow(ImGuiViewport* vp, void* render_arg) {
	renderDrawLists(vp->DrawData);
	hl_call2(bool, HlClosures.Renderer_RenderWindow, ImGuiViewport*, vp, void*, render_arg);
}

void HlRenderer_SwapBuffers(ImGuiViewport* vp, void* render_arg) {
	hl_call2(bool, HlClosures.Renderer_SwapBuffers, ImGuiViewport*, vp, void*, render_arg);
}

HL_PRIM ImGuiPlatformIO* HL_NAME(get_platform_io)() {
	return &ImGui::GetPlatformIO();
}

template <typename T> static void setPlatformCallback(vclosure*& destination, vclosure* callback, T& platform_callback, T wrapper) {
	if (destination != nullptr)
		hl_remove_root(&destination);
	destination = callback;
	platform_callback = callback == nullptr ? nullptr : wrapper;
	if (destination != nullptr)
		hl_add_root(&destination);
}

static void clearPlatformClosure(vclosure*& callback) {
	if (callback != nullptr)
		hl_remove_root(&callback);
	callback = nullptr;
}

// PlatformIO Accessors
HL_PRIM void HL_NAME(platformio_set_platform_create_window)(vclosure* p) {
	ImGuiContext& g = *GImGui;
	// Uncomment for debugging.
	// g.DebugLogFlags |= ImGuiDebugLogFlags_EventViewport;
	ImGuiPlatformIO& pio = ImGui::GetPlatformIO();
	setPlatformCallback(HlClosures.Platform_CreateWindow, p, pio.Platform_CreateWindow, HlPlatform_CreateWindow);
}

HL_PRIM void HL_NAME(platformio_set_platform_destroy_window)(vclosure* p) {
	ImGuiPlatformIO& pio = ImGui::GetPlatformIO();
	setPlatformCallback(HlClosures.Platform_DestroyWindow, p, pio.Platform_DestroyWindow, HlPlatform_DestroyWindow);
}

HL_PRIM void HL_NAME(platformio_set_platform_show_window)(vclosure* p) {
	ImGuiPlatformIO& pio = ImGui::GetPlatformIO();
	setPlatformCallback(HlClosures.Platform_ShowWindow, p, pio.Platform_ShowWindow, HlPlatform_ShowWindow);
}

HL_PRIM void HL_NAME(platformio_set_platform_set_window_pos)(vclosure* p) {
	ImGuiPlatformIO& pio = ImGui::GetPlatformIO();
	setPlatformCallback(HlClosures.Platform_SetWindowPos, p, pio.Platform_SetWindowPos, HlPlatform_SetWindowPos);
}

HL_PRIM void HL_NAME(platformio_set_platform_get_window_pos)(vclosure* p) {
	ImGuiPlatformIO& pio = ImGui::GetPlatformIO();
	setPlatformCallback(HlClosures.Platform_GetWindowPos, p, pio.Platform_GetWindowPos, HlPlatform_GetWindowPos);
}

HL_PRIM void HL_NAME(platformio_set_platform_set_window_size)(vclosure* p) {
	ImGuiPlatformIO& pio = ImGui::GetPlatformIO();
	setPlatformCallback(HlClosures.Platform_SetWindowSize, p, pio.Platform_SetWindowSize, HlPlatform_SetWindowSize);
}

HL_PRIM void HL_NAME(platformio_set_platform_get_window_size)(vclosure* p) {
	ImGuiPlatformIO& pio = ImGui::GetPlatformIO();
	setPlatformCallback(HlClosures.Platform_GetWindowSize, p, pio.Platform_GetWindowSize, HlPlatform_GetWindowSize);
}

HL_PRIM void HL_NAME(platformio_set_platform_set_window_focus)(vclosure* p) {
	ImGuiPlatformIO& pio = ImGui::GetPlatformIO();
	setPlatformCallback(HlClosures.Platform_SetWindowFocus, p, pio.Platform_SetWindowFocus, HlPlatform_SetWindowFocus);
}

HL_PRIM void HL_NAME(platformio_set_platform_get_window_focus)(vclosure* p) {
	ImGuiPlatformIO& pio = ImGui::GetPlatformIO();
	setPlatformCallback(HlClosures.Platform_GetWindowFocus, p, pio.Platform_GetWindowFocus, HlPlatform_GetWindowFocus);
}

HL_PRIM void HL_NAME(platformio_set_platform_get_window_minimized)(vclosure* p) {
	ImGuiPlatformIO& pio = ImGui::GetPlatformIO();
	setPlatformCallback(HlClosures.Platform_GetWindowMinimized, p, pio.Platform_GetWindowMinimized, HlPlatform_GetWindowMinimized);
}

HL_PRIM void HL_NAME(platformio_set_platform_set_window_title)(vclosure* p) {
	ImGuiPlatformIO& pio = ImGui::GetPlatformIO();
	setPlatformCallback(HlClosures.Platform_SetWindowTitle, p, pio.Platform_SetWindowTitle, HlPlatform_SetWindowTitle);
}

HL_PRIM void HL_NAME(platformio_set_platform_set_window_alpha)(vclosure* p) {
	ImGuiPlatformIO& pio = ImGui::GetPlatformIO();
	setPlatformCallback(HlClosures.Platform_SetWindowAlpha, p, pio.Platform_SetWindowAlpha, HlPlatform_SetWindowAlpha);
}

HL_PRIM void HL_NAME(platformio_set_renderer_render_window)(vclosure* p) {
	ImGuiPlatformIO& pio = ImGui::GetPlatformIO();
	setPlatformCallback(HlClosures.Renderer_RenderWindow, p, pio.Renderer_RenderWindow, HlRenderer_RenderWindow);
}

HL_PRIM void HL_NAME(platformio_set_renderer_swap_buffers)(vclosure* p) {
	ImGuiPlatformIO& pio = ImGui::GetPlatformIO();
	setPlatformCallback(HlClosures.Renderer_SwapBuffers, p, pio.Renderer_SwapBuffers, HlRenderer_SwapBuffers);
}

HL_PRIM void HL_NAME(clear_platform_callbacks)() {
	if (GImGui != nullptr) {
		ImGuiPlatformIO& pio = ImGui::GetPlatformIO();
		pio.Platform_CreateWindow = nullptr;
		pio.Platform_DestroyWindow = nullptr;
		pio.Platform_ShowWindow = nullptr;
		pio.Platform_SetWindowPos = nullptr;
		pio.Platform_GetWindowPos = nullptr;
		pio.Platform_SetWindowSize = nullptr;
		pio.Platform_GetWindowSize = nullptr;
		pio.Platform_SetWindowFocus = nullptr;
		pio.Platform_GetWindowFocus = nullptr;
		pio.Platform_GetWindowMinimized = nullptr;
		pio.Platform_SetWindowTitle = nullptr;
		pio.Platform_SetWindowAlpha = nullptr;
		pio.Renderer_RenderWindow = nullptr;
		pio.Renderer_SwapBuffers = nullptr;
	}

	clearPlatformClosure(HlClosures.Platform_CreateWindow);
	clearPlatformClosure(HlClosures.Platform_DestroyWindow);
	clearPlatformClosure(HlClosures.Platform_ShowWindow);
	clearPlatformClosure(HlClosures.Platform_SetWindowPos);
	clearPlatformClosure(HlClosures.Platform_GetWindowPos);
	clearPlatformClosure(HlClosures.Platform_SetWindowSize);
	clearPlatformClosure(HlClosures.Platform_GetWindowSize);
	clearPlatformClosure(HlClosures.Platform_SetWindowFocus);
	clearPlatformClosure(HlClosures.Platform_GetWindowFocus);
	clearPlatformClosure(HlClosures.Platform_GetWindowMinimized);
	clearPlatformClosure(HlClosures.Platform_SetWindowTitle);
	clearPlatformClosure(HlClosures.Platform_SetWindowAlpha);
	clearPlatformClosure(HlClosures.Renderer_RenderWindow);
	clearPlatformClosure(HlClosures.Renderer_SwapBuffers);
}

HL_PRIM void HL_NAME(platformio_add_monitor)(vimvec2* size, vimvec2* pos) {
	ImGuiPlatformIO& pio = ImGui::GetPlatformIO();
	ImGuiPlatformMonitor m;
	m.DpiScale = 1.f;
	m.MainSize.x = size->x;
	m.MainSize.y = size->y;
	m.MainPos.x = pos->x;
	m.MainPos.y = pos->y;

	m.WorkSize = m.MainSize;
	m.WorkPos = m.MainPos;

	pio.Monitors.push_back(m);
}

HL_PRIM ImGuiViewport* HL_NAME(platformio_set_main_viewport)(vdynamic* HWND) {
	ImGuiPlatformIO& pio = ImGui::GetPlatformIO();
	pio.Viewports[0]->PlatformHandle = HWND;
	return pio.Viewports[0];
}

// Actual viewport functions

HL_PRIM void HL_NAME(update_platform_windows)() {
	ImGui::UpdatePlatformWindows();
}

HL_PRIM void HL_NAME(render_platform_windows_default)(void* platform_render_arg, void* renderer_render_arg) {
	ImGui::RenderPlatformWindowsDefault(platform_render_arg, renderer_render_arg);
}

HL_PRIM ImGuiViewport* HL_NAME(get_main_viewport)() {
	return ImGui::GetMainViewport();
}

HL_PRIM ImGuiViewport* HL_NAME(get_window_viewport)() {
	return ImGui::GetWindowViewport();
}

HL_PRIM void HL_NAME(destroy_platform_windows)() {
	ImGui::DestroyPlatformWindows();
}

HL_PRIM ImGuiViewport* HL_NAME(find_viewport_by_id)(ImGuiID viewport_id) {
	return ImGui::FindViewportByID(viewport_id);
}

HL_PRIM ImGuiViewport* HL_NAME(find_viewport_by_platform_handle)(vdynamic* platform_handle) {
	return ImGui::FindViewportByPlatformHandle(platform_handle);
}

// Context accessors
HL_PRIM ImGuiViewport* HL_NAME(context_get_current_viewport)() {
	ImGuiContext& g = *GImGui;
	return g.CurrentViewport;
}

DEFINE_PRIM(_STRUCT, get_platform_io, _NO_ARG);

DEFINE_PRIM(_VOID, platformio_set_platform_create_window, _FUN(_VOID, _STRUCT));
DEFINE_PRIM(_VOID, platformio_set_platform_destroy_window, _FUN(_VOID, _STRUCT));
DEFINE_PRIM(_VOID, platformio_set_platform_show_window, _FUN(_VOID, _STRUCT));
DEFINE_PRIM(_VOID, platformio_set_platform_set_window_pos, _FUN(_VOID, _STRUCT _IMVEC2));
DEFINE_PRIM(_VOID, platformio_set_platform_get_window_pos, _FUN(_VOID, _STRUCT _STRUCT));
DEFINE_PRIM(_VOID, platformio_set_platform_set_window_size, _FUN(_VOID, _STRUCT _IMVEC2));
DEFINE_PRIM(_VOID, platformio_set_platform_get_window_size, _FUN(_VOID, _STRUCT _STRUCT));
DEFINE_PRIM(_VOID, platformio_set_platform_set_window_focus, _FUN(_VOID, _STRUCT));
DEFINE_PRIM(_VOID, platformio_set_platform_get_window_focus, _FUN(_BOOL, _STRUCT));
DEFINE_PRIM(_VOID, platformio_set_platform_get_window_minimized, _FUN(_BOOL, _STRUCT));
DEFINE_PRIM(_VOID, platformio_set_platform_set_window_title, _FUN(_VOID, _STRUCT _BYTES));
DEFINE_PRIM(_VOID, platformio_set_platform_set_window_alpha, _FUN(_VOID, _STRUCT _F32));
DEFINE_PRIM(_VOID, platformio_set_renderer_render_window, _FUN(_VOID, _STRUCT _DYN));
DEFINE_PRIM(_VOID, platformio_set_renderer_swap_buffers, _FUN(_VOID, _STRUCT _DYN));
DEFINE_PRIM(_VOID, clear_platform_callbacks, _NO_ARG);

DEFINE_PRIM(_VOID, platformio_add_monitor, _IMVEC2 _IMVEC2);
DEFINE_PRIM(_STRUCT, platformio_set_main_viewport, _DYN);
DEFINE_PRIM(_STRUCT, context_get_current_viewport, _NO_ARG);
///

DEFINE_PRIM(_VOID, update_platform_windows, _NO_ARG);
DEFINE_PRIM(_VOID, render_platform_windows_default, _DYN _DYN);
DEFINE_PRIM(_STRUCT, get_main_viewport, _NO_ARG);
DEFINE_PRIM(_STRUCT, get_window_viewport, _NO_ARG);
DEFINE_PRIM(_VOID, destroy_platform_windows, _NO_ARG);
DEFINE_PRIM(_STRUCT, find_viewport_by_id, _I32);
DEFINE_PRIM(_STRUCT, find_viewport_by_platform_handle, _DYN);
