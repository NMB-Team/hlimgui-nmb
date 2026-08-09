#include "utils.h"

HL_PRIM int HL_NAME(get_key_index)(ImGuiKey imgui_key) {
	return imgui_key;
}

HL_PRIM bool HL_NAME(is_key_down)(ImGuiKey user_key_index) {
	return ImGui::IsKeyDown(user_key_index);
}

HL_PRIM bool HL_NAME(is_key_pressed)(ImGuiKey user_key_index, bool* repeat) {
	return ImGui::IsKeyPressed(user_key_index, convertPtr(repeat, true));
}

HL_PRIM bool HL_NAME(is_key_released)(ImGuiKey user_key_index) {
	return ImGui::IsKeyReleased(user_key_index);
}

HL_PRIM bool HL_NAME(is_key_chord_pressed)(ImGuiKeyChord key_chord) {
	return ImGui::IsKeyChordPressed(key_chord);
}

HL_PRIM int HL_NAME(get_key_pressed_amount)(ImGuiKey key_index, float repeat_delay, float rate) {
	return ImGui::GetKeyPressedAmount(key_index, repeat_delay, rate);
}

HL_PRIM vbyte* HL_NAME(get_key_name)(ImGuiKey key) {
	return getVByteFromCStr(ImGui::GetKeyName(key));
}

HL_PRIM bool HL_NAME(shortcut)(ImGuiKeyChord key_chord, ImGuiInputFlags* flags) {
	return ImGui::Shortcut(key_chord, convertPtr(flags, 0));
}

HL_PRIM void HL_NAME(set_next_item_shortcut)(ImGuiKeyChord key_chord, ImGuiInputFlags* flags) {
	ImGui::SetNextItemShortcut(key_chord, convertPtr(flags, 0));
}

HL_PRIM void HL_NAME(capture_keyboard_from_app)(bool* want_capture_keyboard_value) {
	ImGui::SetNextFrameWantCaptureKeyboard(convertPtr(want_capture_keyboard_value, true));
}

DEFINE_PRIM(_I32, get_key_index, _I32);
DEFINE_PRIM(_BOOL, is_key_down, _I32);
DEFINE_PRIM(_BOOL, is_key_pressed, _I32 _REF(_BOOL));
DEFINE_PRIM(_BOOL, is_key_released, _I32);
DEFINE_PRIM(_BOOL, is_key_chord_pressed, _I32);
DEFINE_PRIM(_I32, get_key_pressed_amount, _I32 _F32 _F32);
DEFINE_PRIM(_BYTES, get_key_name, _I32);
DEFINE_PRIM(_BOOL, shortcut, _I32 _REF(_I32));
DEFINE_PRIM(_VOID, set_next_item_shortcut, _I32 _REF(_I32));
DEFINE_PRIM(_VOID, capture_keyboard_from_app, _REF(_BOOL));
