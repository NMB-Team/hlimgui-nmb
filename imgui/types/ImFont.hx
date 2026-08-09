package imgui.types;

import imgui.types.Pointers;

/**
	Loaded Dear ImGui font handle.
**/
@:hlNative("hlimgui")
abstract ImFont(ImFontPtr) from ImFontPtr to ImFontPtr {
	/**
		Creates a new `ImFont` instance.
	**/
	public inline function new(ptr:ImFontPtr) {
		this = ptr;
	}

	// todo: Expose API
}
