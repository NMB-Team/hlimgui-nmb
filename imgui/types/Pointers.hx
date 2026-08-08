package imgui.types;

// General Ptr storage
typedef ImFontPtr = hl.Abstract<"imfont">;
typedef ImFontAtlasPtr = hl.Abstract<"imfontatlas">;
typedef ImDrawListPtr = hl.Abstract<"imdrawlist">;
typedef ImStateStoragePtr = hl.Abstract<"imstatestorage">;
typedef ImDrawListSharedDataPtr = hl.Abstract<"imdrawlistshareddata">;
typedef ImGuiMultiSelectIOPtr = hl.Abstract<"imguimultiselectio">;
typedef ImGuiSelectionRequestPtr = hl.Abstract<"imguiselectionrequest">;
typedef ImGuiTableSortSpecsPtr = hl.Abstract<"imguitablesortspecs">;
typedef ImGuiTableColumnSortSpecsPtr = hl.Abstract<"imguitablecolumnsortspecs">;
typedef ImContextPtr = hl.Abstract<"imcontext">;
typedef ImDragDropPayloadPtr = hl.Abstract<"imdnd">;
// typedef ImGuiDockNode = hl.Abstract<"imguidocknode">; // Turned into a struct.
// typedef ImVector = hl.Abstract<"imvector">;
typedef HLFinalizer = hl.Abstract<"finalizer">; // Used for ImGui constructs that require finalizer being called when GCd.
typedef ImGuiTabBar = hl.Abstract<"imtabbar">;
