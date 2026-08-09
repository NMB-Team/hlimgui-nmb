package imgui.types;

import imgui.ImGui;

import hl.NativeArray;
import hl.Bytes;

import imgui.types.Pointers;

@:keep
@:build(imgui._ImGuiInternalMacro.buildFlatStruct())
@:struct class ImFontConfig {
	// char Name[40]
	@:noCompletion var name1:Int;
	@:noCompletion var name2:Int;
	@:noCompletion var name3:Int;
	@:noCompletion var name4:Int;
	@:noCompletion var name5:Int;
	@:noCompletion var name6:Int;
	@:noCompletion var name7:Int;
	@:noCompletion var name8:Int;
	@:noCompletion var name9:Int;
	@:noCompletion var name10:Int;
	@:noCompletion var FontData:Bytes; // TTF/OTF data
	var FontDataSize:Int; // TTF/OTF data size
	var FontDataOwnedByAtlas:Bool; // Force-set to false when adding from memory because GC.
	var MergeMode:Bool; // Merge into previous ImFont, so you can combine multiple inputs font into one ImFont (e.g. ASCII font + icons + Japanese glyphs).
	var PixelSnapH:Bool; // Align every glyph to pixel boundary.
	var OversampleH:hl.UI8; // Rasterize at higher quality for sub-pixel positioning.
	var OversampleV:hl.UI8; // Rasterize at higher quality for sub-pixel positioning.
	var EllipsisChar:hl.UI16; // Explicitly specify unicode codepoint of ellipsis character.
	var SizePixels:Single; // Size in pixels for rasterizer (more or less maps to the resulting font height).
	@:noCompletion var GlyphRanges:Bytes; // Pointer to a user-provided list of Unicode range.
	@:noCompletion var GlyphExcludeRanges:Bytes; // Pointer to a user-provided list of Unicode ranges to exclude.
	@:flatten var GlyphOffset:ImVec2S; // Offset all glyphs from this font input.
	var GlyphMinAdvanceX:Single; // Minimum AdvanceX for glyphs, set Min to align font icons, set both Min/Max to enforce mono-space font
	var GlyphMaxAdvanceX:Single; // Maximum AdvanceX for glyphs
	var GlyphExtraAdvanceX:Single; // Extra spacing (in pixels) between glyphs.
	var FontNo:Int; // Index of font within TTF/OTF file
	var FontLoaderFlags:Int; // Settings for the active font loader.
	var RasterizerMultiply:Single; // Brighten (>1.0f) or darken (<1.0f) font output. Brightening small fonts may be a good workaround to make them more readable.
	var RasterizerDensity:Single; // DPI scale multiplier for rasterization.
	var ExtraSizeScale:Single; // Extra rasterizer scale over SizePixels.

	// [Internal]
	@:noCompletion var Flags:Int;
	@:noCompletion var DstFont:ImFont;
	@:noCompletion var FontLoader:Bytes;
	@:noCompletion var FontLoaderData:Bytes;
	@:noCompletion var PixelSnapV:Bool;

	/**
		Creates a new `value` instance.
	**/
	public function new() {
		init(this);
	}

	// Helper methods for some quick configs

	/**
		Sets oversample.
	**/
	public inline function setOversample(h:Int = 3, v:Int = 1) {
		this.OversampleH = h;
		this.OversampleV = v;
		return this;
	}

	/**
		Sets pixel snap h.
	**/
	public inline function setPixelSnapH(v:Bool = true) {
		this.PixelSnapH = v;
		return this;
	}

	/**
		Sets merge mode.
	**/
	public inline function setMergeMode(v:Bool = true) {
		this.MergeMode = v;
		return this;
	}

	/**
		Sets font no.
	**/
	public inline function setFontNo(v:Int) {
		this.FontNo = v;
		return this;
	}

	@:hlNative("hlimgui", "imfontconfig_init")
	static function init(cfg:ImFontConfig) {}
}

/**
	An output storage for ImFontAtlas.getTexDataAsX methods.
**/
@:keep
class ImFontTexData {
	/**
		Gets or sets buffer.
	**/
	public var buffer:Bytes;

	/**
		Texture width in pixels.
	**/
	public var width:Int;

	/**
		Gets or sets height.
	**/
	public var height:Int;

	/**
		Gets or sets bytes per pixel.
	**/
	public var bytesPerPixel:Int;

	/**
		Creates a new `ImFontTexData` instance.
	**/
	public function new() {}
}

/**
	An output storage for ImFontAtlas.getMouseCursorTexData method.

	ImGui bundled cursor consist of cursor outline and fill, both are monochrome same color.

	In order to properly render the cursor, do the following:

	NOTE: This is how ImGui renders it, for some rerason `uvFill` and `uvBorder` are flipped!

	* Shadow color is black with 18.82% (0x30) alpha.
	* Border color is black.
	* Fill color is white.
	* Full size of the cursor is `size + [2,0]` to account for shadow.

	0. If you render on-screen, offset the drawing position by `-offset` to properly position the cursor pivot.
	1. Draw `uvFill` offset by [1,0] with shadow color
	2. Draw `uvFill` offset by [2,0] with shadow color
	3. Draw `uvFill` with border color
	4. Draw `uvBorder` with fill color

**/
@:keep
class ImCursorData {
	/**
		Cursor hotspot offset from the top-left corner.
	**/
	public var offset:ImVec2;

	/**
		Cursor image size in pixels.
	**/
	public var size:ImVec2;

	/**
		Xy = min, zw = max.
	**/
	public var uvBorder:ImVec4; // xy = min, zw = max

	/**
		Xy = min, zw = max.
	**/
	public var uvFill:ImVec4; // xy = min, zw = max

	/**
		Creates a new `ImCursorData` instance.
	**/
	public function new() {
		offset = ImVec2.get();
		size = ImVec2.get();
		uvBorder = ImVec4.get();
		uvFill = ImVec4.get();
	}
}

@:keep
@:struct class ImFontAtlasCustomRect {
	/**
		Packed rectangle X coordinate in the atlas.
	**/
	public var x:hl.UI16;

	/**
		Gets or sets y.
	**/
	public var y:hl.UI16;

	/**
		Size of rectangle to update (in pixels)
	**/
	public var w:hl.UI16;

	/**
		Gets or sets h.
	**/
	public var h:hl.UI16;

	/**
		UV coordinates (in current texture)
	**/
	@:flatten public var uv0:ImVec2S;

	/**
		Bottom-right texture coordinate of the packed rectangle.
	**/
	@:flatten public var uv1:ImVec2S;

	/**
		Returns whether packed.
	**/
	public inline function isPacked():Bool {
		return x != 0 || y != 0 || w != 0 || h != 0;
	}
}

/**
	Font and texture atlas used by the current Dear ImGui context.
**/
@:hlNative("hlimgui", "imfontatlas_")
abstract ImFontAtlas(ImFontAtlasPtr) from ImFontAtlasPtr to ImFontAtlasPtr {
	inline function new(ptr:ImFontAtlasPtr) {
		this = ptr;
	}

	/**
		Adds font.
	**/
	public function addFont(config:ImFontConfig):ImFont {
		return null;
	}

	/**
		Selects between AddFontDefaultVector() and AddFontDefaultBitmap().
	**/
	public function addFontDefault(?config:ImFontConfig):ImFont {
		return null;
	}

	/**
		Embedded scalable font. Recommended at any higher size.
	**/
	public function addFontDefaultVector(?config:ImFontConfig):ImFont {
		return null;
	}

	/**
		Embedded classic pixel-clean font. Recommended at Size 13px with no scaling.
	**/
	public function addFontDefaultBitmap(?config:ImFontConfig):ImFont {
		return null;
	}

	/**
		Adds font from file ttf.
	**/
	public function addFontFromFileTTF(filename:String, size_pixels:Single, ?font_cfg:ImFontConfig, ?glyph_ranges:hl.NativeArray<hl.UI16>):ImFont {
		return null;
	}

	/**
		Note: Transfer ownership of 'ttf_data' to ImFontAtlas! Will be deleted after destruction of the atlas. Set font_cfg->FontDataOwnedByAtlas=false to keep ownership of your data and it won't be freed.
	**/
	public function addFontFromMemoryTTF(font_data:Bytes, font_size:Int, size_pixels:Single, ?font_cfg:ImFontConfig, ?glyph_ranges:hl.NativeArray<hl.UI16>):ImFont {
		return null;
	}

	/**
		[OBSOLETE] Clear input data (all ImFontConfig structures including sizes, TTF data, glyph ranges, etc.) = all the data used to build the texture and fonts.
	**/
	public function clearInputData() {}

	/**
		[OBSOLETE] Clear CPU-side copy of the texture data. Saves RAM once the texture has been copied to graphics memory.
	**/
	public function clearTexData() {}

	/**
		Clear input+output font data/glyphs. New fonts and textures will be recreated afterwards.
	**/
	public function clearFonts() {}

	/**
		Clear selection.
	**/
	public function clear() {}

	/**
		Remove a font.
	**/
	public function removeFont(font:ImFont) {}

	/**
		Compact cached glyphs and texture.
	**/
	public function compactCache() {}

	/**
		Build pixels data. This is called automatically for you by the GetTexData*** functions.
	**/
	public function build():Bool {
		return false;
	}

	/**
		1 byte per-pixel.
	**/
	public function getTexDataAsAlpha8(output:ImFontTexData) {}

	/**
		4 bytes-per-pixel.
	**/
	public function getTexDataAsRGBA32(output:ImFontTexData) {}

	/**
		Bit ambiguous: used to detect when user didn't build texture but effectively we should check TexID != 0 except that would be backend dependent..
	**/
	public function isBuilt():Bool {
		return false;
	}

	/**
		Sets tex id.
	**/
	public function setTexId(id:ImTextureID) {}

	// GetGlyphRangesX

	/**
		RENAMED in 1.92.0.
	**/
	public function addCustomRectRegular(width:Int, height:Int):Int {
		return 0;
	}

	/**
		OBSOLETED in 1.92.0: Use custom ImFontLoader in ImFontConfig.
	**/
	public function addCustomRectFontGlyph(font:ImFontPtr, id:hl.UI16, width:Int, height:Int, advance_x:Single, ?offset:ImVec2):Int {
		return 0;
	}

	/**
		OBSOLETED in 1.92.0.
	**/
	public function getCustomRectByIndex(index:Int):ImFontAtlasCustomRect {
		return null;
	}

	/**
		OBSOLETED in 1.92.0.
	**/
	public function calcCustomRectUV(rect:ImFontAtlasCustomRect, uv_min:ImVec2, uv_max:ImVec2) {}

	/**
		Returns mouse cursor tex data.
	**/
	public function getMouseCursorTexData(cursor:ImGuiMouseCursor, output:ImCursorData):Bool {
		return false;
	}
}
