package imgui.types;

import imgui.ImGui;
import imgui.types.Pointers.ImTextureDataPtr;

import hl.Bytes;

/**
	Values representing texture status.
**/
enum abstract ImTextureStatus(Int) from Int to Int {
	/**
		The `Ok` value of `ImTextureStatus`.
	**/
	var Ok = 0;

	/**
		The `Destroyed` value of `ImTextureStatus`.
	**/
	var Destroyed;

	/**
		The `WantCreate` value of `ImTextureStatus`.
	**/
	var WantCreate;

	/**
		The `WantUpdates` value of `ImTextureStatus`.
	**/
	var WantUpdates;

	/**
		The `WantDestroy` value of `ImTextureStatus`.
	**/
	var WantDestroy;
}

/**
	Mutable renderer texture state supplied by Dear ImGui.
**/
@:hlNative("hlimgui", "imtexturedata_")
abstract ImTextureData(ImTextureDataPtr) from ImTextureDataPtr to ImTextureDataPtr {
	/**
		Sets texture.
	**/
	public function setTexture(texture:ImTextureID) {}

	/**
		Sets updated.
	**/
	public function setUpdated() {}

	/**
		Sets destroyed.
	**/
	public function setDestroyed() {}
}

/**
	Batch of texture updates requested by Dear ImGui.
**/
@:keep
class RenderTextureList {
	/**
		Gets or sets updates.
	**/
	public var updates:hl.NativeArray<RenderTextureData>;

	/**
		Number of texture updates in `updates`.
	**/
	public var size:Int;

	function new() {
		updates = new hl.NativeArray(0);
	}
}

/**
	Texture creation, update, or destruction data for the renderer.
**/
@:keep
class RenderTextureData {
	/**
		Gets or sets texture data.
	**/
	public var textureData:ImTextureData;

	/**
		Gets or sets unique id.
	**/
	public var uniqueId:Int;

	/**
		Gets or sets status.
	**/
	public var status:ImTextureStatus;

	/**
		Gets or sets texture id.
	**/
	public var textureId:ImTextureID;

	/**
		Gets or sets pixels.
	**/
	public var pixels:Bytes;

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

	function new() {}
}

/**
	Collection of draw lists produced for the current frame.
**/
@:keep
class RenderList {
	/**
		Gets or sets lists.
	**/
	public var lists:hl.NativeArray<RenderData>;

	/**
		Number of draw lists in `lists`.
	**/
	public var size:Int;

	/**
		Generated vertex count for this render pass.
	**/
	public var vertexCount:Int;

	/**
		Generated compact vertex bytes for this render pass.
	**/
	public var vertexBytes:Int;

	/**
		Native render-data preparation time when benchmark instrumentation is enabled.
	**/
	public var prepareTimeUs:Int;

	/**
		Generated index bytes processed by the native bridge.
	**/
	public var indexBytes:Int;

	/**
		Index bytes copied by the native bridge.
	**/
	public var indexCopyBytes:Int;

	/**
		Number of indices rebased by the native bridge.
	**/
	public var rebasedIndexCount:Int;

	/**
		Number of draw commands with a non-zero vertex offset.
	**/
	public var nonzeroVtxOffsetCount:Int;

	/**
		Largest vertex count in one generated draw list.
	**/
	public var maxDrawListVertexCount:Int;

	/**
		Dear ImGui framebuffer pixels per logical X unit for this render pass.
	**/
	public var framebufferScaleX:Single;

	/**
		Dear ImGui framebuffer pixels per logical Y unit for this render pass.
	**/
	public var framebufferScaleY:Single;

	/**
		Width of the Dear ImGui viewport framebuffer in pixels.
	**/
	public var framebufferWidth:Int;

	/**
		Height of the Dear ImGui viewport framebuffer in pixels.
	**/
	public var framebufferHeight:Int;

	function new() {
		lists = new hl.NativeArray(0);
	}
}

/**
	Vertices, indices, and commands for one Dear ImGui draw list.
**/
@:keep
class RenderData {
	/**
		Gets or sets vertex buffer.
	**/
	public var vertexBuffer:Bytes;

	/**
		The vertex buffer size.
	**/
	public var vertexBufferSize:Int;

	/**
		Number of vertices in `vertexBuffer`.
	**/
	public var vertexCount:Int;

	/**
		Vertex size in bytes.
	**/
	public var vertexStride:Int;

	/**
		Byte offset of the position attribute.
	**/
	public var positionOffset:Int;

	/**
		Byte offset of the UV attribute.
	**/
	public var uvOffset:Int;

	/**
		Byte offset of the packed color attribute.
	**/
	public var colorOffset:Int;

	/**
		Draw-data viewport origin on the X axis.
	**/
	public var displayPosX:Single;

	/**
		Draw-data viewport origin on the Y axis.
	**/
	public var displayPosY:Single;

	/**
		Gets or sets index buffer.
	**/
	public var indexBuffer:Bytes;

	/**
		The index buffer size.
	**/
	public var indexBufferSize:Int;

	/**
		Number of 32-bit indices in `indexBuffer`.
	**/
	public var indexCount:Int;

	/**
		Capacity of the borrowed native index buffer in bytes.
	**/
	public var indexBufferCapacity:Int;

	/**
		Gets or sets commands.
	**/
	public var commands:hl.NativeArray<RenderCommand>;

	/**
		The command count.
	**/
	public var commandCount:Int;

	function new() {}
}

/**
	One clipped texture draw or user callback command.
**/
@:keep
class RenderCommand {
	/**
		Gets or sets texture id.
	**/
	public var textureID:ImTextureID;

	/**
		Gets or sets index offset.
	**/
	public var indexOffset:Int;

	/**
		The elem count.
	**/
	public var elemCount:Int;

	/**
		Gets or sets clip left.
	**/
	public var clipLeft:Int;

	/**
		Gets or sets clip top.
	**/
	public var clipTop:Int;

	/**
		Gets or sets clip width.
	**/
	public var clipWidth:Int;

	/**
		Gets or sets clip height.
	**/
	public var clipHeight:Int;

	/**
		Requests the renderer to restore its normal draw state.
	**/
	public var resetRenderState:Bool;

	/**
		If present - instead of regular draw call invoke the callback.
	**/
	public var callback:RenderCommandCallback;

	/**
		Callback invoked for callback data.
	**/
	public var callbackData:Dynamic;

	function new() {}
}

#if heaps
/**
	Renderer-specific context passed to a draw command callback.
**/
class RenderCommandCallbackData {
	/**
		Heaps render context for the callback.
	**/
	public var ctx:h2d.RenderContext;

	/**
		Gets or sets obj.
	**/
	public var obj:h2d.Drawable;

	function new() {}
}
#else

/**
	Renderer-specific context passed to a draw command callback.
**/
typedef RenderCommandCallbackData = Dynamic;
#end

// todo: Make RenderData == ImDrawList
// parentList: RenderData, command: RenderCommand, data: RenderCommandCallbackData
// Avoid recursion by using Dynamic

/**
	Callback invoked for render command.
**/
typedef RenderCommandCallback = (parentList:Dynamic, command:Dynamic, data:Dynamic) -> Void;
