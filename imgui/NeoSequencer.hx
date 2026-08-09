package imgui;

#if hlimgui
import imgui.ImGui.ImVec2;
import imgui.ImGui.ImVec2S;
import imgui.ImGui.ImVec4;
import imgui.ImGui.ImVec4S;
import imgui.ImGui.ImDrawList;
import imgui.ImGui.Ref;

// Flags for ImGui::BeginNeoSequencer()

/**
	Flags controlling neo sequencer.
**/
enum abstract ImGuiNeoSequencerFlags(Int) from Int to Int {
	/**
		No options or flags.
	**/
	var None = 0;

	/**
		Allows changing length of sequence.
	**/
	var AllowLengthChanging = 1 << 0; // Allows changing length of sequence

	/**
		Enables selection of keyframes.
	**/
	var EnableSelection = 1 << 1; // Enables selection of keyframes

	/**
		Disables zoom bar.
	**/
	var HideZoom = 1 << 2; // Disables zoom bar

	// var PH                 = 1 << 3; // PLACEHOLDER

	/**
		Enables overlay header, keeping it visible when scrolling.
	**/
	var AlwaysShowHeader = 1 << 4; // Enables overlay header, keeping it visible when scrolling

	// Selection options, only work with enable selection flag

	/**
		Enables selection enable dragging behavior.
	**/
	var Selection_EnableDragging = 1 << 5;

	/**
		Enables selection enable deletion behavior.
	**/
	var Selection_EnableDeletion = 1 << 6;
}

// Flags for ImGui::BeginNeoTimeline()

/**
	Flags controlling neo timeline.
**/
enum abstract ImGuiNeoTimelineFlags(Int) from Int to Int {
	/**
		No options or flags.
	**/
	var None = 0;

	/**
		Enables allow frame changing behavior.
	**/
	var AllowFrameChanging = 1 << 0;

	/**
		Enables group behavior.
	**/
	var Group = 1 << 1;
}

// Flags for ImGui::IsNeoTimelineSelected()

/**
	Flags controlling neo timeline is selected.
**/
enum abstract ImGuiNeoTimelineIsSelectedFlags(Int) from Int to Int {
	/**
		No options or flags.
	**/
	var None:Int = 0;

	/**
		Enables newly selected behavior.
	**/
	var NewlySelected:Int = 1 << 0;
}

/**
	Values representing neo style color.
**/
enum abstract NeoStyleColor(Int) from Int to Int {
	/**
		The background style color.
	**/
	var Bg = 0;

	/**
		The top bar background style color.
	**/
	var TopBarBg = 1;

	/**
		The selected timeline style color.
	**/
	var SelectedTimeline = 2;

	/**
		The timeline border style color.
	**/
	var TimelineBorder = 3;

	/**
		The timeline background style color.
	**/
	var TimelineBg = 4;

	/**
		The frame pointer style color.
	**/
	var FramePointer = 5;

	/**
		The frame pointer hovered style color.
	**/
	var FramePointerHovered = 6;

	/**
		The frame pointer pressed style color.
	**/
	var FramePointerPressed = 7;

	/**
		The keyframe style color.
	**/
	var Keyframe = 8;

	/**
		The keyframe hovered style color.
	**/
	var KeyframeHovered = 9;

	/**
		The keyframe pressed style color.
	**/
	var KeyframePressed = 10;

	/**
		The keyframe selected style color.
	**/
	var KeyframeSelected = 11;

	/**
		The frame pointer line style color.
	**/
	var FramePointerLine = 12;

	/**
		The zoom bar background style color.
	**/
	var ZoomBarBg = 13;

	/**
		The zoom bar slider style color.
	**/
	var ZoomBarSlider = 14;

	/**
		The zoom bar slider hovered style color.
	**/
	var ZoomBarSliderHovered = 15;

	/**
		The zoom bar slider ends style color.
	**/
	var ZoomBarSliderEnds = 16;

	/**
		The zoom bar slider ends hovered style color.
	**/
	var ZoomBarSliderEndsHovered = 17;

	/**
		The selection border style color.
	**/
	var SelectionBorder = 18;

	/**
		The selection style color.
	**/
	var Selection = 19;

	// var Count = 20;
}

/**
	Neo Sequencer style.
**/
@:keep
@:build(imgui._ImGuiInternalMacro.buildFlatStruct())
@:hlNative("hlimgui", "ns_")
@:struct
class NeoStyle {
	/**
		Corner rounding around whole sequencer.
	**/
	public var SequencerRounding:Single;

	/**
		Value <= 0.0f = Height is calculated by FontSize + FramePadding.y * 2.0f.
	**/
	public var TopBarHeight:Single;

	/**
		Show line for every frame in top bar.
	**/
	public var TopBarShowFrameLines:Bool;

	/**
		Whether top bar show frame text.
	**/
	public var TopBarShowFrameText:Bool;

	@:flatten var ItemSpacing:ImVec2S;

	/**
		Controls depth item s pacing.
	**/
	public var DepthItemSPacing:Single;

	/**
		Controls topbar spacing.
	**/
	public var TopbarSpacing:Single;

	/**
		The timeline border size.
	**/
	public var TimelineBorderSize:Single;

	/**
		Size of pointing arrow above current frame line.
	**/
	public var CurrentFramePointerSize:Single;

	/**
		Controls current fame line width.
	**/
	public var CurrentFameLineWidth:Single;

	/**
		Scale of Zoom bar, base height is font size.
	**/
	public var ZoomHeightScale:Single;

	/**
		Offset on which colliding keyframes are rendered.
	**/
	public var CollidedKeyframeOffset:Single;

	@:flattenMap(NeoStyleColor) var Colors:ImVec4S;

	/**
		Key mod which when held removes selected keyframes from present selection.
	**/
	public var ModRemoveKey:Int;

	/**
		Key mod which when held adds selected keyframes to present selection.
	**/
	public var ModAddKey:Int;

	/**
		Creates a new `NeoStyle` instance.
	**/
	public function new() {
		init_style(this);
	}

	static function init_style(style:NeoStyle) {}
}

/**
	Immediate-mode timeline and keyframe sequencer API.
**/
@:hlNative("hlimgui", "ns_")
class NeoSequencer {
	/**
		Access the Style structure (colors, sizes). Always use PushStyleColor(), PushStyleVar() to modify style mid-frame!
	**/
	public static function getStyle():NeoStyle {
		return null;
	}

	// Context

	/**
		Begins this API scope. Call the matching `end()` function according to its return-value contract.
	**/
	public static function begin(id:String, frame:Ref<Int>, startFrame:Ref<Int>, endFrame:Ref<Int>, size:ImVec2S, flags:ImGuiNeoSequencerFlags = None):Bool {
		return false;
	}

	/**
		Automatically called on the last call of Step() that returns false.
	**/
	public static function end():Void {};

	/**
		Lock horizontal starting position.
	**/
	public static function beginGroup(label:String, ?open:Ref<Bool>):Bool {
		return false;
	}

	/**
		Unlock horizontal starting position + capture the whole group bounding box into one "item" (so you can use IsItemHovered() or layout primitives such as SameLine() on whole group, etc.)
	**/
	public static function endGroup() {};

	/**
		Begins timeline. Call its matching end function only when this returns `true`, unless documented otherwise.
	**/
	public static function beginTimeline(label:String, ?open:Ref<Bool>, flags:ImGuiNeoTimelineFlags = None):Bool {
		return false;
	}

	/**
		Ends timeline.
	**/
	public static function endTimeline() {};

	/**
		Sets selected timeline.
	**/
	public static function setSelectedTimeline(timelineLabel:String):Void {}

	/**
		Returns whether timeline selected.
	**/
	public static function isTimelineSelected(flags:ImGuiNeoTimelineIsSelectedFlags = None):Bool {
		return false;
	}

	/**
		Submits a keyframe and allows its frame value to be edited.
	**/
	public static function keyframe(value:Ref<Int>) {};

	/**
		Returns whether keyframe hovered.
	**/
	public static function isKeyframeHovered():Bool {
		return false;
	}

	/**
		Returns whether keyframe selected.
	**/
	public static function isKeyframeSelected():Bool {
		return false;
	}

	/**
		Returns whether keyframe right clicked.
	**/
	public static function isKeyframeRightClicked():Bool {
		return false;
	}

	/**
		Clears selection.
	**/
	public static function clearSelection():Void {}

	/**
		Returns whether selecting.
	**/
	public static function isSelecting():Bool {
		return false;
	}

	/**
		Returns whether selection.
	**/
	public static function hasSelection():Bool {
		return false;
	}

	/**
		Returns whether dragging selection.
	**/
	public static function isDraggingSelection():Bool {
		return false;
	}

	/**
		Returns whether delete selection.
	**/
	public static function canDeleteSelection():Bool {
		return false;
	}

	/**
		Returns whether keyframe selection right clicked.
	**/
	public static function isKeyframeSelectionRightClicked():Bool {
		return false;
	}

	/**
		Returns keyframe selection size.
	**/
	public static function getKeyframeSelectionSize():Int {
		return 0;
	}

	/**
		Returns keyframe selection.
	**/
	public static function getKeyframeSelection():hl.NativeArray<Int> {
		return null;
	}
}
#end
