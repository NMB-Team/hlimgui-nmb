package imgui.types;

import imgui.ImGui;
import imgui.types.Pointers.ImTextureDataPtr;
import hl.Bytes;

enum abstract ImTextureStatus(Int) from Int to Int {
	var Ok = 0;
	var Destroyed;
	var WantCreate;
	var WantUpdates;
	var WantDestroy;
}

@:hlNative("hlimgui", "imtexturedata_")
abstract ImTextureData(ImTextureDataPtr) from ImTextureDataPtr to ImTextureDataPtr {
	public function setTexture(texture: ImTextureID) {}
	public function setUpdated() {}
	public function setDestroyed() {}
}

@:keep
class RenderTextureList {
	public var updates: hl.NativeArray<RenderTextureData>;
	public var size: Int;

	function new() {
		updates = new hl.NativeArray(0);
	}
}

@:keep
class RenderTextureData {
	public var textureData: ImTextureData;
	public var uniqueId: Int;
	public var status: ImTextureStatus;
	public var textureId: ImTextureID;
	public var pixels: Bytes;
	public var width: Int;
	public var height: Int;
	public var bytesPerPixel: Int;

	function new() {}
}

@:keep
class RenderList {

	public var lists: hl.NativeArray<RenderData>;
	public var size: Int;

	function new() {
		lists = new hl.NativeArray(0);
	}
}

@:keep
class RenderData {
	public var vertexBuffer: Bytes;
	public var vertexBufferSize: Int;
	public var indexBuffer: Bytes;
	public var indexBufferSize: Int;
	public var commands: hl.NativeArray<RenderCommand>;
	public var commandCount: Int;

	function new() {}
}

@:keep
class RenderCommand {
	public var textureID: ImTextureID;
	public var indexOffset: Int;
	public var elemCount: Int;

	public var clipLeft: Int;
	public var clipTop: Int;
	public var clipWidth: Int;
	public var clipHeight: Int;

	/** If present - instead of regular draw call invoke the callback. **/
	public var callback: RenderCommandCallback;
	public var callbackData: Dynamic;

	function new() {}
}

#if heaps
class RenderCommandCallbackData {
	public var ctx: h2d.RenderContext;
	public var obj: h2d.Drawable;

	function new() {}
}
#else
typedef RenderCommandCallbackData = Dynamic;
#end
// TODO: Make RenderData == ImDrawList
// parentList: RenderData, command: RenderCommand, data: RenderCommandCallbackData
// Avoid recursion by using Dynamic
typedef RenderCommandCallback = (parentList: Dynamic, command: Dynamic, data: Dynamic)->Void;