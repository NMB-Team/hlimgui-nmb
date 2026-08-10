package imgui;

import imgui.types.Renderer;
import imgui.ImGuiUtils;
import imgui.types.ImFontAtlas;
import imgui.types.Pointers;

import haxe.io.Bytes;

// Compared to hl.Ref - FieldRef allows referencing instance and static fields without local variable crutching.
// Cannasse pls add $fieldref

/**
	Mutable reference to a Haxe instance or static field.
**/
typedef Ref<T> = imgui.FieldRef<T>;

/**
	Flags controlling window.
**/
enum abstract ImGuiWindowFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None:Int = 0;

	/**
		Disable title-bar.
	**/
	var NoTitleBar:Int = 1;

	/**
		Disable user resizing with the lower-right grip.
	**/
	var NoResize:Int = 2;

	/**
		Disable user moving the window.
	**/
	var NoMove:Int = 4;

	/**
		Disable scrollbars (window can still scroll with mouse or programmatically)
	**/
	var NoScrollbar:Int = 8;

	/**
		Disable user vertically scrolling with mouse wheel. On child window, mouse wheel will be forwarded to the parent unless NoScrollbar is also set.
	**/
	var NoScrollWithMouse:Int = 16;

	/**
		Disable user collapsing window by double-clicking on it. Also referred to as Window Menu Button (e.g. within a docking node).
	**/
	var NoCollapse:Int = 32;

	/**
		Resize every window to its content every frame.
	**/
	var AlwaysAutoResize:Int = 64;

	/**
		Disable drawing background color (WindowBg, etc.) and outside border. Similar as using SetNextWindowBgAlpha(0.0f).
	**/
	var NoBackground:Int = 128;

	/**
		Never load/save settings in .ini file.
	**/
	var NoSavedSettings:Int = 256;

	/**
		Disable catching mouse, hovering test with pass through.
	**/
	var NoMouseInputs:Int = 512;

	/**
		Has a menu-bar.
	**/
	var MenuBar:Int = 1024;

	/**
		Allow horizontal scrollbar to appear (off by default). You may use SetNextWindowContentSize(ImVec2(width,0.0f)); prior to calling Begin() to specify width. Read code in imgui_demo in the "Horizontal Scrolling" section.
	**/
	var HorizontalScrollbar:Int = 2048;

	/**
		Disable taking focus when transitioning from hidden to visible state.
	**/
	var NoFocusOnAppearing:Int = 4096;

	/**
		Disable bringing window to front when taking focus (e.g. clicking on it or programmatically giving it focus)
	**/
	var NoBringToFrontOnFocus:Int = 8192;

	/**
		Always show vertical scrollbar (even if ContentSize.y < Size.y)
	**/
	var AlwaysVerticalScrollbar:Int = 16384;

	/**
		Always show horizontal scrollbar (even if ContentSize.x < Size.x)
	**/
	var AlwaysHorizontalScrollbar:Int = 32768;

	/**
		No keyboard/gamepad navigation within the window.
	**/
	var NoNavInputs:Int = 1 << 16;

	/**
		No focusing toward this window with keyboard/gamepad navigation (e.g. skipped by Ctrl+Tab)
	**/
	var NoNavFocus:Int = 1 << 17;

	/**
		Display a dot next to the title. When used in a tab/docking context, tab is selected when clicking the X + closure is not assumed (will wait for user to stop submitting the tab). Otherwise closure is assumed when pressing the X, so if you keep submitting the tab may reappear at end of tab bar.
	**/
	var UnsavedDocument:Int = 1 << 18;

	/**
		Disable docking of this window.
	**/
	var NoDocking:Int = 1 << 19;

	/**
		Disables nav.
	**/
	var NoNav:Int = NoNavInputs | NoNavFocus;

	/**
		Disables decoration.
	**/
	var NoDecoration:Int = 43;

	/**
		Disables inputs.
	**/
	var NoInputs:Int = NoMouseInputs | NoNavInputs | NoNavFocus;

	/**
		Don't use! For internal use by Begin()/NewFrame()
	**/
	@:noCompletion var DockNodeHost:Int = 1 << 23;

	/**
		Don't use! For internal use by BeginChild()
	**/
	@:noCompletion var ChildWindow:Int = 16777216;

	/**
		Don't use! For internal use by BeginTooltip()
	**/
	@:noCompletion var Tooltip:Int = 33554432;

	/**
		Don't use! For internal use by BeginPopup()
	**/
	@:noCompletion var Popup:Int = 1 << 26;

	/**
		Don't use! For internal use by BeginPopupModal()
	**/
	@:noCompletion var Modal:Int = 1 << 27;

	/**
		Don't use! For internal use by BeginMenu()
	**/
	@:noCompletion var ChildMenu:Int = 1 << 28;
}

/**
	Flags controlling child.
**/
enum abstract ImGuiChildFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None = 0;

	/**
		Show an outer border and enable WindowPadding. (IMPORTANT: this is always == 1 == true for legacy reason)
	**/
	var Borders = 1 << 0;

	/**
		Pad with style.WindowPadding even if no border are drawn (no padding by default for non-bordered child windows because it makes more sense)
	**/
	var AlwaysUseWindowPadding = 1 << 1;

	/**
		Allow resize from right border (layout direction). Enable .ini saving (unless ImGuiWindowFlags_NoSavedSettings passed to window flags)
	**/
	var ResizeX = 1 << 2;

	/**
		Allow resizing from the bottom border.
	**/
	var ResizeY = 1 << 3;

	/**
		Enable auto-resizing width. Read "IMPORTANT: Size measurement" details above.
	**/
	var AutoResizeX = 1 << 4;

	/**
		Enable auto-resizing height. Read "IMPORTANT: Size measurement" details above.
	**/
	var AutoResizeY = 1 << 5;

	/**
		Combined with AutoResizeX/AutoResizeY. Always measure size even when child is hidden, always return true, always disable clipping optimization! NOT RECOMMENDED.
	**/
	var AlwaysAutoResize = 1 << 6;

	/**
		Style the child window like a framed item: use FrameBg, FrameRounding, FrameBorderSize, FramePadding instead of ChildBg, ChildRounding, ChildBorderSize, WindowPadding.
	**/
	var FrameStyle = 1 << 7;

	/**
		[BETA] Share focus scope, allow keyboard/gamepad navigation to cross over parent border to this child or between sibling child windows.
	**/
	var NavFlattened = 1 << 8;
}

/**
	Flags controlling dock node.
**/
enum abstract ImGuiDockNodeFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None:Int = 0;

	/**
		Keeps the dockspace node alive without displaying it or undocking its windows.
	**/
	var KeepAliveOnly:Int = 1;

	/**
		Keeps the central node empty by disabling docking over it.
	**/
	var NoDockingOverCentralNode:Int = 1 << 2;

	/**
		Makes an empty central node transparent to rendering and input. The host window should usually use `setNextWindowBgAlpha(0)`.
	**/
	var PassthruCentralNode:Int = 8;

	/**
		Prevents other windows or nodes from splitting this node.
	**/
	var NoDockingSplit:Int = 16;

	/**
		Prevents resizing the node with splitters or separators.
	**/
	var NoResize:Int = 32;

	/**
		Automatically hides the tab bar when the dock node contains one window.
	**/
	var AutoHideTabBar:Int = 64;

	/**
		Prevents this node from being undocked.
	**/
	var NoUndocking:Int = 128;
}

/**
	Flags controlling tree node.
**/
enum abstract ImGuiTreeNodeFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None:Int = 0;

	/**
		Draw as selected.
	**/
	var Selected:Int = 1;

	/**
		Draw frame with background (e.g. for CollapsingHeader)
	**/
	var Framed:Int = 2;

	/**
		Hit testing will allow subsequent widgets to overlap this one. Require previous frame HoveredId to match before being usable. Shortcut to calling SetNextItemAllowOverlap().
	**/
	var AllowOverlap:Int = 4;

	/**
		Don't do a TreePush() when open (e.g. for CollapsingHeader) = no extra indent nor pushing on ID stack.
	**/
	var NoTreePushOnOpen:Int = 8;

	/**
		Don't automatically and temporarily open node when Logging is active (by default logging will automatically open tree nodes)
	**/
	var NoAutoOpenOnLog:Int = 16;

	/**
		Default node to be open.
	**/
	var DefaultOpen:Int = 32;

	/**
		Open on double-click instead of simple click (default for multi-select unless any _OpenOnXXX behavior is set explicitly). Both behaviors may be combined.
	**/
	var OpenOnDoubleClick:Int = 64;

	/**
		Open when clicking on the arrow part (default for multi-select unless any _OpenOnXXX behavior is set explicitly). Both behaviors may be combined.
	**/
	var OpenOnArrow:Int = 128;

	/**
		No collapsing, no arrow (use as a convenience for leaf nodes). Note: will always open a tree/id scope and return true. If you never use that scope, add ImGuiTreeNodeFlags_NoTreePushOnOpen.
	**/
	var Leaf:Int = 256;

	/**
		Display a bullet instead of arrow. IMPORTANT: node can still be marked open/close if you don't set the _Leaf flag!
	**/
	var Bullet:Int = 512;

	/**
		Use FramePadding (even for an unframed text node) to vertically align text baseline to regular widget height. Equivalent to calling AlignTextToFramePadding() before the node.
	**/
	var FramePadding:Int = 1024;

	/**
		Extend hit box to the right-most edge, even if not framed. This is not the default in order to allow adding other items on the same line without using AllowOverlap mode.
	**/
	var SpanAvailWidth:Int = 2048;

	/**
		Extend hit box to the left-most and right-most edges (cover the indent area).
	**/
	var SpanFullWidth:Int = 4096;

	/**
		Narrow hit box + narrow hovering highlight, will only cover the label text.
	**/
	var SpanLabelWidth:Int = 1 << 13;

	/**
		Frame will span all columns of its container table (label will still fit in current column)
	**/
	var SpanAllColumns:Int = 1 << 14;

	/**
		Label will span all columns of its container table.
	**/
	var LabelSpanAllColumns:Int = 1 << 15;

	/**
		Nav: left arrow moves back to parent. This is processed in TreePop() when there's an unfulfilled Left nav request remaining.
	**/
	var NavLeftJumpsToParent:Int = 1 << 17;

	/**
		Enables collapsing header behavior.
	**/
	var CollapsingHeader:Int = 26;

	/**
		No lines drawn.
	**/
	var DrawLinesNone:Int = 1 << 18;

	/**
		Horizontal lines to child nodes. Vertical line drawn down to TreePop() position: cover full contents. Faster (for large trees).
	**/
	var DrawLinesFull:Int = 1 << 19;

	/**
		Horizontal lines to child nodes. Vertical line drawn down to bottom-most child node. Slower (for large trees).
	**/
	var DrawLinesToNodes:Int = 1 << 20;
}

/**
	Flags controlling tab item.
**/
enum abstract ImGuiTabItemFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None:Int = 0;

	/**
		Display a dot next to the title + set ImGuiTabItemFlags_NoAssumedClosure.
	**/
	var UnsavedDocument:Int = 1;

	/**
		Trigger flag to programmatically make the tab selected when calling BeginTabItem()
	**/
	var SetSelected:Int = 2;

	/**
		Disable behavior of closing tabs (that are submitted with p_open != null) with middle mouse button. You may handle this behavior manually on user's side with if (IsItemHovered() && IsMouseClicked(2)) *p_open = false.
	**/
	var NoCloseWithMiddleMouseButton:Int = 4;

	/**
		Don't call PushID()/PopID() on BeginTabItem()/EndTabItem()
	**/
	var NoPushId:Int = 8;

	/**
		Disable tooltip for the given tab.
	**/
	var NoTooltip:Int = 1 << 4;

	/**
		Disable reordering this tab or having another tab cross over this tab.
	**/
	var NoReorder:Int = 1 << 5;

	/**
		Enforce the tab position to the left of the tab bar (after the tab list popup button)
	**/
	var Leading:Int = 1 << 6;

	/**
		Enforce the tab position to the right of the tab bar (before the scrolling buttons)
	**/
	var Trailing:Int = 1 << 7;

	/**
		Tab is selected when trying to close + closure is not immediately assumed (will wait for user to stop submitting the tab). Otherwise closure is assumed when pressing the X, so if you keep submitting the tab may reappear at end of tab bar.
	**/
	var NoAssumedClosure:Int = 1 << 8;
}

/**
	Flags controlling tab bar.
**/
enum abstract ImGuiTabBarFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None:Int = 0;

	/**
		Allow manually dragging tabs to re-order them + New tabs are appended at the end of list.
	**/
	var Reorderable:Int = 1;

	/**
		Automatically select new tabs when they appear.
	**/
	var AutoSelectNewTabs:Int = 2;

	/**
		Disable buttons to open the tab list popup.
	**/
	var TabListPopupButton:Int = 4;

	/**
		Disable behavior of closing tabs (that are submitted with p_open != null) with middle mouse button. You may handle this behavior manually on user's side with if (IsItemHovered() && IsMouseClicked(2)) *p_open = false.
	**/
	var NoCloseWithMiddleMouseButton:Int = 8;

	/**
		Disable scrolling buttons (apply when fitting policy is ImGuiTabBarFlags_FittingPolicyScroll)
	**/
	var NoTabListScrollingButtons:Int = 16;

	/**
		Disable tooltips when hovering a tab.
	**/
	var NoTooltip:Int = 32;

	/**
		Draw selected overline markers over selected tab.
	**/
	var DrawSelectedOverline:Int = 1 << 6;

	/**
		Shrink down tabs when they don't fit, until width is style.TabMinWidthShrink, then enable scrolling. Setting TabMinWidthShrink to FLT_MAX makes this behave like ImGuiTabBarFlags_FittingPolicyScroll.
	**/
	var FittingPolicyMixed:Int = 1 << 7;

	/**
		Shrink down tabs when they don't fit.
	**/
	var FittingPolicyShrink:Int = 1 << 8;

	/**
		Enable scrolling buttons when tabs don't fit.
	**/
	var FittingPolicyScroll:Int = 1 << 9;

	/**
		Enables fitting policy mask  behavior.
	**/
	var FittingPolicyMask_:Int = FittingPolicyMixed | FittingPolicyShrink | FittingPolicyScroll;

	/**
		Enables fitting policy default  behavior.
	**/
	var FittingPolicyDefault_:Int = FittingPolicyMixed;
}

/**
	Values representing style var.
**/
enum abstract ImGuiStyleVar(Int) from Int to Int {
	/**
		float: use pushStyleVar()
	**/
	var Alpha = 0;

	/**
		float: use pushStyleVar()
	**/
	var DisabledAlpha;

	/**
		ImVec2: use pushStyleVar2()
	**/
	var WindowPadding;

	/**
		float: use pushStyleVar()
	**/
	var WindowRounding;

	/**
		float: use pushStyleVar()
	**/
	var WindowBorderSize;

	/**
		ImVec2: use pushStyleVar2()
	**/
	var WindowMinSize;

	/**
		ImVec2: use pushStyleVar2()
	**/
	var WindowTitleAlign;

	/**
		float: use pushStyleVar()
	**/
	var ChildRounding;

	/**
		float: use pushStyleVar()
	**/
	var ChildBorderSize;

	/**
		float: use pushStyleVar()
	**/
	var PopupRounding;

	/**
		float: use pushStyleVar()
	**/
	var PopupBorderSize;

	/**
		ImVec2: use pushStyleVar2()
	**/
	var FramePadding;

	/**
		float: use pushStyleVar()
	**/
	var FrameRounding;

	/**
		float: use pushStyleVar()
	**/
	var FrameBorderSize;

	/**
		ImVec2: use pushStyleVar2()
	**/
	var ItemSpacing;

	/**
		ImVec2: use pushStyleVar2()
	**/
	var ItemInnerSpacing;

	/**
		float: use pushStyleVar()
	**/
	var IndentSpacing;

	/**
		ImVec2: use pushStyleVar2()
	**/
	var CellPadding;

	/**
		float: use pushStyleVar()
	**/
	var ScrollbarSize;

	/**
		float: use pushStyleVar()
	**/
	var ScrollbarRounding;

	/**
		float: use pushStyleVar()
	**/
	var ScrollbarPadding;

	/**
		float: use pushStyleVar()
	**/
	var GrabMinSize;

	/**
		float: use pushStyleVar()
	**/
	var GrabRounding;

	/**
		float: use pushStyleVar()
	**/
	var ImageRounding;

	/**
		float: use pushStyleVar()
	**/
	var ImageBorderSize;

	/**
		float: use pushStyleVar()
	**/
	var TabRounding;

	/**
		float: use pushStyleVar()
	**/
	var TabBorderSize;

	/**
		float: use pushStyleVar()
	**/
	var TabMinWidthBase;

	/**
		float: use pushStyleVar()
	**/
	var TabMinWidthShrink;

	/**
		float: use pushStyleVar()
	**/
	var TabBarBorderSize;

	/**
		float: use pushStyleVar()
	**/
	var TabBarOverlineSize;

	/**
		float: use pushStyleVar()
	**/
	var TableAngledHeadersAngle;

	/**
		ImVec2: use pushStyleVar2()
	**/
	var TableAngledHeadersTextAlign;

	/**
		float: use pushStyleVar()
	**/
	var TreeLinesSize;

	/**
		float: use pushStyleVar()
	**/
	var TreeLinesRounding;

	/**
		float: use pushStyleVar()
	**/
	var MenuItemRounding;

	/**
		float: use pushStyleVar()
	**/
	var SelectableRounding;

	/**
		float: use pushStyleVar()
	**/
	var DragDropTargetRounding;

	/**
		ImVec2: use pushStyleVar2()
	**/
	var ButtonTextAlign;

	/**
		ImVec2: use pushStyleVar2()
	**/
	var SelectableTextAlign;

	/**
		float: use pushStyleVar()
	**/
	var SeparatorSize;

	/**
		float: use pushStyleVar()
	**/
	var SeparatorTextBorderSize;

	/**
		ImVec2: use pushStyleVar2()
	**/
	var SeparatorTextAlign;

	/**
		ImVec2: use pushStyleVar2()
	**/
	var SeparatorTextPadding;

	/**
		float: use pushStyleVar()
	**/
	var DockingSeparatorSize;

	/**
		Number of values in this enumeration.
	**/
	var COUNT;
}

/**
	Flags controlling popup.
**/
enum abstract ImGuiPopupFlags(Int) from Int to Int {
	final None = 0;
	final MouseButtonLeft = 1 << 2;
	final MouseButtonRight = 2 << 2;
	final MouseButtonMiddle = 3 << 2;
	final NoReopen = 1 << 5;
	final NoOpenOverExistingPopup = 1 << 7;
	final NoOpenOverItems = 1 << 8;
	final AnyPopupId = 1 << 10;
	final AnyPopupLevel = 1 << 11;
	final AnyPopup = AnyPopupId | AnyPopupLevel;
	final MouseButtonShift_ = 2;
	final MouseButtonMask_ = 0x0C;
	final InvalidMask_ = 0x03;
}

/**
	Flags controlling selectable.
**/
enum abstract ImGuiSelectableFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None:Int = 0;

	/**
		Clicking this doesn't close parent popup window (overrides ImGuiItemFlags_AutoClosePopups)
	**/
	var NoAutoClosePopups:Int = 1;

	/**
		Frame will span all columns of its container table (text will still fit in current column)
	**/
	var SpanAllColumns:Int = 2;

	/**
		Generate press events on double clicks too.
	**/
	var AllowDoubleClick:Int = 4;

	/**
		Cannot be selected, display grayed out text.
	**/
	var Disabled:Int = 8;

	/**
		Hit testing will allow subsequent widgets to overlap this one. Require previous frame HoveredId to match before being usable. Shortcut to calling SetNextItemAllowOverlap().
	**/
	var AllowOverlap:Int = 16;

	/**
		Make the item be displayed as if it is hovered.
	**/
	var Highlight:Int = 1 << 5;

	/**
		Auto-select when moved into, unless Ctrl is held. Automatic when in a BeginMultiSelect() block.
	**/
	var SelectOnNav:Int = 1 << 6;
}

/**
	Flags controlling multi select.
**/
enum abstract ImGuiMultiSelectFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None = 0;

	/**
		Disable selecting more than one item. This is available to allow single-selection code to share same code/logic if desired. It essentially disables the main purpose of BeginMultiSelect() tho!
	**/
	var SingleSelect = 1 << 0;

	/**
		Disable Ctrl+A shortcut to select all.
	**/
	var NoSelectAll = 1 << 1;

	/**
		Disable Shift+selection mouse/keyboard support (useful for unordered 2D selection). With BoxSelect is also ensure contiguous SetRange requests are not combined into one. This allows not handling interpolation in SetRange requests.
	**/
	var NoRangeSelect = 1 << 2;

	/**
		Disable selecting items when navigating (useful for e.g. supporting range-select in a list of checkboxes).
	**/
	var NoAutoSelect = 1 << 3;

	/**
		Disable clearing selection when navigating or selecting another one (generally used with ImGuiMultiSelectFlags_NoAutoSelect. useful for e.g. supporting range-select in a list of checkboxes).
	**/
	var NoAutoClear = 1 << 4;

	/**
		Disable clearing selection when clicking/selecting an already selected item.
	**/
	var NoAutoClearOnReselect = 1 << 5;

	/**
		Enable box-selection with same width and same x pos items (e.g. full row Selectable()). Box-selection works better with little bit of spacing between items hit-box in order to be able to aim at empty space.
	**/
	var BoxSelect1d = 1 << 6;

	/**
		Enable box-selection with varying width or varying x pos items support (e.g. different width labels, or 2D layout/grid). This is slower: alters clipping logic so that e.g. horizontal movements will update selection of normally clipped items.
	**/
	var BoxSelect2d = 1 << 7;

	/**
		Disable scrolling when box-selecting and moving mouse near edges of scope.
	**/
	var BoxSelectNoScroll = 1 << 8;

	/**
		Clear selection when pressing Escape while scope is focused.
	**/
	var ClearOnEscape = 1 << 9;

	/**
		Clear selection when clicking on empty location within scope.
	**/
	var ClearOnClickVoid = 1 << 10;

	/**
		Scope for _BoxSelect and _ClearOnClickVoid is whole window (Default). Use if BeginMultiSelect() covers a whole window or used a single time in same window.
	**/
	var ScopeWindow = 1 << 11;

	/**
		Scope for _BoxSelect and _ClearOnClickVoid is rectangle encompassing BeginMultiSelect()/EndMultiSelect(). Use if BeginMultiSelect() is called multiple times in same window.
	**/
	var ScopeRect = 1 << 12;

	/**
		Apply selection on mouse down when clicking on unselected item, on mouse up when clicking on selected item. (Default)
	**/
	var SelectOnAuto = 1 << 13;

	/**
		Apply selection on mouse down when clicking on any items. Prevents Drag and Drop from being used on multiple-selection, but allows e.g. BoxSelect to always reselect even when clicking inside an existing selection. (Excel style behavior)
	**/
	var SelectOnClickAlways = 1 << 14;

	/**
		Apply selection on mouse release when clicking an unselected item. Allow dragging an unselected item without altering selection.
	**/
	var SelectOnClickRelease = 1 << 15;

	/**
		[Temporary] Enable navigation wrapping on X axis. Provided as a convenience because we don't have a design for the general Nav API for this yet. When the more general feature be public we may obsolete this flag in favor of new one.
	**/
	var NavWrapX = 1 << 16;

	/**
		Disable default right-click processing, which selects item on mouse down, and is designed for context-menus.
	**/
	var NoSelectOnRightClick = 1 << 17;
}

/**
	Values representing selection request type.
**/
enum abstract ImGuiSelectionRequestType(Int) from Int to Int {
	/**
		No options or flags.
	**/
	var None = 0;

	/**
		The `SetAll` value of `ImGuiSelectionRequestType`.
	**/
	var SetAll = 1;

	/**
		The `SetRange` value of `ImGuiSelectionRequestType`.
	**/
	var SetRange = 2;
}

/**
	Flags controlling button.
**/
enum abstract ImGuiButtonFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None:Int = 0;

	/**
		React on left mouse button (default)
	**/
	var MouseButtonLeft:Int = 1 << 0;

	/**
		React on right mouse button.
	**/
	var MouseButtonRight:Int = 1 << 1;

	/**
		React on center mouse button.
	**/
	var MouseButtonMiddle:Int = 1 << 2;

	/**
		InvisibleButton(): do not disable navigation/tabbing. Otherwise disabled by default.
	**/
	var EnableNav:Int = 1 << 3;

	/**
		Hit testing will allow subsequent widgets to overlap this one. Require previous frame HoveredId to match before being usable. Shortcut to calling SetNextItemAllowOverlap().
	**/
	var AllowOverlap:Int = 1 << 12;
}

/**
	Values representing mouse cursor.
**/
enum abstract ImGuiMouseCursor(Int) from Int to Int {
	/**
		No options or flags.
	**/
	var None:Int = -1;

	/**
		The arrow mouse cursor.
	**/
	var Arrow:Int = 0;

	/**
		The text input mouse cursor.
	**/
	var TextInput:Int = 1;

	/**
		The resize all mouse cursor.
	**/
	var ResizeAll:Int = 2;

	/**
		The resize ns mouse cursor.
	**/
	var ResizeNS:Int = 3;

	/**
		The resize ew mouse cursor.
	**/
	var ResizeEW:Int = 4;

	/**
		The resize nesw mouse cursor.
	**/
	var ResizeNESW:Int = 5;

	/**
		The resize nwse mouse cursor.
	**/
	var ResizeNWSE:Int = 6;

	/**
		The hand mouse cursor.
	**/
	var Hand:Int = 7;

	/**
		The not allowed mouse cursor.
	**/
	var NotAllowed:Int = 8;

	/**
		Number of values in this enumeration.
	**/
	var COUNT:Int = 9;
}

/**
	Values representing mouse button.
**/
enum abstract ImGuiMouseButton(Int) from Int to Int {
	/**
		The left mouse button.
	**/
	var Left:Int = 0;

	/**
		The right mouse button.
	**/
	var Right:Int = 1;

	/**
		The middle mouse button.
	**/
	var Middle:Int = 2;

	/**
		Number of values in this enumeration.
	**/
	var COUNT:Int = 5;
}

/**
	Values representing key.
**/
enum abstract ImGuiKey(Int) from Int to Int {
	/**
		No options or flags.
	**/
	var None:Int = 0;

	/**
		The `Tab` keyboard key.
	**/
	var Tab:Int = 512;

	/**
		The `LeftArrow` keyboard key.
	**/
	var LeftArrow:Int = 513;

	/**
		The `RightArrow` keyboard key.
	**/
	var RightArrow:Int = 514;

	/**
		The `UpArrow` keyboard key.
	**/
	var UpArrow:Int = 515;

	/**
		The `DownArrow` keyboard key.
	**/
	var DownArrow:Int = 516;

	/**
		The `PageUp` keyboard key.
	**/
	var PageUp:Int = 517;

	/**
		The `PageDown` keyboard key.
	**/
	var PageDown:Int = 518;

	/**
		The `Home` keyboard key.
	**/
	var Home:Int = 519;

	/**
		The `End` keyboard key.
	**/
	var End:Int = 520;

	/**
		The `Insert` keyboard key.
	**/
	var Insert:Int = 521;

	/**
		The `Delete` keyboard key.
	**/
	var Delete:Int = 522;

	/**
		The `Backspace` keyboard key.
	**/
	var Backspace:Int = 523;

	/**
		The `Space` keyboard key.
	**/
	var Space:Int = 524;

	/**
		The `Enter` keyboard key.
	**/
	var Enter:Int = 525;

	/**
		The `Escape` keyboard key.
	**/
	var Escape:Int = 526;

	/**
		The `LeftCtrl` keyboard key.
	**/
	var LeftCtrl:Int = 527;

	/**
		The `LeftShift` keyboard key.
	**/
	var LeftShift:Int = 528;

	/**
		The `LeftAlt` keyboard key.
	**/
	var LeftAlt:Int = 529;

	/**
		The `LeftSuper` keyboard key.
	**/
	var LeftSuper:Int = 530;

	/**
		The `RightCtrl` keyboard key.
	**/
	var RightCtrl:Int = 531;

	/**
		The `RightShift` keyboard key.
	**/
	var RightShift:Int = 532;

	/**
		The `RightAlt` keyboard key.
	**/
	var RightAlt:Int = 533;

	/**
		The `RightSuper` keyboard key.
	**/
	var RightSuper:Int = 534;

	/**
		The `Menu` keyboard key.
	**/
	var Menu:Int = 535;

	/**
		The `Key0` keyboard key.
	**/
	var Key0:Int = 536;

	/**
		The `Key1` keyboard key.
	**/
	var Key1:Int = 537;

	/**
		The `Key2` keyboard key.
	**/
	var Key2:Int = 538;

	/**
		The `Key3` keyboard key.
	**/
	var Key3:Int = 539;

	/**
		The `Key4` keyboard key.
	**/
	var Key4:Int = 540;

	/**
		The `Key5` keyboard key.
	**/
	var Key5:Int = 541;

	/**
		The `Key6` keyboard key.
	**/
	var Key6:Int = 542;

	/**
		The `Key7` keyboard key.
	**/
	var Key7:Int = 543;

	/**
		The `Key8` keyboard key.
	**/
	var Key8:Int = 544;

	/**
		The `Key9` keyboard key.
	**/
	var Key9:Int = 545;

	/**
		The `A` keyboard key.
	**/
	var A:Int = 546;

	/**
		The `B` keyboard key.
	**/
	var B;

	/**
		The `C` keyboard key.
	**/
	var C;

	/**
		The `D` keyboard key.
	**/
	var D;

	/**
		The `E` keyboard key.
	**/
	var E;

	/**
		The `F` keyboard key.
	**/
	var F;

	/**
		The `G` keyboard key.
	**/
	var G;

	/**
		The `H` keyboard key.
	**/
	var H;

	/**
		The `I` keyboard key.
	**/
	var I;

	/**
		The `J` keyboard key.
	**/
	var J;

	/**
		The `K` keyboard key.
	**/
	var K;

	/**
		The `L` keyboard key.
	**/
	var L;

	/**
		The `M` keyboard key.
	**/
	var M;

	/**
		The `N` keyboard key.
	**/
	var N;

	/**
		The `O` keyboard key.
	**/
	var O;

	/**
		The `P` keyboard key.
	**/
	var P;

	/**
		The `Q` keyboard key.
	**/
	var Q;

	/**
		The `R` keyboard key.
	**/
	var R;

	/**
		The `S` keyboard key.
	**/
	var S;

	/**
		The `T` keyboard key.
	**/
	var T;

	/**
		The `U` keyboard key.
	**/
	var U;

	/**
		The `V` keyboard key.
	**/
	var V;

	/**
		The `W` keyboard key.
	**/
	var W;

	/**
		Output // Packed position in Atlas.
	**/
	var X;

	/**
		The `Y` keyboard key.
	**/
	var Y;

	/**
		The `Z` keyboard key.
	**/
	var Z;

	/**
		The `F1` keyboard key.
	**/
	var F1;

	/**
		The `F2` keyboard key.
	**/
	var F2;

	/**
		The `F3` keyboard key.
	**/
	var F3;

	/**
		The `F4` keyboard key.
	**/
	var F4;

	/**
		The `F5` keyboard key.
	**/
	var F5;

	/**
		The `F6` keyboard key.
	**/
	var F6;

	/**
		The `F7` keyboard key.
	**/
	var F7;

	/**
		The `F8` keyboard key.
	**/
	var F8;

	/**
		The `F9` keyboard key.
	**/
	var F9;

	/**
		The `F10` keyboard key.
	**/
	var F10;

	/**
		The `F11` keyboard key.
	**/
	var F11;

	/**
		The `F12` keyboard key.
	**/
	var F12;

	/**
		The `F13` keyboard key.
	**/
	var F13;

	/**
		The `F14` keyboard key.
	**/
	var F14;

	/**
		The `F15` keyboard key.
	**/
	var F15;

	/**
		The `F16` keyboard key.
	**/
	var F16;

	/**
		The `F17` keyboard key.
	**/
	var F17;

	/**
		The `F18` keyboard key.
	**/
	var F18;

	/**
		The `F19` keyboard key.
	**/
	var F19;

	/**
		The `F20` keyboard key.
	**/
	var F20;

	/**
		The `F21` keyboard key.
	**/
	var F21;

	/**
		The `F22` keyboard key.
	**/
	var F22;

	/**
		The `F23` keyboard key.
	**/
	var F23;

	/**
		The `F24` keyboard key.
	**/
	var F24;

	/**
		The `Apostrophe` keyboard key.
	**/
	var Apostrophe;

	/**
		The `Comma` keyboard key.
	**/
	var Comma;

	/**
		The `Minus` keyboard key.
	**/
	var Minus;

	/**
		The `Period` keyboard key.
	**/
	var Period;

	/**
		The `Slash` keyboard key.
	**/
	var Slash;

	/**
		The `Semicolon` keyboard key.
	**/
	var Semicolon;

	/**
		The `Equal` keyboard key.
	**/
	var Equal;

	/**
		The `LeftBracket` keyboard key.
	**/
	var LeftBracket;

	/**
		The `Backslash` keyboard key.
	**/
	var Backslash;

	/**
		The `RightBracket` keyboard key.
	**/
	var RightBracket;

	/**
		The `GraveAccent` keyboard key.
	**/
	var GraveAccent;

	/**
		The `CapsLock` keyboard key.
	**/
	var CapsLock;

	/**
		The `ScrollLock` keyboard key.
	**/
	var ScrollLock;

	/**
		The `NumLock` keyboard key.
	**/
	var NumLock;

	/**
		The `PrintScreen` keyboard key.
	**/
	var PrintScreen;

	/**
		The `Pause` keyboard key.
	**/
	var Pause;

	/**
		The `Keypad0` keyboard key.
	**/
	var Keypad0;

	/**
		The `Keypad1` keyboard key.
	**/
	var Keypad1;

	/**
		The `Keypad2` keyboard key.
	**/
	var Keypad2;

	/**
		The `Keypad3` keyboard key.
	**/
	var Keypad3;

	/**
		The `Keypad4` keyboard key.
	**/
	var Keypad4;

	/**
		The `Keypad5` keyboard key.
	**/
	var Keypad5;

	/**
		The `Keypad6` keyboard key.
	**/
	var Keypad6;

	/**
		The `Keypad7` keyboard key.
	**/
	var Keypad7;

	/**
		The `Keypad8` keyboard key.
	**/
	var Keypad8;

	/**
		The `Keypad9` keyboard key.
	**/
	var Keypad9;

	/**
		The `KeypadDecimal` keyboard key.
	**/
	var KeypadDecimal;

	/**
		The `KeypadDivide` keyboard key.
	**/
	var KeypadDivide;

	/**
		The `KeypadMultiply` keyboard key.
	**/
	var KeypadMultiply;

	/**
		The `KeypadSubtract` keyboard key.
	**/
	var KeypadSubtract;

	/**
		The `KeypadAdd` keyboard key.
	**/
	var KeypadAdd;

	/**
		The `KeypadEnter` keyboard key.
	**/
	var KeypadEnter;

	/**
		The `KeypadEqual` keyboard key.
	**/
	var KeypadEqual;

	/**
		The `AppBack` keyboard key.
	**/
	var AppBack;

	/**
		The `AppForward` keyboard key.
	**/
	var AppForward;

	/**
		The `Oem102` keyboard key.
	**/
	var Oem102;

	/**
		The `GamepadStart` keyboard key.
	**/
	var GamepadStart;

	/**
		The `GamepadBack` keyboard key.
	**/
	var GamepadBack;

	/**
		The `GamepadFaceLeft` keyboard key.
	**/
	var GamepadFaceLeft;

	/**
		The `GamepadFaceRight` keyboard key.
	**/
	var GamepadFaceRight;

	/**
		The `GamepadFaceUp` keyboard key.
	**/
	var GamepadFaceUp;

	/**
		The `GamepadFaceDown` keyboard key.
	**/
	var GamepadFaceDown;

	/**
		The `GamepadDpadLeft` keyboard key.
	**/
	var GamepadDpadLeft;

	/**
		The `GamepadDpadRight` keyboard key.
	**/
	var GamepadDpadRight;

	/**
		The `GamepadDpadUp` keyboard key.
	**/
	var GamepadDpadUp;

	/**
		The `GamepadDpadDown` keyboard key.
	**/
	var GamepadDpadDown;

	/**
		The `GamepadL1` keyboard key.
	**/
	var GamepadL1;

	/**
		The `GamepadR1` keyboard key.
	**/
	var GamepadR1;

	/**
		The `GamepadL2` keyboard key.
	**/
	var GamepadL2;

	/**
		The `GamepadR2` keyboard key.
	**/
	var GamepadR2;

	/**
		The `GamepadL3` keyboard key.
	**/
	var GamepadL3;

	/**
		The `GamepadR3` keyboard key.
	**/
	var GamepadR3;

	/**
		The `GamepadLStickLeft` keyboard key.
	**/
	var GamepadLStickLeft;

	/**
		The `GamepadLStickRight` keyboard key.
	**/
	var GamepadLStickRight;

	/**
		The `GamepadLStickUp` keyboard key.
	**/
	var GamepadLStickUp;

	/**
		The `GamepadLStickDown` keyboard key.
	**/
	var GamepadLStickDown;

	/**
		The `GamepadRStickLeft` keyboard key.
	**/
	var GamepadRStickLeft;

	/**
		The `GamepadRStickRight` keyboard key.
	**/
	var GamepadRStickRight;

	/**
		The `GamepadRStickUp` keyboard key.
	**/
	var GamepadRStickUp;

	/**
		The `GamepadRStickDown` keyboard key.
	**/
	var GamepadRStickDown;

	/**
		The `MouseLeft` keyboard key.
	**/
	var MouseLeft;

	/**
		The `MouseRight` keyboard key.
	**/
	var MouseRight;

	/**
		The `MouseMiddle` keyboard key.
	**/
	var MouseMiddle;

	/**
		The `MouseX1` keyboard key.
	**/
	var MouseX1;

	/**
		The `MouseX2` keyboard key.
	**/
	var MouseX2;

	/**
		The `MouseWheelX` keyboard key.
	**/
	var MouseWheelX;

	/**
		The `MouseWheelY` keyboard key.
	**/
	var MouseWheelY;

	// Compatibility aliases. Prefer ImGuiMod for shortcut chords.

	/**
		The `ModCtrl` keyboard key.
	**/
	var ModCtrl:Int = 1 << 12;

	/**
		The `ModShift` keyboard key.
	**/
	var ModShift:Int = 1 << 13;

	/**
		The `ModAlt` keyboard key.
	**/
	var ModAlt:Int = 1 << 14;

	/**
		The `ModSuper` keyboard key.
	**/
	var ModSuper:Int = 1 << 15;
}

/**
	Values representing mod.
**/
enum abstract ImGuiMod(Int) from Int to Int {
	/**
		No options or flags.
	**/
	var None = 0;

	/**
		The `Ctrl` value of `ImGuiMod`.
	**/
	var Ctrl = 1 << 12;

	/**
		The `Shift` value of `ImGuiMod`.
	**/
	var Shift = 1 << 13;

	/**
		The `Alt` value of `ImGuiMod`.
	**/
	var Alt = 1 << 14;

	/**
		The `Super` value of `ImGuiMod`.
	**/
	var Super = 1 << 15;
}

/**
	Haxe representation of key string extender.
**/
class ImGuiKeyStringExtender {
	/**
		Converts a key name to its `ImGuiKey` value.
	**/
	public static inline function imKey(s:String):Int {
		var v = 546 + (s.charCodeAt(0) - "A".code);
		return v;
	}
}

/**
	Flags controlling input text.
**/
enum abstract ImGuiInputTextFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None:Int = 0;

	/**
		Allow 0123456789.+-* /.
	**/
	var CharsDecimal:Int = 1 << 0;

	/**
		Allow 0123456789ABCDEFabcdef.
	**/
	var CharsHexadecimal:Int = 1 << 1;

	/**
		Allow 0123456789.+-* /eE (Scientific notation input)
	**/
	var CharsScientific:Int = 1 << 2;

	/**
		Turn a..z into A..Z.
	**/
	var CharsUppercase:Int = 1 << 3;

	/**
		Filter out spaces, tabs.
	**/
	var CharsNoBlank:Int = 1 << 4;

	/**
		Pressing TAB input a '\t' character into the text field.
	**/
	var AllowTabInput:Int = 1 << 5;

	/**
		Return 'true' when Enter is pressed (as opposed to every time the value was modified). Consider disabling LiveEdit! or using IsItemDeactivatedAfterEdit() instead!
	**/
	var EnterReturnsTrue:Int = 1 << 6;

	/**
		Escape key clears content if not empty, and deactivate otherwise (contrast to default behavior of Escape to revert)
	**/
	var EscapeClearsAll:Int = 1 << 7;

	/**
		In multi-line mode: validate with Enter, add new line with Ctrl+Enter (default is opposite: validate with Ctrl+Enter, add line with Enter). Note that Shift+Enter always enter a new line either way.
	**/
	var CtrlEnterForNewLine:Int = 1 << 8;

	/**
		Read-only mode.
	**/
	var ReadOnly:Int = 1 << 9;

	/**
		Password mode, display all characters as '*', disable copy.
	**/
	var Password:Int = 1 << 10;

	/**
		Overwrite mode.
	**/
	var AlwaysOverwrite:Int = 1 << 11;

	/**
		Select entire text when first taking mouse focus.
	**/
	var AutoSelectAll:Int = 1 << 12;

	/**
		InputFloat(), InputInt(), InputScalar() etc. only: parse empty string as zero value.
	**/
	var ParseEmptyRefVal:Int = 1 << 13;

	/**
		InputFloat(), InputInt(), InputScalar() etc. only: when value is zero, do not display it. Generally used with ImGuiInputTextFlags_ParseEmptyRefVal.
	**/
	var DisplayEmptyRefVal:Int = 1 << 14;

	/**
		Disable following the cursor horizontally.
	**/
	var NoHorizontalScroll:Int = 1 << 15;

	/**
		Disable undo/redo. Note that input text owns the text data while active, if you want to provide your own undo/redo stack you need e.g. to call ClearActiveID().
	**/
	var NoUndoRedo:Int = 1 << 16;

	/**
		When text doesn't fit, elide left side to ensure right side stays visible. Useful for path/filenames. Single-line only!
	**/
	var ElideLeft:Int = 1 << 17;

	/**
		Callback on pressing TAB (for completion handling)
	**/
	var CallbackCompletion:Int = 1 << 18;

	/**
		Callback on pressing Up/Down arrows (for history handling)
	**/
	var CallbackHistory:Int = 1 << 19;

	/**
		Callback on each iteration. User code may query cursor position, modify text buffer.
	**/
	var CallbackAlways:Int = 1 << 20;

	/**
		Callback on character inputs to replace or discard them. Modify 'EventChar' to replace or discard, or return 1 in callback to discard.
	**/
	var CallbackCharFilter:Int = 1 << 21;

	/**
		Callback on buffer capacity changes request (beyond 'buf_size' parameter value), allowing the string to grow. Notify when the string wants to be resized (for string types which hold a cache of their Size). You will be provided a new BufSize in the callback and NEED to honor it. (see misc/cpp/imgui_stdlib.h for an example of using this)
	**/
	var CallbackResize:Int = 1 << 22;

	/**
		Callback on any edit. Note that InputText() already returns true on edit + you can always use IsItemEdited(). The callback is useful to manipulate the underlying buffer while focus is active.
	**/
	var CallbackEdit:Int = 1 << 23;

	/**
		InputTextMultiline(): word-wrap lines that are too long.
	**/
	var WordWrap:Int = 1 << 24;
}

/**
	Flags controlling hovered.
**/
enum abstract ImGuiHoveredFlags(Int) from Int to Int {
	/**
		Return true if directly over the item/window, not obstructed by another window, not obstructed by an active popup or modal blocking inputs under them.
	**/
	var None = 0; // Return true if directly over the item/window; not obstructed by another window; not obstructed by an active popup or modal blocking inputs under them.

	/**
		IsWindowHovered() only: Return true if any children of the window is hovered.
	**/
	var ChildWindows = 1 << 0; // IsWindowHovered() only: Return true if any children of the window is hovered

	/**
		IsWindowHovered() only: Test from root window (top most parent of the current hierarchy)
	**/
	var RootWindow = 1 << 1; // IsWindowHovered() only: Test from root window (top most parent of the current hierarchy)

	/**
		IsWindowHovered() only: Return true if any window is hovered.
	**/
	var AnyWindow = 1 << 2; // IsWindowHovered() only: Return true if any window is hovered

	/**
		IsWindowHovered() only: Do not consider popup hierarchy (do not treat popup emitter as parent of popup) (when used with _ChildWindows or _RootWindow)
	**/
	var NoPopupHierarchy = 1 << 3; // IsWindowHovered() only: Do not consider popup hierarchy (do not treat popup emitter as parent of popup) (when used with _ChildWindows or _RootWindow)

	/**
		IsWindowHovered() only: Consider docking hierarchy (treat dockspace host as parent of docked window) (when used with _ChildWindows or _RootWindow)
	**/
	var DockHierarchy = 1 << 4; // IsWindowHovered() only: Consider docking hierarchy (treat dockspace host as parent of docked window) (when used with _ChildWindows or _RootWindow)

	/**
		Return true even if a popup window is normally blocking access to this item/window.
	**/
	var AllowWhenBlockedByPopup = 1 << 5; // Return true even if a popup window is normally blocking access to this item/window

	/**
		Return true even if an active item is blocking access to this item/window. Useful for Drag and Drop patterns.
	**/
	var AllowWhenBlockedByActiveItem = 1 << 7; // Return true even if an active item is blocking access to this item/window. Useful for Drag and Drop patterns.

	/**
		IsItemHovered() only: Return true even if the item uses AllowOverlap mode and is overlapped by another hoverable item.
	**/
	var AllowWhenOverlappedByItem = 1 << 8;

	/**
		IsItemHovered() only: Return true even if the position is obstructed or overlapped by another window.
	**/
	var AllowWhenOverlappedByWindow = 1 << 9;

	/**
		IsItemHovered() only: Return true even if the item is disabled.
	**/
	var AllowWhenDisabled = 1 << 10;

	/**
		IsItemHovered() only: Disable using keyboard/gamepad navigation state when active, always query mouse.
	**/
	var NoNavOverride = 1 << 11;

	/**
		Enables allow when overlapped behavior.
	**/
	var AllowWhenOverlapped = AllowWhenOverlappedByItem | AllowWhenOverlappedByWindow;

	/**
		Enables rect only behavior.
	**/
	var RectOnly = AllowWhenBlockedByPopup | AllowWhenBlockedByActiveItem | AllowWhenOverlapped;

	/**
		Enables root and child windows behavior.
	**/
	var RootAndChildWindows = RootWindow | ChildWindows;

	/**
		Shortcut for standard flags when using IsItemHovered() + SetTooltip() sequence.
	**/
	var ForTooltip = 1 << 12;

	/**
		Require mouse to be stationary for style.HoverStationaryDelay (~0.15 sec) _at least one time_. After this, can move on same item/window. Using the stationary test tends to reduces the need for a long delay.
	**/
	var Stationary = 1 << 13;

	/**
		IsItemHovered() only: Return true immediately (default). As this is the default you generally ignore this.
	**/
	var DelayNone = 1 << 14;

	/**
		IsItemHovered() only: Return true after style.HoverDelayShort elapsed (~0.15 sec) (shared between items) + requires mouse to be stationary for style.HoverStationaryDelay (once per item).
	**/
	var DelayShort = 1 << 15;

	/**
		IsItemHovered() only: Return true after style.HoverDelayNormal elapsed (~0.40 sec) (shared between items) + requires mouse to be stationary for style.HoverStationaryDelay (once per item).
	**/
	var DelayNormal = 1 << 16;

	/**
		IsItemHovered() only: Disable shared delay system where moving from one item to the next keeps the previous timer for a short time (standard for tooltips with long delays)
	**/
	var NoSharedDelay = 1 << 17;
}

/**
	Flags controlling focused.
**/
enum abstract ImGuiFocusedFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None:Int = 0;

	/**
		Return true if any children of the window is focused.
	**/
	var ChildWindows:Int = 1;

	/**
		Test from root window (top most parent of the current hierarchy)
	**/
	var RootWindow:Int = 2;

	/**
		Return true if any window is focused. Important: If you are trying to tell how to dispatch your low-level inputs, do NOT use this. Use 'io.WantCaptureMouse' instead! Please read the FAQ!
	**/
	var AnyWindow:Int = 4;

	/**
		Do not consider popup hierarchy (do not treat popup emitter as parent of popup) (when used with _ChildWindows or _RootWindow)
	**/
	var NoPopupHierarchy:Int = 1 << 3;

	/**
		Consider docking hierarchy (treat dockspace host as parent of docked window) (when used with _ChildWindows or _RootWindow)
	**/
	var DockHierarchy:Int = 1 << 4;

	/**
		Enables root and child windows behavior.
	**/
	var RootAndChildWindows:Int = 3;
}

/**
	Flags controlling drag drop.
**/
enum abstract ImGuiDragDropFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None:Int = 0;

	/**
		Disable preview tooltip. By default, a successful call to BeginDragDropSource opens a tooltip so you can display a preview or description of the source contents. This flag disables this behavior.
	**/
	var SourceNoPreviewTooltip:Int = 1;

	/**
		By default, when dragging we clear data so that IsItemHovered() will return false, to avoid subsequent user code submitting tooltips. This flag disables this behavior so you can still call IsItemHovered() on the source item.
	**/
	var SourceNoDisableHover:Int = 2;

	/**
		Disable the behavior that allows to open tree nodes and collapsing header by holding over them while dragging a source item.
	**/
	var SourceNoHoldToOpenOthers:Int = 4;

	/**
		Allow items such as Text(), Image() that have no unique identifier to be used as drag source, by manufacturing a temporary identifier based on their window-relative position. This is extremely unusual within the dear imgui ecosystem and so we made it explicit.
	**/
	var SourceAllowNullID:Int = 8;

	/**
		External source (from outside of dear imgui), won't attempt to read current item/window info. Will always return true. Only one Extern source can be active simultaneously.
	**/
	var SourceExtern:Int = 16;

	/**
		Automatically expire the payload if the source cease to be submitted (otherwise payloads are persisting while being dragged)
	**/
	var PayloadAutoExpire:Int = 1 << 5;

	/**
		Hint to specify that the payload may not be copied outside current dear imgui context.
	**/
	var PayloadNoCrossContext:Int = 1 << 6;

	/**
		Hint to specify that the payload may not be copied outside current process.
	**/
	var PayloadNoCrossProcess:Int = 1 << 7;

	/**
		AcceptDragDropPayload() will returns true even before the mouse button is released. You can then call IsDelivery() to test if the payload needs to be delivered.
	**/
	var AcceptBeforeDelivery:Int = 1024;

	/**
		Do not draw the default highlight rectangle when hovering over target.
	**/
	var AcceptNoDrawDefaultRect:Int = 2048;

	/**
		Request hiding the BeginDragDropSource tooltip from the BeginDragDropTarget site.
	**/
	var AcceptNoPreviewTooltip:Int = 4096;

	/**
		Accepting item will render as if hovered. Useful for e.g. a Button() used as a drop target.
	**/
	var AcceptDrawAsHovered:Int = 1 << 13;

	/**
		For peeking ahead and inspecting the payload before delivery.
	**/
	var AcceptPeekOnly:Int = 3072;
}

/**
	Values representing dir.
**/
enum abstract ImGuiDir(Int) from Int to Int {
	/**
		No options or flags.
	**/
	var None:Int = -1;

	/**
		The left direction.
	**/
	var Left:Int = 0;

	/**
		The right direction.
	**/
	var Right:Int = 1;

	/**
		The up direction.
	**/
	var Up:Int = 2;

	/**
		True for if key is down.
	**/
	var Down:Int = 3;

	/**
		Number of values in this enumeration.
	**/
	var COUNT:Int = 4;
}

/**
	Values representing sort direction.
**/
enum abstract ImGuiSortDirection(Int) from Int to Int {
	/**
		No options or flags.
	**/
	var None = 0;

	/**
		The ascending direction.
	**/
	var Ascending = 1;

	/**
		The descending direction.
	**/
	var Descending = 2;
}

/**
	Values representing data type.
**/
enum abstract ImGuiDataType(Int) from Int to Int {
	/**
		The `S8` value of `ImGuiDataType`.
	**/
	var S8:Int = 0;

	/**
		The `U8` value of `ImGuiDataType`.
	**/
	var U8:Int = 1;

	/**
		The `S16` value of `ImGuiDataType`.
	**/
	var S16:Int = 2;

	/**
		The `U16` value of `ImGuiDataType`.
	**/
	var U16:Int = 3;

	/**
		The `S32` value of `ImGuiDataType`.
	**/
	var S32:Int = 4;

	/**
		The `U32` value of `ImGuiDataType`.
	**/
	var U32:Int = 5;

	/**
		The `S64` value of `ImGuiDataType`.
	**/
	var S64:Int = 6;

	/**
		The `U64` value of `ImGuiDataType`.
	**/
	var U64:Int = 7;

	/**
		The `Float` value of `ImGuiDataType`.
	**/
	var Float:Int = 8;

	/**
		The `Double` value of `ImGuiDataType`.
	**/
	var Double:Int = 9;

	/**
		Number of values in this enumeration.
	**/
	var COUNT:Int = 10;
}

/**
	Scalar value accepted by generic numeric widgets.
**/
abstract ImGuiScalar(Dynamic) from Int from hl.UI8 from hl.UI16 from Single from Float from hl.I64 {}

/**
	Flags controlling config.
**/
enum abstract ImGuiConfigFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None = 0;

	/**
		Master keyboard navigation enable flag. Enable full Tabbing + directional arrows + Space/Enter to activate. Note: some features such as basic Tabbing and CtrL+Tab are enabled by regardless of this flag (and may be disabled via other means, see #4828, #9218).
	**/
	var NavEnableKeyboard = 1 << 0; // Master keyboard navigation enable flag. NewFrame() will automatically fill io.NavInputs[] based on io.AddKeyEvent() calls

	/**
		Master gamepad navigation enable flag. Backend also needs to set ImGuiBackendFlags_HasGamepad.
	**/
	var NavEnableGamepad = 1 << 1; // Master gamepad navigation enable flag. This is mostly to instruct your imgui backend to fill io.NavInputs[]. Backend also needs to set ImGuiBackendFlags_HasGamepad.

	/**
		Instruct dear imgui to disable mouse inputs and interactions.
	**/
	var NoMouse = 1 << 4; // Instruct imgui to clear mouse position/buttons in NewFrame(). This allows ignoring the mouse information set by the backend.

	/**
		Instruct backend to not alter mouse cursor shape and visibility. Use if the backend cursor changes are interfering with yours and you don't want to use SetMouseCursor() to change mouse cursor. You may want to honor requests from imgui by reading GetMouseCursor() yourself instead.
	**/
	var NoMouseCursorChange = 1 << 5; // Instruct backend to not alter mouse cursor shape and visibility. Use if the backend cursor changes are interfering with yours and you don't want to use SetMouseCursor() to change mouse cursor. You may want to honor requests from imgui by reading GetMouseCursor() yourself instead.

	/**
		Instruct dear imgui to disable keyboard inputs and interactions. This is done by ignoring keyboard events and clearing existing states.
	**/
	var NoKeyboard = 1 << 6; // Instruct imgui to disable keyboard inputs and interactions.

	// [BETA] Docking

	/**
		Docking enable flags.
	**/
	var DockingEnable = 1 << 7; // Docking enable flags.

	// [BETA] Viewports
	// When using viewports it is recommended that your default value for ImGuiCol_WindowBg is opaque (Alpha=1.0) so transition to a viewport won't be noticeable.

	/**
		Viewport enable flags (require both ImGuiBackendFlags_PlatformHasViewports + ImGuiBackendFlags_RendererHasViewports set by the respective backends)
	**/
	var ViewportsEnable = 1 << 10; // Viewport enable flags (require both ImGuiBackendFlags_PlatformHasViewports + ImGuiBackendFlags_RendererHasViewports set by the respective backends)

	// User storage (to allow your backend/engine to communicate to code that may be shared between multiple projects. Those flags are not used by core Dear ImGui)

	/**
		Application is SRGB-aware.
	**/
	var IsSRGB = 1 << 20; // Application is SRGB-aware.

	/**
		Application is using a touch screen instead of a mouse.
	**/
	var IsTouchScreen = 1 << 21; // Application is using a touch screen instead of a mouse.

}

/**
	Values representing cond.
**/
enum abstract ImGuiCond(Int) from Int to Int {
	/**
		The `Always` value of `ImGuiCond`.
	**/
	var Always:Int = 1;

	/**
		The `Once` value of `ImGuiCond`.
	**/
	var Once:Int = 2;

	/**
		The `FirstUseEver` value of `ImGuiCond`.
	**/
	var FirstUseEver:Int = 4;

	/**
		Set during the frame where the window is appearing (or re-appearing)
	**/
	var Appearing:Int = 8;
}

/**
	Flags controlling combo.
**/
enum abstract ImGuiComboFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None:Int = 0;

	/**
		Align the popup toward the left by default.
	**/
	var PopupAlignLeft:Int = 1;

	/**
		Max ~4 items visible. Tip: If you want your combo popup to be a specific size you can use SetNextWindowSizeConstraints() prior to calling BeginCombo()
	**/
	var HeightSmall:Int = 2;

	/**
		Max ~8 items visible (default)
	**/
	var HeightRegular:Int = 4;

	/**
		Max ~20 items visible.
	**/
	var HeightLarge:Int = 8;

	/**
		As many fitting items as possible.
	**/
	var HeightLargest:Int = 16;

	/**
		Display on the preview box without the square arrow button.
	**/
	var NoArrowButton:Int = 32;

	/**
		Display only a square arrow button.
	**/
	var NoPreview:Int = 64;

	/**
		Width dynamically calculated from preview contents.
	**/
	var WidthFitPreview:Int = 1 << 7;

	/**
		Enables height mask  behavior.
	**/
	var HeightMask_:Int = 30;
}

/**
	Flags controlling color edit.
**/
enum abstract ImGuiColorEditFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None:Int = 0;

	/**
		Ignores the alpha component in color editors, pickers, and buttons.
	**/
	var NoAlpha:Int = 1 << 1;

	/**
		Prevents opening the picker by clicking the color preview.
	**/
	var NoPicker:Int = 1 << 2;

	/**
		Disables the color editor's right-click options menu.
	**/
	var NoOptions:Int = 1 << 3;

	/**
		Hides the color preview next to editor and picker inputs.
	**/
	var NoSmallPreview:Int = 1 << 4;

	/**
		Hides slider and text inputs in color editors and pickers.
	**/
	var NoInputs:Int = 1 << 5;

	/**
		Disables the tooltip shown when hovering a color preview.
	**/
	var NoTooltip:Int = 1 << 6;

	/**
		Hides the inline label while retaining it for the tooltip and picker.
	**/
	var NoLabel:Int = 1 << 7;

	/**
		Uses the small color preview instead of the large picker-side preview.
	**/
	var NoSidePreview:Int = 1 << 8;

	/**
		Disables color drag-and-drop targets and sources.
	**/
	var NoDragDrop:Int = 1 << 9;

	/**
		Disables the default color-button border.
	**/
	var NoBorder:Int = 1 << 10;

	/**
		Hides the RGBA marker in color editors.
	**/
	var NoColorMarkers:Int = 1 << 11;

	/**
		Hides alpha in the preview while still allowing alpha editing in four-component editors and pickers.
	**/
	var AlphaOpaque:Int = 1 << 12;

	/**
		Disables the checkerboard background behind transparent colors.
	**/
	var AlphaNoBg:Int = 1 << 13;

	/**
		Displays a half-opaque, half-transparent color preview.
	**/
	var AlphaPreviewHalf:Int = 1 << 14;

	/**
		Shows the vertical alpha gradient in color editors and pickers.
	**/
	var AlphaBar:Int = 1 << 18;

	/**
		Removes the 0-to-1 limits from RGBA editing; usually combine with `Float`.
	**/
	var HDR:Int = 1 << 19;

	/**
		[Display] // ColorEdit: override _display_ type among RGB/HSV/Hex. ColorPicker: select any combination using one or more of RGB/HSV/Hex.
	**/
	var DisplayRGB:Int = 1 << 20;

	/**
		[Display] // ".
	**/
	var DisplayHSV:Int = 1 << 21;

	/**
		[Display] // ".
	**/
	var DisplayHex:Int = 1 << 22;

	/**
		[DataType] // ColorEdit, ColorPicker, ColorButton: _display_ values formatted as 0..255.
	**/
	var Uint8:Int = 1 << 23;

	/**
		[DataType] // ColorEdit, ColorPicker, ColorButton: _display_ values formatted as 0.0f..1.0f floats instead of 0..255 integers. No round-trip of value via integers.
	**/
	var Float:Int = 1 << 24;

	/**
		[Picker] // ColorPicker: bar for Hue, rectangle for Sat/Value.
	**/
	var PickerHueBar:Int = 1 << 25;

	/**
		[Picker] // ColorPicker: wheel for Hue, triangle for Sat/Value.
	**/
	var PickerHueWheel:Int = 1 << 26;

	/**
		[Picker] // ColorPicker: disable rotating Sat/Value triangle. Best set in io.ConfigColorEditFlags once.
	**/
	var PickerNoRotate:Int = 1 << 27;

	/**
		[Input] // ColorEdit, ColorPicker: input and output data in RGB format.
	**/
	var InputRGB:Int = 1 << 28;

	/**
		[Input] // ColorEdit, ColorPicker: input and output data in HSV format.
	**/
	var InputHSV:Int = 1 << 29;

	/**
		Enables  default options behavior.
	**/
	var _DefaultOptions:Int = Uint8 | DisplayRGB | InputRGB | PickerHueBar;

	/**
		Enables  alpha mask behavior.
	**/
	var _AlphaMask:Int = NoAlpha | AlphaOpaque | AlphaNoBg | AlphaPreviewHalf;

	/**
		Enables  display mask behavior.
	**/
	var _DisplayMask:Int = DisplayRGB | DisplayHSV | DisplayHex;

	/**
		Enables  data type mask behavior.
	**/
	var _DataTypeMask:Int = Uint8 | Float;

	/**
		Enables  picker mask behavior.
	**/
	var _PickerMask:Int = PickerHueWheel | PickerHueBar;

	/**
		Enables  input mask behavior.
	**/
	var _InputMask:Int = InputRGB | InputHSV;
}

/**
	Values representing col.
**/
enum abstract ImGuiCol(Int) from Int to Int {
	/**
		If Type == ImGuiInputEventType_Text.
	**/
	var Text = 0;

	/**
		The text disabled style color.
	**/
	var TextDisabled;

	/**
		The window background style color.
	**/
	var WindowBg;

	/**
		The child background style color.
	**/
	var ChildBg;

	/**
		The popup background style color.
	**/
	var PopupBg;

	/**
		The border style color.
	**/
	var Border;

	/**
		The border shadow style color.
	**/
	var BorderShadow;

	/**
		The frame background style color.
	**/
	var FrameBg;

	/**
		The frame background hovered style color.
	**/
	var FrameBgHovered;

	/**
		The frame background active style color.
	**/
	var FrameBgActive;

	/**
		The title background style color.
	**/
	var TitleBg;

	/**
		The title background active style color.
	**/
	var TitleBgActive;

	/**
		The title background collapsed style color.
	**/
	var TitleBgCollapsed;

	/**
		The menu bar background style color.
	**/
	var MenuBarBg;

	/**
		The scrollbar background style color.
	**/
	var ScrollbarBg;

	/**
		The scrollbar grab style color.
	**/
	var ScrollbarGrab;

	/**
		The scrollbar grab hovered style color.
	**/
	var ScrollbarGrabHovered;

	/**
		The scrollbar grab active style color.
	**/
	var ScrollbarGrabActive;

	/**
		The check mark style color.
	**/
	var CheckMark;

	/**
		The checkbox selected background style color.
	**/
	var CheckboxSelectedBg;

	/**
		The slider grab style color.
	**/
	var SliderGrab;

	/**
		The slider grab active style color.
	**/
	var SliderGrabActive;

	/**
		The button style color.
	**/
	var Button;

	/**
		The button hovered style color.
	**/
	var ButtonHovered;

	/**
		The button active style color.
	**/
	var ButtonActive;

	/**
		The header style color.
	**/
	var Header;

	/**
		The header hovered style color.
	**/
	var HeaderHovered;

	/**
		The header active style color.
	**/
	var HeaderActive;

	/**
		The separator style color.
	**/
	var Separator;

	/**
		The separator hovered style color.
	**/
	var SeparatorHovered;

	/**
		The separator active style color.
	**/
	var SeparatorActive;

	/**
		The resize grip style color.
	**/
	var ResizeGrip;

	/**
		The resize grip hovered style color.
	**/
	var ResizeGripHovered;

	/**
		The resize grip active style color.
	**/
	var ResizeGripActive;

	/**
		The input text cursor style color.
	**/
	var InputTextCursor;

	/**
		The tab hovered style color.
	**/
	var TabHovered;

	/**
		The tab style color.
	**/
	var Tab;

	/**
		The tab selected style color.
	**/
	var TabSelected;

	/**
		The tab selected overline style color.
	**/
	var TabSelectedOverline;

	/**
		The tab dimmed style color.
	**/
	var TabDimmed;

	/**
		The tab dimmed selected style color.
	**/
	var TabDimmedSelected;

	/**
		The tab dimmed selected overline style color.
	**/
	var TabDimmedSelectedOverline;

	/**
		The docking preview style color.
	**/
	var DockingPreview;

	/**
		The docking empty background style color.
	**/
	var DockingEmptyBg;

	/**
		The plot lines style color.
	**/
	var PlotLines;

	/**
		The plot lines hovered style color.
	**/
	var PlotLinesHovered;

	/**
		The plot histogram style color.
	**/
	var PlotHistogram;

	/**
		The plot histogram hovered style color.
	**/
	var PlotHistogramHovered;

	/**
		The table header background style color.
	**/
	var TableHeaderBg;

	/**
		The table border strong style color.
	**/
	var TableBorderStrong;

	/**
		The table border light style color.
	**/
	var TableBorderLight;

	/**
		The table row background style color.
	**/
	var TableRowBg;

	/**
		The table row background alt style color.
	**/
	var TableRowBgAlt;

	/**
		The text link style color.
	**/
	var TextLink;

	/**
		The text selected background style color.
	**/
	var TextSelectedBg;

	/**
		The tree lines style color.
	**/
	var TreeLines;

	/**
		The drag drop target style color.
	**/
	var DragDropTarget;

	/**
		The drag drop target background style color.
	**/
	var DragDropTargetBg;

	/**
		The unsaved marker style color.
	**/
	var UnsavedMarker;

	/**
		The nav cursor style color.
	**/
	var NavCursor;

	/**
		The nav windowing highlight style color.
	**/
	var NavWindowingHighlight;

	/**
		The nav windowing dim background style color.
	**/
	var NavWindowingDimBg;

	/**
		The modal window dim background style color.
	**/
	var ModalWindowDimBg;

	/**
		Number of values in this enumeration.
	**/
	var COUNT;
}

/**
	Flags controlling backend.
**/
enum abstract ImGuiBackendFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None:Int = 0;

	/**
		Backend Platform supports gamepad and currently has one connected.
	**/
	var HasGamepad:Int = 1;

	/**
		Backend Platform supports honoring GetMouseCursor() value to change the OS cursor shape.
	**/
	var HasMouseCursors:Int = 2;

	/**
		Backend Platform supports io.WantSetMousePos requests to reposition the OS mouse position (only used if io.ConfigNavMoveSetMousePos is set).
	**/
	var HasSetMousePos:Int = 4;

	/**
		Backend Renderer supports ImDrawCmd::VtxOffset. This enables output of large meshes (64K+ vertices) while still using 16-bit indices.
	**/
	var RendererHasVtxOffset:Int = 8;

	/**
		Backend Renderer supports ImTextureData requests to create/update/destroy textures. This enables incremental texture updates and texture reloads. See https://github.com/ocornut/imgui/blob/master/docs/BACKENDS.md for instructions on how to upgrade your custom backend.
	**/
	var RendererHasTextures:Int = 1 << 4;

	/**
		Backend Renderer supports multiple viewports.
	**/
	var RendererHasViewports:Int = 1 << 10;

	/**
		Backend Platform supports multiple viewports.
	**/
	var PlatformHasViewports:Int = 1 << 11;

	/**
		Backend Platform supports calling io.AddMouseViewportEvent() with the viewport under the mouse. IF POSSIBLE, ignore viewports with the ImGuiViewportFlags_NoInputs flag (Win32 backend, GLFW 3.30+ backend can do this, SDL backend cannot). If this cannot be done, Dear ImGui needs to use a flawed heuristic to find the viewport under.
	**/
	var HasMouseHoveredViewport:Int = 1 << 12;

	/**
		Backend Platform supports honoring viewport->ParentViewport/ParentViewportId value, by applying the corresponding parent/child relationship at the Platform level. Child windows always appear in front of their parent window.
	**/
	var HasParentViewport:Int = 1 << 13;
}

/**
	Flags controlling font atlas.
**/
enum abstract ImFontAtlasFlags(Int) from Int to Int {
	/**
		No options or flags.
	**/
	var None:Int = 0;

	/**
		Disables power of two height.
	**/
	var NoPowerOfTwoHeight:Int = 1;

	/**
		Disables mouse cursors.
	**/
	var NoMouseCursors:Int = 2;
}

/**
	Flags controlling draw list.
**/
enum abstract ImDrawListFlags(Int) from Int to Int {
	/**
		No options or flags.
	**/
	var None:Int = 0;

	/**
		Enable anti-aliased lines/borders. Disable if you are really tight on CPU/GPU. Latched at the beginning of the frame (copied to ImDrawList).
	**/
	var AntiAliasedLines:Int = 1 << 0;

	/**
		Enable anti-aliased lines/borders using textures where possible. Require backend to render with bilinear filtering (NOT point/nearest filtering). Latched at the beginning of the frame (copied to ImDrawList).
	**/
	var AntiAliasedLinesUseTex:Int = 1 << 1;

	/**
		Enable anti-aliased edges around filled shapes (rounded rectangles, circles, etc.). Disable if you are really tight on CPU/GPU. Latched at the beginning of the frame (copied to ImDrawList).
	**/
	var AntiAliasedFill:Int = 1 << 2;

	/**
		Enables allow vtx offset behavior.
	**/
	var AllowVtxOffset:Int = 1 << 3;

	/**
		Enables text no pixel snap behavior.
	**/
	var TextNoPixelSnap:Int = 1 << 4;
}

/**
	Flags controlling slider.
**/
enum abstract ImGuiSliderFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None:Int = 0;

	/**
		Make the widget logarithmic (linear otherwise). Consider using ImGuiSliderFlags_NoRoundToFormat with this if using a format-string with small amount of digits.
	**/
	var Logarithmic:Int = 1 << 5;

	/**
		Disable rounding underlying value to match precision of the display format string (e.g. %.3f values are rounded to those 3 digits).
	**/
	var NoRoundToFormat:Int = 1 << 6;

	/**
		Disable Ctrl+Click or Enter key allowing to input text directly into the widget.
	**/
	var NoInput:Int = 1 << 7;

	/**
		Enable wrapping around from max to min and from min to max. Only supported by DragXXX() functions for now.
	**/
	var WrapAround:Int = 1 << 8;

	/**
		Clamp value to min/max bounds when input manually with Ctrl+Click. By default Ctrl+Click allows going out of bounds.
	**/
	var ClampOnInput:Int = 1 << 9;

	/**
		Clamp even if min==max==0.0f. Otherwise due to legacy reason DragXXX functions don't clamp with those values. When your clamping limits are dynamic you almost always want to use it.
	**/
	var ClampZeroRange:Int = 1 << 10;

	/**
		Disable keyboard modifiers altering tweak speed. Useful if you want to alter tweak speed yourself based on your own logic.
	**/
	var NoSpeedTweaks:Int = 1 << 11;

	/**
		DragScalarN(), SliderScalarN(): Draw R/G/B/A color markers on each component.
	**/
	var ColorMarkers:Int = 1 << 12;

	/**
		Enables always clamp behavior.
	**/
	var AlwaysClamp:Int = ClampOnInput | ClampZeroRange;
}

/**
	Flags controlling table.
**/
enum abstract ImGuiTableFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None = 0;

	/**
		Enable resizing columns.
	**/
	var Resizable = 1 << 0; // Enable resizing columns.

	/**
		Enable reordering columns in header row. (Need calling TableSetupColumn() + TableHeadersRow() to display headers, or using ImGuiTableFlags_ContextMenuInBody to access context-menu without headers).
	**/
	var Reorderable = 1 << 1; // Enable reordering columns in header row (need calling TableSetupColumn() + TableHeadersRow() to display headers)

	/**
		Enable hiding/disabling columns in context menu.
	**/
	var Hideable = 1 << 2; // Enable hiding/disabling columns in context menu.

	/**
		Enable sorting. Call TableGetSortSpecs() to obtain sort specs. Also see ImGuiTableFlags_SortMulti and ImGuiTableFlags_SortTristate.
	**/
	var Sortable = 1 << 3; // Enable sorting. Call TableGetSortSpecs() to obtain sort specs. Also see var SortMulti and var SortTristate.

	/**
		Disable persisting columns order, width, visibility and sort settings in the .ini file.
	**/
	var NoSavedSettings = 1 << 4; // Disable persisting columns order; width and sort settings in the .ini file.

	/**
		Right-click on columns body/contents will also display table context menu. By default it is available in TableHeadersRow().
	**/
	var ContextMenuInBody = 1 << 5; // Right-click on columns body/contents will display table context menu. By default it is available in TableHeadersRow().

	// Decorations

	/**
		Set each RowBg color with ImGuiCol_TableRowBg or ImGuiCol_TableRowBgAlt (equivalent of calling TableSetBgColor with ImGuiTableBgFlags_RowBg0 on each row manually)
	**/
	var RowBg = 1 << 6; // Set each RowBg color with ImGuiCol_TableRowBg or ImGuiCol_TableRowBgAlt (equivalent of calling TableSetBgColor with ImGuiTableBgFlags_RowBg0 on each row manually)

	/**
		Draw horizontal borders between rows.
	**/
	var BordersInnerH = 1 << 7; // Draw horizontal borders between rows.

	/**
		Draw horizontal borders at the top and bottom.
	**/
	var BordersOuterH = 1 << 8; // Draw horizontal borders at the top and bottom.

	/**
		Draw vertical borders between columns.
	**/
	var BordersInnerV = 1 << 9; // Draw vertical borders between columns.

	/**
		Draw vertical borders on the left and right sides.
	**/
	var BordersOuterV = 1 << 10; // Draw vertical borders on the left and right sides.

	/**
		Draw horizontal borders.
	**/
	var BordersH = BordersInnerH | BordersOuterH; // Draw horizontal borders.

	/**
		Draw vertical borders.
	**/
	var BordersV = BordersInnerV | BordersOuterV; // Draw vertical borders.

	/**
		Draw inner borders.
	**/
	var BordersInner = BordersInnerV | BordersInnerH; // Draw inner borders.

	/**
		Draw outer borders.
	**/
	var BordersOuter = BordersOuterV | BordersOuterH; // Draw outer borders.

	/**
		Draw all borders.
	**/
	var Borders = BordersInner | BordersOuter; // Draw all borders.

	/**
		[ALPHA] Disable vertical borders in columns Body (borders will always appear in Headers). -> May move to style.
	**/
	var NoBordersInBody = 1 << 11; // [ALPHA] Disable vertical borders in columns Body (borders will always appears in Headers). -> May move to style

	/**
		[ALPHA] Disable vertical borders in columns Body until hovered for resize (borders will always appear in Headers). -> May move to style.
	**/
	var NoBordersInBodyUntilResize = 1 << 12; // [ALPHA] Disable vertical borders in columns Body until hovered for resize (borders will always appears in Headers). -> May move to style

	// Sizing Policy (read above for defaults)

	/**
		Columns default to _WidthFixed or _WidthAuto (if resizable or not resizable), matching contents width.
	**/
	var SizingFixedFit = 1 << 13; // Columns default to _WidthFixed or _WidthAuto (if resizable or not resizable); matching contents width.

	/**
		Columns default to _WidthFixed or _WidthAuto (if resizable or not resizable), matching the maximum contents width of all columns. Implicitly enable ImGuiTableFlags_NoKeepColumnsVisible.
	**/
	var SizingFixedSame = 2 << 13; // Columns default to _WidthFixed or _WidthAuto (if resizable or not resizable); matching the maximum contents width of all columns. Implicitly enable var NoKeepColumnsVisible.

	/**
		Columns default to _WidthStretch with default weights proportional to each columns contents widths.
	**/
	var SizingStretchProp = 3 << 13; // Columns default to _WidthStretch with default weights proportional to each columns contents widths.

	/**
		Columns default to _WidthStretch with default weights all equal, unless overridden by TableSetupColumn().
	**/
	var SizingStretchSame = 4 << 13; // Columns default to _WidthStretch with default weights all equal; unless overridden by TableSetupColumn().

	// Sizing Extra Options

	/**
		Make outer width auto-fit to columns, overriding outer_size.x value. Only available when ScrollX/ScrollY are disabled and Stretch columns are not used.
	**/
	var NoHostExtendX = 1 << 16; // Make outer width auto-fit to columns; overriding outer_size.x value. Only available when ScrollX/ScrollY are disabled and Stretch columns are not used.

	/**
		Make outer height stop exactly at outer_size.y (prevent auto-extending table past the limit). Only available when ScrollX/ScrollY are disabled. Data below the limit will be clipped and not visible.
	**/
	var NoHostExtendY = 1 << 17; // Make outer height stop exactly at outer_size.y (prevent auto-extending table past the limit). Only available when ScrollX/ScrollY are disabled. Data below the limit will be clipped and not visible.

	/**
		Disable keeping column always minimally visible when ScrollX is off and table gets too small. Not recommended if columns are resizable.
	**/
	var NoKeepColumnsVisible = 1 << 18; // Disable keeping column always minimally visible when ScrollX is off and table gets too small. Not recommended if columns are resizable.

	/**
		Disable distributing remainder width to stretched columns (width allocation on a 100-wide table with 3 columns: Without this flag: 33,33,34. With this flag: 33,33,33). With larger number of columns, resizing will appear to be less smooth.
	**/
	var PreciseWidths = 1 << 19; // Disable distributing remainder width to stretched columns (width allocation on a 100-wide table with 3 columns: Without this flag: 33;33;34. With this flag: 33;33;33). With larger number of columns; resizing will appear to be less smooth.

	// Clipping

	/**
		Disable clipping rectangle for every individual columns (reduce draw command count, items will be able to overflow into other columns). Generally incompatible with TableSetupScrollFreeze().
	**/
	var NoClip = 1 << 20; // Disable clipping rectangle for every individual columns (reduce draw command count; items will be able to overflow into other columns). Generally incompatible with TableSetupScrollFreeze().

	// Padding

	/**
		Default if BordersOuterV is on. Enable outermost padding. Generally desirable if you have headers.
	**/
	var PadOuterX = 1 << 21; // Default if BordersOuterV is on. Enable outer-most padding. Generally desirable if you have headers.

	/**
		Default if BordersOuterV is off. Disable outermost padding.
	**/
	var NoPadOuterX = 1 << 22; // Default if BordersOuterV is off. Disable outer-most padding.

	/**
		Disable inner padding between columns (double inner padding if BordersOuterV is on, single inner padding if BordersOuterV is off).
	**/
	var NoPadInnerX = 1 << 23; // Disable inner padding between columns (double inner padding if BordersOuterV is on; single inner padding if BordersOuterV is off).

	// Scrolling

	/**
		Enable horizontal scrolling. Require 'outer_size' parameter of BeginTable() to specify the container size. Changes default sizing policy. Because this creates a child window, ScrollY is currently generally recommended when using ScrollX.
	**/
	var ScrollX = 1 << 24; // Enable horizontal scrolling. Require 'outer_size' parameter of BeginTable() to specify the container size. Changes default sizing policy. Because this create a child window; ScrollY is currently generally recommended when using ScrollX.

	/**
		Enable vertical scrolling. Require 'outer_size' parameter of BeginTable() to specify the container size.
	**/
	var ScrollY = 1 << 25; // Enable vertical scrolling. Require 'outer_size' parameter of BeginTable() to specify the container size.

	// Sorting

	/**
		Hold shift when clicking headers to sort on multiple column. TableGetSortSpecs() may return specs where (SpecsCount > 1).
	**/
	var SortMulti = 1 << 26; // Hold shift when clicking headers to sort on multiple column. TableGetSortSpecs() may return specs where (SpecsCount > 1).

	/**
		Allow no sorting, disable default sorting. TableGetSortSpecs() may return specs where (SpecsCount == 0).
	**/
	var SortTristate = 1 << 27; // Allow no sorting; disable default sorting. TableGetSortSpecs() may return specs where (SpecsCount == 0).

	/**
		Highlight column headers when hovered (may evolve into a fuller highlight)
	**/
	var HighlightHoveredColumn = 1 << 28;
}

/**
	Flags controlling table row.
**/
enum abstract ImGuiTableRowFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None = 0;

	/**
		Identify header row (set default background color + width of its contents accounted differently for auto column width)
	**/
	var Headers = 1 << 0; // Identify header row (set default background color + width of its contents accounted differently for auto column width)

}

/**
	Values representing table bg target.
**/
enum abstract ImGuiTableBgTarget(Int) from Int to Int {
	/**
		No options or flags.
	**/
	var None = 0;

	/**
		Set row background color 0 (generally used for background, automatically set when ImGuiTableFlags_RowBg is used)
	**/
	var RowBg0 = 1; // Set row background color 0 (generally used for background, automatically set when ImGuiTableFlags_RowBg is used)

	/**
		Set row background color 1 (generally used for selection marking)
	**/
	var RowBg1 = 2; // Set row background color 1 (generally used for selection marking)

	/**
		Set cell background color (top-most color)
	**/
	var CellBg = 3; // Set cell background color (top-most color)

}

/**
	Flags controlling table column.
**/
enum abstract ImGuiTableColumnFlags(Int) from Int to Int {
	// Input configuration flags

	/**
		No flags.
	**/
	var None = 0;

	/**
		Overriding/master disable flag: hide column, won't show in context menu (unlike calling TableSetColumnEnabled() which manipulates the user accessible state)
	**/
	var Disabled = 1 << 0; // Overriding/master disable flag: hide column; won't show in context menu (unlike calling TableSetColumnEnabled() which manipulates the user accessible state)

	/**
		Default as a hidden/disabled column.
	**/
	var DefaultHide = 1 << 1; // Default as a hidden/disabled column.

	/**
		Default as a sorting column.
	**/
	var DefaultSort = 1 << 2; // Default as a sorting column.

	/**
		Column will stretch. Preferable with horizontal scrolling disabled (default if table sizing policy is _SizingStretchSame or _SizingStretchProp).
	**/
	var WidthStretch = 1 << 3; // Column will stretch. Preferable with horizontal scrolling disabled (default if table sizing policy is _SizingStretchSame or _SizingStretchProp).

	/**
		Column will not stretch. Preferable with horizontal scrolling enabled (default if table sizing policy is _SizingFixedFit and table is resizable).
	**/
	var WidthFixed = 1 << 4; // Column will not stretch. Preferable with horizontal scrolling enabled (default if table sizing policy is _SizingFixedFit and table is resizable).

	/**
		Disable manual resizing.
	**/
	var NoResize = 1 << 5; // Disable manual resizing.

	/**
		Disable manual reordering this column, this will also prevent other columns from crossing over this column.
	**/
	var NoReorder = 1 << 6; // Disable manual reordering this column; this will also prevent other columns from crossing over this column.

	/**
		Disable ability to hide/disable this column.
	**/
	var NoHide = 1 << 7; // Disable ability to hide/disable this column.

	/**
		Disable clipping for this column (all NoClip columns will render in a same draw command).
	**/
	var NoClip = 1 << 8; // Disable clipping for this column (all NoClip columns will render in a same draw command).

	/**
		Disable ability to sort on this field (even if ImGuiTableFlags_Sortable is set on the table).
	**/
	var NoSort = 1 << 9; // Disable ability to sort on this field (even if ImGuiTableFlags_Sortable is set on the table).

	/**
		Disable ability to sort in the ascending direction.
	**/
	var NoSortAscending = 1 << 10; // Disable ability to sort in the ascending direction.

	/**
		Disable ability to sort in the descending direction.
	**/
	var NoSortDescending = 1 << 11; // Disable ability to sort in the descending direction.

	/**
		TableHeadersRow() will submit an empty label for this column. Convenient for some small columns. Name will still appear in context menu or in angled headers. You may append into this cell by calling TableSetColumnIndex() right after the TableHeadersRow() call.
	**/
	var NoHeaderLabel = 1 << 12; // TableHeadersRow() will not submit label for this column. Convenient for some small columns. Name will still appear in context menu.

	/**
		Disable header text width contribution to automatic column width.
	**/
	var NoHeaderWidth = 1 << 13; // Disable header text width contribution to automatic column width.

	/**
		Make the initial sort direction Ascending when first sorting on this column (default).
	**/
	var PreferSortAscending = 1 << 14; // Make the initial sort direction Ascending when first sorting on this column (default).

	/**
		Make the initial sort direction Descending when first sorting on this column.
	**/
	var PreferSortDescending = 1 << 15; // Make the initial sort direction Descending when first sorting on this column.

	/**
		Use current Indent value when entering cell (default for column 0).
	**/
	var IndentEnable = 1 << 16; // Use current Indent value when entering cell (default for column 0).

	/**
		Ignore current Indent value when entering cell (default for columns > 0). Indentation changes _within_ the cell will still be honored.
	**/
	var IndentDisable = 1 << 17; // Ignore current Indent value when entering cell (default for columns > 0). Indentation changes _within_ the cell will still be honored.

	/**
		TableHeadersRow() will submit an angled header row for this column. Note this will add an extra row.
	**/
	var AngledHeader = 1 << 18;

	// Output status flags; read-only via TableGetColumnFlags()

	/**
		Status: is enabled == not hidden by user/api (referred to as "Hide" in _DefaultHide and _NoHide) flags.
	**/
	var IsEnabled = 1 << 24; // Status: is enabled == not hidden by user/api (referred to as "Hide" in _DefaultHide and _NoHide) flags.

	/**
		Status: is visible == is enabled AND not clipped by scrolling.
	**/
	var IsVisible = 1 << 25; // Status: is visible == is enabled AND not clipped by scrolling.

	/**
		Status: is currently part of the sort specs.
	**/
	var IsSorted = 1 << 26; // Status: is currently part of the sort specs

	/**
		Status: is hovered by mouse.
	**/
	var IsHovered = 1 << 27; // Status: is hovered by mouse

}

/**
	Flags controlling input.
**/
enum abstract ImGuiInputFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None = 0;

	/**
		Enable repeat. Return true on successive repeats. Default for legacy IsKeyPressed(). NOT Default for legacy IsMouseClicked(). MUST BE == 1.
	**/
	var Repeat = 1 << 0;

	/**
		Route to active item only.
	**/
	var RouteActive = 1 << 10;

	/**
		Route to windows in the focus stack (DEFAULT). Deep-most focused window takes inputs. Active item takes inputs over deep-most focused window.
	**/
	var RouteFocused = 1 << 11;

	/**
		Global route (unless a focused window or active item registered the route).
	**/
	var RouteGlobal = 1 << 12;

	/**
		Do not register route, poll keys directly.
	**/
	var RouteAlways = 1 << 13;

	/**
		Option: global route: higher priority than focused route (unless active item in focused route).
	**/
	var RouteOverFocused = 1 << 14;

	/**
		Option: global route: higher priority than active item. Unlikely you need to use that: will interfere with every active items, e.g. Ctrl+A registered by InputText will be overridden by this. May not be fully honored as user/internal code is likely to always assume they can access keys when active.
	**/
	var RouteOverActive = 1 << 15;

	/**
		Option: global route: will not be applied if underlying background/void is focused (== no Dear ImGui windows are focused). Useful for overlay applications.
	**/
	var RouteUnlessBgFocused = 1 << 16;

	/**
		Option: route evaluated from the point of view of root window rather than current window.
	**/
	var RouteFromRootWindow = 1 << 17;

	/**
		Automatically display a tooltip when hovering item [BETA] Unsure of right api (opt-in/opt-out)
	**/
	var Tooltip = 1 << 18;
}

/**
	Flags controlling item.
**/
enum abstract ImGuiItemFlags(Int) from Int to Int {
	/**
		Default:
	**/
	var None = 0;

	/**
		False // Disable keyboard tabbing. This is a "lighter" version of ImGuiItemFlags_NoNav.
	**/
	var NoTabStop = 1 << 0;

	/**
		False // Disable any form of focusing: keyboard/gamepad directional navigation and SetKeyboardFocusHere() calls.
	**/
	var NoNav = 1 << 1;

	/**
		False // Disable item being a candidate for default focus (e.g. used by title bar items).
	**/
	var NoNavDefaultFocus = 1 << 2;

	/**
		False // Any button-like behavior will have repeat mode enabled (based on io.KeyRepeatDelay and io.KeyRepeatRate values). Note that you can also call IsItemActive() after any button to tell if it is being held.
	**/
	var ButtonRepeat = 1 << 3;

	/**
		True // MenuItem()/Selectable() automatically close their parent popup window.
	**/
	var AutoClosePopups = 1 << 4;

	/**
		False // Allow submitting an item with the same identifier as an item already submitted this frame without triggering a warning tooltip if io.ConfigDebugHighlightIdConflicts is set.
	**/
	var AllowDuplicateId = 1 << 5;

	/**
		False // [Internal] Disable interactions. DOES NOT affect visuals. This is used by BeginDisabled()/EndDisabled() and only provided here so you can read back via GetItemFlags().
	**/
	@:noCompletion var Disabled = 1 << 6;

	/**
		True // InputText: apply keyboard edits to backing value while typing. Otherwise, edits are applied when validating, tabbing out or losing focus.
	**/
	var LiveEditOnInputText = 1 << 7;

	/**
		False // DragXXX, SliderXXX, InputScalar: apply keyboard edits to backing value while typing. Otherwise, edits are applied when validating, tabbing out or losing focus.
	**/
	var LiveEditOnInputScalar = 1 << 8;

	/**
		Enables live edit on input behavior.
	**/
	var LiveEditOnInput = LiveEditOnInputText | LiveEditOnInputScalar;
}

// Flags for ImDrawList functions
// (Legacy: bit 0 must always correspond to ImDrawFlags_Closed to be backward compatible with old API using a bool. Bits 1..3 must be unused)

/**
	Flags controlling draw.
**/
enum abstract ImDrawFlags(Int) from Int to Int {
	/**
		No options or flags.
	**/
	var None = 0;

	/**
		Enables closed behavior.
	**/
	var Closed = 1 << 9;

	/**
		AddRect(); AddRectFilled(); PathRect(): enable rounding top-left corner only (when rounding > 0.0f; we default to all corners). Was 0x01.
	**/
	var RoundCornersTopLeft = 1 << 4; // AddRect(); AddRectFilled(); PathRect(): enable rounding top-left corner only (when rounding > 0.0f; we default to all corners). Was 0x01.

	/**
		AddRect(); AddRectFilled(); PathRect(): enable rounding top-right corner only (when rounding > 0.0f; we default to all corners). Was 0x02.
	**/
	var RoundCornersTopRight = 1 << 5; // AddRect(); AddRectFilled(); PathRect(): enable rounding top-right corner only (when rounding > 0.0f; we default to all corners). Was 0x02.

	/**
		AddRect(); AddRectFilled(); PathRect(): enable rounding bottom-left corner only (when rounding > 0.0f; we default to all corners). Was 0x04.
	**/
	var RoundCornersBottomLeft = 1 << 6; // AddRect(); AddRectFilled(); PathRect(): enable rounding bottom-left corner only (when rounding > 0.0f; we default to all corners). Was 0x04.

	/**
		AddRect(); AddRectFilled(); PathRect(): enable rounding bottom-right corner only (when rounding > 0.0f; we default to all corners). Wax 0x08.
	**/
	var RoundCornersBottomRight = 1 << 7; // AddRect(); AddRectFilled(); PathRect(): enable rounding bottom-right corner only (when rounding > 0.0f; we default to all corners). Wax 0x08.

	/**
		AddRect(); AddRectFilled(); PathRect(): disable rounding on all corners (when rounding > 0.0f). This is NOT zero; NOT an implicit flag!
	**/
	var RoundCornersNone = 1 << 8; // AddRect(); AddRectFilled(); PathRect(): disable rounding on all corners (when rounding > 0.0f). This is NOT zero; NOT an implicit flag!

	/**
		Enables round corners top behavior.
	**/
	var RoundCornersTop = RoundCornersTopLeft | RoundCornersTopRight;

	/**
		Enables round corners bottom behavior.
	**/
	var RoundCornersBottom = RoundCornersBottomLeft | RoundCornersBottomRight;

	/**
		Enables round corners left behavior.
	**/
	var RoundCornersLeft = RoundCornersBottomLeft | RoundCornersTopLeft;

	/**
		Enables round corners right behavior.
	**/
	var RoundCornersRight = RoundCornersBottomRight | RoundCornersTopRight;

	/**
		Enables round corners all behavior.
	**/
	var RoundCornersAll = RoundCornersTopLeft | RoundCornersTopRight | RoundCornersBottomLeft | RoundCornersBottomRight;

	/**
		Default to ALL corners if none of the _RoundCornersXX flags are specified.
	**/
	var RoundCornersDefault_ = (1 << 4 | 1 << 5 | 1 << 6 | 1 << 7); // Default to ALL corners if none of the _RoundCornersXX flags are specified.

	/**
		Enables round corners mask behavior.
	**/
	var RoundCornersMask_ = RoundCornersAll | RoundCornersNone;
}

/**
	Flags controlling viewport.
**/
enum abstract ImGuiViewportFlags(Int) from Int to Int {
	/**
		No flags.
	**/
	var None = 0;

	/**
		Represent a Platform Window.
	**/
	var IsPlatformWindow = 1 << 0; // Represent a Platform Window

	/**
		Represent a Platform Monitor (unused yet)
	**/
	var IsPlatformMonitor = 1 << 1; // Represent a Platform Monitor (unused yet)

	/**
		Platform Window: Is created/managed by the user application? (rather than our backend)
	**/
	var OwnedByApp = 1 << 2; // Platform Window: is created/managed by the application (rather than a dear imgui backend)

	/**
		Platform Window: Disable platform decorations: title bar, borders, etc. (generally set all windows, but if ImGuiConfigFlags_ViewportsDecoration is set we only set this on popups/tooltips)
	**/
	var NoDecoration = 1 << 3; // Platform Window: Disable platform decorations: title bar, borders, etc. (generally set all windows, but if ImGuiConfigFlags_ViewportsDecoration is set we only set this on popups/tooltips)

	/**
		Platform Window: Disable platform task bar icon (generally set on popups/tooltips, or all windows if ImGuiConfigFlags_ViewportsNoTaskBarIcon is set)
	**/
	var NoTaskBarIcon = 1 << 4; // Platform Window: Disable platform task bar icon (generally set on popups/tooltips, or all windows if ImGuiConfigFlags_ViewportsNoTaskBarIcon is set)

	/**
		Platform Window: Don't take focus when created.
	**/
	var NoFocusOnAppearing = 1 << 5; // Platform Window: Don't take focus when created.

	/**
		Platform Window: Don't take focus when clicked on.
	**/
	var NoFocusOnClick = 1 << 6; // Platform Window: Don't take focus when clicked on.

	/**
		Platform Window: Make mouse pass through so we can drag this window while peaking behind it.
	**/
	var NoInputs = 1 << 7; // Platform Window: Make mouse pass through so we can drag this window while peaking behind it.

	/**
		Platform Window: Renderer doesn't need to clear the framebuffer ahead (because we will fill it entirely).
	**/
	var NoRendererClear = 1 << 8; // Platform Window: Renderer doesn't need to clear the framebuffer ahead (because we will fill it entirely).

	/**
		Platform Window: Avoid merging this window into another host window. This can only be set via ImGuiWindowClass viewport flags override (because we need to now ahead if we are going to create a viewport in the first place!).
	**/
	var NoAutoMerge = 1 << 9;

	/**
		Platform Window: Display on top (for tooltips only).
	**/
	var TopMost = 1 << 10;

	/**
		Viewport can host multiple imgui windows (secondary viewports are associated to a single window). // FIXME: In practice there's still probably code making the assumption that this is always and only on the MainViewport. Will fix once we add support for "no main viewport".
	**/
	var CanHostOtherWindows = 1 << 11;

	/**
		Platform Window: Window is minimized, can skip render. When minimized we tend to avoid using the viewport pos/size for clipping window or testing if they are contained in the viewport.
	**/
	var IsMinimized = 1 << 12;

	/**
		Platform Window: Window is focused (last call to Platform_GetWindowFocus() returned true)
	**/
	var IsFocused = 1 << 13;
}

/**
	Public alias of `{`.
**/
typedef ImEvents = {
	/**
		Elapsed frame time in seconds.
	**/
	dt:Single,

	/**
		Mouse X position in display coordinates.
	**/
	mouse_x:Single,

	/**
		Mouse Y position in display coordinates.
	**/
	mouse_y:Single,

	/**
		Vertical mouse-wheel delta.
	**/
	wheel:Single,

	/**
		Whether the left mouse button is pressed.
	**/
	left_click:Bool,

	/**
		Whether the right mouse button is pressed.
	**/
	right_click:Bool,

	/**
		Whether Shift is held.
	**/
	shift:Bool,

	/**
		Whether Ctrl is held.
	**/
	ctrl:Bool,

	/**
		Whether Alt is held.
	**/
	alt:Bool
}

// In reality it's h3d.mat.Texture, but HL really dislike passing instances
// directly for some reason.

#if heaps
/**
	Renderer-defined texture identifier used by draw commands.
**/
abstract ImTextureID(Dynamic) from h3d.mat.Texture to h3d.mat.Texture {}
#else

/**
	Renderer-defined texture identifier used by draw commands.
**/
typedef ImTextureID = Dynamic;
#end

/**
	Dear ImGui texture reference and optional Heaps texture wrapper.
**/
abstract ImTextureRef(ImTextureID) from ImTextureID to ImTextureID {
	#if heaps
	/**
		Creates an ImGui texture reference from a Heaps texture.
	**/
	@:from public static inline function fromTexture(texture:h3d.mat.Texture):ImTextureRef {
		return cast texture;
	}
	#end
}

/**
	Packed unsigned 32-bit value used for Dear ImGui colors.
**/
typedef ImU32 = Int;

/**
	Stable 32-bit identifier generated by Dear ImGui.
**/
typedef ImGuiID = Int;

/**
	Public alias of `hl.I64`.
**/
typedef ImGuiSelectionUserData = hl.I64;

/**
	The raw memory ImVec2
**/
@:keep
@:structInit class ImVec2S {
	public var x:Single;

	/**
		Gets or sets y.
	**/
	public var y:Single;

	@:deprecated("Remainder of ExtDynamic")
	@:noCompletion public var v(get, never):ImVec2;

	inline function get_v()
		return this;

	@:deprecated("Remainder of ExtDynamic")
	@:noCompletion public inline function to():ImVec2
		return this;

	/**
		Creates a new `ImTextureRef` instance.
	**/
	public inline function new(x:Single = 0.0, y:Single = 0.0) {
		this.x = x;
		this.y = y;
	}

	/**
		Updates this value's components.
	**/
	public inline function set(x:Single = 0, y:Single = 0):ImVec2 {
		this.x = x;
		this.y = y;
		return this;
	}

	/**
		Returns a value initialized from the supplied components.
	**/
	public static inline function get(x:Single = 0, y:Single = 0):ImVec2 {
		return {x: x, y: y};
	};

	/**
		Returns a readable string representation of this value.
	**/
	@:keep public function toString() {
		return '{ x: $x, y: $y }';
	}

	@:noCompletion public inline function addScalar(other:Single) {
		return get(x + other, y + other);
	}

	@:noCompletion public inline function subScalar(other:Single) {
		return get(x - other, y - other);
	}

	@:noCompletion public inline function mulScalar(other:Single) {
		return get(x * other, y * other);
	}

	@:noCompletion public inline function divScalar(other:Single) {
		return get(x / other, y / other);
	}

	@:noCompletion public inline function modScalar(other:Single) {
		return get(x % other, y % other);
	}

	@:noCompletion public inline function add(other:ImVec2S) {
		return get(x + other.x, y + other.y);
	}

	@:noCompletion public inline function sub(other:ImVec2S) {
		return get(x - other.x, y - other.y);
	}

	@:noCompletion public inline function mul(other:ImVec2S) {
		return get(x * other.x, y * other.y);
	}

	@:noCompletion public inline function div(other:ImVec2S) {
		return get(x / other.x, y / other.y);
	}

	@:noCompletion public inline function neg() {
		return get(-x, -y);
	}

	@:noCompletion public inline function addSelf(other:ImVec2S) {
		x += other.x;
		y += other.y;
		return this;
	}

	@:noCompletion public inline function subSelf(other:ImVec2S) {
		x -= other.x;
		y -= other.y;
		return this;
	}

	@:noCompletion public inline function mulSelf(other:ImVec2S) {
		x *= other.x;
		y *= other.y;
		return this;
	}

	@:noCompletion public inline function divSelf(other:ImVec2S) {
		x /= other.x;
		y /= other.y;
		return this;
	}

	@:noCompletion public inline function negSelf() {
		x = -x;
		y = -y;
		return this;
	}

	@:noCompletion public inline function addSelfScalar(other:Single) {
		x += other;
		y += other;
		return this;
	}

	@:noCompletion public inline function subSelfScalar(other:Single) {
		x -= other;
		y -= other;
		return this;
	}

	@:noCompletion public inline function mulSelfScalar(other:Single) {
		x *= other;
		y *= other;
		return this;
	}

	@:noCompletion public inline function divSelfScalar(other:Single) {
		x /= other;
		y /= other;
		return this;
	}

	@:noCompletion public inline function modSelfScalar(other:Single) {
		x %= other;
		y %= other;
		return this;
	}

	@:noCompletion public inline function compare(other:ImVec2S) {
		return x == other.x && y == other.y;
	}
}

/**
	The raw memory ImVec2
**/
@:keep
@:structInit class ImVec4S {
	public var x:Single;

	/**
		Gets or sets y.
	**/
	public var y:Single;

	/**
		Gets or sets z.
	**/
	public var z:Single;

	/**
		Size of rectangle to update (in pixels)
	**/
	public var w:Single;

	/**
		Creates a new `ImTextureRef` instance.
	**/
	public inline function new(x:Single = 0.0, y:Single = 0.0, z:Single = 0.0, w:Single = 0.0) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	/**
		Alias to `x`
	**/
	public var r(get, set):Single;

	/**
		Alias to `y`
	**/
	public var g(get, set):Single;

	/**
		Alias to `z`
	**/
	public var b(get, set):Single;

	/**
		Alias to `w`
	**/
	public var a(get, set):Single;

	inline function get_r()
		return x;

	inline function set_r(v)
		return x = v;

	inline function get_g()
		return y;

	inline function set_g(v)
		return y = v;

	inline function get_b()
		return z;

	inline function set_b(v)
		return z = v;

	inline function get_a()
		return w;

	inline function set_a(v)
		return w = v;

	@:deprecated("Remainder of ExtDynamic")
	@:noCompletion public var v(get, never):ImVec4;

	inline function get_v()
		return this;

	@:deprecated("Remainder of ExtDynamic")
	@:noCompletion public inline function to():ImVec4
		return this;

	/**
		Updates this value's components.
	**/
	public inline function set(x:Single = 0, y:Single = 0, z:Single = 0, w:Single = 0):ImVec4 {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
		return this;
	}

	/**
		Sets color.
	**/
	public inline function setColor(colWAlpha:Int):ImVec4 {
		return set(((colWAlpha >> 16) & 0xff) / 0xff, ((colWAlpha >> 8) & 0xff) / 0xff, ((colWAlpha) & 0xff) / 0xff, ((colWAlpha >> 24) & 0xff) / 0xff);
	}

	/**
		Sets color rgb.
	**/
	public inline function setColorRGB(col:Int, alpha:Float = 1.0):ImVec4 {
		return set(((col) & 0xff) / 0xff, ((col >> 8) & 0xff) / 0xff, ((col >> 16) & 0xff) / 0xff, alpha);
	}

	/**
		Returns a value initialized from the supplied components.
	**/
	public static inline function get(x:Single = 0, y:Single = 0, z:Single = 0, w:Single = 0):ImVec4 {
		return {
			x: x,
			y: y,
			z: z,
			w: w
		};
	}

	/**
		Returns color.
	**/
	public static inline function getColor(colWAlpha:Int):ImVec4 {
		return {
			x: ((colWAlpha >> 16) & 0xff) / 0xff,
			y: ((colWAlpha >> 8) & 0xff) / 0xff,
			z: ((colWAlpha) & 0xff) / 0xff,
			w: ((colWAlpha >> 24) & 0xff) / 0xff
		};
	}

	/**
		Returns color rgb.
	**/
	public static inline function getColorRGB(col:Int, alpha:Float = 1.0):ImVec4 {
		return {
			x: ((col >> 16) & 0xff) / 0xff,
			y: ((col >> 8) & 0xff) / 0xff,
			z: ((col) & 0xff) / 0xff,
			w: alpha
		};
	}

	/**
		Returns this value as a packed color.
	**/
	public inline function toColor():Int {
		return ((Std.int(z * 0xff) & 0xff))
			+ ((Std.int(y * 0xff) & 0xff) << 8)
			+ ((Std.int(x * 0xff) & 0xff) << 16)
			+ ((Std.int(w * 0xff) & 0xff) << 24);
	}

	/**
		Returns the first two components as an `ImVec2`.
	**/
	public function xy():ImVec2 {
		return ImVec2S.get(x, y);
	}

	/**
		Returns the last two components as an `ImVec2`.
	**/
	public function zw():ImVec2 {
		return ImVec2S.get(z, w);
	}

	/**
		Returns a readable string representation of this value.
	**/
	@:keep public function toString() {
		return '{ x: $x, y: $y, z: $z, w: $w }';
	}

	@:noCompletion public inline function addScalar(other:Single) {
		return get(x + other, y + other, z + other, w + other);
	}

	@:noCompletion public inline function subScalar(other:Single) {
		return get(x - other, y - other, z - other, w - other);
	}

	@:noCompletion public inline function mulScalar(other:Single) {
		return get(x * other, y * other, z * other, w * other);
	}

	@:noCompletion public inline function divScalar(other:Single) {
		return get(x / other, y / other, z / other, w / other);
	}

	@:noCompletion public inline function modScalar(other:Single) {
		return get(x % other, y % other, z % other, w % other);
	}

	@:noCompletion public inline function add(other:ImVec4S) {
		return get(x + other.x, y + other.y, z + other.z, w + other.w);
	}

	@:noCompletion public inline function sub(other:ImVec4S) {
		return get(x - other.x, y - other.y, z - other.z, w - other.w);
	}

	@:noCompletion public inline function mul(other:ImVec4S) {
		return get(x * other.x, y * other.y, z * other.z, w * other.w);
	}

	@:noCompletion public inline function div(other:ImVec4S) {
		return get(x / other.x, y / other.y, z / other.z, w / other.w);
	}

	@:noCompletion public inline function neg() {
		return get(-x, -y, -z, -w);
	}

	@:noCompletion public inline function addSelf(other:ImVec4S) {
		x += other.x;
		y += other.y;
		z += other.z;
		w += other.w;
		return this;
	}

	@:noCompletion public inline function subSelf(other:ImVec4S) {
		x -= other.x;
		y -= other.y;
		z -= other.z;
		w -= other.w;
		return this;
	}

	@:noCompletion public inline function mulSelf(other:ImVec4S) {
		x *= other.x;
		y *= other.y;
		z *= other.z;
		w *= other.w;
		return this;
	}

	@:noCompletion public inline function divSelf(other:ImVec4S) {
		x /= other.x;
		y /= other.y;
		z /= other.z;
		w /= other.w;
		return this;
	}

	@:noCompletion public inline function negSelf() {
		x = -x;
		y = -y;
		z = -z;
		w = -w;
		return this;
	}

	@:noCompletion public inline function addSelfScalar(other:Single) {
		x += other;
		y += other;
		z += other;
		w += other;
		return this;
	}

	@:noCompletion public inline function subSelfScalar(other:Single) {
		x -= other;
		y -= other;
		z -= other;
		w -= other;
		return this;
	}

	@:noCompletion public inline function mulSelfScalar(other:Single) {
		x *= other;
		y *= other;
		z *= other;
		w *= other;
		return this;
	}

	@:noCompletion public inline function divSelfScalar(other:Single) {
		x /= other;
		y /= other;
		z /= other;
		w /= other;
		return this;
	}

	@:noCompletion public inline function modSelfScalar(other:Single) {
		x %= other;
		y %= other;
		z %= other;
		w %= other;
		return this;
	}

	@:noCompletion public inline function compare(other:ImVec4S) {
		return other != null && x == other.x && y == other.y && z == other.z && w == other.w;
	}
}

/**
	Two-component floating-point vector used by Dear ImGui APIs.
**/
@:forward
@:forwardStatics
@:structInit
abstract ImVec2(ImVec2S) from ImVec2S to ImVec2S {
	/**
		Creates a new `ImVec2` instance.
	**/
	public inline function new(x:Single = 0.0, y:Single = 0.0)
		this = new ImVec2S(x, y);

	@:op(A + B) static inline function _add(a:ImVec2, b:ImVec2)
		return a.add(b);

	@:op(A - B) static inline function _sub(a:ImVec2, b:ImVec2)
		return a.sub(b);

	@:op(A * B) static inline function _mul(a:ImVec2, b:ImVec2)
		return a.mul(b);

	@:op(A / B) static inline function _div(a:ImVec2, b:ImVec2)
		return a.div(b);

	@:op(-A) static inline function _neg(a:ImVec2)
		return a.neg();

	@:op(A + B) static inline function _addScalar(a:ImVec2, b:Single)
		return a.addScalar(b);

	@:op(A - B) static inline function _subScalar(a:ImVec2, b:Single)
		return a.subScalar(b);

	@:op(A * B) static inline function _mulScalar(a:ImVec2, b:Single)
		return a.mulScalar(b);

	@:op(A / B) static inline function _divScalar(a:ImVec2, b:Single)
		return a.divScalar(b);

	@:op(A % B) static inline function _modScalar(a:ImVec2, b:Single)
		return a.modScalar(b);

	@:op(A += B) static inline function _addSelf(a:ImVec2, b:ImVec2)
		return a.addSelf(b);

	@:op(A -= B) static inline function _subSelf(a:ImVec2, b:ImVec2)
		return a.subSelf(b);

	@:op(A *= B) static inline function _mulSelf(a:ImVec2, b:ImVec2)
		return a.mulSelf(b);

	@:op(A /= B) static inline function _divSelf(a:ImVec2, b:ImVec2)
		return a.divSelf(b);

	@:op(A += B) static inline function _addSelfScalar(a:ImVec2, b:Single)
		return a.addSelfScalar(b);

	@:op(A -= B) static inline function _subSelfScalar(a:ImVec2, b:Single)
		return a.subSelfScalar(b);

	@:op(A *= B) static inline function _mulSelfScalar(a:ImVec2, b:Single)
		return a.mulSelfScalar(b);

	@:op(A /= B) static inline function _divSelfScalar(a:ImVec2, b:Single)
		return a.divSelfScalar(b);

	@:op(A %= B) static inline function _modSelfScalar(a:ImVec2, b:Single)
		return a.modSelfScalar(b);

	@:op(A == B) static inline function _compare(a:ImVec2, b:ImVec2)
		return a == null ? b == null : a.compare(b);
}

/**
	Four-component floating-point vector commonly used for colors and rectangles.
**/
@:forward
@:forwardStatics
@:structInit
abstract ImVec4(ImVec4S) from ImVec4S to ImVec4S {
	/**
		Creates a new `ImVec4` instance.
	**/
	public inline function new(x:Single = 0.0, y:Single = 0.0, z:Single = 0.0, w:Single = 0.0)
		this = new ImVec4S(x, y, z, w);

	@:op(A + B) static inline function _add(a:ImVec4, b:ImVec4)
		return a.add(b);

	@:op(A - B) static inline function _sub(a:ImVec4, b:ImVec4)
		return a.sub(b);

	@:op(A * B) static inline function _mul(a:ImVec4, b:ImVec4)
		return a.mul(b);

	@:op(A / B) static inline function _div(a:ImVec4, b:ImVec4)
		return a.div(b);

	@:op(-A) static inline function _neg(a:ImVec4)
		return a.neg();

	@:op(A + B) static inline function _addScalar(a:ImVec4, b:Single)
		return a.addScalar(b);

	@:op(A - B) static inline function _subScalar(a:ImVec4, b:Single)
		return a.subScalar(b);

	@:op(A * B) static inline function _mulScalar(a:ImVec4, b:Single)
		return a.mulScalar(b);

	@:op(A / B) static inline function _divScalar(a:ImVec4, b:Single)
		return a.divScalar(b);

	@:op(A % B) static inline function _modScalar(a:ImVec4, b:Single)
		return a.modScalar(b);

	@:op(A += B) static inline function _addSelf(a:ImVec4, b:ImVec4)
		return a.addSelf(b);

	@:op(A -= B) static inline function _subSelf(a:ImVec4, b:ImVec4)
		return a.subSelf(b);

	@:op(A *= B) static inline function _mulSelf(a:ImVec4, b:ImVec4)
		return a.mulSelf(b);

	@:op(A /= B) static inline function _divSelf(a:ImVec4, b:ImVec4)
		return a.divSelf(b);

	@:op(A += B) static inline function _addSelfScalar(a:ImVec4, b:Single)
		return a.addSelfScalar(b);

	@:op(A -= B) static inline function _subSelfScalar(a:ImVec4, b:Single)
		return a.subSelfScalar(b);

	@:op(A *= B) static inline function _mulSelfScalar(a:ImVec4, b:Single)
		return a.mulSelfScalar(b);

	@:op(A /= B) static inline function _divSelfScalar(a:ImVec4, b:Single)
		return a.divSelfScalar(b);

	@:op(A %= B) static inline function _modSelfScalar(a:ImVec4, b:Single)
		return a.modSelfScalar(b);

	@:op(A == B) static inline function _compare(a:ImVec4, b:ImVec4)
		return a == null ? b == null : a.compare(b);
}

@:keep
@:build(imgui._ImGuiInternalMacro.buildFlatStruct())
@:hlNative("hlimgui")
@:struct class ImGuiStyle {
	var FontSizeBase:Single;
	var FontScaleMain:Single;
	var FontScaleDpi:Single;
	var Alpha:Single; // Global alpha applies to everything in Dear ImGui.
	var DisabledAlpha:Single; // Additional alpha multiplier applied by BeginDisabled(). Multiply over current value of Alpha.
	@:flatten var WindowPadding:ImVec2S; // Padding within a window.
	var WindowRounding:Single; // Radius of window corners rounding. Set to 0.0f to have rectangular windows. Large values tend to lead to variety of artifacts and are not recommended.
	var WindowBorderSize:Single; // Thickness of border around windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).
	var WindowBorderHoverPadding:Single;
	@:flatten var WindowMinSize:ImVec2S; // Minimum window size. This is a global setting. If you want to constraint individual windows, use SetNextWindowSizeConstraints().
	@:flatten var WindowTitleAlign:ImVec2S; // Alignment for title bar text. Defaults to (0.0f,0.5f) for left-aligned,vertically centered.
	var WindowMenuButtonPosition:ImGuiDir; // Side of the collapsing/docking button in the title bar (None/Left/Right). Defaults to ImGuiDir_Left.
	var ChildRounding:Single; // Radius of child window corners rounding. Set to 0.0f to have rectangular windows.
	var ChildBorderSize:Single; // Thickness of border around child windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).
	var PopupRounding:Single; // Radius of popup window corners rounding. (Note that tooltip windows use WindowRounding)
	var PopupBorderSize:Single; // Thickness of border around popup/tooltip windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).
	@:flatten var FramePadding:ImVec2S; // Padding within a framed rectangle (used by most widgets).
	var FrameRounding:Single; // Radius of frame corners rounding. Set to 0.0f to have rectangular frame (used by most widgets).
	var FrameBorderSize:Single; // Thickness of border around frames. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).
	@:flatten var ItemSpacing:ImVec2S; // Horizontal and vertical spacing between widgets/lines.
	@:flatten var ItemInnerSpacing:ImVec2S; // Horizontal and vertical spacing between within elements of a composed widget (e.g. a slider and its label).
	@:flatten var CellPadding:ImVec2S; // Padding within a table cell
	@:flatten var TouchExtraPadding:ImVec2S; // Expand reactive bounding box for touch-based system where touch position is not accurate enough. Unfortunately we don't sort widgets so priority on overlap will always be given to the first widget. So don't grow this too much!
	var IndentSpacing:Single; // Horizontal indentation when e.g. entering a tree node. Generally == (FontSize + FramePadding.x*2).
	var ColumnsMinSpacing:Single; // Minimum horizontal spacing between two columns. Preferably > (FramePadding.x + 1).
	var ScrollbarSize:Single; // Width of the vertical scrollbar, Height of the horizontal scrollbar.
	var ScrollbarRounding:Single; // Radius of grab corners for scrollbar.
	var ScrollbarPadding:Single;
	var GrabMinSize:Single; // Minimum width/height of a grab box for slider/scrollbar.
	var GrabRounding:Single; // Radius of grabs corners rounding. Set to 0.0f to have rectangular slider grabs.
	var LogSliderDeadzone:Single; // The size in pixels of the dead-zone around zero on logarithmic sliders that cross zero.
	var ImageRounding:Single;
	var ImageBorderSize:Single;
	var TabRounding:Single; // Radius of upper corners of a tab. Set to 0.0f to have rectangular tabs.
	var TabBorderSize:Single; // Thickness of border around tabs.
	var TabMinWidthBase:Single;
	var TabMinWidthShrink:Single;
	var TabCloseButtonMinWidthSelected:Single;
	var TabCloseButtonMinWidthUnselected:Single;
	var TabBarBorderSize:Single;
	var TabBarOverlineSize:Single;
	var TableAngledHeadersAngle:Single;
	@:flatten var TableAngledHeadersTextAlign:ImVec2S;
	var TreeLinesFlags:ImGuiTreeNodeFlags;
	var TreeLinesSize:Single;
	var TreeLinesRounding:Single;
	var MenuItemRounding:Single;
	var SelectableRounding:Single;
	var DragDropTargetRounding:Single;
	var DragDropTargetBorderSize:Single;
	var DragDropTargetPadding:Single;
	var ColorMarkerSize:Single;
	var ColorButtonPosition:ImGuiDir; // Side of the color button in the ColorEdit4 widget (left/right). Defaults to ImGuiDir_Right.
	@:flatten var ButtonTextAlign:ImVec2S; // Alignment of button text when button is larger than text. Defaults to (0.5f, 0.5f) (centered).
	@:flatten var SelectableTextAlign:ImVec2S; // Alignment of selectable text. Defaults to (0.0f, 0.0f) (top-left aligned). It's generally important to keep this left-aligned if you want to lay multiple items on a same line.
	var InputTextCursorSize:Single;
	var SeparatorSize:Single;
	var SeparatorTextBorderSize:Single; // Alignment of button text when button is larger than text.
	@:flatten var SeparatorTextAlign:ImVec2S; // Alignment of text within the separator. Defaults to (0.0f, 0.5f) (left aligned, center).
	@:flatten var SeparatorTextPadding:ImVec2S; // Horizontal offset of text from each edge of the separator + spacing on other axis. Generally small values. .y is recommended to be == FramePadding.y.
	@:flatten var DisplayWindowPadding:ImVec2S; // Window position are clamped to be visible within the display area or monitors by at least this amount. Only applies to regular windows.
	@:flatten var DisplaySafeAreaPadding:ImVec2S; // If you cannot see the edges of your screen (e.g. on a TV) increase the safe area padding. Apply to popups/tooltips as well regular windows. NB: Prefer configuring your TV sets correctly!
	var DockingNodeHasCloseButton:Bool;
	var DockingSeparatorSize:Single;
	var MouseCursorScale:Single; // Scale software rendered mouse cursor (when io.MouseDrawCursor is enabled). We apply per-monitor DPI scaling over this scale. May be removed later.
	var AntiAliasedLines:Bool; // Enable anti-aliased lines/borders. Disable if you are really tight on CPU/GPU. Latched at the beginning of the frame (copied to ImDrawList).
	var AntiAliasedLinesUseTex:Bool; // Enable anti-aliased lines/borders using textures where possible. Require backend to render with bilinear filtering. Latched at the beginning of the frame (copied to ImDrawList).
	var AntiAliasedFill:Bool; // Enable anti-aliased edges around filled shapes (rounded rectangles, circles, etc.). Disable if you are really tight on CPU/GPU. Latched at the beginning of the frame (copied to ImDrawList).
	var CurveTessellationTol:Single; // Tessellation tolerance when using PathBezierCurveTo() without a specific number of segments. Decrease for highly tessellated curves (higher quality, more polygons), increase to reduce quality.
	var CircleTessellationMaxError:Single; // Maximum error (in pixels) allowed when using AddCircle()/AddCircleFilled() or drawing rounded corner rectangles with no explicit segment count specified. Decrease for higher quality but more geometry.
	@:flattenMap(ImGuiCol) var Colors:ImVec4S;
	var HoverStationaryDelay:Single;
	var HoverDelayShort:Single;
	var HoverDelayNormal:Single;
	var HoverFlagsForTooltipMouse:ImGuiHoveredFlags;
	var HoverFlagsForTooltipNav:ImGuiHoveredFlags;
	@:noCompletion var _MainScale:Single;
	@:noCompletion var _NextFrameFontSizeBase:Single;

	/**
		Creates a new `ImVec4` instance.
	**/
	public function new() {
		// Match allocation via C: Set default values andn use default colors.
		init_style(this);
	}

	/**
		Scale all spacing/padding/thickness values. Do not scale fonts. See comments in definition. Consider not calling this if your initial scale factor if <1.0.
	**/
	public function scaleAllSizes(scaleFactor:Single) {
		style_scale_all_sizes(this, scaleFactor);
	}

	static function init_style(style:ImGuiStyle) {}

	static function style_scale_all_sizes(style:ImGuiStyle, scaleFactor:Single):Void {}
}

/**
	Keyboard key combined with optional modifier flags.
**/
enum abstract ImGuiKeyChord(Int) from Int to Int {
	/**
		No options or flags.
	**/
	var None;

	/**
		The `Ctrl` value of `ImGuiKeyChord`.
	**/
	var Ctrl = ImGuiKey.ModCtrl;

	/**
		The `Shift` value of `ImGuiKeyChord`.
	**/
	var Shift = ImGuiKey.ModShift;

	/**
		The `Alt` value of `ImGuiKeyChord`.
	**/
	var Alt = ImGuiKey.ModAlt;

	/**
		The `Super` value of `ImGuiKeyChord`.
	**/
	var Super = ImGuiKey.ModSuper;
}

@:keep
@:structInit class ImGuiKeyData {
	/**
		True for if key is down.
	**/
	public var Down:Bool;

	/**
		Duration the key has been down (<0.0f: not pressed, 0.0f: just pressed, >0.0f: time held)
	**/
	public var DownDuration:Single;

	/**
		Last frame duration the key has been down.
	**/
	public var DownDurationPrev:Single;

	/**
		0.0f..1.0f for gamepad values.
	**/
	public var AnalogValue:Single;
}

@:keep
@:build(imgui._ImGuiInternalMacro.buildFlatStruct())
@:hlNative("hlimgui")
@:struct class ImGuiIO {
	var ConfigFlags:ImGuiConfigFlags;
	var BackendFlags:ImGuiBackendFlags;
	@:flatten var DisplaySize:ImVec2S;
	@:flatten var DisplayFramebufferScale:ImVec2S;
	var DeltaTime:Single;
	var IniSavingRate:Single;
	var IniFilename:hl.Bytes;
	var LogFilename:hl.Bytes;
	var UserData:hl.Bytes;

	var Fonts:ImFontAtlas;
	var FontDefault:ImFont;
	var FontAllowUserScaling:Bool;

	// Keyboard/Gamepad Navigation options
	var ConfigNavSwapGamepadButtons:Bool;
	var ConfigNavMoveSetMousePos:Bool;
	var ConfigNavCaptureKeyboard:Bool;
	var ConfigNavEscapeClearFocusItem:Bool;
	var ConfigNavEscapeClearFocusWindow:Bool;
	var ConfigNavCursorVisibleAuto:Bool;
	var ConfigNavCursorVisibleAlways:Bool;

	// Docking options (when ImGuiConfigFlags_DockingEnable is set)
	var ConfigDockingNoSplit:Bool;
	var ConfigDockingNoDockingOver:Bool;
	var ConfigDockingWithShift:Bool;
	var ConfigDockingAlwaysTabBar:Bool;
	var ConfigDockingTransparentPayload:Bool;

	// Viewport options (when ImGuiConfigFlags_ViewportsEnable is set; which it's not in hlimgui)
	var ConfigViewportsNoAutoMerge:Bool;
	var ConfigViewportsNoTaskBarIcon:Bool;
	var ConfigViewportsNoDecoration:Bool;
	var ConfigViewportsNoDefaultParent:Bool;
	var ConfigViewportsPlatformFocusSetsImGuiFocus:Bool;

	// DPI/Scaling options
	var ConfigDpiScaleFonts:Bool;
	var ConfigDpiScaleViewports:Bool;

	// Widget options
	var ConfigMacOSXBehaviors:Bool;
	var ConfigInputTrickleEventQueue:Bool;
	var ConfigInputTextCursorBlink:Bool;
	var ConfigInputTextEnterKeepActive:Bool;
	var ConfigColorEditFlags:ImGuiColorEditFlags;
	var ConfigDragClickToInputText:Bool;
	var ConfigWindowsResizeFromEdges:Bool;
	var ConfigWindowsMoveFromTitleBarOnly:Bool;
	var ConfigWindowsCopyContentsWithCtrlC:Bool;
	var ConfigScrollbarScrollByPage:Bool;

	// Ini settings options
	var ConfigIniSettingsSaveLastUsedDate:Bool;
	var ConfigIniSettingsAutoDiscardMonths:Int;
	var ConfigDebugIniSettings:Bool;

	// Miscellaneous options
	var MouseDrawCursor:Bool;
	var ConfigMemoryCompactTimer:Single;

	// Inputs Behaviors
	var MouseDoubleClickTime:Single;
	var MouseDoubleClickMaxDist:Single;
	var MouseSingleClickDelay:Single;
	var MouseDragThreshold:Single;
	var KeyRepeatDelay:Single;
	var KeyRepeatRate:Single;

	// Debug options
	var ConfigErrorRecovery:Bool;
	var ConfigErrorRecoveryEnableAssert:Bool;
	var ConfigErrorRecoveryEnableDebugLog:Bool;
	var ConfigErrorRecoveryEnableTooltip:Bool;
	var ConfigDebugIsDebuggerPresent:Bool;
	var ConfigDebugHighlightIdConflicts:Bool;
	var ConfigDebugHighlightIdConflictsShowItemPicker:Bool;
	var ConfigDebugBeginReturnValueOnce:Bool;
	var ConfigDebugBeginReturnValueLoop:Bool;
	var ConfigDebugIgnoreFocusLoss:Bool;

	//------------------------------------------------------------------
	// Platform Functions
	// (the imgui_impl_xxxx backend files are setting those up for you)
	//------------------------------------------------------------------
	var BackendPlatformName:hl.Bytes;
	var BackendRendererName:hl.Bytes;
	var BackendPlatformUserData:hl.Bytes;
	var BackendRendererUserData:hl.Bytes;
	var BackendLanguageUserData:hl.Bytes;

	//------------------------------------------------------------------
	// Input - Call before calling NewFrame()
	//------------------------------------------------------------------

	/**
		Queue a new key down/up event. Key should be "translated" (as in, generally ImGuiKey_A matches the key end-user would use to emit an 'A' character)
	**/
	public function addKeyEvent(key:ImGuiKey, down:Bool) {
		io_add_key_event(this, key, down);
	} // Queue a new key down/up event. Key should be "translated" (as in, generally ImGuiKey_A matches the key end-user would use to emit an 'A' character)

	/**
		Queue a new key down/up event for analog values (e.g. ImGuiKey_Gamepad_ values). Dead-zones should be handled by the backend.
	**/
	public function addKeyAnalogEvent(key:ImGuiKey, down:Bool, v:Single) {
		io_add_key_analog_event(this, key, down, v);
	} // Queue a new key down/up event for analog values (e.g. ImGuiKey_Gamepad_ values). Dead-zones should be handled by the backend.

	/**
		Queue a mouse position update. Use -FLT_MAX,-FLT_MAX to signify no mouse (e.g. app not focused and not hovered)
	**/
	public function addMousePosEvent(x:Single, y:Single) {
		io_add_mouse_pos_event(this, x, y);
	} // Queue a mouse position update. Use -FLT_MAX,-FLT_MAX to signify no mouse (e.g. app not focused and not hovered)

	/**
		Queue a mouse button change.
	**/
	public function addMouseButtonEvent(button:Int, down:Bool) {
		io_add_mouse_button_event(this, button, down);
	} // Queue a mouse button change

	/**
		Queue a mouse wheel update. wheel_y<0: scroll down, wheel_y>0: scroll up, wheel_x<0: scroll right, wheel_x>0: scroll left.
	**/
	public function addMouseWheelEvent(wheel_x:Single, wheel_y:Single) {
		io_add_mouse_wheel_event(this, wheel_x, wheel_y);
	} // Queue a mouse wheel update. wheel_y<0: scroll down, wheel_y>0: scroll up, wheel_x<0: scroll right, wheel_x>0: scroll left.

	/**
		Queue a mouse hovered viewport. Requires backend to set ImGuiBackendFlags_HasMouseHoveredViewport to call this (for multi-viewport support).
	**/
	public function addMouseViewportEvent(id:ImGuiID) {
		io_add_mouse_viewport_event(this, id);
	} // Queue a mouse hovered viewport. Requires backend to set ImGuiBackendFlags_HasMouseHoveredViewport to call this (for multi-viewport support).

	/**
		Queue a gain/loss of focus for the application (generally based on OS/platform focus of your window)
	**/
	public function addFocusEvent(focused:Bool) {
		io_add_focus_event(this, focused);
	} // Queue a gain/loss of focus for the application (generally based on OS/platform focus of your window)

	/**
		Queue a new character input.
	**/
	public function addInputCharacter(c:Int) {
		io_add_input_character(this, c);
	} // Queue a new character input

	/**
		Queue a new character input from a UTF-16 character, it can be a surrogate.
	**/
	public function addInputCharacterUTF16(c:Int) {
		io_add_input_character_utf16(this, c);
	} // Queue a new character input from a UTF-16 character, it can be a surrogate

	/**
		Queue a new characters input from a UTF-8 string.
	**/
	public function addInputCharactersUTF8(chars:String) {
		io_add_input_characters_utf8(this, chars);
	} // Queue a new characters input from a UTF-8 string

	// No, I have no idea why the utf8 variant accepts multiple characters...
	// [Optional] Specify index for legacy <1.87 IsKeyXXX() functions with native indices + specify native keycode, scancode.

	/**
		[Optional] Specify index for legacy <1.87 IsKeyXXX() functions with native indices + specify native keycode, scancode.
	**/
	public function setKeyEventNativeData(key:ImGuiKey, native_keycode:Int, native_scancode:Int, native_legacy:Int = -1) {
		io_set_key_event_native_data(this, key, native_keycode, native_scancode, native_legacy);
	}

	/**
		Set master flag for accepting key/mouse/text events (default to true). Useful if you have native dialog boxes that are interrupting your application loop/refresh, and you want to disable events being queued while your app is frozen.
	**/
	public function setAppAcceptingEvents(accepting_events:Bool) {
		io_set_app_accepting_events(this, accepting_events);
	} // Set master flag for accepting key/mouse/text events (default to true). Useful if you have native dialog boxes that are interrupting your application loop/refresh, and you want to disable events being queued while your app is frozen.

	/**
		Clears input characters.
	**/
	public function clearInputCharacters() {
		io_clear_input_characters(this);
	} // Set master flag for accepting key/mouse/text events (default to true). Useful if you have native dialog boxes that are interrupting your application loop/refresh, and you want to disable events being queued while your app is frozen.

	/**
		Clear current keyboard/gamepad state + current frame text input buffer. Equivalent to releasing all keys/buttons.
	**/
	public function clearInputKeys() {
		io_clear_input_keys(this);
	} // Set master flag for accepting key/mouse/text events (default to true). Useful if you have native dialog boxes that are interrupting your application loop/refresh, and you want to disable events being queued while your app is frozen.

	static function io_add_key_event(io:ImGuiIO, key:ImGuiKey, down:Bool) {}

	static function io_add_key_analog_event(io:ImGuiIO, key:ImGuiKey, down:Bool, v:Single) {}

	static function io_add_mouse_pos_event(io:ImGuiIO, x:Single, y:Single) {}

	static function io_add_mouse_button_event(io:ImGuiIO, button:Int, down:Bool) {}

	static function io_add_mouse_wheel_event(io:ImGuiIO, wheel_x:Single, wheel_y:Single) {}

	static function io_add_mouse_viewport_event(io:ImGuiIO, id:ImGuiID) {}

	static function io_add_focus_event(io:ImGuiIO, focused:Bool) {}

	static function io_add_input_character(io:ImGuiIO, c:Int) {}

	static function io_add_input_character_utf16(io:ImGuiIO, c:Int) {}

	static function io_add_input_characters_utf8(io:ImGuiIO, chars:String) {}

	static function io_set_key_event_native_data(io:ImGuiIO, key:ImGuiKey, native_keycode:Int, native_scancode:Int, native_legacy:Int) {}

	static function io_set_app_accepting_events(io:ImGuiIO, accepting_events:Bool) {}

	static function io_clear_input_characters(io:ImGuiIO) {}

	static function io_clear_input_keys(io:ImGuiIO) {}

	//------------------------------------------------------------------
	// Output - Updated by NewFrame() or EndFrame()/Render()
	// (when reading from the io.WantCaptureMouse, io.WantCaptureKeyboard flags to dispatch your inputs, it is
	//  generally easier and more correct to use their state BEFORE calling NewFrame(). See FAQ for details!)
	//------------------------------------------------------------------
	var WantCaptureMouse:Bool; // Set when Dear ImGui will use mouse inputs, in this case do not dispatch them to your main game/application (either way, always pass on mouse inputs to imgui). (e.g. unclicked mouse is hovering over an imgui window, widget is active, mouse was clicked over an imgui window, etc.).
	var WantCaptureKeyboard:Bool; // Set when Dear ImGui will use keyboard inputs, in this case do not dispatch them to your main game/application (either way, always pass keyboard inputs to imgui). (e.g. InputText active, or an imgui window is focused and navigation is enabled, etc.).
	var WantTextInput:Bool; // Mobile/console: when set, you may display an on-screen keyboard. This is set by Dear ImGui when it wants textual keyboard input to happen (e.g. when a InputText widget is active).
	var WantSetMousePos:Bool; // MousePos has been altered, backend should reposition mouse on next frame. Rarely used! Set only when ImGuiConfigFlags_NavEnableSetMousePos flag is enabled.
	var WantSaveIniSettings:Bool; // When manual .ini load/save is active (io.IniFilename == NULL), this will be set to notify your application that you can call SaveIniSettingsToMemory() and save yourself. Important: clear io.WantSaveIniSettings yourself after saving!
	var NavActive:Bool; // Keyboard/Gamepad navigation is currently allowed (will handle ImGuiKey_NavXXX events) = a window is focused and it doesn't use the ImGuiWindowFlags_NoNavInputs flag.
	var NavVisible:Bool; // Keyboard/Gamepad navigation is visible and allowed (will handle ImGuiKey_NavXXX events).
	var Framerate:Single; // Estimate of application framerate (rolling average over 60 frames, based on io.DeltaTime), in frame per second. Solely for convenience. Slow applications may not want to use a moving average or may want to reset underlying buffers occasionally.
	var MetricsRenderVertices:Int; // Vertices output during last call to Render()
	var MetricsRenderIndices:Int; // Indices output during last call to Render() = number of triangles * 3
	var MetricsRenderWindows:Int; // Number of visible windows
	var MetricsActiveWindows:Int; // Number of active windows
	@:flatten var MouseDelta:ImVec2S; // Mouse delta. Note that this is zero if either current or previous position are invalid (-FLT_MAX,-FLT_MAX), so a disappearing/reappearing mouse won't have a huge delta.

	//------------------------------------------------------------------
	// [Internal] Dear ImGui will maintain those fields. Forward compatibility not guaranteed!
	//------------------------------------------------------------------
	// Main Input State
	// (this block used to be written by backend, since 1.87 it is best to NOT write to those directly, call the AddXXX functions above instead)
	// (reading from those variables is fair game, as they are extremely unlikely to be moving anywhere)
	@:noCompletion var Ctx:hl.Bytes;
	@:flatten var MousePos:ImVec2S;
	// @todo: This is broken
	// @:flattenMap(ImGuiMouseButton) var MouseDown: Bool;
	// gross hack instead
	var MouseDown_Left:Bool;
	var MouseDown_Right:Bool;
	var MouseDown_Middle:Bool;
	var MouseDown_AltA:Bool;
	var MouseDown_AltB:Bool;
	// end hack
	var MouseWheel:Single;
	var MouseWheelH:Single;
	var MouseSource:Int;
	var MouseHoveredViewport:ImGuiID;
	var KeyCtrl:Bool;
	var KeyShift:Bool;
	var KeyAlt:Bool;
	var KeySuper:Bool;

	var KeyMods:ImGuiKeyChord;
	// @todo: We need a way to expose the key map here to go any further.
}

@:keep
@:build(imgui._ImGuiInternalMacro.buildFlatStruct())
@:hlNative("hlimgui")
@:struct class ImGuiPlatformIO {
	// MSVC throws errors on empty structures
	private var __placeholder:Int;

	// Internal functions. We don't bother passing the ptr here since we can only ever
	// have one PlatformIO instance.
	static function platformioSetPlatformCreateWindow(func:ImGuiViewport -> Void) {};

	static function platformioSetPlatformDestroyWindow(func:ImGuiViewport -> Void) {};

	static function platformioSetPlatformShowWindow(func:ImGuiViewport -> Void) {};

	static function platformioSetPlatformSetWindowPos(func:(ImGuiViewport, ImVec2) -> Void) {};

	static function platformioSetPlatformGetWindowPos(func:(ImGuiViewport, ImGuiVec2Struct) -> Void) {};

	static function platformioSetPlatformSetWindowSize(func:(ImGuiViewport, ImVec2) -> Void) {};

	static function platformioSetPlatformGetWindowSize(func:(ImGuiViewport, ImGuiVec2Struct) -> Void) {};

	static function platformioSetPlatformSetWindowFocus(func:ImGuiViewport -> Void) {};

	static function platformioSetPlatformGetWindowFocus(func:ImGuiViewport -> Bool) {};

	static function platformioSetPlatformGetWindowMinimized(func:ImGuiViewport -> Bool) {};

	static function platformioSetPlatformSetWindowTitle(func:(ImGuiViewport, hl.Bytes) -> Void) {};

	static function platformioSetPlatformSetWindowAlpha(func:(ImGuiViewport, Single) -> Void) {};

	static function platformioSetRendererRenderWindow(func:(ImGuiViewport, Dynamic) -> Void) {};

	static function platformioSetRendererSwapBuffers(func:(ImGuiViewport, Dynamic) -> Void) {};

	// Utils
	static function platformioAddMonitor(size:ImVec2S, pos:ImVec2S) {};

	static function platformioSetMainViewport(w:Dynamic):ImGuiViewport {
		return null;
	};

	// haxe setters

	/**
		Controls platform create window.
	**/
	public var Platform_CreateWindow(never, set):ImGuiViewport -> Void;

	/**
		Controls platform destroy window.
	**/
	public var Platform_DestroyWindow(never, set):ImGuiViewport -> Void;

	/**
		Controls platform show window.
	**/
	public var Platform_ShowWindow(never, set):ImGuiViewport -> Void;

	/**
		Controls platform set window position.
	**/
	public var Platform_SetWindowPos(never, set):(ImGuiViewport, ImVec2) -> Void;

	/**
		Controls platform get window position.
	**/
	public var Platform_GetWindowPos(never, set):(ImGuiViewport, ImGuiVec2Struct) -> Void;

	/**
		The platform set window size.
	**/
	public var Platform_SetWindowSize(never, set):(ImGuiViewport, ImVec2) -> Void;

	/**
		The platform get window size.
	**/
	public var Platform_GetWindowSize(never, set):(ImGuiViewport, ImGuiVec2Struct) -> Void;

	/**
		Controls platform set window focus.
	**/
	public var Platform_SetWindowFocus(never, set):ImGuiViewport -> Void;

	/**
		Controls platform get window focus.
	**/
	public var Platform_GetWindowFocus(never, set):ImGuiViewport -> Bool;

	/**
		Controls platform get window minimized.
	**/
	public var Platform_GetWindowMinimized(never, set):ImGuiViewport -> Bool;

	/**
		Controls platform set window title.
	**/
	public var Platform_SetWindowTitle(never, set):(ImGuiViewport, hl.Bytes) -> Void;

	/**
		Controls platform set window alpha.
	**/
	public var Platform_SetWindowAlpha(never, set):(ImGuiViewport, Single) -> Void;

	/**
		Controls renderer render window.
	**/
	public var Renderer_RenderWindow(never, set):(ImGuiViewport, Dynamic) -> Void;

	/**
		Controls renderer swap buffers.
	**/
	public var Renderer_SwapBuffers(never, set):(ImGuiViewport, Dynamic) -> Void;

	inline function set_Platform_CreateWindow(func:ImGuiViewport -> Void):ImGuiViewport -> Void {
		platformioSetPlatformCreateWindow(func);
		return func;
	};

	inline function set_Platform_DestroyWindow(func:ImGuiViewport -> Void):ImGuiViewport -> Void {
		platformioSetPlatformDestroyWindow(func);
		return func;
	}

	inline function set_Platform_ShowWindow(func:ImGuiViewport -> Void):ImGuiViewport -> Void {
		platformioSetPlatformShowWindow(func);
		return func;
	}

	inline function set_Platform_SetWindowPos(func:(ImGuiViewport, ImVec2) -> Void):(ImGuiViewport, ImVec2) -> Void {
		platformioSetPlatformSetWindowPos(func);
		return func;
	}

	inline function set_Platform_GetWindowPos(func:(ImGuiViewport, ImGuiVec2Struct) -> Void):(ImGuiViewport, ImGuiVec2Struct) -> Void {
		platformioSetPlatformGetWindowPos(func);
		return func;
	}

	inline function set_Platform_SetWindowSize(func:(ImGuiViewport, ImVec2) -> Void):(ImGuiViewport, ImVec2) -> Void {
		platformioSetPlatformSetWindowSize(func);
		return func;
	}

	inline function set_Platform_GetWindowSize(func:(ImGuiViewport, ImGuiVec2Struct) -> Void):(ImGuiViewport, ImGuiVec2Struct) -> Void {
		platformioSetPlatformGetWindowSize(func);
		return func;
	}

	inline function set_Platform_SetWindowFocus(func:ImGuiViewport -> Void):ImGuiViewport -> Void {
		platformioSetPlatformSetWindowFocus(func);
		return func;
	}

	inline function set_Platform_GetWindowFocus(func:ImGuiViewport -> Bool):ImGuiViewport -> Bool {
		platformioSetPlatformGetWindowFocus(func);
		return func;
	}

	inline function set_Platform_GetWindowMinimized(func:ImGuiViewport -> Bool):ImGuiViewport -> Bool {
		platformioSetPlatformGetWindowMinimized(func);
		return func;
	}

	inline function set_Platform_SetWindowTitle(func:(ImGuiViewport, hl.Bytes) -> Void):(ImGuiViewport, hl.Bytes) -> Void {
		platformioSetPlatformSetWindowTitle(func);
		return func;
	}

	inline function set_Platform_SetWindowAlpha(func:(ImGuiViewport, Single) -> Void):(ImGuiViewport, Single) -> Void {
		platformioSetPlatformSetWindowAlpha(func);
		return func;
	}

	inline function set_Renderer_RenderWindow(func:(ImGuiViewport, Dynamic) -> Void):(ImGuiViewport, Dynamic) -> Void {
		platformioSetRendererRenderWindow(func);
		return func;
	}

	inline function set_Renderer_SwapBuffers(func:(ImGuiViewport, Dynamic) -> Void):(ImGuiViewport, Dynamic) -> Void {
		platformioSetRendererSwapBuffers(func);
		return func;
	}

	// Utils

	/**
		Adds monitor.
	**/
	public function addMonitor(size:ImVec2S, pos:ImVec2S):Void
		platformioAddMonitor(size, pos);

	/**
		Sets main viewport.
	**/
	public function setMainViewport(window:Dynamic):ImGuiViewport
		return platformioSetMainViewport(window);
}

/**
	Public alias of `imgui.types.ImFontAtlas.ImFontConfig`.
**/
typedef ImFontConfig = imgui.types.ImFontAtlas.ImFontConfig;

// Callbacks

/**
	@return `0` for success of the callback.
**/
typedef ImGuiInputTextCallbackDataFunc = (ImGuiInputTextCallbackData) -> Int;

/**
	Editable text state passed to an input-text callback.
**/
@:keep
@:struct @:hlNative("hlimgui")
class ImGuiInputTextCallbackData {
	/**
		One ImGuiInputTextFlags_Callback* // Read-only.
	**/
	public var eventFlag:ImGuiInputTextFlags; // One ImGuiInputTextFlags_Callback*    // Read-only

	/**
		What user passed to InputText() // Read-only.
	**/
	public var flags:ImGuiInputTextFlags; // What user passed to InputText()      // Read-only

	var unused:hl.Bytes; // Internally used pointer to the callback func.

	/**
		Character input // Read-write // [CharFilter] Replace character with another one, or set to zero to drop. return 1 is equivalent to setting EventChar=0;.
	**/
	public var eventChar:hl.UI16; // Character input                      // Read-write   // [CharFilter] Replace character with another one, or set to zero to drop. return 1 is equivalent to setting EventChar=0;

	/**
		Key pressed (Up/Down/TAB) // Read-only // [Completion,History].
	**/
	public var eventKey:Int; // Key pressed (Up/Down/TAB)            // Read-only    // [Completion,History]

	/**
		Text buffer // Read-write // [Resize] Can replace pointer / [Completion,History,Always] Only write to pointed data, don't replace the actual pointer!
	**/
	public var buf:hl.Bytes; // Text buffer                          // Read-write   // [Resize] Can replace pointer / [Completion,History,Always] Only write to pointed data, don't replace the actual pointer!

	/**
		Text length (in bytes) // Read-write // [Resize,Completion,History,Always] Exclude zero-terminator storage. In C land: == strlen(some_text), in C++ land: string.length()
	**/
	public var bufTextLen:Int; // Text length (in bytes)               // Read-write   // [Resize,Completion,History,Always] Exclude zero-terminator storage. In C land: == strlen(some_text), in C++ land: string.length()

	/**
		Buffer size (in bytes) = capacity+1 // Read-only // [Resize,Completion,History,Always] Include zero-terminator storage. In C land == ARRAYSIZE(my_char_array), in C++ land: string.capacity()+1.
	**/
	public var bufSize:Int; // Buffer size (in bytes) = capacity+1  // Read-only    // [Resize,Completion,History,Always] Include zero-terminator storage. In C land == ARRAYSIZE(my_char_array), in C++ land: string.capacity()+1

	/**
		Set if you modify Buf/BufTextLen! // Write // [Completion,History,Always].
	**/
	public var bufDirty:Bool; // Set if you modify Buf/BufTextLen!    // Write        // [Completion,History,Always]

	/**
		Read-write // [Completion,History,Always].
	**/
	public var cursorPos:Int; //                                      // Read-write   // [Completion,History,Always]

	/**
		Read-write // [Completion,History,Always] == to SelectionEnd when no selection)
	**/
	public var selectionStart:Int; //                                      // Read-write   // [Completion,History,Always] == to SelectionEnd when no selection)

	/**
		Read-write // [Completion,History,Always].
	**/
	public var selectionEnd:Int; //                                      // Read-write   // [Completion,History,Always]

	/**
		Helper method to calculate byte position of a character at position `pos` in Unicode string.
	**/
	public function utfCharPos(pos:Int, startAt:Int = 0):Int {
		var i = startAt;
		var p = 0;
		while (++p < pos) {
			var c = buf[i];
			if (c < 0x80) {
				if (c == 0)
					return i;
				i++;
			} else if (c < 0xC0)
				return i;
			else if (c < 0xE0) {
				if ((buf[i + 1] & 0x80) == 0)
					return i;
				i += 2;
			} else if (c < 0xF0) {
				if ((buf[i + 1] & buf[i + 2] & 0x80) == 0)
					return i;
				i += 3;
			} else if (c < 0xF8) {
				if ((buf[i + 1] & buf[i + 2] & buf[i + 3] & 0x80) == 0)
					return i;
				p++;
				i += 4;
			} else
				return i;
		}
		return i;
	}

	/**
		Helper method to delete N UTF-8 characters instead of N bytes
		@param pos The character position inside the string. (Not byte position)
		@param charCount The amount of UTF-8 character to delete. Pass -1 to delete everything past `pos`.
	**/
	public function deleteCharsUnicode(pos:Int, charCount:Int) {
		pos = utfCharPos(pos);
		if (charCount == -1) {
			deleteChars(pos, bufTextLen - pos);
			return;
		}
		deleteChars(pos, utfCharPos(charCount, pos));
	}

	/**
		Helper method to insert `text` at the UTF-8 character position instead of byte position.
	**/
	public function insertCharsUnicode(pos:Int, text:String) {
		insertChars(utfCharPos(pos), text);
	}

	/**
		Deletes `bytesCount` bytes starting at `pos` position from the text buffer.
	**/
	public inline function deleteChars(pos:Int, bytesCount:Int)
		input_text_callback_delete_chars(this, pos, bytesCount);

	/**
		Inserts `text` at `pos` byte position in the text buffer.
	**/
	public inline function insertChars(pos:Int, text:String)
		input_text_callback_insert_chars(this, pos, text);

	/**
		Selects all editable text or items in the current scope.
	**/
	public function selectAll() {
		selectionStart = 0;
		selectionEnd = bufTextLen;
	}

	/**
		Clears selection.
	**/
	public function clearSelection() {
		selectionStart = selectionEnd = bufTextLen;
	}

	/**
		Returns whether selection.
	**/
	public function hasSelection() {
		return selectionStart != selectionEnd;
	}

	static function input_text_callback_delete_chars(data:ImGuiInputTextCallbackData, pos:Int, bytes_count:Int) {}

	static function input_text_callback_insert_chars(data:ImGuiInputTextCallbackData, pos:Int, text:String) {}
}

/**
	Low-level drawing API for submitting shapes, text, and images.
**/
typedef ImDrawList = imgui.types.ImDrawList;

/**
	Splits a draw list into channels that can be reordered and merged.
**/
typedef ImDrawListSplitter = imgui.types.ImDrawList.ImDrawListSplitter;

/**
	Loaded Dear ImGui font handle.
**/
typedef ImFont = imgui.types.ImFont;

/**
	Font and texture atlas used by the current Dear ImGui context.
**/
typedef ImFontAtlas = imgui.types.ImFontAtlas;

/**
	Helper that submits only the visible range of large uniformly sized lists.
**/
typedef ImGuiListClipper = imgui.types.ImGuiListClipper;

/**
	Public alias of `imgui.types.ImGuiDockNode`.
**/
typedef ImGuiDockNode = imgui.types.ImGuiDockNode;

@:keep
@:build(imgui._ImGuiInternalMacro.buildFlatStruct())
@:hlNative("hlimgui")
@:struct class ImGuiVec2Struct {
	/**
		Horizontal component.
	**/
	public var x:Single;

	/**
		Gets or sets y.
	**/
	public var y:Single;
}

@:keep
@:build(imgui._ImGuiInternalMacro.buildFlatStruct())
@:hlNative("hlimgui")
@:struct class ImGuiViewport {
	/**
		Widget ID // Read-only.
	**/
	public var ID:ImGuiID;

	/**
		What user passed to InputText() // Read-only.
	**/
	public var Flags:ImGuiViewportFlags;

	/**
		Read-only. Window position, for reference.
	**/
	@:flatten public var Pos:ImVec2S;

	/**
		Full viewport size in screen coordinates.
	**/
	@:flatten public var Size:ImVec2S;

	/**
		Amount of pixels for each unit of DisplaySize. Copied from viewport->FramebufferScale (== io.DisplayFramebufferScale for main viewport). Generally (1,1) on normal display, (2,2) on OSX with Retina display.
	**/
	@:flatten public var FramebufferScale:ImVec2S;

	/**
		Work Area: Position of the viewport minus task bars, menus bars, status bars (>= Pos)
	**/
	@:flatten public var WorkPos:ImVec2S;

	/**
		Work Area: Size of the viewport minus task bars, menu bars, status bars (<= Size)
	**/
	@:flatten public var WorkSize:ImVec2S;

	/**
		1.0f = 96 DPI = No extra scale.
	**/
	public var DpiScale:Single;

	/**
		Hint for the platform backend. -1: use default. 0: request platform backend to not parent the platform. != 0: request platform backend to create a parent<>child relationship between the platform windows. Not conforming backends are free to e.g. parent every viewport to the main viewport or not.
	**/
	public var ParentViewportId:ImGuiID;

	@:noCompletion public var ParentViewport:hl.Bytes; // ImGuiViewport*
	@:noCompletion public var DrawData:hl.Bytes; // ImDrawData*

	@:noCompletion public var RendererUserData:hl.Bytes; // void*

	/**
		Void*.
	**/
	public var PlatformUserData:h3d.Engine; // void*

	@:noCompletion public var PlatformIconData:hl.Bytes; // void*

	/**
		Void*.
	**/
	public var PlatformHandle:hxd.Window; // void*

	@:noCompletion public var PlatformHandleRaw:Dynamic; // void*

	/**
		Platform window has been created (Platform_CreateWindow() has been called). This is false during the first frame where a viewport is being created.
	**/
	public var PlatformWindowCreated:Bool; // Platform window has been created (Platform_CreateWindow() has been called). This is false during the first frame where a viewport is being created.

	/**
		Platform window requested move (e.g. window was moved by the OS / host window manager, authoritative position will be OS window position)
	**/
	public var PlatformRequestMove:Bool; // Platform window requested move (e.g. window was moved by the OS / host window manager, authoritative position will be OS window position)

	/**
		Platform window requested resize (e.g. window was resized by the OS / host window manager, authoritative size will be OS window size)
	**/
	public var PlatformRequestResize:Bool; // Platform window requested resize (e.g. window was resized by the OS / host window manager, authoritative size will be OS window size)

	/**
		Platform window requested closure (e.g. window was moved by the OS / host window manager, e.g. pressing ALT-F4)
	**/
	public var PlatformRequestClose:Bool; // Platform window requested closure (e.g. window was moved by the OS / host window manager, e.g. pressing ALT-F4)

}

@:keep
@:build(imgui._ImGuiInternalMacro.buildFlatStruct())
@:hlNative("hlimgui")
@:struct class ImGuiWindowClass {
	/**
		User data. 0 = Default class (unclassed). Windows of different classes cannot be docked with each others.
	**/
	public var ClassId:ImGuiID;

	/**
		Hint for the platform backend. -1: use default. 0: request platform backend to not parent the platform. != 0: request platform backend to create a parent<>child relationship between the platform windows. Not conforming backends are free to e.g. parent every viewport to the main viewport or not.
	**/
	public var ParentViewportId:ImGuiID;

	/**
		ID of parent window for shortcut focus route evaluation, e.g. Shortcut() call from Parent Window will succeed when this window is focused.
	**/
	public var FocusRouteParentWindowId:ImGuiID;

	/**
		Viewport flags to set when a window of this class owns a viewport. This allows you to enforce OS decoration or task bar icon, override the defaults on a per-window basis.
	**/
	public var ViewportFlagsOverrideSet:ImGuiViewportFlags;

	/**
		Viewport flags to clear when a window of this class owns a viewport. This allows you to enforce OS decoration or task bar icon, override the defaults on a per-window basis.
	**/
	public var ViewportFlagsOverrideClear:ImGuiViewportFlags;

	/**
		[EXPERIMENTAL] TabItem flags to set when a window of this class gets submitted into a dock node tab bar. May use with ImGuiTabItemFlags_Leading or ImGuiTabItemFlags_Trailing.
	**/
	public var TabItemFlagsOverrideSet:ImGuiTabItemFlags;

	/**
		[EXPERIMENTAL] Dock node flags to set when a window of this class is hosted by a dock node (it doesn't have to be selected!)
	**/
	public var DockNodeFlagsOverrideSet:ImGuiDockNodeFlags;

	/**
		Set to true to enforce single floating windows of this class always having their own docking node (equivalent of setting the global io.ConfigDockingAlwaysTabBar)
	**/
	public var DockingAlwaysTabBar:Bool;

	/**
		Set to true to allow windows of this class to be docked/merged with an unclassed window. // FIXME-DOCK: Move to DockNodeFlags override?
	**/
	public var DockingAllowUnclassed:Bool;

	@:noCompletion var PlatformIconData:hl.Bytes;

	/**
		Creates a window-class configuration initialized to Dear ImGui defaults.
	**/
	public function new() {
		init_window_class(this);
	}

	static function init_window_class(window_class:ImGuiWindowClass):Void {}
}

/**
	One selection update requested by a multi-select widget.
**/
@:hlNative("hlimgui")
abstract ImGuiSelectionRequest(ImGuiSelectionRequestPtr) from ImGuiSelectionRequestPtr to ImGuiSelectionRequestPtr {
	/**
		Kind of selection change requested.
	**/
	public var type(get, never):ImGuiSelectionRequestType;

	/**
		Whether selected.
	**/
	public var selected(get, never):Bool;

	/**
		Gets or sets range direction.
	**/
	public var rangeDirection(get, never):Int;

	/**
		Gets or sets range first item.
	**/
	public var rangeFirstItem(get, never):ImGuiSelectionUserData;

	/**
		Gets or sets range last item.
	**/
	public var rangeLastItem(get, never):ImGuiSelectionUserData;

	inline function get_type():ImGuiSelectionRequestType
		return selection_request_get_type(this);

	inline function get_selected():Bool
		return selection_request_get_selected(this);

	inline function get_rangeDirection():Int
		return selection_request_get_range_direction(this);

	inline function get_rangeFirstItem():ImGuiSelectionUserData
		return selection_request_get_range_first_item(this);

	inline function get_rangeLastItem():ImGuiSelectionUserData
		return selection_request_get_range_last_item(this);

	static function selection_request_get_type(request:ImGuiSelectionRequestPtr):ImGuiSelectionRequestType
		return 0;

	static function selection_request_get_selected(request:ImGuiSelectionRequestPtr):Bool
		return false;

	static function selection_request_get_range_direction(request:ImGuiSelectionRequestPtr):Int
		return 0;

	static function selection_request_get_range_first_item(request:ImGuiSelectionRequestPtr):ImGuiSelectionUserData
		return 0;

	static function selection_request_get_range_last_item(request:ImGuiSelectionRequestPtr):ImGuiSelectionUserData
		return 0;
}

// Valid only for the current multi-select block and frame.

/**
	Selection requests and state exchanged with a multi-select scope.
**/
@:hlNative("hlimgui")
abstract ImGuiMultiSelectIO(ImGuiMultiSelectIOPtr) from ImGuiMultiSelectIOPtr to ImGuiMultiSelectIOPtr {
	/**
		The requests count.
	**/
	public var requestsCount(get, never):Int;

	/**
		Gets or sets range src item.
	**/
	public var rangeSrcItem(get, never):ImGuiSelectionUserData;

	/**
		Gets or sets nav id item.
	**/
	public var navIdItem(get, never):ImGuiSelectionUserData;

	/**
		Whether nav id selected.
	**/
	public var navIdSelected(get, never):Bool;

	/**
		Whether range src reset.
	**/
	public var rangeSrcReset(get, set):Bool;

	/**
		The items count.
	**/
	public var itemsCount(get, never):Int;

	/**
		Returns request.
	**/
	public inline function getRequest(index:Int):ImGuiSelectionRequest {
		return multi_select_io_get_request(this, index);
	}

	inline function get_requestsCount():Int
		return multi_select_io_get_requests_count(this);

	inline function get_rangeSrcItem():ImGuiSelectionUserData
		return multi_select_io_get_range_src_item(this);

	inline function get_navIdItem():ImGuiSelectionUserData
		return multi_select_io_get_nav_id_item(this);

	inline function get_navIdSelected():Bool
		return multi_select_io_get_nav_id_selected(this);

	inline function get_rangeSrcReset():Bool
		return multi_select_io_get_range_src_reset(this);

	inline function set_rangeSrcReset(value:Bool):Bool {
		multi_select_io_set_range_src_reset(this, value);
		return value;
	}

	inline function get_itemsCount():Int
		return multi_select_io_get_items_count(this);

	static function multi_select_io_get_requests_count(io:ImGuiMultiSelectIOPtr):Int
		return 0;

	static function multi_select_io_get_request(io:ImGuiMultiSelectIOPtr, index:Int):ImGuiSelectionRequestPtr
		return null;

	static function multi_select_io_get_range_src_item(io:ImGuiMultiSelectIOPtr):ImGuiSelectionUserData
		return 0;

	static function multi_select_io_get_nav_id_item(io:ImGuiMultiSelectIOPtr):ImGuiSelectionUserData
		return 0;

	static function multi_select_io_get_nav_id_selected(io:ImGuiMultiSelectIOPtr):Bool
		return false;

	static function multi_select_io_get_range_src_reset(io:ImGuiMultiSelectIOPtr):Bool
		return false;

	static function multi_select_io_set_range_src_reset(io:ImGuiMultiSelectIOPtr, value:Bool):Void {}

	static function multi_select_io_get_items_count(io:ImGuiMultiSelectIOPtr):Int
		return 0;
}

/**
	Sort direction and priority for one table column.
**/
@:hlNative("hlimgui")
abstract ImGuiTableColumnSortSpecs(ImGuiTableColumnSortSpecsPtr) from ImGuiTableColumnSortSpecsPtr to ImGuiTableColumnSortSpecsPtr {
	/**
		Gets or sets column user id.
	**/
	public var columnUserID(get, never):ImGuiID;

	/**
		Gets or sets column index.
	**/
	public var columnIndex(get, never):Int;

	/**
		Gets or sets sort order.
	**/
	public var sortOrder(get, never):Int;

	/**
		Gets or sets sort direction.
	**/
	public var sortDirection(get, never):ImGuiSortDirection;

	inline function get_columnUserID():ImGuiID
		return table_column_sort_specs_get_column_user_id(this);

	inline function get_columnIndex():Int
		return table_column_sort_specs_get_column_index(this);

	inline function get_sortOrder():Int
		return table_column_sort_specs_get_sort_order(this);

	inline function get_sortDirection():ImGuiSortDirection
		return table_column_sort_specs_get_sort_direction(this);

	static function table_column_sort_specs_get_column_user_id(specs:ImGuiTableColumnSortSpecsPtr):ImGuiID
		return 0;

	static function table_column_sort_specs_get_column_index(specs:ImGuiTableColumnSortSpecsPtr):Int
		return 0;

	static function table_column_sort_specs_get_sort_order(specs:ImGuiTableColumnSortSpecsPtr):Int
		return 0;

	static function table_column_sort_specs_get_sort_direction(specs:ImGuiTableColumnSortSpecsPtr):ImGuiSortDirection
		return 0;
}

/**
	Valid until the next BeginTable() call or the end of the current frame.
**/
@:hlNative("hlimgui")
abstract ImGuiTableSortSpecs(ImGuiTableSortSpecsPtr) from ImGuiTableSortSpecsPtr to ImGuiTableSortSpecsPtr {
	/**
		The specs count.
	**/
	public var specsCount(get, never):Int;

	/**
		Whether specs dirty.
	**/
	public var specsDirty(get, set):Bool;

	/**
		Returns spec.
	**/
	public inline function getSpec(index:Int):ImGuiTableColumnSortSpecs {
		return table_sort_specs_get_spec(this, index);
	}

	inline function get_specsCount():Int
		return table_sort_specs_get_specs_count(this);

	inline function get_specsDirty():Bool
		return table_sort_specs_get_specs_dirty(this);

	inline function set_specsDirty(value:Bool):Bool {
		table_sort_specs_set_specs_dirty(this, value);
		return value;
	}

	static function table_sort_specs_get_specs_count(specs:ImGuiTableSortSpecsPtr):Int
		return 0;

	static function table_sort_specs_get_specs_dirty(specs:ImGuiTableSortSpecsPtr):Bool
		return false;

	static function table_sort_specs_set_specs_dirty(specs:ImGuiTableSortSpecsPtr, value:Bool):Void {}

	static function table_sort_specs_get_spec(specs:ImGuiTableSortSpecsPtr, index:Int):ImGuiTableColumnSortSpecsPtr
		return null;
}

/**
	Opaque context-owned draw-list state. Do not retain it after destroying the ImGui context.
**/
abstract ImDrawListSharedData(ImDrawListSharedDataPtr) from ImDrawListSharedDataPtr to ImDrawListSharedDataPtr {}

/**
	Key-value state storage associated with a Dear ImGui window.
**/
@:hlNative("hlimgui")
abstract ImStateStorage(ImStateStoragePtr) from ImStateStoragePtr to ImStateStoragePtr {
	/**
		Creates a new `ImStateStorage` instance.
	**/
	public inline function new(ptr:ImStateStoragePtr) {
		this = ptr;
	}

	static function state_storage_get_int(storage:ImStateStoragePtr, id:ImGuiID, default_val:Int):Int {
		return 0;
	}

	static function state_storage_set_int(storage:ImStateStoragePtr, id:ImGuiID, val:Int):Void {}

	static function state_storage_get_bool(storage:ImStateStoragePtr, id:ImGuiID, default_val:Bool):Bool {
		return false;
	}

	static function state_storage_set_bool(storage:ImStateStoragePtr, id:ImGuiID, val:Bool):Void {}

	static function state_storage_get_float(storage:ImStateStoragePtr, id:ImGuiID, default_val:Single):Single {
		return 0;
	}

	static function state_storage_set_float(storage:ImStateStoragePtr, id:ImGuiID, val:Single):Void {}

	/**
		Sets int.
	**/
	public inline function setInt(id:ImGuiID, val:Int):Void
		state_storage_set_int(this, id, val);

	/**
		Returns int.
	**/
	public inline function getInt(id:ImGuiID, default_val:Int = 0):Int
		return state_storage_get_int(this, id, default_val);

	/**
		Sets bool.
	**/
	public inline function setBool(id:ImGuiID, val:Bool):Void
		state_storage_set_bool(this, id, val);

	/**
		Returns bool.
	**/
	public inline function getBool(id:ImGuiID, default_val:Bool = false):Bool
		return state_storage_get_bool(this, id, default_val);

	/**
		Sets float.
	**/
	public inline function setFloat(id:ImGuiID, val:Single):Void
		state_storage_set_float(this, id, val);

	/**
		Returns float.
	**/
	public inline function getFloat(id:ImGuiID, default_val:Single = 0.0):Single
		return state_storage_get_float(this, id, default_val);
}

/**
	Typed data currently carried by a drag-and-drop operation.
**/
@:hlNative("hlimgui")
abstract ImDragDropPayload(ImDragDropPayloadPtr) from ImDragDropPayloadPtr to ImDragDropPayloadPtr {
	/**
		Creates a new `ImDragDropPayload` instance.
	**/
	public inline function new(ptr:ImDragDropPayloadPtr) {
		this = ptr;
	}

	/**
		Clear selection.
	**/
	public inline function clear()
		dndpayload_clear(this);

	/**
		Returns whether data type.
	**/
	public inline function isDataType(type:String)
		return dndpayload_is_data_type(this, type);

	/**
		Whether is preview.
	**/
	public var isPreview(get, never):Bool;

	/**
		Whether is delivery.
	**/
	public var isDelivery(get, never):Bool;

	/**
		Gets or sets as binary.
	**/
	public var asBinary(get, never):hl.Bytes;

	/**
		Gets or sets as string.
	**/
	public var asString(get, never):String;

	/**
		Gets or sets as int.
	**/
	public var asInt(get, never):Int;

	/**
		Gets or sets as float.
	**/
	public var asFloat(get, never):Float;

	/**
		Whether as bool.
	**/
	public var asBool(get, never):Bool;

	/**
		@param clear If true, the stored object will be removed from gc root and could be GC collected at any time if no other references to it remained on Haxe side.
		Subsequent asObject calls would return null as well.
	**/
	public inline function asObject<T>(clear:Bool = false):T
		return dndpayload_get_object(this, clear);

	inline function get_isPreview()
		return dndpayload_is_preview(this);

	inline function get_isDelivery()
		return dndpayload_is_delivery(this);

	inline function get_asBinary()
		return dndpayload_get_binary(this);

	inline function get_asString()
		return @:privateAccess String.fromUTF8(asBinary);

	inline function get_asInt()
		return asBinary.getI32(0);

	inline function get_asFloat()
		return asBinary.getF64(0);

	inline function get_asBool()
		return asBinary[0] != 0;

	static function dndpayload_clear(payload:ImDragDropPayloadPtr) {};

	static function dndpayload_is_data_type(payload:ImDragDropPayloadPtr, type:String):Bool {
		return false;
	};

	static function dndpayload_is_preview(payload:ImDragDropPayloadPtr):Bool {
		return false;
	};

	static function dndpayload_is_delivery(payload:ImDragDropPayloadPtr):Bool {
		return false;
	};

	static function dndpayload_get_binary(payload:ImDragDropPayloadPtr):hl.Bytes {
		return null;
	}

	static function dndpayload_get_object(payload:ImDragDropPayloadPtr, clear:Bool):Dynamic {
		return null;
	}
}

/**
	Dear ImGui end-user API exposed to Haxe.
**/
@:hlNative("hlimgui")
class ImGui {
	/**
		Largest finite 32-bit floating-point value, useful as an unbounded API limit.
	**/
	public static inline var FLT_MAX = 3.402823466e+38;

	/**
		Smallest positive normalized 32-bit floating-point value.
	**/
	public static inline var FLT_MIN = 1.175494e-38;

	/**
		The fonts.
	**/
	public static final fonts = new ImGuiFonts();

	// Context

	/**
		Creates a Dear ImGui context and makes it current.
	**/
	public static function createContext():ImContextPtr {
		return null;
	}

	/**
		Destroys `ctx`, or the current context when `ctx` is omitted.
	**/
	public static function destroyContext(?ctx:ImContextPtr) {
		final destroyedContext = ctx == null ? getCurrentContext() : ctx;
		destroy_context(ctx);
		fonts.contextDestroyed(destroyedContext);
	}

	@:hlNative("hlimgui", "destroy_context")
	static function destroy_context(ctx:ImContextPtr) {}

	/**
		Returns the current Dear ImGui context, or `null` if none exists.
	**/
	public static function getCurrentContext():ImContextPtr {
		return null;
	}

	/**
		Makes `ctx` the current Dear ImGui context.
	**/
	public static function setCurrentContext(ctx:ImContextPtr) {}

	@:noCompletion public static function ensureContext():ImContextPtr {
		var context = getCurrentContext();
		if (context == null)
			context = createContext();
		return context;
	}

	// Main

	/**
		Access the ImGuiIO structure (mouse/keyboard/gamepad inputs, time, various configuration options/flags)
	**/
	public static function getIO():ImGuiIO {
		return null;
	}

	/**
		Access the ImGuiPlatformIO structure (mostly hooks/functions to connect to platform/renderer and OS Clipboard, IME etc.)
	**/
	public static function getPlatformIO():ImGuiPlatformIO {
		return null;
	}

	/**
		Access the Style structure (colors, sizes). Always use PushStyleColor(), PushStyleVar() to modify style mid-frame!
	**/
	public static function getStyle():ImGuiStyle {
		return null;
	}

	/**
		Sets style.
	**/
	public static function setStyle(style:ImGuiStyle) {}

	/**
		Start a new Dear ImGui frame, you can submit any command from this point until Render()/EndFrame().
	**/
	public static function newFrame() {}

	/**
		Ends the Dear ImGui frame. automatically called by Render(). If you don't need to render data (skipping rendering) you may call EndFrame() without Render()... but you'll have wasted CPU already! If you don't need to render, better to not create any windows and not call NewFrame() at all!
	**/
	public static function endFrame() {}

	/**
		Ends the Dear ImGui frame, finalize the draw data. You can then get call GetDrawData().
	**/
	public static function render() {}

	// Demo, Debug, Information

	/**
		Create Demo window. demonstrate most ImGui features. call this to learn about the library! try to make it always available in your application!
	**/
	public static function showDemoWindow(?open:Ref<Bool>) {}

	/**
		Create Metrics/Debugger window. display Dear ImGui internals: windows, draw commands, various internal state, etc.
	**/
	public static function showMetricsWindow(?open:Ref<Bool>) {}

	/**
		Create Debug Log window. display a simplified log of important dear imgui events.
	**/
	public static function showDebugLogWindow(?open:Ref<Bool>) {}

	/**
		Shows stack tool window.
	**/
	public static function showStackToolWindow(?open:Ref<Bool>) {}

	/**
		Create About window. display Dear ImGui version, credits and build/system information.
	**/
	public static function showAboutWindow(?open:Ref<Bool>) {}

	/**
		Add style editor block (not a window). you can pass in a reference ImGuiStyle structure to compare to, revert to and save to (else it uses the default style)
	**/
	public static function showStyleEditor(?style:ImGuiStyle) {}

	/**
		Add style selector block (not a window), essentially a combo listing the default styles.
	**/
	public static function showStyleSelector(label:String):Bool {
		return false;
	}

	/**
		Add font selector block (not a window), essentially a combo listing the loaded fonts.
	**/
	public static function showFontSelector(label:String) {}

	/**
		Add basic help/info block (not a window): how to manipulate ImGui as an end-user (mouse/keyboard controls).
	**/
	public static function showUserGuide() {}

	static function get_version():hl.Bytes {
		return null;
	}

	/**
		Get the compiled version string e.g. "1.80 WIP" (essentially the value for IMGUI_VERSION from the compiled version of imgui.cpp)
	**/
	public static inline function getVersion():String {
		return @:privateAccess String.fromUTF8(get_version());
	}

	// Styles

	/**
		New, recommended style (default)
	**/
	public static function styleColorsDark(?style:ImGuiStyle) {}

	/**
		Classic imgui style.
	**/
	public static function styleColorsClassic(?style:ImGuiStyle) {}

	/**
		Best used with borders and a custom, thicker font.
	**/
	public static function styleColorsLight(?style:ImGuiStyle) {}

	// Windows

	/**
		Starts a window and returns `false` when its contents can be skipped. Always call `end()`, regardless of the return value.
	**/
	public static function begin(name:String, ?open:Ref<Bool>, flags:ImGuiWindowFlags = 0):Bool {
		return false;
	}

	/**
		Always call `end()` regardless of `begin()` return value!
	**/
	public static function end() {}

	// Child Windows

	/**
		Starts a child scrolling and clipping region. Always call `endChild()`, regardless of the return value.
	**/
	public static extern inline overload function beginChild(str_id:String, ?size:ImVec2, childFlags:ImGuiChildFlags = 0, windowFlags:ImGuiWindowFlags = 0):Bool {
		return begin_child(str_id, size, childFlags, windowFlags);
	}

	/**
		Starts a child scrolling and clipping region. Always call `endChild()`, regardless of the return value.
	**/
	public static extern inline overload function beginChild(id:Int, ?size:ImVec2, childFlags:ImGuiChildFlags = 0, windowFlags:ImGuiWindowFlags = 0):Bool {
		return begin_child2(id, size, childFlags, windowFlags);
	}

	static function begin_child(str_id:String, ?size:ImVec2, childFlags:ImGuiChildFlags = 0, windowFlags:ImGuiWindowFlags = 0):Bool {
		return false;
	}

	static function begin_child2(id:Int, ?size:ImVec2, childFlags:ImGuiChildFlags = 0, windowFlags:ImGuiWindowFlags = 0):Bool {
		return false;
	}

	/**
		Always call `endChild()` regardless of `beginChild()` return value!
	**/
	public static function endChild() {}

	// Windows Utilities

	/**
		Returns whether window appearing.
	**/
	public static function isWindowAppearing():Bool {
		return false;
	}

	/**
		Returns whether window collapsed.
	**/
	public static function isWindowCollapsed():Bool {
		return false;
	}

	/**
		Is current window focused? or its root/child, depending on flags. see flags for options.
	**/
	public static function isWindowFocused(flags:ImGuiFocusedFlags = 0) {
		return false;
	}

	/**
		Is current window hovered and hoverable (e.g. not blocked by a popup/modal)? See ImGuiHoveredFlags_ for options. IMPORTANT: If you are trying to check whether your mouse should be dispatched to Dear ImGui or to your underlying app, you should not use this function! Use the 'io.WantCaptureMouse' boolean for that! Refer to FAQ entry "How can I tell whether to dispatch mouse/keyboard to Dear ImGui or my application?" for details.
	**/
	public static function isWindowHovered(flags:ImGuiHoveredFlags = 0) {
		return false;
	}

	/**
		Get draw list associated to the current window, to append your own drawing primitives.
	**/
	public static function getWindowDrawList():ImDrawList {
		return null;
	}

	/**
		Get DPI scale currently associated to the current window's viewport.
	**/
	public static function getWindowDpiScale():Single {
		return 0;
	}

	/**
		Get current window position in screen space (IT IS UNLIKELY YOU EVER NEED TO USE THIS. Consider always using GetCursorScreenPos() and GetContentRegionAvail() instead)
	**/
	public static function getWindowPos():ImVec2 {
		return null;
	}

	/**
		Get current window size (IT IS UNLIKELY YOU EVER NEED TO USE THIS. Consider always using GetCursorScreenPos() and GetContentRegionAvail() instead)
	**/
	public static function getWindowSize():ImVec2 {
		return null;
	}

	/**
		Get current window width (IT IS UNLIKELY YOU EVER NEED TO USE THIS). Shortcut for GetWindowSize().x.
	**/
	public static function getWindowWidth():Single {
		return 0;
	}

	/**
		Get current window height (IT IS UNLIKELY YOU EVER NEED TO USE THIS). Shortcut for GetWindowSize().y.
	**/
	public static function getWindowHeight():Single {
		return 0;
	}

	/**
		Get viewport currently associated to the current window.
	**/
	public static function getWindowViewport():ImGuiViewport {
		return null;
	}

	// Window manipulation

	/**
		Set next window position. call before Begin(). use pivot=(0.5f,0.5f) to center on given point, etc.
	**/
	public static function setNextWindowPos(pos:ImVec2, cond:ImGuiCond = 0, ?pivot:ImVec2) {}

	/**
		Set next window size. set axis to 0.0f to force an auto-fit on this axis. call before Begin()
	**/
	public static function setNextWindowSize(size:ImVec2, cond:ImGuiCond = 0) {}

	/**
		Set next window size limits. use 0.0f or FLT_MAX if you don't want limits. Use -1 for both min and max of same axis to preserve current size (which itself is a constraint). Use callback to apply non-trivial programmatic constraints.
	**/
	public static function setNextWindowSizeConstraints(size_min:ImVec2, size_max:ImVec2) {}

	/**
		Set next window content size (~ scrollable client area, which enforce the range of scrollbars). Not including window decorations (title bar, menu bar, etc.) nor WindowPadding. set an axis to 0.0f to leave it automatic. call before Begin()
	**/
	public static function setNextWindowContentSize(size:ImVec2) {}

	/**
		Set next window collapsed state. call before Begin()
	**/
	public static function setNextWindowCollapsed(collapsed:Bool, cond:ImGuiCond = 0) {}

	/**
		Set next window to be focused / top-most. call before Begin()
	**/
	public static function setNextWindowFocus() {}

	/**
		Set next window background color alpha. helper to easily override the Alpha component of ImGuiCol_WindowBg/ChildBg/PopupBg. you may also use ImGuiWindowFlags_NoBackground.
	**/
	public static function setNextWindowBgAlpha(alpha:Single) {}

	/**
		(not recommended) set current window position - call within Begin()/End(). prefer using SetNextWindowPos(), as this may incur tearing and side-effects.
	**/
	public static extern inline overload function setWindowPos(pos:ImVec2, cond:ImGuiCond = 0) {
		set_window_pos(pos, cond);
	}

	/**
		(not recommended) set current window size - call within Begin()/End(). set to ImVec2(0, 0) to force an auto-fit. prefer using SetNextWindowSize(), as this may incur tearing and minor side-effects.
	**/
	public static extern inline overload function setWindowSize(size:ImVec2, cond:ImGuiCond = 0) {
		set_window_size(size, cond);
	}

	/**
		(not recommended) set current window collapsed state. prefer using SetNextWindowCollapsed().
	**/
	public static extern inline overload function setWindowCollapsed(collapsed:Bool, cond:ImGuiCond = 0) {
		set_window_collapsed(collapsed, cond);
	}

	/**
		(not recommended) set current window to be focused / top-most. prefer using SetNextWindowFocus().
	**/
	public static extern inline overload function setWindowFocus() {
		set_window_focus();
	}

	/**
		Set font scale factor for current window. Prefer using PushFont(null, style.FontSizeBase * factor) or use style.FontScaleMain to scale all windows.
	**/
	public static extern inline overload function setWindowFontScale(scale:Single) {}

	/**
		(not recommended) set current window position - call within Begin()/End(). prefer using SetNextWindowPos(), as this may incur tearing and side-effects.
	**/
	public static extern inline overload function setWindowPos(name:String, pos:ImVec2, cond:ImGuiCond = 0) {
		set_window_pos2(name, pos, cond);
	}

	/**
		(not recommended) set current window size - call within Begin()/End(). set to ImVec2(0, 0) to force an auto-fit. prefer using SetNextWindowSize(), as this may incur tearing and minor side-effects.
	**/
	public static extern inline overload function setWindowSize(name:String, size:ImVec2, cond:ImGuiCond = 0) {
		set_window_size2(name, size, cond);
	}

	/**
		(not recommended) set current window collapsed state. prefer using SetNextWindowCollapsed().
	**/
	public static extern inline overload function setWindowCollapsed(name:String, collapsed:Bool, cond:ImGuiCond = 0) {
		set_window_collapsed2(name, collapsed, cond);
	}

	/**
		(not recommended) set current window to be focused / top-most. prefer using SetNextWindowFocus().
	**/
	public static extern inline overload function setWindowFocus(name:String) {
		set_window_focus2(name);
	}

	static function set_window_pos(pos:ImVec2, cond:ImGuiCond = 0) {}

	static function set_window_size(size:ImVec2, cond:ImGuiCond = 0) {}

	static function set_window_collapsed(collapsed:Bool, cond:ImGuiCond = 0) {}

	static function set_window_focus() {}

	static function set_window_pos2(name:String, pos:ImVec2, cond:ImGuiCond = 0) {}

	static function set_window_size2(name:String, size:ImVec2, cond:ImGuiCond = 0) {}

	static function set_window_collapsed2(name:String, collapsed:Bool, cond:ImGuiCond = 0) {}

	static function set_window_focus2(name:String) {}

	// Content region

	/**
		Content boundaries max (e.g. window boundaries including scrolling, or current column boundaries). You should never need this. Always use GetCursorScreenPos() and GetContentRegionAvail()!
	**/
	public static function getContentRegionMax():ImVec2 {
		return null;
	}

	/**
		Available space from current position. THIS IS YOUR BEST FRIEND.
	**/
	public static function getContentRegionAvail():ImVec2 {
		return null;
	}

	/**
		Content boundaries min for the window (roughly (0,0)-Scroll), in window-local coordinates. You should never need this. Always use GetCursorScreenPos() and GetContentRegionAvail()!
	**/
	public static function getWindowContentRegionMin():ImVec2 {
		return null;
	}

	/**
		Content boundaries max for the window (roughly (0,0)+Size-Scroll), in window-local coordinates. You should never need this. Always use GetCursorScreenPos() and GetContentRegionAvail()!
	**/
	public static function getWindowContentRegionMax():ImVec2 {
		return null;
	}

	// Windows Scrolling

	/**
		Get scrolling amount [0 .. GetScrollMaxX()].
	**/
	public static function getScrollX():Single {
		return 0;
	}

	/**
		Get scrolling amount [0 .. GetScrollMaxY()].
	**/
	public static function getScrollY():Single {
		return 0;
	}

	/**
		Set scrolling amount [0 .. GetScrollMaxX()].
	**/
	public static function setScrollX(scroll_x:Single) {}

	/**
		Set scrolling amount [0 .. GetScrollMaxY()].
	**/
	public static function setScrollY(scroll_y:Single) {}

	/**
		Get maximum scrolling amount ~~ ContentSize.x - WindowSize.x - DecorationsSize.x.
	**/
	public static function getScrollMaxX():Single {
		return 0;
	}

	/**
		Get maximum scrolling amount ~~ ContentSize.y - WindowSize.y - DecorationsSize.y.
	**/
	public static function getScrollMaxY():Single {
		return 0;
	}

	/**
		Adjust scrolling amount to make current cursor position visible. center_x_ratio=0.0: left, 0.5: center, 1.0: right. When using to make a "default/current item" visible, consider using SetItemDefaultFocus() instead.
	**/
	public static function setScrollHereX(center_x_ratio:Single = 0.5) {}

	/**
		Adjust scrolling amount to make current cursor position visible. center_y_ratio=0.0: top, 0.5: center, 1.0: bottom. When using to make a "default/current item" visible, consider using SetItemDefaultFocus() instead.
	**/
	public static function setScrollHereY(center_y_ratio:Single = 0.5) {}

	/**
		Adjust scrolling amount to make given position visible. Generally GetCursorStartPos() + offset to compute a valid position.
	**/
	public static function setScrollFromPosX(local_x:Single, center_x_ratio:Single = 0.5) {}

	/**
		Adjust scrolling amount to make given position visible. Generally GetCursorStartPos() + offset to compute a valid position.
	**/
	public static function setScrollFromPosY(local_y:Single, center_y_ratio:Single = 0.5) {}

	// Parameters stacks (shared)

	/**
		Use null as a shortcut to keep current font. Use 0.0f to keep current size.
	**/
	public static function pushFont(font:ImFont, fontSizeBaseUnscaled:Single = 0) {}

	/**
		Pops font from its stack.
	**/
	public static function popFont() {}

	/**
		Modify a style color. always use this if you modify the style after NewFrame().
	**/
	public static extern inline overload function pushStyleColor(idx:ImGuiCol, col:ImU32) {
		push_style_color(idx, col);
	}

	/**
		Modify a style color. always use this if you modify the style after NewFrame().
	**/
	public static extern inline overload function pushStyleColor(idx:ImGuiCol, col:ImVec4) {
		push_style_color2(idx, col);
	}

	/**
		Pops style color from its stack.
	**/
	public static function popStyleColor(count:Int = 1) {}

	/**
		Modify a style float variable. always use this if you modify the style after NewFrame()!
	**/
	public static extern inline overload function pushStyleVar(idx:ImGuiStyleVar, val:Single) {
		push_style_var(idx, val);
	}

	/**
		Modify a style float variable. always use this if you modify the style after NewFrame()!
	**/
	public static extern inline overload function pushStyleVar(idx:ImGuiStyleVar, val:ImVec2) {
		push_style_var2(idx, val);
	}

	/**
		Pops style var from its stack.
	**/
	public static function popStyleVar(count:Int = 1) {}

	/**
		Pushes allow keyboard focus onto its stack.
	**/
	public static function pushAllowKeyboardFocus(allow_keyboard_focus:Bool) {}

	/**
		Pops allow keyboard focus from its stack.
	**/
	public static function popAllowKeyboardFocus() {}

	/**
		Pushes button repeat onto its stack.
	**/
	public static function pushButtonRepeat(repeat:Bool) {}

	/**
		Pops button repeat from its stack.
	**/
	public static function popButtonRepeat() {}

	static function push_style_color(idx:ImGuiCol, col:ImU32) {}

	static function push_style_color2(idx:ImGuiCol, col:ImVec4) {}

	static function push_style_var(idx:ImGuiStyleVar, val:Single) {}

	static function push_style_var2(idx:ImGuiStyleVar, val:ImVec2) {}

	// Parameters stacks (current window)

	/**
		Push width of items for common large "item+label" widgets. >0.0f: width in pixels, <0.0f align xx pixels to the right of window (so -FLT_MIN always align width to the right side).
	**/
	public static function pushItemWidth(item_width:Single) {}

	/**
		Pops item width from its stack.
	**/
	public static function popItemWidth() {}

	/**
		Set width of the _next_ common large "item+label" widget. >0.0f: width in pixels, <0.0f align xx pixels to the right of window (so -FLT_MIN always align width to the right side)
	**/
	public static function setNextItemWidth(item_width:Single) {}

	/**
		Width of item given pushed settings and current cursor position. NOT necessarily the width of last item unlike most 'Item' functions.
	**/
	public static function calcItemWidth():Single {
		return 0;
	}

	/**
		Push word-wrapping position for Text*() commands. < 0.0f: no wrapping; 0.0f: wrap to end of window (or column); > 0.0f: wrap at 'wrap_pos_x' position in window local space.
	**/
	public static function pushTextWrapPos(wrap_local_pos_x:Single = 0.0) {}

	/**
		Pops text wrap pos from its stack.
	**/
	public static function popTextWrapPos() {}

	// Style read access

	/**
		Get current font.
	**/
	public static function getFont():ImFont {
		return null;
	}

	/**
		Get current scaled font size (= height in pixels). AFTER global scale factors applied. *IMPORTANT* DO NOT PASS THIS VALUE TO PushFont()! Use ImGui.GetStyle().FontSizeBase to get value before global scale factors.
	**/
	public static function getFontSize():Single {
		return 0;
	}

	/**
		Get UV coordinate for a white pixel, useful to draw custom shapes via the ImDrawList API.
	**/
	public static function getFontTexUvWhitePixel():ImVec2 {
		return null;
	}

	/**
		Retrieve given style color with style alpha applied and optional extra alpha multiplier, packed as a 32-bit value suitable for ImDrawList.
	**/
	public static extern inline overload function getColorU32(idx:ImGuiCol, alpha_mul:Single = 1.0):ImU32 {
		return get_color_u32(idx, alpha_mul);
	}

	/**
		Retrieve given style color with style alpha applied and optional extra alpha multiplier, packed as a 32-bit value suitable for ImDrawList.
	**/
	public static extern inline overload function getColorU32(col:ImVec4):ImU32 {
		return get_color_u322(col);
	}

	/**
		Retrieve given style color with style alpha applied and optional extra alpha multiplier, packed as a 32-bit value suitable for ImDrawList.
	**/
	public static extern inline overload function getColorU32(col:ImU32):ImU32 {
		return get_color_u323(col);
	}

	/**
		Retrieve style color as stored in ImGuiStyle structure. use to feed back into PushStyleColor(), otherwise use GetColorU32() to get style color with style alpha baked in.
	**/
	public static function getStyleColorVec4(idx:ImGuiCol):ImVec4 {
		return null;
	}

	static function get_color_u32(idx:ImGuiCol, alpha_mul:Single = 1.0):ImU32 {
		return 0;
	}

	static function get_color_u322(col:ImVec4):ImU32 {
		return 0;
	}

	static function get_color_u323(col:ImU32):ImU32 {
		return 0;
	}

	// Cursor / Layout

	/**
		Separator, generally horizontal. inside a menu bar or in horizontal layout mode, this becomes a vertical separator.
	**/
	public static function separator() {}

	/**
		Call between widgets or groups to layout them horizontally. X position given in window coordinates.
	**/
	public static function sameLine(offset_from_start_x:Single = 0.0, spacing:Single = -1.0) {}

	/**
		Undo a SameLine() or force a new line when in a horizontal-layout context.
	**/
	public static function newLine() {}

	/**
		Add vertical spacing.
	**/
	public static function spacing() {}

	/**
		Add a dummy item of given size. unlike InvisibleButton(), Dummy() won't take the mouse click or be navigable into.
	**/
	public static function dummy(size:ImVec2) {}

	/**
		Move content position toward the right, by indent_w, or style.IndentSpacing if indent_w <= 0.
	**/
	public static function indent(indent_w:Single = 0.0) {}

	/**
		Move content position back to the left, by indent_w, or style.IndentSpacing if indent_w <= 0.
	**/
	public static function unindent(indent_w:Single = 0.0) {}

	/**
		Lock horizontal starting position.
	**/
	public static function beginGroup() {}

	/**
		Unlock horizontal starting position + capture the whole group bounding box into one "item" (so you can use IsItemHovered() or layout primitives such as SameLine() on whole group, etc.)
	**/
	public static function endGroup() {}

	/**
		[window-local] cursor position in window-local coordinates. This is not your best friend.
	**/
	public static function getCursorPos():ImVec2 {
		return null;
	}

	/**
		[window-local] ".
	**/
	public static function getCursorPosX():Single {
		return 0;
	}

	/**
		[window-local] ".
	**/
	public static function getCursorPosY():Single {
		return 0;
	}

	/**
		[window-local] ".
	**/
	public static function setCursorPos(local_pos:ImVec2) {}

	/**
		[window-local] ".
	**/
	public static function setCursorPosX(local_x:Single) {}

	/**
		[window-local] ".
	**/
	public static function setCursorPosY(local_y:Single) {}

	/**
		[window-local] initial cursor position, in window-local coordinates. Call GetCursorScreenPos() after Begin() to get the absolute coordinates version.
	**/
	public static function getCursorStartPos():ImVec2 {
		return null;
	}

	/**
		Cursor position, absolute coordinates. THIS IS YOUR BEST FRIEND (prefer using this rather than GetCursorPos(), also more useful to work with ImDrawList API).
	**/
	public static function getCursorScreenPos():ImVec2 {
		return null;
	}

	/**
		Cursor position, absolute coordinates. THIS IS YOUR BEST FRIEND.
	**/
	public static function setCursorScreenPos(pos:ImVec2) {}

	/**
		Vertically align upcoming text baseline to FramePadding.y so that it will align properly to regularly framed items (call if you have text on a line before a framed item)
	**/
	public static function alignTextToFramePadding() {}

	/**
		~ FontSize.
	**/
	public static function getTextLineHeight():Single {
		return 0;
	}

	/**
		~ FontSize + style.ItemSpacing.y (distance in pixels between 2 consecutive lines of text)
	**/
	public static function getTextLineHeightWithSpacing():Single {
		return 0;
	}

	/**
		~ FontSize + style.FramePadding.y * 2.
	**/
	public static function getFrameHeight():Single {
		return 0;
	}

	/**
		~ FontSize + style.FramePadding.y * 2 + style.ItemSpacing.y (distance in pixels between 2 consecutive lines of framed widgets)
	**/
	public static function getFrameHeightWithSpacing():Single {
		return 0;
	}

	// ID stack/scopes

	/**
		Push string into the ID stack (will hash string).
	**/
	public static function pushID(str_id:String) {}

	/**
		Pushes idsub onto its stack.
	**/
	@:native("push_id_sub") public static function pushIDSub(str_id:String, begin:Int, end:Int) {}

	/**
		Pushes idint onto its stack.
	**/
	@:native("push_id_int") public static function pushIDInt(int_id:Int) {}

	/**
		Pushes idptr onto its stack.
	**/
	@:native("push_id_ptr") public static function pushIDPtr(obj:Any) {}

	/**
		Pop from the ID stack.
	**/
	public static function popID() {}

	/**
		Calculate unique ID (hash of whole ID stack + given parameter). e.g. if you want to query into ImGuiStorage yourself.
	**/
	public static function getID(str_id:String):Int {
		return 0;
	}

	/**
		Returns idsub.
	**/
	@:native("get_id_sub") public static function getIDSub(str_id:String, begin:Int, end:Int):Int {
		return 0;
	}

	/**
		Returns idptr.
	**/
	@:native("get_id_ptr") public static function getIDPtr(obj:Any):Int {
		return 0;
	}

	// Widgets: Text
	// TextUnformatted(text: String, ?start: Int, ?end: Int) is not exposed.
	// Format arguments are not supported.

	/**
		Formatted text.
	**/
	public static function text(text:String) {}

	/**
		Shortcut for PushStyleColor(ImGuiCol_Text, col); Text(fmt, ...); PopStyleColor();.
	**/
	public static function textColored(col:ImVec4, fmt:String) {}

	/**
		Shortcut for PushStyleColor(ImGuiCol_Text, style.Colors[ImGuiCol_TextDisabled]); Text(fmt, ...); PopStyleColor();.
	**/
	public static function textDisabled(text:String) {}

	/**
		Shortcut for PushTextWrapPos(0.0f); Text(fmt, ...); PopTextWrapPos();. Note that this won't work on an auto-resizing window if there's no other widgets to extend the window width, yoy may need to set a size using SetNextWindowSize().
	**/
	public static function textWrapped(text:String) {}

	/**
		Display text+label aligned the same way as value+label widgets.
	**/
	public static function labelText(label:String, text:String) {}

	/**
		Shortcut for Bullet()+Text()
	**/
	public static function bulletText(text:String) {}

	/**
		Currently: formatted text with a horizontal line.
	**/
	public static function separatorText(label:String) {}

	//	public static function textMarkdown(text : String) {}
	// Widgets: Main

	/**
		Button.
	**/
	public static function button(name:String, ?size:ImVec2):Bool {
		return false;
	}

	/**
		Button with (FramePadding.y == 0) to easily embed within text.
	**/
	public static function smallButton(label:String):Bool {
		return false;
	}

	/**
		Flexible button behavior without the visuals, frequently useful to build custom behaviors using the public api (along with IsItemActive, IsItemHovered, etc.)
	**/
	public static function invisibleButton(str_id:String, ?size:ImVec2, flags:ImGuiButtonFlags = 0):Bool {
		return false;
	}

	/**
		Square button with an arrow shape.
	**/
	public static function arrowButton(str_id:String, dir:ImGuiDir):Bool {
		return false;
	}

	/**
		Hyperlink text button, return true when clicked.
	**/
	public static function textLink(label:String):Bool {
		return false;
	}

	/**
		Hyperlink text button, automatically open file/url when clicked.
	**/
	public static function textLinkOpenURL(label:String, ?url:String):Bool {
		return false;
	}

	/**
		<-- 'border_col' was removed in favor of ImGuiCol_ImageBorder. If you use 'tint_col', use ImageWithBg() instead.
	**/
	public static extern inline overload function image(tex_ref:ImTextureRef, size:ImVec2, ?uv0:ImVec2, ?uv1:ImVec2):Void {
		image_ref(tex_ref, size, uv0, uv1);
	}

	@:deprecated("Use image() or imageWithBg() and configure ImGuiCol.Border/ImageBorderSize for borders")
	/**
		<-- 'border_col' was removed in favor of ImGuiCol_ImageBorder. If you use 'tint_col', use ImageWithBg() instead.
	**/
	public static extern inline overload function image(user_texture_id:ImTextureID, size:ImVec2, uv0:ImVec2, uv1:ImVec2, tint_col:ImVec4, ?border_col:ImVec4):Void {
		image_compat(user_texture_id, size, uv0, uv1, tint_col, border_col);
	}

	/**
		Draws an image using the supplied texture and layout options.
	**/
	public static function imageWithBg(tex_ref:ImTextureRef, size:ImVec2, ?uv0:ImVec2, ?uv1:ImVec2, ?bg_col:ImVec4, ?tint_col:ImVec4):Void {}

	/**
		Draws an image widget and returns `true` when its button variant is activated.
	**/
	public static extern inline overload function imageButton(str_id:String, tex_ref:ImTextureRef, size:ImVec2, ?uv0:ImVec2, ?uv1:ImVec2, ?bg_col:ImVec4, ?tint_col:ImVec4):Bool {
		return image_button(str_id, tex_ref, size, uv0, uv1, bg_col, tint_col);
	}

	@:deprecated("Use imageButton(strId, texture, size, ...) with an explicit ID")
	/**
		Draws an image widget and returns `true` when its button variant is activated.
	**/
	public static extern inline overload function imageButton(user_texture_id:ImTextureID, size:ImVec2, ?uv0:ImVec2, ?uv1:ImVec2, frame_padding:Int = -1, ?bg_col:ImVec4, ?tint_col:ImVec4):Bool {
		return image_button_compat(user_texture_id, size, uv0, uv1, frame_padding, bg_col, tint_col);
	}

	#if heaps
	/**
		Draws an image using the supplied texture and layout options.
	**/
	public static inline function imageTile(tile:h2d.Tile, ?size:ImVec2, ?tint_col:ImVec4, ?border_col:ImVec4) @:privateAccess {
		var imageSize = size == null ? ImTypeCache.vec2(tile.width, tile.height) : size;
		var uv0 = ImTypeCache.vec2(tile.u, tile.v);
		var uv1 = ImTypeCache.vec2(tile.u2, tile.v2);
		if (tint_col == null && border_col == null)
			image_ref(tile.getTexture(), imageSize, uv0, uv1);
		else
			image_compat(tile.getTexture(), imageSize, uv0, uv1, tint_col, border_col);
	}

	/**
		Draws an image widget and returns `true` when its button variant is activated.
	**/
	public static extern inline overload function imageTileButton(str_id:String, tile:h2d.Tile, ?size:ImVec2, ?bg_col:ImVec4, ?tint_col:ImVec4):Bool @:privateAccess {
		return image_button(str_id, tile.getTexture(), size == null ? ImTypeCache.vec2(tile.width, tile.height) : size, ImTypeCache.vec2(tile.u, tile.v), ImTypeCache.vec2(tile.u2, tile.v2), bg_col, tint_col);
	}

	@:deprecated("Use imageTileButton(strId, tile, ...) with an explicit ID")
	/**
		Draws an image widget and returns `true` when its button variant is activated.
	**/
	public static extern inline overload function imageTileButton(tile:h2d.Tile, ?size:ImVec2, frame_padding:Int = -1, ?bg_col:ImVec4, ?tint_col:ImVec4):Bool @:privateAccess {
		return image_button_compat(tile.getTexture(), size == null ? ImTypeCache.vec2(tile.width, tile.height) : size, ImTypeCache.vec2(tile.u, tile.v), ImTypeCache.vec2(tile.u2, tile.v2), frame_padding, bg_col, tint_col);
	}
	#end

	/**
		Displays a checkbox and updates the referenced value when edited.
	**/
	public static function checkbox(label:String, v:Ref<Bool>):Bool {
		return false;
	}

	/**
		Displays a checkbox and updates the referenced value when edited.
	**/
	public static function checkboxFlags(label:String, flags:Ref<Int>, flags_value:Int):Bool {
		return false;
	}

	/**
		Use with e.g. if (RadioButton("one", my_value==1)) { my_value = 1; }.
	**/
	public static extern inline overload function radioButton(label:String, active:Bool):Bool {
		return radio_button(label, active);
	}

	/**
		Use with e.g. if (RadioButton("one", my_value==1)) { my_value = 1; }.
	**/
	public static extern inline overload function radioButton(label:String, v:Ref<Int>, v_button:Int):Bool {
		return radio_button2(label, v, v_button);
	}

	/**
		Draws a progress bar for `fraction`, with an optional size and overlay text.
	**/
	public static function progressBar(fraction:Single, ?size_arg:ImVec2, ?overlay:String) {}

	/**
		Draw a small circle + keep the cursor on the same line. advance cursor x position by GetTreeNodeToLabelSpacing(), same distance that TreeNode() uses.
	**/
	public static function bullet() {}

	static function radio_button(label:String, active:Bool):Bool {
		return false;
	}

	static function radio_button2(label:String, v:Ref<Int>, v_button:Int):Bool {
		return false;
	}

	static function image_ref(tex_ref:ImTextureRef, size:ImVec2, ?uv0:ImVec2, ?uv1:ImVec2):Void {}

	static function image_compat(user_texture_id:ImTextureID, size:ImVec2, uv0:ImVec2, uv1:ImVec2, tint_col:ImVec4, border_col:ImVec4):Void {}

	static function image_button(str_id:String, tex_ref:ImTextureRef, size:ImVec2, uv0:ImVec2, uv1:ImVec2, bg_col:ImVec4, tint_col:ImVec4):Bool
		return false;

	static function image_button_compat(user_texture_id:ImTextureID, size:ImVec2, uv0:ImVec2, uv1:ImVec2, frame_padding:Int, bg_col:ImVec4, tint_col:ImVec4):Bool
		return false;

	// Widgets: Combo Box

	/**
		You MUST call `endCombo()` if this method returns `true`!
	**/
	public static function beginCombo(label:String, preview_value:String, flags:ImGuiComboFlags = 0):Bool {
		return false;
	}

	/**
		Only call `endCombo()` if `beginCombo()` returns `true`!
	**/
	public static function endCombo() {}

	/**
		Separate items with \0 within a string, end item-list with \0\0. e.g. "One\0Two\0Three\0".
	**/
	public static extern inline overload function combo(label:String, current_item:Ref<Int>, items:hl.NativeArray<String>, popup_max_height_in_items:Int = -1):Bool {
		return _combo(label, current_item, items, popup_max_height_in_items);
	}

	/**
		Separate items with \0 within a string, end item-list with \0\0. e.g. "One\0Two\0Three\0".
	**/
	public static extern inline overload function combo(label:String, current_item:Ref<Int>, items_separated_by_zeros:String, popup_max_height_in_items:Int = -1):Bool {
		return _combo2(label, current_item, items_separated_by_zeros, popup_max_height_in_items);
	}

	// The callback variant is not exposed.

	@:native("combo") static function _combo(label:String, current_item:Ref<Int>, items:hl.NativeArray<String>, popup_max_height_in_items:Int = -1):Bool {
		return false;
	}

	@:native("combo_2") static function _combo2(label:String, current_item:Ref<Int>, items_separated_by_zeros:String, popup_max_height_in_items:Int = -1):Bool {
		return false;
	}

	// Widgets: Drag Sliders

	/**
		If v_min >= v_max we have no bound.
	**/
	public static function dragFloat(label:String, v:Ref<Single>, v_speed:Single = 1.0, v_min:Single = 0.0, v_max:Single = 0.0, format:String = "%.3f", flags:ImGuiSliderFlags = 0):Bool {
		return false;
	}

	/**
		If v_min >= v_max we have no bound.
	**/
	public static function dragInt(label:String, v:Ref<Int>, v_speed:Single = 1.0, v_min:Int = 0, v_max:Int = 0, format:String = "%d", flags:ImGuiSliderFlags = 0):Bool {
		return false;
	}

	/**
		Displays a draggable numeric input and updates the supplied value when edited.
	**/
	public static function dragDouble(label:String, v:Ref<Float>, v_speed:Single = 1.0, v_min:Float = 0.0, v_max:Float = 0.0, format:String = "%.3lf", flags:ImGuiSliderFlags = 0):Bool {
		return false;
	}

	/**
		Displays a draggable numeric input and updates the supplied value when edited.
	**/
	public static function dragFloatRange2(label:String, v_current_min:Ref<Single>, v_current_max:Ref<Single>, v_speed:Single = 1.0, v_min:Single = 0.0, v_max:Single = 0.0, format:String = "%.3f", ?format_max:String,
			flags:ImGuiSliderFlags = 0):Bool {
		return false;
	}

	/**
		Displays a draggable numeric input and updates the supplied value when edited.
	**/
	public static function dragIntRange2(label:String, v_current_min:Ref<Int>, v_current_max:Ref<Int>, v_speed:Single = 1.0, v_min:Int = 0, v_max:Int = 0, format:String = "%.d", ?format_max:String, flags:ImGuiSliderFlags = 0):Bool {
		return false;
	}

	/**
		Displays a draggable numeric input and updates the supplied value when edited.
	**/
	public static inline function dragFloatN(label:String, v:hl.NativeArray<Single>, v_speed:Single = 1.0, v_min:Single = 0.0, v_max:Single = 0.0, format:String = "%.3f", flags:ImGuiSliderFlags = 0):Bool {
		return drag_scalar_n(label, ImGuiDataType.Float, cast v, v_speed, v_min, v_max, format, flags);
	}

	/**
		Displays a draggable numeric input and updates the supplied value when edited.
	**/
	public static inline function dragIntN(label:String, v:hl.NativeArray<Int>, v_speed:Single = 1.0, v_min:Int = 0, v_max:Int = 0, format:String = "%d", flags:ImGuiSliderFlags = 0):Bool {
		return drag_scalar_n(label, ImGuiDataType.S32, cast v, v_speed, v_min, v_max, format, flags);
	}

	/**
		Displays a draggable numeric input and updates the supplied value when edited.
	**/
	public static inline function dragDoubleN(label:String, v:hl.NativeArray<Float>, v_speed:Single = 1.0, v_min:Float = 0.0, v_max:Float = 0.0, format:String = "%.3lf", flags:ImGuiSliderFlags = 0):Bool {
		return drag_scalar_n(label, ImGuiDataType.Double, cast v, v_speed, v_min, v_max, format, flags);
	}

	static function drag_scalar_n(label:String, type:Int, v:hl.NativeArray<Dynamic>, v_speed:Single, v_min:Dynamic, v_max:Dynamic, format:String, flags:Int):Bool {
		return false;
	}

	// Widgets: Regular Sliders

	/**
		Adjust format to decorate the value with a prefix or a suffix for in-slider labels or unit display.
	**/
	public static function sliderFloat(label:String, v:Ref<Single>, v_min:Single, v_max:Single, format:String = "%.3f", flags:ImGuiSliderFlags = 0):Bool {
		return false;
	}

	/**
		Displays a numeric slider and updates the supplied value when edited.
	**/
	public static function sliderInt(label:String, v:Ref<Int>, v_min:Int, v_max:Int, format:String = "%d", flags:ImGuiSliderFlags = 0):Bool {
		return false;
	}

	/**
		Displays a numeric slider and updates the supplied value when edited.
	**/
	public static function sliderDouble(label:String, v:Ref<Float>, v_min:Float, v_max:Float, format:String = "%.3lf", flags:ImGuiSliderFlags = 0):Bool {
		return false;
	}

	/**
		Displays a numeric slider and updates the supplied value when edited.
	**/
	public static function vSliderFloat(label:String, size:ImVec2, v:Ref<Single>, v_min:Single, v_max:Single, format:String = "%.3f", flags:ImGuiSliderFlags = 0):Bool {
		return false;
	}

	/**
		Displays a numeric slider and updates the supplied value when edited.
	**/
	public static function vSliderInt(label:String, size:ImVec2, v:Ref<Int>, v_min:Int, v_max:Int, format:String = "%d", flags:ImGuiSliderFlags = 0):Bool {
		return false;
	}

	/**
		Displays a numeric slider and updates the supplied value when edited.
	**/
	public static function sliderAngle(label:String, v_rad:Ref<Single>, v_degrees_min:Single = -360.0, v_degrees_max:Single = 360.0, format:String = "%.0f deg", flags:ImGuiSliderFlags = 0):Bool {
		return false;
	}

	/**
		Displays a numeric slider and updates the supplied value when edited.
	**/
	public static inline function sliderFloatN(label:String, v:hl.NativeArray<Single>, v_min:Single, v_max:Single, format:String = "%.3f", flags:ImGuiSliderFlags = 0):Bool {
		return slider_scalar_n(label, ImGuiDataType.Float, cast v, v_min, v_max, format, flags);
	}

	/**
		Displays a numeric slider and updates the supplied value when edited.
	**/
	public static inline function sliderIntN(label:String, v:hl.NativeArray<Int>, v_min:Int, v_max:Int, format:String = "%d", flags:ImGuiSliderFlags = 0):Bool {
		return slider_scalar_n(label, ImGuiDataType.S32, cast v, v_min, v_max, format, flags);
	}

	/**
		Displays a numeric slider and updates the supplied value when edited.
	**/
	public static inline function sliderDoubleN(label:String, v:hl.NativeArray<Float>, v_min:Float, v_max:Float, format:String = "%.3lf", flags:ImGuiSliderFlags = 0):Bool {
		return slider_scalar_n(label, ImGuiDataType.Double, cast v, v_min, v_max, format, flags);
	}

	static function slider_scalar_n(label:String, type:Int, v:hl.NativeArray<ImGuiScalar>, v_min:ImGuiScalar, v_max:ImGuiScalar, format:String, flags:Int):Bool {
		return false;
	}

	/**
		Displays a numeric slider and updates the supplied value when edited.
	**/
	public static function vSliderDouble(label:String, size:ImVec2, v:Ref<Float>, v_min:Float, v_max:Float, ?format:String, flags:Int = 0) {
		var tmp = ImTypeCache.array(v.get());
		var ret = v_slider_scalar(label, size, Double, cast tmp, v_min, v_max, format, flags);
		if (isItemEdited())
			v.set(tmp[0]);
		return ret;
	}

	// Direct vSliderScalar usage is not exposed.

	/**
		Displays a numeric slider and updates the supplied value when edited.
	**/
	public static function v_slider_scalar(label:String, size:ImVec2, type:ImGuiDataType, v:hl.NativeArray<ImGuiScalar>, v_min:ImGuiScalar, v_max:ImGuiScalar, ?format:String, flags:Int = 0):Bool {
		return false;
	}

	// Widgets: Input with Keyboard

	/**
		Displays an editable input field and updates the supplied value when edited.
	**/
	public static function inputText(label:String, value:Ref<String>, flags:ImGuiInputTextFlags = 0, ?callback:ImGuiInputTextCallbackDataFunc):Bool {
		return false;
	}

	/**
		Displays an editable input field and updates the supplied value when edited.
	**/
	public static function inputTextMultiline(label:String, value:Ref<String>, ?size:ImVec2, flags:ImGuiInputTextFlags = 0, ?callback:ImGuiInputTextCallbackDataFunc):Bool {
		return false;
	}

	/**
		Displays an editable input field and updates the supplied value when edited.
	**/
	public static function inputTextWithHint(label:String, hint:String, value:Ref<String>, flags:ImGuiInputTextFlags = 0, ?callback:ImGuiInputTextCallbackDataFunc):Bool {
		return false;
	}

	/**
		Displays an editable input field and updates the supplied value when edited.
	**/
	public static function inputTextBuf(label:String, buf:hl.Bytes, buf_size:Int, flags:ImGuiInputTextFlags = 0, ?callback:ImGuiInputTextCallbackDataFunc):Bool {
		return false;
	}

	/**
		Displays an editable input field and updates the supplied value when edited.
	**/
	public static function inputTextMultilineBuf(label:String, buf:hl.Bytes, buf_size:Int, ?size:ImVec2, flags:ImGuiInputTextFlags = 0, ?callback:ImGuiInputTextCallbackDataFunc):Bool {
		return false;
	}

	/**
		Displays an editable input field and updates the supplied value when edited.
	**/
	public static function inputTextWithHintBuf(label:String, hint:String, buf:hl.Bytes, buf_size:Int, flags:ImGuiInputTextFlags = 0, ?callback:ImGuiInputTextCallbackDataFunc):Bool {
		return false;
	}

	/**
		Displays an editable input field and updates the supplied value when edited.
	**/
	public static function inputInt(label:String, v:Ref<Int>, step:Int = 1, step_fast:Int = 100, flags:ImGuiInputTextFlags = 0):Bool {
		return false;
	}

	/**
		Displays an editable input field and updates the supplied value when edited.
	**/
	public static function inputFloat(label:String, v:Ref<Single>, step:Single = 0.0, step_fast:Single = 0.0, format:String = "%.3f", flags:ImGuiInputTextFlags = 0):Bool {
		return false;
	}

	/**
		Displays an editable input field and updates the supplied value when edited.
	**/
	public static function inputDouble(label:String, v:Ref<Float>, step:Float = 0.0, step_fast:Float = 0.0, format:String = "%.6f", flags:ImGuiInputTextFlags = 0):Bool {
		return false;
	}

	/**
		Displays an editable input field and updates the supplied value when edited.
	**/
	public static inline function inputFloatN(label:String, v:hl.NativeArray<Single>, step:Single = 0.0, step_fast:Single = 0.0, format:String = "%.3f", flags:ImGuiInputTextFlags = 0):Bool {
		return input_scalar_n(label, ImGuiDataType.Float, cast v, step, step_fast, format, flags);
	}

	/**
		Displays an editable input field and updates the supplied value when edited.
	**/
	public static inline function inputIntN(label:String, v:hl.NativeArray<Int>, step:Int = 0, step_fast:Int = 0, flags:ImGuiInputTextFlags = 0):Bool {
		return input_scalar_n(label, ImGuiDataType.S32, cast v, step, step_fast, "%d", flags);
	}

	/**
		Displays an editable input field and updates the supplied value when edited.
	**/
	public static inline function inputDoubleN(label:String, v:hl.NativeArray<Float>, step:Float = 0.0, step_fast:Float = 0.0, format:String = "%.6f", flags:ImGuiInputTextFlags = 0):Bool {
		return input_scalar_n(label, ImGuiDataType.Double, cast v, step, step_fast, format, flags);
	}

	static function input_scalar_n(label:String, type:Int, v:hl.NativeArray<ImGuiScalar>, step:ImGuiScalar, step_fast:ImGuiScalar, format:String, flags:Int):Bool {
		return false;
	}

	// Widgets: Color Editor/Picker

	/**
		Displays a compact color editor and updates the supplied color when edited.
	**/
	public static function colorEdit3(label:String, col:hl.NativeArray<Single>, flags:ImGuiColorEditFlags = 0):Bool {
		return false;
	}

	/**
		Displays a compact color editor and updates the supplied color when edited.
	**/
	public static function colorEdit4(label:String, col:hl.NativeArray<Single>, flags:ImGuiColorEditFlags = 0):Bool {
		return false;
	}

	/**
		Displays a color picker and updates the supplied color when edited.
	**/
	public static function colorPicker3(label:String, col:hl.NativeArray<Single>, flags:ImGuiColorEditFlags = 0):Bool {
		return false;
	}

	/**
		Displays a color picker and updates the supplied color when edited.
	**/
	public static function colorPicker4(label:String, col:hl.NativeArray<Single>, flags:ImGuiColorEditFlags = 0, ?ref_col:Ref<Single>):Bool {
		return false;
	}

	/**
		Display a color square/button, hover for details, return true when pressed.
	**/
	public static function colorButton(desc_id:String, ?col:ImVec4, flags:ImGuiColorEditFlags = 0, ?size:ImVec2):Bool {
		return false;
	}

	/**
		Set current options for if you want to select a default format, picker type, etc. User will be able to change those settings, unless you pass the _NoOptions flag to your calls.
	**/
	public static function setColorEditOptions(flags:ImGuiColorEditFlags) {}

	// Widgets: Trees

	/**
		Helper variation to easily decorrelate the id from the displayed string. Read the FAQ about why and how to use ID. to align arbitrary text at the same level as a TreeNode() you can use Bullet().
	**/
	public static extern inline overload function treeNode(label:String):Bool {
		return tree_node(label);
	}

	/**
		Helper variation to easily decorrelate the id from the displayed string. Read the FAQ about why and how to use ID. to align arbitrary text at the same level as a TreeNode() you can use Bullet().
	**/
	public static extern inline overload function treeNode(str_id:String, label:String):Bool {
		return tree_node2(str_id, label);
	}

	/**
		Begins a tree node and returns whether its contents are visible. Call `treePop()` only when it returns `true`.
	**/
	public static extern inline overload function treeNodeEx(label:String, flags:ImGuiTreeNodeFlags = 0):Bool {
		return tree_node_ex(label, flags);
	}

	/**
		Begins a tree node and returns whether its contents are visible. Call `treePop()` only when it returns `true`.
	**/
	public static extern inline overload function treeNodeEx(str_id:String, flags:ImGuiTreeNodeFlags, label:String):Bool {
		return tree_node_ex2(str_id, flags, label);
	}

	/**
		~ Indent()+PushID(). Already called by TreeNode() when returning true, but you can call TreePush/TreePop yourself if desired.
	**/
	public static function treePush(str_id:String) {}

	/**
		~ Unindent()+PopID()
	**/
	public static function treePop() {}

	/**
		Horizontal distance preceding label when using TreeNode*() or Bullet() == (g.FontSize + style.FramePadding.x*2) for a regular unframed TreeNode.
	**/
	public static function getTreeNodeToLabelSpacing():Single {
		return 0;
	}

	/**
		If returning 'true' the header is open. doesn't indent nor push on ID stack. user doesn't have to call TreePop().
	**/
	public static extern inline overload function collapsingHeader(label:String, flags:ImGuiTreeNodeFlags = 0):Bool {
		return collapsing_header(label, flags);
	}

	/**
		If returning 'true' the header is open. doesn't indent nor push on ID stack. user doesn't have to call TreePop().
	**/
	public static extern inline overload function collapsingHeader(label:String, p_open:Ref<Bool>, flags:ImGuiTreeNodeFlags = 0):Bool {
		return collapsing_header2(label, p_open, flags);
	}

	/**
		Set next TreeNode/CollapsingHeader open state.
	**/
	public static function setNextItemOpen(is_open:Bool, cond:ImGuiCond = 0) {}

	static function tree_node(label:String):Bool {
		return false;
	}

	static function tree_node2(str_id:String, label:String):Bool {
		return false;
	}

	static function tree_node_ex(label:String, flags:ImGuiTreeNodeFlags = 0):Bool {
		return false;
	}

	static function tree_node_ex2(str_id:String, flags:ImGuiTreeNodeFlags, label:String):Bool {
		return false;
	}

	static function collapsing_header(label:String, flags:ImGuiTreeNodeFlags = 0):Bool {
		return false;
	}

	static function collapsing_header2(label:String, p_open:Ref<Bool>, flags:ImGuiTreeNodeFlags = 0):Bool {
		return false;
	}

	// Widgets: Selectables

	/**
		"bool selected" carry the selection state (read-only). Selectable() is clicked is returns true so you can modify your selection state. size.x==0.0: use remaining width, size.x>0.0: specify width. size.y==0.0: use label height, size.y>0.0: specify height.
	**/
	public static extern inline overload function selectable(label:String, selected:Bool = false, flags:ImGuiSelectableFlags = 0, ?size:ImVec2):Bool {
		return _selectable(label, selected, flags, size);
	}

	/**
		"bool selected" carry the selection state (read-only). Selectable() is clicked is returns true so you can modify your selection state. size.x==0.0: use remaining width, size.x>0.0: specify width. size.y==0.0: use label height, size.y>0.0: specify height.
	**/
	public static extern inline overload function selectable(label:String, p_selected:Ref<Bool>, flags:ImGuiSelectableFlags = 0, ?size:ImVec2):Bool {
		return _selectable2(label, p_selected, flags, size);
	}

	@:native("selectable") static function _selectable(label:String, selected:Bool = false, flags:ImGuiSelectableFlags = 0, ?size:ImVec2):Bool {
		return false;
	}

	@:native("selectable_2") static function _selectable2(label:String, p_selected:Ref<Bool>, flags:ImGuiSelectableFlags = 0, ?size:ImVec2):Bool {
		return false;
	}

	// Widgets: Multi-Select

	/**
		Begins multi select. Call the corresponding end function only when this returns `true`, unless documented otherwise.
	**/
	public static function beginMultiSelect(flags:ImGuiMultiSelectFlags, selection_size:Int = -1, items_count:Int = -1):ImGuiMultiSelectIO
		return null;

	/**
		Ends multi select.
	**/
	public static function endMultiSelect():ImGuiMultiSelectIO
		return null;

	/**
		Sets next item selection user data.
	**/
	public static function setNextItemSelectionUserData(selection_user_data:ImGuiSelectionUserData):Void {}

	/**
		Was the last item selection state toggled? Useful if you need the per-item information _before_ reaching EndMultiSelect(). We only returns toggle _event_ in order to handle clipping correctly.
	**/
	public static function isItemToggledSelection():Bool
		return false;

	// Widgets: List Boxes

	/**
		You MUST call `endListBox()` if this method returns `true`!
		- Choose frame width:   size.x > 0.0f: custom  /  size.x < 0.0f or -FLT_MIN: right-align   /  size.x = 0.0f (default): use current ItemWidth
		- Choose frame height:  size.y > 0.0f: custom  /  size.y < 0.0f or -FLT_MIN: bottom-align  /  size.y = 0.0f (default): arbitrary default height which can fit ~7 items
	**/
	public static function beginListBox(label:String, ?size:ImVec2):Bool {
		return false;
	}

	/**
		Only call `endListBox()` if `beginListBox()` returns `true`!
	**/
	public static function endListBox() {}

	/**
		Displays a list box and updates the selected item index.
	**/
	public static function listBox(label:String, current_item:Ref<Int>, items:hl.NativeArray<String>, height_in_items:Int = -1):Bool {
		return false;
	}

	// The callback variant is not exposed.
	// Widgets: Data Plotting

	/**
		Plots the supplied numeric values in the current window.
	**/
	public static function plotLines(label:String, values:hl.NativeArray<Single>, values_offset:Int = 0, ?overlay_text:String, scale_min:Single = FLT_MAX, scale_max:Single = FLT_MAX, ?graph_size:ImVec2) {}

	/**
		Plots the supplied numeric values in the current window.
	**/
	public static function plotHistogram(label:String, values:hl.NativeArray<Single>, values_offset:Int = 0, ?overlay_text:String, scale_min:Single = FLT_MAX, scale_max:Single = FLT_MAX, ?graph_size:ImVec2) {}

	// Widgets: Value() Helpers.

	/**
		Displays a label and its formatted value.
	**/
	public static function valueBool(prefix:String, b:Bool) {}

	/**
		Displays a label and its formatted value.
	**/
	public static function valueInt(prefix:String, v:Int) {}

	/**
		Displays a label and its formatted value.
	**/
	public static function valueSingle(prefix:String, v:Single, ?float_format:String) {}

	/**
		Displays a label and its formatted value.
	**/
	public static function valueDouble(prefix:String, v:Float, ?double_format:String) {}

	// Widgets: Menus

	/**
		Append to menu-bar of current window (requires ImGuiWindowFlags_MenuBar flag set on parent window).
	**/
	public static function beginMenuBar():Bool {
		return false;
	}

	/**
		Only call `endMenuBar()` if `beginMenuBar()` returns `true`!
	**/
	public static function endMenuBar() {}

	/**
		Create and append to a full screen menu-bar.
	**/
	public static function beginMainMenuBar():Bool {
		return false;
	}

	/**
		Only call `endMainMenuBar()` if `beginMainMenuBar()` returns `true`!
	**/
	public static function endMainMenuBar() {}

	/**
		Create a sub-menu entry. only call EndMenu() if this returns true!
	**/
	public static function beginMenu(label:String, enabled:Bool = true):Bool {
		return false;
	}

	/**
		Only call `endMenu()` if `beginMenu()` returns `true`!
	**/
	public static function endMenu() {}

	/**
		Return true when activated.
	**/
	public static extern inline overload function menuItem(label:String, ?shortcut:String, selected:Bool = false, enabled:Bool = true):Bool {
		return menu_item(label, shortcut, selected, enabled);
	}

	/**
		Return true when activated.
	**/
	public static extern inline overload function menuItem(label:String, shortcut:String, p_selected:Ref<Bool>, enabled:Bool = true):Bool {
		return menu_item2(label, shortcut, p_selected, enabled);
	}

	static function menu_item(label:String, ?shortcut:String, selected:Bool = false, enabled:Bool = true):Bool {
		return false;
	}

	static function menu_item2(label:String, shortcut:String, p_selected:Ref<Bool>, enabled:Bool = true):Bool {
		return false;
	}

	// ToolTips

	/**
		Begin/append a tooltip window.
	**/
	public static function beginTooltip():Bool {
		return false;
	}

	/**
		Only call EndTooltip() if BeginTooltip()/BeginItemTooltip() returns true!
	**/
	public static function endTooltip() {}

	/**
		Set a text-only tooltip. Often used after a ImGui.IsItemHovered() check. Override any previous call to SetTooltip().
	**/
	public static function setTooltip(text:String) {}

	/**
		Begin/append a tooltip window if preceding item was hovered.
	**/
	public static function beginItemTooltip():Bool {
		return false;
	}

	/**
		Set a text-only tooltip if preceding item was hovered. override any previous call to SetTooltip().
	**/
	public static function setItemTooltip(text:String):Void {}

	// Popups, Modals
	// Popups: begin/end function

	/**
		Return true if the popup is open, and you can start outputting to it.
	**/
	public static function beginPopup(str_id:String, flags:ImGuiWindowFlags = 0):Bool {
		return false;
	}

	/**
		Return true if the modal is open, and you can start outputting to it.
	**/
	public static function beginPopupModal(name:String, ?p_open:Ref<Bool>, flags:ImGuiWindowFlags = 0):Bool {
		return false;
	}

	/**
		Only call `endPopup()` if `beginPopupXXX()` returns `true`!
	**/
	public static function endPopup() {}

	// Popups: open/close functions

	/**
		Call to mark popup as open (don't call every frame!).
	**/
	public static function openPopup(str_id:String, flags:ImGuiPopupFlags = 0):Bool {
		return false;
	}

	/**
		Marks the popup identified by an ImGui ID as open.
	**/
	public static function openPopupId(id:ImGuiID, flags:ImGuiPopupFlags = 0):Bool {
		return false;
	}

	/**
		Helper to open popup when clicked on last item. Default to ImGuiPopupFlags_MouseButtonRight == 1. (note: actually triggers on the mouse _released_ event to be consistent with popup behaviors)
	**/
	public static function openPopupOnItemClick(?str_id:String, flags:ImGuiPopupFlags = 0):Bool {
		return false;
	}

	/**
		Manually close the popup we have begin-ed into.
	**/
	public static function closeCurrentPopup() {}

	// Popups: open+begin combined function helpers

	/**
		Open+begin popup when clicked on last item. Use str_id==null to associate the popup to previous item. If you want to use that on a non-interactive item such as Text() you need to pass in an explicit ID here. read comments in .cpp!
	**/
	public static function beginPopupContextItem(?str_id:String, flags:ImGuiPopupFlags = 0):Bool {
		return false;
	}

	/**
		Open+begin popup when clicked on current window.
	**/
	public static function beginPopupContextWindow(?str_id:String, flags:ImGuiPopupFlags = 0):Bool {
		return false;
	}

	/**
		Open+begin popup when clicked in void (where there are no windows).
	**/
	public static function beginPopupContextVoid(?str_id:String, flags:ImGuiPopupFlags = 0):Bool {
		return false;
	}

	// Popups: query functions

	/**
		Return true if the popup is open.
	**/
	public static function isPopupOpen(str_id:String, flags:ImGuiPopupFlags = 0):Bool {
		return false;
	}

	// Tables

	/**
		Begins table. Call the corresponding end function only when this returns `true`, unless documented otherwise.
	**/
	public static function beginTable(id:String, column:Int, flags:ImGuiTableFlags = ImGuiTableFlags.None, ?outer_size:ImVec2, inner_width:Single = 0):Bool {
		return false;
	}

	/**
		Only call `endTable()` if `beginTable()` returns `true`!
	**/
	public static function endTable() {}

	/**
		Append into the first cell of a new row. 'min_row_height' include the minimum top and bottom padding aka CellPadding.y * 2.0f.
	**/
	public static function tableNextRow(rowFlags:ImGuiTableRowFlags = ImGuiTableRowFlags.None, minRowHeight:Single = 0) {}

	/**
		Access the ImGuiPlatformIO structure (mostly hooks/functions to …7740 tokens truncated…
	**/
	public static function tableNextColumn():Bool {
		return false;
	}

	/**
		Append into the specified column. Return true when column is visible.
	**/
	public static function tableSetColumnIndex(columnIndex:Int):Bool {
		return false;
	}

	// Tables: Headers & Columns declaration

	/**
		Declares a table column and configures its label, flags, initial size, and user ID.
	**/
	public static function tableSetupColumn(id:String, flags:ImGuiTableColumnFlags = ImGuiTableColumnFlags.None, initWidthOrHeight:Single = 0, userId:ImGuiID = 0) {}

	/**
		Lock columns/rows so they stay visible when scrolled.
	**/
	public static function tableSetupScrollFreeze(cols:Int, rows:Int) {}

	/**
		Submit a row with headers cells based on data provided to TableSetupColumn() + submit context menu.
	**/
	public static function tableHeadersRow() {}

	/**
		Submit a row with angled headers for every column with the ImGuiTableColumnFlags_AngledHeader flag. MUST BE FIRST ROW.
	**/
	public static function tableAngledHeadersRow() {}

	/**
		Submit one header cell manually (rarely used)
	**/
	public static function tableHeader(id:String) {}

	// Tables: Sorting

	/**
		Get latest sort specs for the table (null if not sorting). Lifetime: don't hold on this pointer over multiple frames or past any subsequent call to BeginTable().
	**/
	public static function tableGetSortSpecs():ImGuiTableSortSpecs {
		return null;
	}

	// Tables: Miscellaneous functions

	/**
		Return number of columns (value passed to BeginTable)
	**/
	public static function tableGetColumnCount():Int {
		return 0;
	}

	/**
		Return current column index.
	**/
	public static function tableGetColumnIndex():Int {
		return 0;
	}

	/**
		Return current row index (header rows are accounted for)
	**/
	public static function tableGetRowIndex():Int {
		return 0;
	}

	static function table_get_column_name(column_n:Int = -1):hl.Bytes {
		return null;
	}

	/**
		Return "" if column didn't have a name declared by TableSetupColumn(). Pass -1 to use current column.
	**/
	public static function tableGetColumnName(column_n:Int = -1):String {
		return @:privateAccess String.fromUTF8(table_get_column_name(column_n));
	}

	/**
		Return column flags so you can query their Enabled/Visible/Sorted/Hovered status flags. Pass -1 to use current column.
	**/
	public static function tableGetColumnFlags(column_n:Int = -1):ImGuiTableColumnFlags {
		return 0;
	}

	/**
		Return hovered column. return -1 when table is not hovered. return columns_count if the unused space at the right of visible columns is hovered. Can also use (TableGetColumnFlags() & ImGuiTableColumnFlags_IsHovered) instead.
	**/
	public static function tableGetHoveredColumn():Int {
		return -1;
	}

	/**
		Change user accessible enabled/disabled state of a column. Set to false to hide the column. User can use the context menu to change this themselves (right-click in headers, or right-click in columns body with ImGuiTableFlags_ContextMenuInBody)
	**/
	public static function tableSetColumnEnabled(column_n:Int, enabled:Bool):Void {}

	/**
		Overrides a table cell, row, or column background color.
	**/
	public static function tableSetBGColor(target:ImGuiTableBgTarget, color:Int, column_n:Int = -1):Void {}

	// Legacy Columns API (prefer using Tables!)

	/**
		Configures the legacy columns layout for the current window.
	**/
	public static function columns(count:Int = 1, ?id:String, border:Bool = true) {}

	/**
		Next column, defaults to current row or next row if the current row is finished.
	**/
	public static function nextColumn() {}

	/**
		Get current column index.
	**/
	public static function getColumnIndex():Int {
		return 0;
	}

	/**
		Get column width (in pixels). pass -1 to use current column.
	**/
	public static function getColumnWidth(column_index:Int = -1):Single {
		return 0;
	}

	/**
		Set column width (in pixels). pass -1 to use current column.
	**/
	public static function setColumnWidth(column_index:Int, width:Single) {}

	/**
		Get position of column line (in pixels, from the left side of the contents region). pass -1 to use current column, otherwise 0..GetColumnsCount() inclusive. column 0 is typically 0.0f.
	**/
	public static function getColumnOffset(column_index:Int = -1):Single {
		return 0;
	}

	/**
		Set position of column line (in pixels, from the left side of the contents region). pass -1 to use current column.
	**/
	public static function setColumnOffset(column_index:Int, offset_x:Single) {}

	/**
		Returns columns count.
	**/
	public static function getColumnsCount():Int {
		return 0;
	}

	// Tab Bars, Tabs

	/**
		Create and append into a TabBar.
	**/
	public static function beginTabBar(str_id:String, flags:ImGuiTabBarFlags = 0):Bool {
		return false;
	}

	/**
		Only call `endTabBar()` if `beginTabBar()` returns `true`!
	**/
	public static function endTabBar() {}

	/**
		Create a Tab. Returns true if the Tab is selected.
	**/
	public static function beginTabItem(label:String, ?p_open:Ref<Bool>, flags:ImGuiTabItemFlags = 0):Bool {
		return false;
	}

	/**
		Only call `endTabItem()` if `beginTabItem()` returns `true`!
	**/
	public static function endTabItem() {}

	/**
		Create a Tab behaving like a button. return true when clicked. cannot be selected in the tab bar.
	**/
	public static function tabItemButton(label:String, flags:ImGuiTabItemFlags = 0):Bool {
		return false;
	}

	/**
		Notify TabBar or Docking system of a closed tab/window ahead (useful to reduce visual flicker on reorderable tab bars). For tab-bar: call after BeginTabBar() and before Tab submissions. Otherwise call with a window name.
	**/
	public static function setTabItemClosed(tab_or_docked_window_label:String) {}

	// Docking

	/**
		Creates a dockspace with the supplied ID, size, and node flags.
	**/
	public static function dockSpace(id:ImGuiID, ?size:ImVec2, flags:ImGuiDockNodeFlags = 0, ?window_class:ImGuiWindowClass):ImGuiID {
		return 0;
	}

	/**
		Creates a dockspace covering a viewport.
	**/
	public static function dockSpaceOverViewport(dockspace_id:ImGuiID = 0, ?viewport:ImGuiViewport, flags:ImGuiDockNodeFlags = 0, ?window_class:ImGuiWindowClass):ImGuiID {
		return 0;
	}

	/**
		Sets next window dock id.
	**/
	public static function setNextWindowDockId(id:ImGuiID, cond:ImGuiCond = 0) {}

	/**
		Set next window class (control docking compatibility + provide hints to platform backend via custom viewport flags and platform parent/child relationship)
	**/
	public static function setNextWindowClass(window_class:ImGuiWindowClass):Void {}

	/**
		Returns window dock id.
	**/
	public static function getWindowDockId():ImGuiID {
		return 0;
	}

	/**
		Is current window docked into another window?
	**/
	public static function isWindowDocked():Bool {
		return false;
	}

	// [imgui_internal] Dock Builder

	/**
		Docks a named window into a dock-builder node.
	**/
	public static function dockBuilderDockWindow(window_name:String, node_id:ImGuiID) {}

	/**
		Returns a dock-builder node by ID.
	**/
	public static function dockBuilderGetNode(node_id:ImGuiID):ImGuiDockNode {
		return null;
	}

	/**
		Returns the central node of a dockspace.
	**/
	public static function dockBuilderGetCentralNode(node_id:ImGuiID):ImGuiDockNode {
		return null;
	}

	/**
		Adds a dock-builder node and returns its ID.
	**/
	public static function dockBuilderAddNode(node_id:ImGuiID, flags:ImGuiDockNodeFlags):ImGuiID {
		return 0;
	}

	/**
		Removes a dock-builder node and its layout.
	**/
	public static function dockBuilderRemoveNode(node_id:ImGuiID) {}

	/**
		Undocks all windows from a dock-builder node.
	**/
	public static function dockBuilderRemoveNodeDockedWindows(node_id:ImGuiID, clear_settings_refs:Bool) {}

	/**
		Removes all child nodes from a dock-builder node.
	**/
	public static function dockBuilderRemoveNodeChildNodes(node_id:ImGuiID) {}

	/**
		Sets a dock-builder node position in screen coordinates.
	**/
	public static function dockBuilderSetNodePos(node_id:ImGuiID, pos:ImVec2) {}

	/**
		Sets a dock-builder node size.
	**/
	public static function dockBuilderSetNodeSize(node_id:ImGuiID, size:ImVec2) {}

	/**
		Splits a dock-builder node and returns the resulting node IDs through the output references.
	**/
	public static function dockBuilderSplitNode(node_id:ImGuiID, split_dir:ImGuiDir, size_ratio_for_node_at_dir:Single, out_id_at_dir:Ref<ImGuiID>, out_id_at_opposite_dir:Ref<ImGuiID>) {
		return 0;
	}

	// DockBuilderCopyDockSpace
	// DockBuilderCopyNode

	/**
		Copies docking settings from one named window to another.
	**/
	public static function dockBuilderCopyWindowSettings(src_name:String, dst_name:String) {}

	/**
		Finishes a programmatically built dockspace.
	**/
	public static function dockBuilderFinish(node_id:ImGuiID) {}

	// Logging/Capture

	/**
		Start logging to tty (stdout)
	**/
	public static function logToTTY(auto_open_depth:Int = -1) {}

	/**
		Start logging to file.
	**/
	public static function logToFile(auto_open_depth:Int = -1, ?filename:String) {}

	/**
		Start logging to OS clipboard.
	**/
	public static function logToClipboard(auto_open_depth:Int = -1) {}

	/**
		Stop logging (close file, etc.)
	**/
	public static function logFinish() {}

	/**
		Helper to display buttons for logging to tty/file/clipboard.
	**/
	public static function logButtons() {}

	/**
		Pass text data straight to log (without being displayed)
	**/
	public static function logText(text:String) {} // Format arguments are not supported.

	// Drag and drop

	/**
		Call after submitting an item that may receive a payload. If this returns true, you can call AcceptDragDropPayload() + EndDragDropTarget()
	**/
	public static function beginDragDropTarget():Bool {
		return false;
	}

	/**
		Only call `endDragDropTarget()` if `beginDragDropTarget()` returns `true`!
	**/
	public static function endDragDropTarget() {}

	/**
		Call after submitting an item which may be dragged. when this return true, you can call SetDragDropPayload() + EndDragDropSource()
	**/
	public static function beginDragDropSource(flags:ImGuiDragDropFlags = 0):Bool {
		return false;
	}

	/**
		Only call `endDragDropSource()` if `beginDragDropSource()` returns `true`!
	**/
	public static function endDragDropSource() {}

	/**
		Type is a user defined string of maximum 32 characters. Strings starting with '_' are reserved for dear imgui internal types. Data is copied and held by imgui. Return true when payload has been accepted.
	**/
	public static function setDragDropPayload(type:String, payload:hl.Bytes, length:Int, cond:ImGuiCond = 0):Bool {
		return false;
	}

	/**
		Accept contents of a given type. If ImGuiDragDropFlags_AcceptBeforeDelivery is set you can peek into the payload before the mouse button is released.
	**/
	public static function acceptDragDropPayload(type:String, cond:ImGuiCond = 0):ImDragDropPayload {
		return null;
	}

	/**
		Peek directly into the current payload from anywhere. returns null when drag and drop is finished or inactive. use ImGuiPayload::IsDataType() to test for the payload type.
	**/
	public static function getDragDropPayload():ImDragDropPayload {
		return null;
	}

	/**
		Due to Haxe being a GC language, payload will be added as gc root until new payload is set or `clearDragDropPayloadObject()` is called.
		Alternatively, when accepting payload, call `payload.asObject(true)` to clear the stored object, however subsequent `asObject` calls will yield `null`.
	**/
	public static function setDragDropPayloadObject(type:String, payload:Dynamic, cond:ImGuiCond = 0):Bool {
		return false;
	}

	/**
		Clears drag drop payload object.
	**/
	public static function clearDragDropPayloadObject() {}

	/**
		Returns currently stored payload object.
	**/
	public static function getDragDropPayloadObject<T>():T {
		return null;
	}

	// Payload helpers

	/**
		Shortcut to set a String payload
	**/
	public static inline function setDragDropPayloadString(type:String, payload:String, cond:ImGuiCond = 0):Bool {
		var b = Bytes.ofString(payload + "\x00");
		return setDragDropPayload(type, b, b.length, cond);
	}

	/**
		Accept a drag&drop payload with specified type and return it as String or null if no payload present.
	**/
	public static inline function acceptDragDropPayloadString(type:String, cond:ImGuiCond = 0):String {
		var payload = acceptDragDropPayload(type, cond);
		return payload != null ? payload.asString : null;
	}

	/**
		Shortcut to set an Int payload
	**/
	public static inline function setDragDropPayloadInt(type:String, payload:Int, cond:ImGuiCond = 0):Bool {
		var b = new hl.Bytes(4);
		b.setI32(0, payload);
		return setDragDropPayload(type, b, 4, cond);
	}

	/**
		Accept a drag&drop payload with specified type and return it as an Int or 0 if no payload present.
	**/
	public static inline function acceptDragDropPayloadInt(type:String, cond:ImGuiCond = 0):Int {
		var payload = ImGui.acceptDragDropPayload(type);
		return payload != null ? payload.asInt : 0;
	}

	/**
		Accept a drag&drop payload with specified type and return it as `T` or null if no payload present.
	**/
	public static inline function acceptDragDropPayloadObject<T>(type:String, cond:ImGuiCond = 0, clear:Bool = false):T {
		var payload = ImGui.acceptDragDropPayload(type);
		return payload != null ? payload.asObject(clear) : null;
	}

	// Disabling [BETA API]

	/**
		Begins disabled. Call the corresponding end function only when this returns `true`, unless documented otherwise.
	**/
	public static inline function beginDisabled(disabled:Bool = true) {
		begin_disabled(disabled);
	}

	static function begin_disabled(disabled:Bool) {}

	/**
		Ends disabled.
	**/
	public static function endDisabled() {}

	// Clipping

	/**
		Render-level scissoring. This is passed down to your render function but not used for CPU-side coarse clipping. Prefer using higher-level ImGui.PushClipRect() to affect logic (hit-testing and widget culling)
	**/
	public static function pushClipRect(clip_rect_min:ImVec2, clip_rect_max:ImVec2, intersect_with_current_clip_rect:Bool) {}

	/**
		Pops clip rect from its stack.
	**/
	public static function popClipRect() {}

	// Focus, Activation

	/**
		Make last item the default focused item of a newly appearing window.
	**/
	public static function setItemDefaultFocus() {}

	/**
		Focus keyboard on the next widget. Use positive 'offset' to access sub components of a multiple component widget. Use -1 to access previous widget.
	**/
	public static function setKeyboardFocusHere(offset:Int = 0) {}

	/**
		Alter visibility of keyboard/gamepad cursor. by default: show when using an arrow key, hide when clicking with mouse.
	**/
	public static function setNavCursorVisible(visible:Bool):Void {}

	// Item/Widgets Utilities

	/**
		Is the last item hovered? (and usable, aka not blocked by a popup, etc.). See ImGuiHoveredFlags for more options.
	**/
	public static function isItemHovered(flags:ImGuiHoveredFlags = 0):Bool {
		return false;
	}

	/**
		Is the last item active? (e.g. button being held, text field being edited. This will continuously return true while holding mouse button on an item. Items that don't interact will always return false)
	**/
	public static function isItemActive():Bool {
		return false;
	}

	/**
		Is the last item focused for keyboard/gamepad navigation?
	**/
	public static function isItemFocused():Bool {
		return false;
	}

	/**
		Is the last item hovered and mouse clicked on? (**) == IsMouseClicked(mouse_button) && IsItemHovered()Important. (**) this is NOT equivalent to the behavior of e.g. Button(). Read comments in function definition.
	**/
	public static function isItemClicked(mouse_button:ImGuiMouseButton = 0):Bool {
		return false;
	}

	/**
		Is the last item visible? (items may be out of sight because of clipping/scrolling)
	**/
	public static function isItemVisible():Bool {
		return false;
	}

	/**
		Did the last item modify its underlying value this frame? or was pressed? This is generally the same as the "bool" return value of many widgets.
	**/
	public static function isItemEdited():Bool {
		return false;
	}

	/**
		Was the last item just made active (item was previously inactive).
	**/
	public static function isItemActivated():Bool {
		return false;
	}

	/**
		Was the last item just made inactive (item was previously active). Useful for Undo/Redo patterns with widgets that require continuous editing.
	**/
	public static function isItemDeactivated():Bool {
		return false;
	}

	/**
		Was the last item just made inactive and made a value change when it was active? (e.g. Slider/Drag moved). Useful for Undo/Redo patterns with widgets that require continuous editing. Note that you may get false positives (some widgets such as Combo()/ListBox()/Selectable() will return true even when clicking an already selected item).
	**/
	public static function isItemDeactivatedAfterEdit():Bool {
		return false;
	}

	/**
		Was the last item open state toggled? set by TreeNode().
	**/
	public static function isItemToggledOpen():Bool {
		return false;
	}

	/**
		Is any item hovered?
	**/
	public static function isAnyItemHovered():Bool {
		return false;
	}

	/**
		Is any item active?
	**/
	public static function isAnyItemActive():Bool {
		return false;
	}

	/**
		Is any item focused?
	**/
	public static function isAnyItemFocused():Bool {
		return false;
	}

	/**
		Get ID of last item (~~ often same ImGui.GetID(label) beforehand)
	**/
	public static function getItemID():ImGuiID {
		return 0;
	}

	/**
		Get upper-left bounding rectangle of the last item (screen space)
	**/
	public static function getItemRectMin():ImVec2 {
		return null;
	}

	/**
		Get lower-right bounding rectangle of the last item (screen space)
	**/
	public static function getItemRectMax():ImVec2 {
		return null;
	}

	/**
		Get size of last item.
	**/
	public static function getItemRectSize():ImVec2 {
		return null;
	}

	/**
		Get generic flags of last item.
	**/
	public static function getItemFlags():ImGuiItemFlags {
		return 0;
	}

	/**
		[BETA] building block for disambiguation between single-click and double-click. Returns 1 on single-click but delayed by io.MouseSingleClickDelay after mouse release. Returns 2+ on double-click or repeated clicks.
	**/
	public static function getItemClickedCountWithSingleClickDelay(mouse_button:ImGuiMouseButton = ImGuiMouseButton.Left, delay:Single = -1.0):Int {
		return 0;
	}

	/**
		Allow next item to be overlapped by a subsequent item. Typically useful with InvisibleButton(), Selectable(), TreeNode() covering an area where subsequent items may need to be added. Note that both Selectable() and TreeNode() have dedicated flags doing this.
	**/
	public static function setNextItemAllowOverlap():Void {}

	@:deprecated("Use setNextItemAllowOverlap() before submitting the item")
	/**
		Sets item allow overlap.
	**/
	public static function setItemAllowOverlap() {}

	// Key owner [EXPERIMENTAL API]

	/**
		Sets key owner.
	**/
	public static function setKeyOwner(key:ImGuiKey, owner_id:ImGuiID, flags:ImGuiInputFlags = ImGuiInputFlags.None):Void {}

	/**
		Set key owner to last item ID if it is hovered or active. Return true when ownership has been set. Roughly equivalent to 'if (TestKeyOwner(key, GetItemID()) && (IsItemHovered() || IsItemActive())) { SetKeyOwner(key, GetItemID());'.
	**/
	public static function setItemKeyOwner(key:ImGuiKey, flags:ImGuiInputFlags = ImGuiInputFlags.None):Bool {
		return false;
	}

	// Context accessors

	/**
		Returns the viewport associated with the current window context.
	**/
	public static function contextGetCurrentViewport():ImGuiViewport {
		return null;
	};

	// Miscellaneous Utilities

	/**
		Test if rectangle (of given size, starting from cursor position) is visible / not clipped.
	**/
	public static inline extern overload function isRectVisible(size:ImVec2):Bool {
		return is_rect_visible(size);
	}

	/**
		Test if rectangle (of given size, starting from cursor position) is visible / not clipped.
	**/
	public static inline extern overload function isRectVisible(rect_min:ImVec2, rect_max:ImVec2):Bool {
		return is_rect_visible2(rect_min, rect_max);
	}

	static function is_rect_visible(size:ImVec2):Bool {
		return false;
	}

	static function is_rect_visible2(rect_min:ImVec2, rect_max:ImVec2):Bool {
		return false;
	}

	/**
		Get global imgui time. incremented by io.DeltaTime every frame.
	**/
	public static function getTime():Float {
		return 0;
	}

	/**
		Get global imgui frame count. incremented by 1 every frame.
	**/
	public static function getFrameCount():Int {
		return 0;
	}

	/**
		Get foreground draw list for the given viewport or viewport associated to the current window. this draw list will be the top-most rendered one. Useful to quickly draw shapes/text over dear imgui contents.
	**/
	public static function getForegroundDrawList():ImDrawList {
		return null;
	}

	// getForegroundDrawList(viewport) // Viewport API

	/**
		Get background draw list for the given viewport or viewport associated to the current window. this draw list will be the first rendering one. Useful to quickly draw shapes/text behind dear imgui contents.
	**/
	public static function getBackgroundDrawList():ImDrawList {
		return null;
	}

	// getBackgroundDrawList(viewport) // Viewport API

	/**
		You may use this when creating your own ImDrawList instances.
	**/
	public static function getDrawListSharedData():ImDrawListSharedData {
		return null;
	}

	static function get_style_color_name(idx:ImGuiCol):hl.Bytes {
		return null;
	}

	/**
		Get a string corresponding to the enum value (for display, saving, etc.).
	**/
	public static function getStyleColorName(idx:ImGuiCol):String {
		return @:privateAccess String.fromUTF8(get_style_color_name(idx));
	}

	/**
		Returns state storage.
	**/
	public static function getStateStorage():ImStateStorage {
		return null;
	}

	/**
		Replace current window storage with our own (if you want to manipulate it yourself, typically clear subsection of it)
	**/
	public static function setStateStorage(storage:ImStateStorage):Void {}

	/**
		Begins child frame. Call the corresponding end function only when this returns `true`, unless documented otherwise.
	**/
	public static function beginChildFrame(id:ImGuiID, size:ImVec2, flags:ImGuiWindowFlags = 0):Bool {
		return false;
	}

	/**
		Always call `endChildFrame()` regardless of `beginChildFrame()` return value!
	**/
	public static function endChildFrame() {}

	@:deprecated("Obsolete: Use ImGuiListClipper")
	/**
		Calculates the visible item range for a uniformly sized list.
	**/
	public static function calcListClipping(items_count:Int, items_height:Single, out_items_display_start:Ref<Int>, out_items_display_end:Ref<Int>) {}

	// Text Utilities

	/**
		Calculates the rendered size of text without drawing it.
	**/
	public static function calcTextSize(text:String, ?text_end:String, hide_text_after_double_hash:Bool = false, wrap_width:Single = -1.0):ImVec2 {
		return null;
	}

	// Color Utilities

	/**
		Converts a packed 32-bit color to normalized RGBA components.
	**/
	public static function colorConvertU32ToFloat4(color:ImU32):ImVec4 {
		return null;
	}

	/**
		Converts normalized RGBA components to a packed 32-bit color.
	**/
	public static function colorConvertFloat4ToU32(color:ImVec4):ImU32 {
		return 0;
	}

	/**
		Converts RGB components to HSV and writes the results to the output references.
	**/
	public static function colorConvertRGBtoHSV(r:Single, g:Single, b:Single, out_h:Ref<Single>, out_s:Ref<Single>, out_v:Ref<Single>) {}

	/**
		Converts HSV components to RGB and writes the results to the output references.
	**/
	public static function colorConvertHSVtoRGB(h:Single, s:Single, v:Single, out_r:Ref<Single>, out_g:Ref<Single>, out_b:Ref<Single>) {}

	/**
		Helper method to reduce Ref dependency. w/alpha is preserved.
	**/
	public static function colorConvertRGBtoHSVVec(input:ImVec4):ImVec4 {
		return null;
	}

	/**
		Helper method to reduce Ref dependency. w/alpha is preserved.
	**/
	public static function colorConvertHSVtoRGBVec(input:ImVec4):ImVec4 {
		return null;
	}

	// Inputs Utilities: Keyboard

	/**
		Is key being held.
	**/
	public static function isKeyDown(key:ImGuiKey):Bool {
		return false;
	}

	/**
		Was key pressed (went from !Down to Down)? Repeat rate uses io.KeyRepeatDelay / KeyRepeatRate.
	**/
	public static function isKeyPressed(key:ImGuiKey, repeat:Bool = true):Bool {
		return false;
	}

	/**
		Was key released (went from Down to !Down)?
	**/
	public static function isKeyReleased(key:ImGuiKey):Bool {
		return false;
	}

	/**
		Was key chord (mods + key) pressed, e.g. you can pass 'ImGuiMod_Ctrl | ImGuiKey_S' as a key-chord. This doesn't do any routing or focus check, please consider using Shortcut() function instead.
	**/
	public static function isKeyChordPressed(key_chord:ImGuiKeyChord):Bool {
		return false;
	}

	/**
		Uses provided repeat rate/delay. return a count, most often 0 or 1 but might be >1 if RepeatRate is small enough that DeltaTime > RepeatRate.
	**/
	public static function getKeyPressedAmount(key:ImGuiKey, repeat_delay:Single, rate:Single):Int {
		return 0;
	}

	static function get_key_name(key:ImGuiKey):hl.Bytes {
		return null;
	}

	/**
		[DEBUG] returns English name of the key. Those names are provided for debugging purpose and are not meant to be saved persistently nor compared.
	**/
	public static function getKeyName(key:ImGuiKey):String {
		return @:privateAccess String.fromUTF8(get_key_name(key));
	}

	/**
		Returns `true` when the key chord is pressed according to the routing flags.
	**/
	public static function shortcut(key_chord:ImGuiKeyChord, flags:ImGuiInputFlags = ImGuiInputFlags.None):Bool {
		return false;
	}

	/**
		Sets next item shortcut.
	**/
	public static function setNextItemShortcut(key_chord:ImGuiKeyChord, flags:ImGuiInputFlags = ImGuiInputFlags.None):Void {}

	/**
		Requests keyboard capture for the next frame. Prefer reading `WantCaptureKeyboard` for input dispatch.
	**/
	public static function captureKeyboardFromApp(want_capture_keyboard_value:Bool = true) {}

	@:deprecated("Obsolete")
	/**
		Returns key index.
	**/
	public static function getKeyIndex(imgui_key:ImGuiKey):Int {
		return 0;
	}

	// Inputs Utilities: Mouse

	/**
		Is mouse button held?
	**/
	public static function isMouseDown(button:ImGuiMouseButton):Bool {
		return false;
	}

	/**
		Did mouse button clicked? (went from !Down to Down). Same as GetMouseClickedCount() == 1.
	**/
	public static function isMouseClicked(button:ImGuiMouseButton, repeat:Bool = false):Bool {
		return false;
	}

	/**
		Did mouse button released? (went from Down to !Down)
	**/
	public static function isMouseReleased(button:ImGuiMouseButton):Bool {
		return false;
	}

	/**
		Did mouse button double-clicked? Same as GetMouseClickedCount() == 2. (note that a double-click will also report IsMouseClicked() == true)
	**/
	public static function isMouseDoubleClicked(button:ImGuiMouseButton):Bool {
		return false;
	}

	/**
		Return the number of successive mouse-clicks at the time where a click happen (otherwise 0).
	**/
	public static function getMouseClickedCount(button:ImGuiMouseButton):Int {
		return 0;
	}

	/**
		Is mouse hovering given bounding rect (in screen space). clipped by current clipping settings, but disregarding of other consideration of focus/window ordering/popup-block.
	**/
	public static function isMouseHoveringRect(r_min:ImVec2, r_max:ImVec2, clip:Bool = true):Bool {
		return false;
	}

	/**
		By convention we use (-FLT_MAX,-FLT_MAX) to denote that there is no mouse available.
	**/
	public static function isMousePosValid(?mouse_pos:ImVec2):Bool {
		return false;
	}

	/**
		[WILL OBSOLETE] is any mouse button held? This was designed for backends, but prefer having backend maintain a mask of held mouse buttons, because upcoming input queue system will make this invalid.
	**/
	public static function isAnyMouseDown():Bool {
		return false;
	}

	/**
		Shortcut to ImGui.GetIO().MousePos provided by user, to be consistent with other calls.
	**/
	public static function getMousePos():ImVec2 {
		return null;
	}

	/**
		Retrieve mouse position at the time of opening popup we have BeginPopup() into (helper to avoid user backing that value themselves)
	**/
	public static function getMousePosOnOpeningCurrentPopup():ImVec2 {
		return null;
	}

	/**
		Is mouse dragging? (uses io.MouseDraggingThreshold if lock_threshold < 0.0f)
	**/
	public static function isMouseDragging(button:ImGuiMouseButton, lock_threshold:Single = -1.0):Bool {
		return false;
	}

	/**
		Return the delta from the initial clicking position while the mouse button is pressed or was just released. This is locked and return 0.0f until the mouse moves past a distance threshold at least once (uses io.MouseDraggingThreshold if lock_threshold < 0.0f)
	**/
	public static function getMouseDragDelta(button:ImGuiMouseButton = 0, lock_threshold:Single = -1.0):ImVec2 {
		return null;
	}

	/**
		Resets mouse drag delta.
	**/
	public static function resetMouseDragDelta(button:ImGuiMouseButton = 0) {}

	/**
		Get desired mouse cursor shape. Important: reset in ImGui.NewFrame(), this is updated during the frame. valid before Render(). If you use software rendering by setting io.MouseDrawCursor ImGui will render those for you.
	**/
	public static function getMouseCursor():ImGuiMouseCursor {
		return 0;
	}

	/**
		Set desired mouse cursor shape.
	**/
	public static function setMouseCursor(cursor_type:ImGuiMouseCursor) {}

	/**
		Requests mouse capture for the next frame. Prefer reading `WantCaptureMouse` for input dispatch.
	**/
	public static function captureMouseFromApp(want_capture_mouse_value:Bool = true) {}

	// Clipboard Utilities
	static function get_clipboard_text():hl.Bytes {
		return null;
	}

	/**
		Returns clipboard text.
	**/
	public static function getClipboardText():String {
		return @:privateAccess String.fromUTF8(get_clipboard_text());
	}

	/**
		Sets clipboard text.
	**/
	public static function setClipboardText(text:String) {}

	// Settings/.Ini Utilities

	/**
		Call after CreateContext() and before the first call to NewFrame(). NewFrame() automatically calls LoadIniSettingsFromDisk(io.IniFilename).
	**/
	public static function loadIniSettingsFromDisk(ini_filename:String) {}

	/**
		Call after CreateContext() and before the first call to NewFrame() to provide .ini data from your own data source.
	**/
	public static function loadIniSettingsFromMemory(ini_data:String, ini_size:Int = 0) {}

	/**
		This is automatically called (if io.IniFilename is not empty) a few seconds after any modification that should be reflected in the .ini file (and also by DestroyContext).
	**/
	public static function saveIniSettingsToDisk(ini_filename:String) {}

	static function save_ini_settings_to_memory(out_ini_size:Ref<Int>):hl.Bytes {
		return null;
	}

	/**
		Return a zero-terminated string with the .ini data which you can save by your own mean. call when io.WantSaveIniSettings is set, then save data by your own mean and clear io.WantSaveIniSettings.
	**/
	public static function saveIniSettingsToMemory(?out_ini_size:Ref<Int>):String {
		return @:privateAccess String.fromUTF8(save_ini_settings_to_memory(out_ini_size));
	}

	// Viewport

	/**
		Return primary/default viewport. This can never be null.
	**/
	public static function getMainViewport():ImGuiViewport {
		return null;
	}

	/**
		Call in main loop. will call CreateWindow/ResizeWindow/etc. platform functions for each secondary viewport, and DestroyWindow for each inactive viewport.
	**/
	public static function updatePlatformWindows() {};

	/**
		Call in main loop. will call RenderWindow/SwapBuffers platform functions for each secondary viewport which doesn't have the ImGuiViewportFlags_Minimized flag set. May be reimplemented by user for custom rendering needs.
	**/
	public static function renderPlatformWindowsDefault(?platform_arg:Dynamic, ?render_arg:Dynamic) {};

	/**
		Call DestroyWindow platform functions for all viewports. call from backend Shutdown() if you need to close platform windows before imgui shutdown. otherwise will be called by DestroyContext().
	**/
	public static function destroyPlatformWindows():Void {};

	/**
		Clears callbacks installed by the platform and viewport renderer backends.
	**/
	@:noCompletion public static function clearPlatformCallbacks():Void {};

	/**
		This is a helper for backends.
	**/
	public static function findViewportByID(viewport_id:ImGuiID):ImGuiViewport {
		return null;
	}

	/**
		The handle must be the same opaque object stored in ImGuiViewport.PlatformHandle.
	**/
	public static function findViewportByPlatformHandle(platform_handle:Dynamic):ImGuiViewport {
		return null;
	}

	// Debug Utilities

	/**
		Displays UTF-8 encoding diagnostics for the supplied text.
	**/
	public static function debugTextEncoding(text:String):Void {}

	/**
		Flashes a style color in the user interface for debugging.
	**/
	public static function debugFlashStyleColor(idx:ImGuiCol):Void {}

	/**
		Starts Dear ImGui's interactive item picker.
	**/
	public static function debugStartItemPicker():Void {}

	// debugCheckVersionAndDataLayout
	// GetDrawData remains internal: render() immediately converts it into RenderList for the HashLink renderer callback.
	// Memory Allocators - Should not be exposed!
	// setAllocatorFunctions(ImGuiMemAllocFunc alloc_func, ImGuiMemFreeFunc free_func, void* user_data = NULL);
	// getAllocatorFunctions(ImGuiMemAllocFunc* p_alloc_func, ImGuiMemFreeFunc* p_free_func, void** p_user_data);
	// memAlloc(size_t size);
	// memFree(void* ptr);
	// (Optional) Platform/OS interface for multi-viewport support
	// Read comments around the ImGuiPlatformIO structure for more details.
	// Note: You may use GetWindowViewport() to get the current viewport of the current window.
	// GetPlatformIO(): ImGuiPlatformIO
	// UpdatePlatformWindows();                                        // call in main loop. will call CreateWindow/ResizeWindow/etc. platform functions for each secondary viewport, and DestroyWindow for each inactive viewport.
	// RenderPlatformWindowsDefault(void* platform_render_arg = NULL, void* renderer_render_arg = NULL); // call in main loop. will call RenderWindow/SwapBuffers platform functions for each secondary viewport which doesn't have the ImGuiViewportFlags_Minimized flag set. May be reimplemented by user for custom rendering needs.
	// DestroyPlatformWindows();                                       // call DestroyWindow platform functions for all viewports. call from backend Shutdown() if you need to close platform windows before imgui shutdown. otherwise will be called by DestroyContext().
	// FindViewportByID(ImGuiID id): ImGuiViewport;                                   // this is a helper for backends.
	// FindViewportByPlatformHandle(void* platform_handle): ImGuiViewport;            // this is a helper for backends. the type platform_handle is decided by the backend (e.g. HWND, MyWindow*, GLFWwindow* etc.)
	// GetIO()->... wrappers

	/**
		Sets ini filename.
	**/
	@:deprecated public static function setIniFilename(filename:String) {} // IniFilename

	/**
		Queues a Unicode character as text input.
	**/
	@:deprecated public static function addKeyChar(c:Int) {} // AddInputCharacter

	/**
		Queue a new key down/up event. Key should be "translated" (as in, generally ImGuiKey_A matches the key end-user would use to emit an 'A' character)
	**/
	@:deprecated public static function addKeyEvent(c:Int, down:Bool) {} // AddKeyEvent

	// Shortcut to set MousePos, MouseWheel, MouseDown[0] and MouseDown[1]

	/**
		Sets events.
	**/
	@:deprecated public static function setEvents(dt:Single, mouse_x:Single, mouse_y:Single, wheel:Single, left_click:Bool, right_click:Bool) {}

	/**
		Sets display size.
	**/
	@:deprecated public static function setDisplaySize(display_width:Int, display_height:Int) {} // DisplaySize

	/**
		Returns whether Dear ImGui wants to consume mouse input.
	**/
	@:deprecated public static function wantCaptureMouse():Bool {
		return false;
	} // WantCaptureMouse

	/**
		Returns whether Dear ImGui wants to consume keyboard input.
	**/
	@:deprecated public static function wantCaptureKeyboard():Bool {
		return false;
	} // WantCaptureKeyboard

	/**
		Sets config flags.
	**/
	@:deprecated public static function setConfigFlags(flags:ImGuiConfigFlags = 0):Void {} // ConfigFlags

	/**
		Returns config flags.
	**/
	@:deprecated public static function getConfigFlags():ImGuiConfigFlags {
		return 0;
	} // ConfigFlags

	/**
		Sets user data.
	**/
	@:deprecated public static function setUserData(data:Dynamic) {} // UserData; Should be safe to store anything and not be GCd.

	/**
		Returns user data.
	**/
	@:deprecated public static function getUserData():Dynamic {
		return null;
	} // UserData

	/**
		Returns font atlas.
	**/
	public static function getFontAtlas():ImFontAtlas {
		return null;
	}

	// internal functions

	/**
		Sets render callback.
	**/
	public static function setRenderCallback(render_fn:RenderList -> Void) {}

	/**
		Sets texture callback.
	**/
	public static function setTextureCallback(texture_fn:RenderTextureList -> Void) {}

	/**
		Marks renderer textures for recreation.
	**/
	public static function invalidateRendererTextures() {}

	/**
		Mandatory to call before anything else!
		Provides C side the necessary hl_type references for data constructed on C side such as ImVec2 and ImVec4.
	**/
	public static inline function provideTypes() @:privateAccess {
		_init(ImVec2.get(), ImVec4.get(), new RenderList(), new RenderData(), new RenderCommand(), new RenderTextureList(), new RenderTextureData());
	}

	@:hlNative("hlimgui", "initialize")
	static function _init(vec2:ImVec2, vec4:ImVec4, renderlist:RenderList, renderdata:RenderData, rendercommand:RenderCommand, texturelist:RenderTextureList, texturedata:RenderTextureData) {};

	/**
		Bootstrap helper to initialize Imgui.
	**/
	public static inline function initialize(render_fn:RenderList -> Void):ImFontTexData {
		provideTypes();
		ensureContext();
		setRenderCallback(render_fn);
		var fonts = getFontAtlas();
		fonts.addFontDefault();
		var output = new ImFontTexData();
		fonts.getTexDataAsRGBA32(output);
		fonts.clearTexData();
		return output;
	}

	@:deprecated("Use beginPopupContextWindow(id, MouseButtonRight | NoOpenOverItems)") @:noCompletion
	/**
		Begins popup context window2. Call the corresponding end function only when this returns `true`, unless documented otherwise.
	**/
	public static function beginPopupContextWindow2(?str_id:String, mouse_button:ImGuiMouseButton = 1, also_over_items:Bool = true):Bool {
		return beginPopupContextWindow(str_id, mouse_button | (also_over_items ? NoOpenOverItems : 0));
	}

	// DEPRECATED SECTION

	@:deprecated("Use getFontAtlas().getTexDataAsRGBA32() + getFontAtlas().clearTexData()") @:noCompletion
	/**
		Returns tex data as rgba32.
	**/
	public static inline function getTexDataAsRgba32():ImFontTexData {
		var atlas = getFontAtlas();
		var output = new ImFontTexData();
		atlas.getTexDataAsRGBA32(output);
		atlas.clearTexData();
		return output;
	}

	// ImFontAtlas / ImGui::GetIO().Fonts->... wrappers

	@:deprecated("Use getFontAtlas().setTexId()")
	/**
		Sets font texture.
	**/
	public static inline function setFontTexture(texture_id:ImTextureID) {
		getFontAtlas().setTexId(texture_id);
	}

	@:deprecated("Use getFontAtlas().addFontDefault()")
	/**
		Selects between AddFontDefaultVector() and AddFontDefaultBitmap().
	**/
	public static inline function addFontDefault(?config:ImFontConfig):ImFont {
		return getFontAtlas().addFontDefault(config);
	}

	@:deprecated("Use getFontAtlas().addFontFromFileTTF()")
	/**
		Loads a TrueType font from a file into the current font atlas.
	**/
	public static inline function addFontFromFileTtf(filename:String, size:Single, ?config:ImFontConfig, ?glyphRanges:hl.NativeArray<hl.UI16>):ImFont {
		return getFontAtlas().addFontFromFileTTF(filename, size, config, glyphRanges);
	}

	@:deprecated("Use getFontAtlas().addFontFromMemoryTTF()")
	/**
		Loads TrueType font bytes into the current font atlas.
	**/
	public static inline function addFontFromMemoryTtf(bytes:hl.Bytes, size:Int, font_size:Single, ?config:ImFontConfig, ?glyphRanges:hl.NativeArray<hl.UI16>):ImFont {
		return getFontAtlas().addFontFromMemoryTTF(bytes, size, font_size, config, glyphRanges);
	}

	@:deprecated("Use getFontAtlas().build()")
	/**
		Builds the current font atlas and returns whether it succeeded.
	**/
	public static inline function buildFont():Bool {
		return getFontAtlas().build();
	}

	@:deprecated("Use beginListBox")
	/**
		Begins a legacy list-box region. Call `listBoxFooter()` when it returns `true`.
	**/
	public static inline function listBoxHeader(label:String, ?size:ImVec2):Bool {
		return beginListBox(label, size);
	}

	@:deprecated("Obsolete")
	/**
		Begins a legacy list-box region sized from its item count. Call `listBoxFooter()` when it returns `true`.
	**/
	public static function listBoxHeader2(label:String, items_count:Int, height_in_items:Int = -1):Bool {
		return false;
	}

	@:deprecated("Use endListBox")
	/**
		Ends a legacy list-box region.
	**/
	public static inline function listBoxFooter() {
		endListBox();
	}

	@:deprecated("Use inputFloatN")
	/**
		Displays an editable input field and updates the supplied value when edited.
	**/
	public static inline function inputFloat2(label:String, v:hl.NativeArray<Single>, format:String = "%.3f", flags:ImGuiInputTextFlags = 0):Bool {
		return inputFloatN(label, v, format, flags);
	}

	@:deprecated("Use inputFloatN")
	/**
		Displays an editable input field and updates the supplied value when edited.
	**/
	public static inline function inputFloat3(label:String, v:hl.NativeArray<Single>, format:String = "%.3f", flags:ImGuiInputTextFlags = 0):Bool {
		return inputFloatN(label, v, format, flags);
	}

	@:deprecated("Use inputFloatN")
	/**
		Displays an editable input field and updates the supplied value when edited.
	**/
	public static inline function inputFloat4(label:String, v:hl.NativeArray<Single>, format:String = "%.3f", flags:ImGuiInputTextFlags = 0):Bool {
		return inputFloatN(label, v, format, flags);
	}

	@:deprecated("Use inputIntN")
	/**
		Displays an editable input field and updates the supplied value when edited.
	**/
	public static inline function inputInt2(label:String, v:hl.NativeArray<Int>, flags:ImGuiInputTextFlags = 0):Bool {
		return inputIntN(label, v, flags);
	}

	@:deprecated("Use inputIntN")
	/**
		Displays an editable input field and updates the supplied value when edited.
	**/
	public static inline function inputInt3(label:String, v:hl.NativeArray<Int>, flags:ImGuiInputTextFlags = 0):Bool {
		return inputIntN(label, v, flags);
	}

	@:deprecated("Use inputIntN")
	/**
		Displays an editable input field and updates the supplied value when edited.
	**/
	public static inline function inputInt4(label:String, v:hl.NativeArray<Int>, flags:ImGuiInputTextFlags = 0):Bool {
		return inputIntN(label, v, flags);
	}

	@:deprecated("Obsolete in latest imgui. Use GetWindowContentRegionMax().x - GetWindowContentRegionMin().x")
	/**
		Returns window content region width.
	**/
	public static function getWindowContentRegionWidth():Single {
		return 0;
	}

	@:deprecated("use getIDSub") @:noCompletion public static function getID2(str_id:String, begin:Int, end:Int):Int {
		return getIDSub(str_id, begin, end);
	}

	@:deprecated("use pushIDSub") @:noCompletion public static inline function pushID2(str_id:String, begin:Int, end:Int) {
		pushIDSub(str_id, begin, end);
	}

	@:deprecated("use pushIDInt") @:noCompletion public static inline function pushID3(int_id:Int) {
		pushIDInt(int_id);
	}

	// Pre-overload support methods.

	@:deprecated("Use beginChild overload.") @:noCompletion
	/**
		Begins child2. Call the corresponding end function only when this returns `true`, unless documented otherwise.
	**/
	public static inline function beginChild2(id:Int, ?size:ImVec2, childFlags:ImGuiChildFlags = 0, windowFlags:ImGuiWindowFlags = 0):Bool {
		return begin_child2(id, size, childFlags, windowFlags);
	}

	@:deprecated("Use setWindowPos overload.") @:noCompletion
	/**
		Sets window pos2.
	**/
	public static inline function setWindowPos2(name:String, pos:ImVec2, cond:ImGuiCond = 0) {
		set_window_pos2(name, pos, cond);
	}

	@:deprecated("Use setWindowSize overload.") @:noCompletion
	/**
		Sets window size2.
	**/
	public static inline function setWindowSize2(name:String, size:ImVec2, cond:ImGuiCond = 0) {
		set_window_size2(name, size, cond);
	}

	@:deprecated("Use setWindowCollapsed overload.") @:noCompletion
	/**
		Sets window collapsed2.
	**/
	public static inline function setWindowCollapsed2(name:String, collapsed:Bool, cond:ImGuiCond = 0) {
		set_window_collapsed2(name, collapsed, cond);
	}

	@:deprecated("Use setWindowFocus overload.") @:noCompletion
	/**
		Sets window focus2.
	**/
	public static inline function setWindowFocus2(name:String) {
		set_window_focus2(name);
	}

	@:deprecated("Use pushStyleColor overload.") @:noCompletion
	/**
		Pushes style color2 onto its stack.
	**/
	public static inline function pushStyleColor2(idx:ImGuiCol, col:ImVec4) {
		push_style_color2(idx, col);
	}

	@:deprecated("Use pushStyleVar overload.") @:noCompletion
	/**
		Pushes style var2 onto its stack.
	**/
	public static inline function pushStyleVar2(idx:ImGuiStyleVar, val:ImVec2) {
		push_style_var2(idx, val);
	}

	@:deprecated("Use getColorU32 overload.") @:noCompletion
	/**
		Returns color u322.
	**/
	public static inline function getColorU322(col:ImVec4):ImU32 {
		return get_color_u322(col);
	}

	@:deprecated("Use getColorU32 overload.") @:noCompletion
	/**
		Returns color u323.
	**/
	public static inline function getColorU323(col:ImU32):ImU32 {
		return get_color_u323(col);
	}

	@:deprecated("Use radioButton overload.") @:noCompletion
	/**
		Displays a radio button and sets the referenced value when activated.
	**/
	public static inline function radioButton2(label:String, v:Ref<Int>, v_button:Int):Bool {
		return radio_button2(label, v, v_button);
	}

	@:deprecated("Use combo overload.") @:noCompletion
	/**
		Displays a combo box backed by a zero-separated item string.
	**/
	public static inline function combo2(label:String, current_item:Ref<Int>, items_separated_by_zeros:String, popup_max_height_in_items:Int = -1):Bool {
		return _combo2(label, current_item, items_separated_by_zeros, popup_max_height_in_items);
	}

	@:deprecated("Use treeNode overload.") @:noCompletion
	/**
		Begins a tree node using a separate ID and visible label.
	**/
	public static inline function treeNode2(str_id:String, label:String):Bool {
		return tree_node2(str_id, label);
	}

	@:deprecated("Use treeNodeEx overload.") @:noCompletion
	/**
		Begins a flagged tree node using a separate ID and visible label.
	**/
	public static inline function treeNodeEx2(str_id:String, flags:ImGuiTreeNodeFlags, label:String):Bool {
		return tree_node_ex2(str_id, flags, label);
	}

	@:deprecated("Use collapsingHeader overload.") @:noCompletion
	/**
		Displays a closable collapsing header and updates its open state.
	**/
	public static inline function collapsingHeader2(label:String, p_open:Ref<Bool>, flags:ImGuiTreeNodeFlags = 0):Bool {
		return collapsing_header2(label, p_open, flags);
	}

	@:deprecated("Use selectable overload.") @:noCompletion
	/**
		Displays a selectable item and updates its selected state.
	**/
	public static inline function selectable2(label:String, p_selected:Ref<Bool>, flags:ImGuiSelectableFlags = 0, ?size:ImVec2):Bool {
		return _selectable2(label, p_selected, flags, size);
	}

	@:deprecated("Use menuItem overload.") @:noCompletion
	/**
		Displays a menu item and updates its selected state.
	**/
	public static inline function menuItem2(label:String, shortcut:String, p_selected:Ref<Bool>, enabled:Bool = true):Bool {
		return menu_item2(label, shortcut, p_selected, enabled);
	}

	@:deprecated("Use isRectVisible overload.") @:noCompletion
	/**
		Returns whether rect visible2.
	**/
	public static inline function isRectVisible2(rect_min:ImVec2, rect_max:ImVec2):Bool {
		return false;
	}
}
