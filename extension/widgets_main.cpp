#include "utils.h"

HL_PRIM bool HL_NAME(button)(vstring* label, vimvec2* size)
{
	return ImGui::Button(convertString(label), getImVec2(size));
}

HL_PRIM bool HL_NAME(small_button)(vstring* label)
{
	return ImGui::SmallButton(convertString(label));
}

HL_PRIM bool HL_NAME(invisible_button)(vstring* str_id, vimvec2* size, ImGuiButtonFlags* flags)
{
	return ImGui::InvisibleButton(convertString(str_id), getImVec2(size), convertPtr(flags, 0));
}

HL_PRIM bool HL_NAME(arrow_button)(vstring* str_id, ImGuiDir dir)
{
	return ImGui::ArrowButton(convertString(str_id), dir);
}

HL_PRIM void HL_NAME(image_ref)(ImTextureID texture_id, vimvec2* size, vimvec2* uv0, vimvec2* uv1)
{
	ImGui::Image(
		ImTextureRef(texture_id),
		getImVec2(size),
		getImVec2(uv0),
		getImVec2(uv1, ImVec2(1, 1))
	);
}

HL_PRIM void HL_NAME(image_compat)(ImTextureID texture_id, vimvec2* size, vimvec2* uv0, vimvec2* uv1, vimvec4* tint_col, vimvec4* border_col)
{
	const ImVec4 border = getImVec4(border_col);
	const float border_size = ImGui::GetStyle().ImageBorderSize > 1.0f ? ImGui::GetStyle().ImageBorderSize : 1.0f;
	ImGui::PushStyleVar(ImGuiStyleVar_ImageBorderSize, border.w > 0.0f ? border_size : 0.0f);
	ImGui::PushStyleColor(ImGuiCol_Border, border);
	ImGui::ImageWithBg(
		ImTextureRef(texture_id),
		getImVec2(size),
		getImVec2(uv0),
		getImVec2(uv1, ImVec2(1, 1)),
		ImVec4(0, 0, 0, 0),
		getImVec4(tint_col, ImVec4(1, 1, 1, 1))
	);
	ImGui::PopStyleColor();
	ImGui::PopStyleVar();
}

HL_PRIM void HL_NAME(image_with_bg)(ImTextureID texture_id, vimvec2* size, vimvec2* uv0, vimvec2* uv1, vimvec4* bg_col, vimvec4* tint_col)
{
	ImGui::ImageWithBg(
		ImTextureRef(texture_id),
		getImVec2(size),
		getImVec2(uv0),
		getImVec2(uv1, ImVec2(1, 1)),
		getImVec4(bg_col),
		getImVec4(tint_col, ImVec4(1, 1, 1, 1))
	);
}

HL_PRIM bool HL_NAME(image_button)(vstring* str_id, ImTextureID texture_id, vimvec2* size, vimvec2* uv0, vimvec2* uv1, vimvec4* bg_col, vimvec4* tint_col)
{
	return ImGui::ImageButton(
		convertStringNullAsEmpty(str_id),
		ImTextureRef(texture_id),
		getImVec2(size),
		getImVec2(uv0),
		getImVec2(uv1, ImVec2(1, 1)),
		getImVec4(bg_col),
		getImVec4(tint_col, ImVec4(1, 1, 1, 1))
	);
}

HL_PRIM bool HL_NAME(image_button_compat)(ImTextureID texture_id, vimvec2* size, vimvec2* uv0, vimvec2* uv1, int frame_padding, vimvec4* bg_col, vimvec4* tint_col)
{
	bool has_frame_padding = frame_padding >= 0;
	if (has_frame_padding) ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2((float)frame_padding, (float)frame_padding));
	ImGui::PushID((void*)(uintptr_t)texture_id);
	bool result = ImGui::ImageButton(
		"##image_button",
		ImTextureRef(texture_id),
		getImVec2(size),
		getImVec2(uv0),
		getImVec2(uv1, ImVec2(1, 1)),
		getImVec4(bg_col),
		getImVec4(tint_col, ImVec4(1, 1, 1, 1))
	);
	ImGui::PopID();
	if (has_frame_padding) ImGui::PopStyleVar();
	return result;
}

HL_PRIM bool HL_NAME(checkbox)(vstring* label, bool* v)
{
	return ImGui::Checkbox(convertString(label), v);
}

HL_PRIM bool HL_NAME(checkbox_flags)(vstring* label, unsigned int* flags, unsigned int flags_value)
{
	return ImGui::CheckboxFlags(convertString(label), flags, flags_value);
}

HL_PRIM bool HL_NAME(radio_button)(vstring* label, bool active)
{
	return ImGui::RadioButton(convertString(label), active);
}

HL_PRIM bool HL_NAME(radio_button2)(vstring* label, int* v, int v_button)
{
	return ImGui::RadioButton(convertString(label), v, v_button);
}

HL_PRIM void HL_NAME(progress_bar)(float fraction, vimvec2* size_arg, vstring* overlay)
{
	ImGui::ProgressBar(fraction, getImVec2(size_arg, ImVec2(-1, 0)), convertString(overlay));
}

HL_PRIM void HL_NAME(bullet)()
{
	ImGui::Bullet();
}

DEFINE_PRIM(_BOOL, button, _STRING _IMVEC2);
DEFINE_PRIM(_BOOL, small_button, _STRING);
DEFINE_PRIM(_BOOL, invisible_button, _STRING _IMVEC2 _REF(_I32));
DEFINE_PRIM(_BOOL, arrow_button, _STRING _I32);
DEFINE_PRIM(_VOID, image_ref, _IMTEXID _IMVEC2 _IMVEC2 _IMVEC2);
DEFINE_PRIM(_VOID, image_compat, _IMTEXID _IMVEC2 _IMVEC2 _IMVEC2 _IMVEC4 _IMVEC4);
DEFINE_PRIM(_VOID, image_with_bg, _IMTEXID _IMVEC2 _IMVEC2 _IMVEC2 _IMVEC4 _IMVEC4);
DEFINE_PRIM(_BOOL, image_button, _STRING _IMTEXID _IMVEC2 _IMVEC2 _IMVEC2 _IMVEC4 _IMVEC4);
DEFINE_PRIM(_BOOL, image_button_compat, _IMTEXID _IMVEC2 _IMVEC2 _IMVEC2 _I32 _IMVEC4 _IMVEC4);
DEFINE_PRIM(_BOOL, checkbox, _STRING _REF(_BOOL));
DEFINE_PRIM(_BOOL, checkbox_flags, _STRING _REF(_I32) _I32);
DEFINE_PRIM(_BOOL, radio_button, _STRING _BOOL);
DEFINE_PRIM(_BOOL, radio_button2, _STRING _REF(_I32) _I32);
DEFINE_PRIM(_VOID, progress_bar, _F32 _IMVEC2 _STRING);
DEFINE_PRIM(_VOID, bullet, _NO_ARG);
