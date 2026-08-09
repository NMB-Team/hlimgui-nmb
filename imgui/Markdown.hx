package imgui;

#if hlimgui
import imgui.ImGui.ImVec2;
import imgui.ImGui.ImVec2S;
import imgui.ImGui.ImVec4;
import imgui.ImGui.ImVec4S;
import imgui.ImGui.ImDrawList;
import imgui.ImGui.ImFont;

/**
	Data passed to Markdown link and image callbacks.
**/
@:keep
@:struct
class MarkdownLinkCallbackData {
	/**
		Link label text between square brackets.
	**/
	public var text:hl.Bytes;

	/**
		The text length.
	**/
	public var textLength:Int;

	/**
		Text between brackets ()
	**/
	public var link:hl.Bytes;

	/**
		The link length.
	**/
	public var linkLength:Int;

	/**
		Void*.
	**/
	public var userData:hl.Bytes; // void*

	/**
		True if '!' is detected in front of the link syntax.
	**/
	public var isImage:Bool;
}

/**
	Data passed to Markdown tooltip callbacks.
**/
@:keep
@:struct
class MarkdownTooltipCallbackData // for tooltips
{
	// MarkdownLinkCallbackData

	/**
		Link label text between square brackets.
	**/
	public var text:hl.Bytes;

	/**
		The text length.
	**/
	public var textLength:Int;

	/**
		Text between brackets ()
	**/
	public var link:hl.Bytes;

	/**
		The link length.
	**/
	public var linkLength:Int;

	/**
		Void*.
	**/
	public var userData:hl.Bytes; // void*

	/**
		True if '!' is detected in front of the link syntax.
	**/
	public var isImage:Bool;

	//

	/**
		Void*.
	**/
	public var linkIcon:hl.Bytes; // void*

}

/**
	Image properties populated by a Markdown image callback.
**/
@:struct
@:build(imgui._ImGuiInternalMacro.buildFlatStruct())
class MarkdownImageData {
	/**
		If true, will draw the image.
	**/
	public var isValid:Bool;

	/**
		If true, linkCallback will be called when image is clicked.
	**/
	public var useLinkCallback:Bool;

	/**
		Gets or sets texture id.
	**/
	public var textureId:imgui.ImGui.ImTextureID;

	/**
		Image display size in pixels.
	**/
	@:flatten public var size:ImVec2S;

	/**
		UV coordinates (in current texture)
	**/
	@:flatten public var uv0:ImVec2S;

	/**
		Bottom-right texture coordinate.
	**/
	@:flatten public var uv1:ImVec2S;

	/**
		Gets or sets tint color.
	**/
	@:flatten public var tintColor:ImVec4S;

	/**
		Gets or sets border color.
	**/
	@:flatten public var borderColor:ImVec4S;
}

/**
	Callback invoked for markdown image.
**/
typedef MarkdownImageCallback = (MarkdownLinkCallbackData, MarkdownImageData) -> Void;

/**
	Callback invoked for markdown link.
**/
typedef MarkdownLinkCallback = (MarkdownLinkCallbackData) -> Void;

/**
	Callback invoked for markdown tooltip.
**/
typedef MarkdownTooltipCallback = (MarkdownTooltipCallbackData) -> Void;

/**
	Node editor style.
	Unlike imgui style, there's no "set" function, so there is no constructor.
**/
@:keep
@:build(imgui._ImGuiInternalMacro.buildFlatStruct())
@:hlNative("hlimgui", "markdown_")
@:struct
class MarkdownConfig {
	/**
		Gets or sets heading1.
	**/
	public var heading1:ImFont;

	/**
		Whether heading1 separator.
	**/
	public var heading1Separator:Bool;

	/**
		Gets or sets heading2.
	**/
	public var heading2:ImFont;

	/**
		Whether heading2 separator.
	**/
	public var heading2Separator:Bool;

	/**
		Gets or sets heading3.
	**/
	public var heading3:ImFont;

	/**
		Whether heading3 separator.
	**/
	public var heading3Separator:Bool;

	/**
		WARNING: This is a const char*!
	**/
	public var linkIcon:hl.Bytes; // WARNING: This is a const char*!

	/**
		WARNING: This is a const void*!
	**/
	public var userData:hl.Bytes; // WARNING: This is a const void*!

	/**
		Callback invoked for image callback.
	**/
	public var imageCallback:MarkdownImageCallback;

	/**
		Callback invoked for link callback.
	**/
	public var linkCallback:MarkdownLinkCallback;

	/**
		Callback invoked for tooltip callback.
	**/
	public var tooltipCallback:MarkdownTooltipCallback;

	/**
		Callback invoked for cb1.
	**/
	public var cb1:hl.Bytes;

	/**
		Creates a new `MarkdownConfig` instance.
	**/
	public function new() {
		init_config(this);
	}

	static function init_config(config:MarkdownConfig) {}
}

/**
	Renders Markdown content with Dear ImGui.
**/
@:hlNative("hlimgui", "markdown_")
class Markdown {
	// Context

	/**
		Formatted text.
	**/
	public static function text(text:String, config:MarkdownConfig):Void {}
}
#end
