package imgui;

#if hlimgui
import imgui.ImGui.ImVec2;
import imgui.ImGui.ImVec2S;
import imgui.ImGui.ImVec4;
import imgui.ImGui.ImVec4S;
import imgui.ImGui.ImDrawList;

/**
	Stable identifier for node.
**/
typedef NodeId = hl.I64;

/**
	Stable identifier for pin.
**/
typedef PinId = hl.I64;

/**
	Stable identifier for link.
**/
typedef LinkId = hl.I64;

private typedef ImDrawListPtr = hl.Abstract<"imdrawlist">;

/**
	Opaque native context owned by a node editor instance.
**/
typedef EditorContext = hl.Abstract<"imnecontext">;

/**
	Values representing style color.
**/
enum abstract StyleColor(Int) from Int to Int {
	/**
		The background style color.
	**/
	var Bg = 0;

	/**
		The grid style color.
	**/
	var Grid = 1;

	/**
		The node background style color.
	**/
	var NodeBg = 2;

	/**
		The node border style color.
	**/
	var NodeBorder = 3;

	/**
		The hovered node border style color.
	**/
	var HovNodeBorder = 4;

	/**
		The selected node border style color.
	**/
	var SelNodeBorder = 5;

	/**
		The node selected rectangle style color.
	**/
	var NodeSelRect = 6;

	/**
		The node selected rectangle border style color.
	**/
	var NodeSelRectBorder = 7;

	/**
		The hovered link border style color.
	**/
	var HovLinkBorder = 8;

	/**
		The selected link border style color.
	**/
	var SelLinkBorder = 9;

	/**
		The link selected rectangle style color.
	**/
	var LinkSelRect = 10;

	/**
		The link selected rectangle border style color.
	**/
	var LinkSelRectBorder = 11;

	/**
		The pin rectangle style color.
	**/
	var PinRect = 12;

	/**
		The pin rectangle border style color.
	**/
	var PinRectBorder = 13;

	/**
		The flow style color.
	**/
	var Flow = 14;

	/**
		The flow marker style color.
	**/
	var FlowMarker = 15;

	/**
		The group background style color.
	**/
	var GroupBg = 16;

	/**
		The group border style color.
	**/
	var GroupBorder = 17;

	/**
		Number of values in this enumeration.
	**/
	var Count = 18;
}

/**
	Values representing style var.
**/
enum abstract StyleVar(Int) from Int to Int {
	/**
		The `NodePadding` value of `StyleVar`.
	**/
	var NodePadding = 0;

	/**
		The `NodeRounding` value of `StyleVar`.
	**/
	var NodeRounding = 1;

	/**
		The `NodeBorderWidth` value of `StyleVar`.
	**/
	var NodeBorderWidth = 2;

	/**
		The `HoveredNodeBorderWidth` value of `StyleVar`.
	**/
	var HoveredNodeBorderWidth = 3;

	/**
		The `SelectedNodeBorderWidth` value of `StyleVar`.
	**/
	var SelectedNodeBorderWidth = 4;

	/**
		The `PinRounding` value of `StyleVar`.
	**/
	var PinRounding = 5;

	/**
		The `PinBorderWidth` value of `StyleVar`.
	**/
	var PinBorderWidth = 6;

	/**
		The `LinkStrength` value of `StyleVar`.
	**/
	var LinkStrength = 7;

	/**
		The `SourceDirection` value of `StyleVar`.
	**/
	var SourceDirection = 8;

	/**
		The `TargetDirection` value of `StyleVar`.
	**/
	var TargetDirection = 9;

	/**
		The `ScrollDuration` value of `StyleVar`.
	**/
	var ScrollDuration = 10;

	/**
		The `FlowMarkerDistance` value of `StyleVar`.
	**/
	var FlowMarkerDistance = 11;

	/**
		The `FlowSpeed` value of `StyleVar`.
	**/
	var FlowSpeed = 12;

	/**
		The `FlowDuration` value of `StyleVar`.
	**/
	var FlowDuration = 13;

	/**
		The `PivotAlignment` value of `StyleVar`.
	**/
	var PivotAlignment = 14;

	/**
		The `PivotSize` value of `StyleVar`.
	**/
	var PivotSize = 15;

	/**
		The `PivotScale` value of `StyleVar`.
	**/
	var PivotScale = 16;

	/**
		The `PinCorners` value of `StyleVar`.
	**/
	var PinCorners = 17;

	/**
		The `PinRadius` value of `StyleVar`.
	**/
	var PinRadius = 18;

	/**
		The `PinArrowSize` value of `StyleVar`.
	**/
	var PinArrowSize = 19;

	/**
		The `PinArrowWidth` value of `StyleVar`.
	**/
	var PinArrowWidth = 20;

	/**
		The `GroupRounding` value of `StyleVar`.
	**/
	var GroupRounding = 21;

	/**
		The `GroupBorderWidth` value of `StyleVar`.
	**/
	var GroupBorderWidth = 22;

	/**
		Number of values in this enumeration.
	**/
	var Count = 23;
}

/**
	Node editor style.
	Unlike imgui style, there's no "set" function, so there is no constructor.
**/
@:keep
@:build(imgui._ImGuiInternalMacro.buildFlatStruct())
@:hlNative("hlimgui", "nodeeditor_")
@:struct
class Style {
	@:flatten var NodePadding:ImVec4S;

	/**
		Controls node rounding.
	**/
	public var NodeRounding:Single;

	/**
		Controls node border width.
	**/
	public var NodeBorderWidth:Single;

	/**
		Controls hovered node border width.
	**/
	public var HoveredNodeBorderWidth:Single;

	/**
		Controls selected node border width.
	**/
	public var SelectedNodeBorderWidth:Single;

	/**
		Controls pin rounding.
	**/
	public var PinRounding:Single;

	/**
		Controls pin border width.
	**/
	public var PinBorderWidth:Single;

	/**
		Controls link strength.
	**/
	public var LinkStrength:Single;

	@:flatten var SourceDirection:ImVec2;
	@:flatten var TargetDirection:ImVec2;

	/**
		Controls scroll duration.
	**/
	public var ScrollDuration:Single;

	/**
		Controls flow marker distance.
	**/
	public var FlowMarkerDistance:Single;

	/**
		Controls flow speed.
	**/
	public var FlowSpeed:Single;

	/**
		Controls flow duration.
	**/
	public var FlowDuration:Single;

	@:flatten var PivotAlignment:ImVec2;
	@:flatten var PivotSize:ImVec2;
	@:flatten var PivotScale:ImVec2;

	/**
		Controls pin corners.
	**/
	public var PinCorners:Single;

	/**
		Controls pin radius.
	**/
	public var PinRadius:Single;

	/**
		The pin arrow size.
	**/
	public var PinArrowSize:Single;

	/**
		Controls pin arrow width.
	**/
	public var PinArrowWidth:Single;

	/**
		Controls group rounding.
	**/
	public var GroupRounding:Single;

	/**
		Controls group border width.
	**/
	public var GroupBorderWidth:Single;

	@:flattenMap(StyleColor) var Colors:ImVec4S;

	/**
		Creates a new `Style` instance.
	**/
	public function new() {
		init_style(this);
	}

	static function init_style(style:Style) {}
}

/**
	Values representing pin kind.
**/
enum abstract PinKind(Int) from Int to Int {
	/**
		The `Input` value of `PinKind`.
	**/
	var Input:Int = 0;

	/**
		The `Output` value of `PinKind`.
	**/
	var Output:Int = 1;
}

/**
	Values representing flow direction.
**/
enum abstract FlowDirection(Int) from Int to Int {
	/**
		The forward direction.
	**/
	var Forward:Int = 0;

	/**
		The backward direction.
	**/
	var Backward:Int = 1;
}

/**
	Immediate-mode node editor API.
**/
@:hlNative("hlimgui", "nodeeditor_")
class NodeEditor {
	// Context

	/**
		Sets current editor.
	**/
	public static function setCurrentEditor(context:EditorContext):Void {}

	/**
		Returns current editor.
	**/
	public static function getCurrentEditor():EditorContext {
		return null;
	}

	/**
		Creates editor.
	**/
	public static function createEditor():EditorContext {
		return null;
	}

	/**
		Destroys editor.
	**/
	public static function destroyEditor(context:EditorContext):Void {}

	// Style

	/**
		Access the Style structure (colors, sizes). Always use PushStyleColor(), PushStyleVar() to modify style mid-frame!
	**/
	public static function getStyle():Style {
		return null;
	}

	/**
		Sets style.
	**/
	public static function setStyle(style:Style) {}

	/**
		Modify a style float variable. always use this if you modify the style after NewFrame()!
	**/
	public static function pushStyleVar(varIndex:StyleVar, val:Single) {}

	/**
		Pushes style var2 onto its stack.
	**/
	public static function pushStyleVar2(varIndex:StyleVar, vec2:ImVec2) {}

	/**
		Pushes style var3 onto its stack.
	**/
	public static function pushStyleVar3(varIndex:StyleVar, vec4:ImVec4) {}

	/**
		Pops style var from its stack.
	**/
	public static function popStyleVar(count:Int = 1) {}

	/**
		Modify a style color. always use this if you modify the style after NewFrame().
	**/
	public static function pushStyleColor(varIndex:StyleColor, vec2:ImVec4) {}

	/**
		Pops style color from its stack.
	**/
	public static function popStyleColor(count:Int = 1) {}

	// Item

	/**
		Begins this API scope. Call the matching `end()` function according to its return-value contract.
	**/
	public static function begin(name:String, ?size:ImVec2):Void {}

	/**
		Automatically called on the last call of Step() that returns false.
	**/
	public static function end():Void {}

	/**
		Begins node. Call its matching end function only when this returns `true`, unless documented otherwise.
	**/
	public static function beginNode(nodeId:NodeId):Void {}

	/**
		Ends node.
	**/
	public static function endNode():Void {}

	/**
		Begins pin. Call its matching end function only when this returns `true`, unless documented otherwise.
	**/
	public static function beginPin(pinId:PinId, kind:PinKind):Void {}

	/**
		Sets the pin interaction rectangle.
	**/
	public static function pinRect(a:ImVec2, b:ImVec2):Void {}

	/**
		Sets the pin pivot rectangle.
	**/
	public static function pinPivotRect(a:ImVec2, b:ImVec2):Void {}

	/**
		Sets the pin pivot size.
	**/
	public static function pinPivotSize(size:ImVec2):Void {}

	/**
		Sets the pin pivot scale.
	**/
	public static function pinPivotScale(scale:ImVec2):Void {}

	/**
		Sets the pin pivot alignment.
	**/
	public static function pinPivotAlignment(alignment:ImVec2):Void {}

	/**
		Ends pin.
	**/
	public static function endPin():Void {}

	// group

	/**
		Groups the current node contents into the supplied size.
	**/
	public static function group(size:ImVec2 = null):Void {}

	/**
		Begins group hint. Call its matching end function only when this returns `true`, unless documented otherwise.
	**/
	public static function beginGroupHint(nodeId:NodeId):Bool {
		return false;
	}

	/**
		Returns group min.
	**/
	public static function getGroupMin():ImVec2 {
		return null;
	}

	/**
		Returns group max.
	**/
	public static function getGroupMax():ImVec2 {
		return null;
	}

	/**
		Returns hint foreground draw list.
	**/
	public static inline function getHintForegroundDrawList():ImDrawList {
		return new ImDrawList(get_hint_foreground_draw_list());
	}

	/**
		Returns hint background draw list.
	**/
	public static inline function getHintBackgroundDrawList():ImDrawList {
		return new ImDrawList(get_hint_background_draw_list());
	}

	/**
		Ends group hint.
	**/
	public static function endGroupHint():Void {}

	/**
		Returns node background draw list.
	**/
	public static inline function getNodeBackgroundDrawList(nodeId:NodeId):ImDrawList {
		return new ImDrawList(get_node_background_draw_list(nodeId));
	}

	/**
		Draws a link between the supplied pins.
	**/
	public static function link(linkId:LinkId, startId:PinId, endId:PinId, color:ImVec4 = null, thickness:Single = 0):Bool {
		return false;
	}

	/**
		Starts the flow animation for a link.
	**/
	public static function flow(linkId:LinkId, direction:FlowDirection = FlowDirection.Forward):Void {}

	// Create

	/**
		Begins create. Call its matching end function only when this returns `true`, unless documented otherwise.
	**/
	public static function beginCreate(color:ImVec4 = null, thickness:Single = 1.0):Bool {
		return false;
	}

	/**
		Queries new link.
	**/
	public static function queryNewLink(startPinId:hl.Ref<PinId>, endPinId:hl.Ref<PinId>):Bool {
		return false;
	}

	/**
		Queries new link2.
	**/
	public static function queryNewLink2(startPinId:hl.Ref<PinId>, endPinId:hl.Ref<PinId>, color:ImVec4, thickness:Single = 1.0):Bool {
		return false;
	}

	/**
		Queries new node.
	**/
	public static function queryNewNode(startNodeId:hl.Ref<NodeId>):Bool {
		return false;
	}

	/**
		Queries new node2.
	**/
	public static function queryNewNode2(startNodeId:hl.Ref<NodeId>, color:ImVec4, thickness:Single = 1.0):Bool {
		return false;
	}

	/**
		Accepts new item.
	**/
	public static function acceptNewItem():Bool {
		return false;
	}

	/**
		Accepts new item2.
	**/
	public static function acceptNewItem2(color:ImVec4 = null, thickness:Single = 1.0):Bool {
		return false;
	}

	/**
		Rejects new item.
	**/
	public static function rejectNewItem():Bool {
		return false;
	}

	/**
		Rejects new item2.
	**/
	public static function rejectNewItem2(color:ImVec4 = null, thickness:Single = 1.0):Bool {
		return false;
	}

	/**
		Ends create.
	**/
	public static function endCreate():Void {}

	// Delete

	/**
		Begins delete. Call its matching end function only when this returns `true`, unless documented otherwise.
	**/
	public static function beginDelete():Bool {
		return false;
	}

	/**
		Queries deleted link.
	**/
	public static function queryDeletedLink(linkId:hl.Ref<LinkId>, startId:hl.Ref<PinId>, endId:hl.Ref<PinId>):Bool {
		return false;
	}

	/**
		Queries deleted node.
	**/
	public static function queryDeletedNode(nodeID:hl.Ref<NodeId>):Bool {
		return false;
	}

	/**
		Accepts deleted item.
	**/
	public static function acceptDeletedItem(deleteDependencies:Bool = true):Bool {
		return false;
	}

	/**
		Rejects deleted item.
	**/
	public static function rejectDeletedItem():Void {}

	/**
		Ends delete.
	**/
	public static function endDelete():Void {}

	// Status

	/**
		Sets node position.
	**/
	public static function setNodePosition(nodeId:NodeId, position:ImVec2):Void {}

	/**
		Returns node position.
	**/
	public static function getNodePosition(nodeId:NodeId):ImVec2 {
		return null;
	}

	/**
		Returns node size.
	**/
	public static function getNodeSize(nodeId:NodeId):ImVec2 {
		return null;
	}

	/**
		Sets group size.
	**/
	public static function setGroupSize(nodeId:NodeId, size:ImVec2):Void {}

	/**
		Centers node on screen.
	**/
	public static function centerNodeOnScreen(nodeId:NodeId):Void {}

	/**
		Sets node z position, nodes with higher value are drawn over nodes with lower value.
	**/
	public static function setNodeZPosition(nodeId:NodeId, z:Single):Void {}

	/**
		Returns node z position, defaults is 0.0f.
	**/
	public static function getNodeZPosition(nodeId:NodeId):Single {
		return 0;
	}

	//

	/**
		Restores node state.
	**/
	public static function restoreNodeState(nodeId:NodeId):Void {}

	//

	/**
		Suspends node-editor interaction while drawing overlays.
	**/
	public static function suspend():Void {}

	/**
		Resumes node-editor interaction after `suspend()`.
	**/
	public static function resume():Void {}

	/**
		Returns whether suspended.
	**/
	public static function isSuspended():Bool {
		return false;
	}

	/**
		Returns whether active.
	**/
	public static function isActive():Bool {
		return false;
	}

	//

	/**
		Returns whether selection changed.
	**/
	public static function hasSelectionChanged():Bool {
		return false;
	}

	/**
		Returns selected object count.
	**/
	public static function getSelectedObjectCount():Int {
		return 0;
	}

	/**
		Returns selected nodes.
	**/
	public static function getSelectedNodes():hl.NativeArray<NodeId> {
		return null;
	}

	/**
		Returns selected links.
	**/
	public static function getSelectedLinks():hl.NativeArray<LinkId> {
		return null;
	}

	/**
		Returns whether node selected.
	**/
	public static function isNodeSelected(nodeId:NodeId):Bool {
		return false;
	}

	/**
		Returns whether link selected.
	**/
	public static function isLinkSelected(linkId:NodeId):Bool {
		return false;
	}

	/**
		Clears selection.
	**/
	public static function clearSelection():Void {}

	/**
		Selects node.
	**/
	public static function selectNode(nodeId:NodeId, append:Bool = false):Void {}

	/**
		Selects link.
	**/
	public static function selectLink(linkId:LinkId, append:Bool = false):Void {}

	/**
		Deselects node.
	**/
	public static function deselectNode(nodeId:NodeId):Void {}

	/**
		Deselects link.
	**/
	public static function deselectLink(linkId:LinkId):Void {}

	//

	/**
		Deletes node.
	**/
	public static function deleteNode(nodeId:NodeId):Bool {
		return false;
	}

	/**
		Deletes link.
	**/
	public static function deleteLink(linkId:LinkId):Bool {
		return false;
	}

	//

	/**
		Returns true if node has any link connected.
	**/
	public static function hasAnyLinks(nodeId:NodeId):Bool {
		return false;
	}

	/**
		Returns whether any links2.
	**/
	public static function hasAnyLinks2(pinId:PinId):Bool {
		return false;
	}

	/**
		Break all links connected to this node.
	**/
	public static function breakLinks(nodeId:NodeId):Int {
		return 0;
	}

	/**
		Breaks links2.
	**/
	public static function breakLinks2(pinId:PinId):Int {
		return 0;
	}

	//

	/**
		Navigates to content.
	**/
	public static function navigateToContent(duration:Single = -1):Void {}

	/**
		Navigates to selection.
	**/
	public static function navigateToSelection(zoomIn:Bool = false, duration:Single = -1):Void {}

	//

	/**
		Shows node context menu.
	**/
	public static function showNodeContextMenu(nodeId:hl.Ref<NodeId>):Bool {
		return false;
	}

	/**
		Shows link context menu.
	**/
	public static function showLinkContextMenu(linkId:hl.Ref<LinkId>):Bool {
		return false;
	}

	/**
		Shows pin context menu.
	**/
	public static function showPinContextMenu(pinId:hl.Ref<PinId>):Bool {
		return false;
	}

	/**
		Shows background context menu.
	**/
	public static function showBackgroundContextMenu():Bool {
		return false;
	}

	//

	/**
		Enables shortcuts.
	**/
	public static function enableShortcuts(enabled:Bool):Void {}

	/**
		Returns whether node-editor shortcuts are enabled.
	**/
	public static function areShortcutsEnabled():Bool {
		return false;
	}

	//
	// @todo shortcuts
	//

	/**
		Returns current zoom.
	**/
	public static function getCurrentZoom():Single {
		return 0;
	}

	//

	/**
		Returns hovered node.
	**/
	public static function getHoveredNode():NodeId {
		return 0;
	}

	/**
		Returns hovered link.
	**/
	public static function getHoveredLink():LinkId {
		return 0;
	}

	/**
		Returns hovered pin.
	**/
	public static function getHoveredPin():PinId {
		return 0;
	}

	/**
		Returns double clicked node.
	**/
	public static function getDoubleClickedNode():NodeId {
		return 0;
	}

	/**
		Returns double clicked link.
	**/
	public static function getDoubleClickedLink():LinkId {
		return 0;
	}

	/**
		Returns double clicked pin.
	**/
	public static function getDoubleClickedPin():PinId {
		return 0;
	}

	/**
		Returns whether background clicked.
	**/
	public static function isBackgroundClicked():Bool {
		return false;
	}

	/**
		Returns whether background double clicked.
	**/
	public static function isBackgroundDoubleClicked():Bool {
		return false;
	}

	//

	/**
		Pass nullptr if particular pin do not interest you.
	**/
	public static function getLinkPins(linkId:LinkId, startPinId:hl.Ref<PinId>, endPinId:hl.Ref<PinId>):Bool {
		return false;
	} // pass nullptr if particular pin do not interest you

	/**
		Returns whether the current pin has any links.
	**/
	public static function pinHadAnyLinks(pinId:PinId):Bool {
		return false;
	}

	//

	/**
		Returns screen size.
	**/
	public static function getScreenSize():ImVec2 {
		return null;
	}

	/**
		Converts a screen-space position to node-editor canvas coordinates.
	**/
	public static function screenToCanvas(pos:ImVec2):ImVec2 {
		return null;
	}

	/**
		Returns whether vas to screen.
	**/
	public static function canvasToScreen(pos:ImVec2):ImVec2 {
		return null;
	}

	//

	/**
		Returns number of submitted nodes since Begin() call.
	**/
	public static function getNodeCount():Int {
		return 0;
	}

	// Internal
	static function get_hint_foreground_draw_list():ImDrawListPtr {
		return null;
	}

	static function get_hint_background_draw_list():ImDrawListPtr {
		return null;
	}

	static function get_node_background_draw_list(nodeId:NodeId):ImDrawListPtr {
		return null;
	}
}
#end
