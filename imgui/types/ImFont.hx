package imgui.types;

import imgui.types.Pointers;

/**
	Loaded Dear ImGui font handle.

	This is a non-owning handle. The font is owned by its ImFontAtlas.
	Do not use this handle after the font has been removed from the atlas
	or after the owning ImGui context has been destroyed.
**/
@:hlNative("hlimgui", "imfont_")
abstract ImFont(ImFontPtr) from ImFontPtr to ImFontPtr {
	/**
		Creates a new `ImFont` instance.
	**/
	public inline function new(ptr:ImFontPtr) {
		this = ptr;
	}

	/**
		Returns whether this font is currently attached to an ImFontAtlas.

		Note: this must not be used as a validity check after the font
		has already been removed, because the handle is non-owning.
	**/
	public function isLoaded():Bool {
		return false;
	}

	/**
		Returns whether the font contains the specified Unicode code point.
	**/
	public function hasGlyph(codepoint:Int):Bool {
		return false;
	}

	/**
		Returns Dear ImGui's debug name for this font.
	**/
	public inline extern function getDebugName():String {
		return @:privateAccess String.fromUTF8(_getDebugName());
	}

	@:hlNative("hlimgui", "imfont_get_debug_name")
	private function _getDebugName():hl.Bytes {
		return null;
	}
}
