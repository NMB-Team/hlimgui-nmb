#include "utils.h"
#include "lib/imgui/imgui_internal.h"

HL_PRIM bool HL_NAME(is_item_hovered)(ImGuiHoveredFlags* flags)
{
    return ImGui::IsItemHovered(convertPtr(flags, 0));
}

HL_PRIM bool HL_NAME(is_item_active)()
{
    return ImGui::IsItemActive();
}

HL_PRIM bool HL_NAME(is_item_focused)()
{
    return ImGui::IsItemFocused();
}

HL_PRIM bool HL_NAME(is_item_clicked)(ImGuiMouseButton* mouse_button)
{
    return ImGui::IsItemClicked(convertPtr(mouse_button, 0));
}

HL_PRIM bool HL_NAME(is_item_visible)()
{
    return ImGui::IsItemVisible();
}

HL_PRIM bool HL_NAME(is_item_edited)()
{
    return ImGui::IsItemEdited();
}

HL_PRIM bool HL_NAME(is_item_activated)()
{
    return ImGui::IsItemActivated();
}

HL_PRIM bool HL_NAME(is_item_deactivated)()
{
    return ImGui::IsItemDeactivated();
}

HL_PRIM bool HL_NAME(is_item_deactivated_after_edit)()
{
    return ImGui::IsItemDeactivatedAfterEdit();
}

HL_PRIM bool HL_NAME(is_item_toggled_open)()
{
    return ImGui::IsItemToggledOpen();
}

HL_PRIM bool HL_NAME(is_any_item_hovered)()
{
    return ImGui::IsAnyItemHovered();
}

HL_PRIM bool HL_NAME(is_any_item_active)()
{
    return ImGui::IsAnyItemActive();
}

HL_PRIM bool HL_NAME(is_any_item_focused)()
{
    return ImGui::IsAnyItemFocused();
}

HL_PRIM ImGuiID HL_NAME(get_item_id)()
{
    return ImGui::GetItemID();
}

HL_PRIM vimvec2* HL_NAME(get_item_rect_min)()
{
    return ImGui::GetItemRectMin();
}

HL_PRIM vimvec2* HL_NAME(get_item_rect_max)()
{
    return ImGui::GetItemRectMax();
}

HL_PRIM vimvec2* HL_NAME(get_item_rect_size)()
{
    return ImGui::GetItemRectSize();
}

HL_PRIM ImGuiItemFlags HL_NAME(get_item_flags)()
{
    return ImGui::GetItemFlags();
}

HL_PRIM int HL_NAME(get_item_clicked_count_with_single_click_delay)(ImGuiMouseButton* mouse_button, float* delay)
{
    return ImGui::GetItemClickedCountWithSingleClickDelay(convertPtr(mouse_button, 0), convertPtr(delay, -1.0f));
}

HL_PRIM void HL_NAME(set_nav_cursor_visible)(bool visible)
{
    ImGui::SetNavCursorVisible(visible);
}

HL_PRIM void HL_NAME(set_next_item_allow_overlap)()
{
    ImGui::SetNextItemAllowOverlap();
}

HL_PRIM void HL_NAME(set_item_allow_overlap)()
{
    ImGui::SetNextItemAllowOverlap();
}

HL_PRIM void HL_NAME(set_key_owner)( ImGuiKey key, ImGuiID owner_id, ImGuiInputFlags* flags )
{
    ImGui::SetKeyOwner( key, owner_id, convertPtr(flags,0) );
}

HL_PRIM bool HL_NAME(set_item_key_owner)( ImGuiKey key, ImGuiInputFlags* flags )
{
    const ImGuiInputFlags value = convertPtr(flags, 0);
    return value == 0 ? ImGui::SetItemKeyOwner(key) : ImGui::SetItemKeyOwner(key, value);
}

DEFINE_PRIM(_BOOL, is_item_hovered, _REF(_I32));
DEFINE_PRIM(_BOOL, is_item_active, _NO_ARG);
DEFINE_PRIM(_BOOL, is_item_focused, _NO_ARG);
DEFINE_PRIM(_BOOL, is_item_clicked, _REF(_I32));
DEFINE_PRIM(_BOOL, is_item_visible, _NO_ARG);
DEFINE_PRIM(_BOOL, is_item_edited, _NO_ARG);
DEFINE_PRIM(_BOOL, is_item_activated, _NO_ARG);
DEFINE_PRIM(_BOOL, is_item_deactivated, _NO_ARG);
DEFINE_PRIM(_BOOL, is_item_deactivated_after_edit, _NO_ARG);
DEFINE_PRIM(_BOOL, is_item_toggled_open, _NO_ARG);
DEFINE_PRIM(_BOOL, is_any_item_hovered, _NO_ARG);
DEFINE_PRIM(_BOOL, is_any_item_active, _NO_ARG);
DEFINE_PRIM(_BOOL, is_any_item_focused, _NO_ARG);
DEFINE_PRIM(_I32, get_item_id, _NO_ARG);
DEFINE_PRIM(_IMVEC2, get_item_rect_min, _NO_ARG);
DEFINE_PRIM(_IMVEC2, get_item_rect_max, _NO_ARG);
DEFINE_PRIM(_IMVEC2, get_item_rect_size, _NO_ARG);
DEFINE_PRIM(_I32, get_item_flags, _NO_ARG);
DEFINE_PRIM(_I32, get_item_clicked_count_with_single_click_delay, _REF(_I32) _REF(_F32));
DEFINE_PRIM(_VOID, set_nav_cursor_visible, _BOOL);
DEFINE_PRIM(_VOID, set_next_item_allow_overlap, _NO_ARG);
DEFINE_PRIM(_VOID, set_item_allow_overlap, _NO_ARG);
DEFINE_PRIM(_VOID, set_key_owner, _I32 _I32 _REF(_I32) );
DEFINE_PRIM(_BOOL, set_item_key_owner, _I32 _REF(_I32) );
