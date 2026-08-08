#include "utils.h"

HL_PRIM bool HL_NAME(selectable)(vstring* label, bool* selected, ImGuiSelectableFlags* flags, vimvec2* size)
{
    return ImGui::Selectable(convertString(label), convertPtr(selected, false), convertPtr(flags, 0), getImVec2(size));
}

HL_PRIM bool HL_NAME(selectable_2)(vstring* label, bool* p_selected, ImGuiSelectableFlags* flags, vimvec2* size)
{
    return ImGui::Selectable(convertString(label), p_selected, convertPtr(flags, 0), getImVec2(size));
}

HL_PRIM ImGuiMultiSelectIO* HL_NAME(begin_multi_select)(ImGuiMultiSelectFlags flags, int* selection_size, int* items_count)
{
    return ImGui::BeginMultiSelect(flags, convertPtr(selection_size, -1), convertPtr(items_count, -1));
}

HL_PRIM ImGuiMultiSelectIO* HL_NAME(end_multi_select)()
{
    return ImGui::EndMultiSelect();
}

HL_PRIM void HL_NAME(set_next_item_selection_user_data)(ImGuiSelectionUserData selection_user_data)
{
    ImGui::SetNextItemSelectionUserData(selection_user_data);
}

HL_PRIM bool HL_NAME(is_item_toggled_selection)()
{
    return ImGui::IsItemToggledSelection();
}

HL_PRIM int HL_NAME(multi_select_io_get_requests_count)(ImGuiMultiSelectIO* io)
{
    return io->Requests.Size;
}

HL_PRIM ImGuiSelectionRequest* HL_NAME(multi_select_io_get_request)(ImGuiMultiSelectIO* io, int index)
{
    if (index < 0 || index >= io->Requests.Size) throw_error("Selection request index out of bounds");
    return &io->Requests[index];
}

HL_PRIM ImGuiSelectionUserData HL_NAME(multi_select_io_get_range_src_item)(ImGuiMultiSelectIO* io)
{
    return io->RangeSrcItem;
}

HL_PRIM ImGuiSelectionUserData HL_NAME(multi_select_io_get_nav_id_item)(ImGuiMultiSelectIO* io)
{
    return io->NavIdItem;
}

HL_PRIM bool HL_NAME(multi_select_io_get_nav_id_selected)(ImGuiMultiSelectIO* io)
{
    return io->NavIdSelected;
}

HL_PRIM bool HL_NAME(multi_select_io_get_range_src_reset)(ImGuiMultiSelectIO* io)
{
    return io->RangeSrcReset;
}

HL_PRIM void HL_NAME(multi_select_io_set_range_src_reset)(ImGuiMultiSelectIO* io, bool value)
{
    io->RangeSrcReset = value;
}

HL_PRIM int HL_NAME(multi_select_io_get_items_count)(ImGuiMultiSelectIO* io)
{
    return io->ItemsCount;
}

HL_PRIM int HL_NAME(selection_request_get_type)(ImGuiSelectionRequest* request)
{
    return request->Type;
}

HL_PRIM bool HL_NAME(selection_request_get_selected)(ImGuiSelectionRequest* request)
{
    return request->Selected;
}

HL_PRIM int HL_NAME(selection_request_get_range_direction)(ImGuiSelectionRequest* request)
{
    return request->RangeDirection;
}

HL_PRIM ImGuiSelectionUserData HL_NAME(selection_request_get_range_first_item)(ImGuiSelectionRequest* request)
{
    return request->RangeFirstItem;
}

HL_PRIM ImGuiSelectionUserData HL_NAME(selection_request_get_range_last_item)(ImGuiSelectionRequest* request)
{
    return request->RangeLastItem;
}

#define _TMULTISELECTIO _ABSTRACT(imguimultiselectio)
#define _TSELECTIONREQUEST _ABSTRACT(imguiselectionrequest)

DEFINE_PRIM(_BOOL, selectable, _STRING _REF(_BOOL) _REF(_I32) _IMVEC2);
DEFINE_PRIM(_BOOL, selectable_2, _STRING _REF(_BOOL) _REF(_I32) _IMVEC2);
DEFINE_PRIM(_TMULTISELECTIO, begin_multi_select, _I32 _REF(_I32) _REF(_I32));
DEFINE_PRIM(_TMULTISELECTIO, end_multi_select, _NO_ARG);
DEFINE_PRIM(_VOID, set_next_item_selection_user_data, _I64);
DEFINE_PRIM(_BOOL, is_item_toggled_selection, _NO_ARG);
DEFINE_PRIM(_I32, multi_select_io_get_requests_count, _TMULTISELECTIO);
DEFINE_PRIM(_TSELECTIONREQUEST, multi_select_io_get_request, _TMULTISELECTIO _I32);
DEFINE_PRIM(_I64, multi_select_io_get_range_src_item, _TMULTISELECTIO);
DEFINE_PRIM(_I64, multi_select_io_get_nav_id_item, _TMULTISELECTIO);
DEFINE_PRIM(_BOOL, multi_select_io_get_nav_id_selected, _TMULTISELECTIO);
DEFINE_PRIM(_BOOL, multi_select_io_get_range_src_reset, _TMULTISELECTIO);
DEFINE_PRIM(_VOID, multi_select_io_set_range_src_reset, _TMULTISELECTIO _BOOL);
DEFINE_PRIM(_I32, multi_select_io_get_items_count, _TMULTISELECTIO);
DEFINE_PRIM(_I32, selection_request_get_type, _TSELECTIONREQUEST);
DEFINE_PRIM(_BOOL, selection_request_get_selected, _TSELECTIONREQUEST);
DEFINE_PRIM(_I32, selection_request_get_range_direction, _TSELECTIONREQUEST);
DEFINE_PRIM(_I64, selection_request_get_range_first_item, _TSELECTIONREQUEST);
DEFINE_PRIM(_I64, selection_request_get_range_last_item, _TSELECTIONREQUEST);
