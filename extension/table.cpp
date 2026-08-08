#include "utils.h"

HL_PRIM bool HL_NAME(begin_table)(vstring *id, int column, ImGuiTableFlags *flags, vimvec2 *outer_size, float *inner_width)
{
    return ImGui::BeginTable( convertString( id ), column, convertPtr( flags, 0 ), getImVec2( outer_size ), convertPtr( inner_width, 0.0f ) );
}

HL_PRIM void HL_NAME(end_table)()
{
    ImGui::EndTable();
}

HL_PRIM void HL_NAME(table_next_row)( ImGuiTableRowFlags *row_flags, float *min_row_height )
{
     ImGui::TableNextRow( convertPtr( row_flags, 0 ), convertPtr( min_row_height, 0.0f ) );
}

HL_PRIM bool HL_NAME(table_next_column)()
{
    return ImGui::TableNextColumn();
}

HL_PRIM bool HL_NAME(table_set_column_index)(int column_index)
{
    return ImGui::TableSetColumnIndex(column_index);
}

HL_PRIM void HL_NAME(table_setup_column)( vstring *id, ImGuiTableColumnFlags *flags, float *init_width_or_weight, ImGuiID *user_id )
{
    ImGui::TableSetupColumn( convertString(id), convertPtr(flags, 0), convertPtr(init_width_or_weight, 0.0f), convertPtr(user_id, 0 ) );
}

HL_PRIM void HL_NAME(table_setup_scroll_freeze)(int cols, int rows )
{
    ImGui::TableSetupScrollFreeze(cols, rows);
}

HL_PRIM void HL_NAME(table_headers_row)()
{
    ImGui::TableHeadersRow();
}

HL_PRIM void HL_NAME(table_angled_headers_row)()
{
    ImGui::TableAngledHeadersRow();
}

HL_PRIM void HL_NAME(table_header)( vstring *id )
{
    ImGui::TableHeader( convertString( id ) );
}

HL_PRIM ImGuiTableSortSpecs* HL_NAME(table_get_sort_specs)()
{
    return ImGui::TableGetSortSpecs();
}

HL_PRIM int HL_NAME(table_sort_specs_get_specs_count)(ImGuiTableSortSpecs* specs)
{
    return specs->SpecsCount;
}

HL_PRIM bool HL_NAME(table_sort_specs_get_specs_dirty)(ImGuiTableSortSpecs* specs)
{
    return specs->SpecsDirty;
}

HL_PRIM void HL_NAME(table_sort_specs_set_specs_dirty)(ImGuiTableSortSpecs* specs, bool value)
{
    specs->SpecsDirty = value;
}

HL_PRIM const ImGuiTableColumnSortSpecs* HL_NAME(table_sort_specs_get_spec)(ImGuiTableSortSpecs* specs, int index)
{
    if (index < 0 || index >= specs->SpecsCount) throw_error("Table sort spec index out of bounds");
    return &specs->Specs[index];
}

HL_PRIM ImGuiID HL_NAME(table_column_sort_specs_get_column_user_id)(const ImGuiTableColumnSortSpecs* specs)
{
    return specs->ColumnUserID;
}

HL_PRIM int HL_NAME(table_column_sort_specs_get_column_index)(const ImGuiTableColumnSortSpecs* specs)
{
    return specs->ColumnIndex;
}

HL_PRIM int HL_NAME(table_column_sort_specs_get_sort_order)(const ImGuiTableColumnSortSpecs* specs)
{
    return specs->SortOrder;
}

HL_PRIM int HL_NAME(table_column_sort_specs_get_sort_direction)(const ImGuiTableColumnSortSpecs* specs)
{
    return specs->SortDirection;
}

HL_PRIM int HL_NAME(table_get_column_count)()
{
    return ImGui::TableGetColumnCount();
}

HL_PRIM int HL_NAME(table_get_column_index)()
{
    return ImGui::TableGetColumnIndex();
}

HL_PRIM int HL_NAME(table_get_row_index)()
{
    return ImGui::TableGetRowIndex();
}

HL_PRIM vbyte* HL_NAME(table_get_column_name)( int *column_n )
{
    return getVByteFromCStr( ImGui::TableGetColumnName( convertPtr( column_n, -1 ) ) );
}

HL_PRIM ImGuiTableColumnFlags HL_NAME(table_get_column_flags)(int* column_n)
{
    return ImGui::TableGetColumnFlags(convertPtr(column_n, -1));
}

HL_PRIM int HL_NAME(table_get_hovered_column)()
{
    return ImGui::TableGetHoveredColumn();
}

HL_PRIM void HL_NAME(table_set_column_enabled)( int column_n, bool enabled )
{
    ImGui::TableSetColumnEnabled( column_n, enabled );
}

HL_PRIM void HL_NAME(table_set_bgcolor)( ImGuiTableBgTarget target, ImU32 color, int *column_n )
{
    ImGui::TableSetBgColor( target, color, convertPtr( column_n, -1 ) );
}

#define _TTABLESORTSPECS _ABSTRACT(imguitablesortspecs)
#define _TCOLUMNSORTSPECS _ABSTRACT(imguitablecolumnsortspecs)

DEFINE_PRIM(_BOOL, begin_table, _STRING _I32 _REF(_I32) _IMVEC2 _REF(_F32));
DEFINE_PRIM(_VOID, end_table, _NO_ARG);
DEFINE_PRIM(_VOID, table_next_row, _REF(_I32) _REF(_F32) );
DEFINE_PRIM(_BOOL, table_next_column, _NO_ARG);
DEFINE_PRIM(_BOOL, table_set_column_index, _I32 );
DEFINE_PRIM(_VOID, table_setup_column, _STRING _REF(_I32) _REF(_F32) _REF(_I32) );
DEFINE_PRIM(_VOID, table_setup_scroll_freeze, _I32 _I32 );
DEFINE_PRIM(_VOID, table_headers_row, _NO_ARG );
DEFINE_PRIM(_VOID, table_angled_headers_row, _NO_ARG );
DEFINE_PRIM(_VOID, table_header, _STRING );
DEFINE_PRIM(_TTABLESORTSPECS, table_get_sort_specs, _NO_ARG );
DEFINE_PRIM(_I32, table_sort_specs_get_specs_count, _TTABLESORTSPECS );
DEFINE_PRIM(_BOOL, table_sort_specs_get_specs_dirty, _TTABLESORTSPECS );
DEFINE_PRIM(_VOID, table_sort_specs_set_specs_dirty, _TTABLESORTSPECS _BOOL );
DEFINE_PRIM(_TCOLUMNSORTSPECS, table_sort_specs_get_spec, _TTABLESORTSPECS _I32 );
DEFINE_PRIM(_I32, table_column_sort_specs_get_column_user_id, _TCOLUMNSORTSPECS );
DEFINE_PRIM(_I32, table_column_sort_specs_get_column_index, _TCOLUMNSORTSPECS );
DEFINE_PRIM(_I32, table_column_sort_specs_get_sort_order, _TCOLUMNSORTSPECS );
DEFINE_PRIM(_I32, table_column_sort_specs_get_sort_direction, _TCOLUMNSORTSPECS );
DEFINE_PRIM(_I32, table_get_column_count, _NO_ARG );
DEFINE_PRIM(_I32, table_get_column_index, _NO_ARG );
DEFINE_PRIM(_I32, table_get_row_index, _NO_ARG );
DEFINE_PRIM(_BYTES, table_get_column_name, _REF(_I32) );
DEFINE_PRIM(_I32, table_get_column_flags, _REF(_I32) );
DEFINE_PRIM(_I32, table_get_hovered_column, _NO_ARG );
DEFINE_PRIM(_VOID, table_set_column_enabled, _I32 _BOOL );
DEFINE_PRIM(_VOID, table_set_bgcolor, _I32 _I32 _REF(_I32) );

