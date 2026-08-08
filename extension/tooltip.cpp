#include "utils.h"

HL_PRIM bool HL_NAME(begin_tooltip)()
{
    return ImGui::BeginTooltip();
}

HL_PRIM void HL_NAME(end_tooltip)()
{
    ImGui::EndTooltip();
}

HL_PRIM void HL_NAME(set_tooltip)(vstring* fmt)
{
    ImGui::SetTooltip("%s", convertStringNullAsEmpty(fmt));
}

HL_PRIM bool HL_NAME(begin_item_tooltip)()
{
    return ImGui::BeginItemTooltip();
}

HL_PRIM void HL_NAME(set_item_tooltip)(vstring* text)
{
    ImGui::SetItemTooltip("%s", convertStringNullAsEmpty(text));
}

DEFINE_PRIM(_BOOL, begin_tooltip, _NO_ARG);
DEFINE_PRIM(_VOID, end_tooltip, _NO_ARG);
DEFINE_PRIM(_VOID, set_tooltip, _STRING);
DEFINE_PRIM(_BOOL, begin_item_tooltip, _NO_ARG);
DEFINE_PRIM(_VOID, set_item_tooltip, _STRING);
