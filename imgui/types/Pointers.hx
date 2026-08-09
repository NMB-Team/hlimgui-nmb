package imgui.types;

// General Ptr storage

/**
	Opaque native pointer to im font.
**/
typedef ImFontPtr = hl.Abstract<"imfont">;

/**
	Opaque native pointer to im font atlas.
**/
typedef ImFontAtlasPtr = hl.Abstract<"imfontatlas">;

/**
	Opaque native pointer to im texture data.
**/
typedef ImTextureDataPtr = hl.Abstract<"imtexturedata">;

/**
	Opaque native pointer to im draw list.
**/
typedef ImDrawListPtr = hl.Abstract<"imdrawlist">;

/**
	Opaque native pointer to im state storage.
**/
typedef ImStateStoragePtr = hl.Abstract<"imstatestorage">;

/**
	Opaque native pointer to im draw list shared data.
**/
typedef ImDrawListSharedDataPtr = hl.Abstract<"imdrawlistshareddata">;

/**
	Opaque native pointer to im gui multi select io.
**/
typedef ImGuiMultiSelectIOPtr = hl.Abstract<"imguimultiselectio">;

/**
	Opaque native pointer to im gui selection request.
**/
typedef ImGuiSelectionRequestPtr = hl.Abstract<"imguiselectionrequest">;

/**
	Opaque native pointer to im gui table sort specs.
**/
typedef ImGuiTableSortSpecsPtr = hl.Abstract<"imguitablesortspecs">;

/**
	Opaque native pointer to im gui table column sort specs.
**/
typedef ImGuiTableColumnSortSpecsPtr = hl.Abstract<"imguitablecolumnsortspecs">;

/**
	Opaque native pointer to im context.
**/
typedef ImContextPtr = hl.Abstract<"imcontext">;

/**
	Opaque native pointer to im drag drop payload.
**/
typedef ImDragDropPayloadPtr = hl.Abstract<"imdnd">;

// typedef ImGuiDockNode = hl.Abstract<"imguidocknode">; // Turned into a struct.
// typedef ImVector = hl.Abstract<"imvector">;

/**
	Public alias of `hl.Abstract<"finalizer">; // Used for ImGui constructs that require finalizer being called when GCd.`.
**/
typedef HLFinalizer = hl.Abstract<"finalizer">; // Used for ImGui constructs that require finalizer being called when GCd.

/**
	Public alias of `hl.Abstract<"imtabbar">`.
**/
typedef ImGuiTabBar = hl.Abstract<"imtabbar">;
