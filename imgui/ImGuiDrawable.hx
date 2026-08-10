package imgui;

import imgui.types.Renderer;
import imgui.types.ImFontAtlas;

#if heaps
import h2d.Tile;

import h3d.mat.Texture;

#if !hlimgui_heaps_old_buffer_alloc
import hxd.BufferFormat.InputFormat;
import hxd.BufferFormat.Precision;
#end

import imgui.ImGui;

import hxd.Key;
#if heaps_nmb
import hxd.Key.KeyCode;
#else
import hxd.Key in KeyCode;
#end

#if limen
import limen.platform.Platform as SdlPlatform;
#elseif hlsdl
import sdl.Sdl as SdlPlatform;
#end

private typedef ManagedImGuiTexture = {
	var texture:Texture;
	var pixels:hxd.Pixels;
}

#if !hlimgui_heaps_old_buffer_alloc
private class ImGuiPositionShader extends hxsl.Shader {
	static var SRC = {
		@const var enabled:Bool;
		@param var displayOffset:Vec2;
		var absolutePosition:Vec4;
		function vertex() {
			if (enabled)
				absolutePosition.xy -= displayOffset;
		}
	}
}
#end

/**
	Owns reusable Heaps buffers and textures used by the Dear ImGui renderer.
**/
class ImGuiDrawableBuffers {
	#if !hlimgui_heaps_old_buffer_alloc
	static final vertexFormat = hxd.BufferFormat.make([
		{name: "position", type: InputFormat.DVec2},
		{name: "uv", type: InputFormat.DVec2},
		{name: "color", type: InputFormat.DVec4, precision: Precision.U8}
	]);
	#end

	/**
		The instance.
	**/
	public static final instance = new ImGuiDrawableBuffers();

	/**
		Gets or sets vertex buffers.
	**/
	public var vertex_buffers(default, null):Array<h3d.Buffer> = [];

	/**
		Gets or sets index buffers.
	**/
	public var index_buffers(default, null):Array<h3d.Indexes> = [];

	/**
		Hl.NativeArray<RenderCommand> See https://github.com/HaxeFoundation/hashlink/issues/461.
	**/
	public var commands:Array<RenderData> = []; // hl.NativeArray<RenderCommand> See https://github.com/HaxeFoundation/hashlink/issues/461

	/**
		The buffer count.
	**/
	public var bufferCount:Int;

	/** Last generated ImGui vertex count. **/
	public var lastVertexCount(default, null):Int = 0;

	/** Last generated ImGui draw-list count. **/
	public var lastDrawListCount(default, null):Int = 0;

	/** Last vertex stride uploaded to the GPU. **/
	public var lastVertexStride(default, null):Int = 0;

	/** Last number of vertex bytes uploaded to the GPU. **/
	public var lastVertexBytes(default, null):Int = 0;

	/** Last native preparation time in microseconds, or zero without benchmark instrumentation. **/
	public var lastPrepareTimeUs(default, null):Int = 0;

	/** Current Dear ImGui framebuffer width in pixels. **/
	public var framebufferWidth(default, null):Int = 0;

	/** Current Dear ImGui framebuffer height in pixels. **/
	public var framebufferHeight(default, null):Int = 0;

	var framebufferScaleX:Single = 1;
	var framebufferScaleY:Single = 1;

	var noTexture:Texture;
	final textures:Array<ManagedImGuiTexture> = [];
	#if hlimgui_heaps_old_buffer_alloc
	final legacyVertexData:Array<hxd.FloatBuffer> = [];
	#end
	#if hlimgui_render_benchmark
	var benchmarkSamples = 0;
	#end

	var commandData:RenderCommandCallbackData = @:privateAccess new RenderCommandCallbackData();

	private var initialized:Bool = false;
	private var ownerCount:Int = 0;
	private var compatibilityOwner:Bool = false;
	#if hlimgui_cursor
	private var previousCursorHandler:hxd.Cursor -> Void;
	#end

	/**
		Gets or sets font texture.
	**/
	public var font_texture:Texture;

	#if hlimgui_cursor
	/**
		Gets or sets cursor map.
	**/
	public var cursor_map:Map<ImGuiMouseCursor, hxd.Cursor> = [];
	#end

	/**
		Acquires shared renderer ownership, initializing its resources for the first owner.
	**/
	public function acquire(addDefaultFont:Bool = true) {
		if (ownerCount == 0) {
			try {
				initializeInternal(addDefaultFont);
			} catch (error:Dynamic) {
				disposeInternal();
				throw error;
			}
		}
		ownerCount++;
	}

	/**
		Releases shared renderer ownership and its resources after the final owner.
	**/
	public function release() {
		if (ownerCount <= 0)
			throw "ImGui renderer release without acquire";

		ownerCount--;
		if (ownerCount == 0)
			disposeInternal();
	}

	/**
		Initializes this instance and its native resources.
	**/
	public function initialize(addDefaultFont:Bool = true) {
		if (compatibilityOwner)
			return;
		acquire(addDefaultFont);
		compatibilityOwner = true;
	}

	/**
		Releases resources acquired through `initialize()`.
	**/
	public function dispose() {
		if (!compatibilityOwner)
			return;
		compatibilityOwner = false;
		release();
	}

	private function initializeInternal(addDefaultFont:Bool) {
		if (initialized)
			throw "ImGui renderer initialized without a final release";

		ImGui.provideTypes();
		ImGui.ensureContext();
		ImGui.setRenderCallback(renderDrawList);
		ImGui.setTextureCallback(updateTextures);

		var io = ImGui.getIO();
		io.BackendFlags |= ImGuiBackendFlags.RendererHasTextures | ImGuiBackendFlags.RendererHasVtxOffset;

		noTexture = Tile.fromColor(0xffffff).getTexture();
		#if hlimgui_cursor
		previousCursorHandler = hxd.System.setCursor;
		hxd.System.setCursor = updateCursor;
		#end
		initialized = true;
	}

	private function disposeInternal() {
		ImGui.setRenderCallback(null);
		ImGui.setTextureCallback(null);
		if (ImGui.getCurrentContext() != null) {
			var io = ImGui.getIO();
			io.BackendFlags &= ~(ImGuiBackendFlags.RendererHasTextures | ImGuiBackendFlags.RendererHasVtxOffset);
			ImGui.invalidateRendererTextures();
		}

		bufferCount = 0;
		commands = [];
		commandData.ctx = null;
		commandData.obj = null;
		for (index_buffer in index_buffers) {
			index_buffer.dispose();
		}
		index_buffers = [];

		for (vertex_buffer in vertex_buffers) {
			vertex_buffer.dispose();
		}
		vertex_buffers = [];
		#if hlimgui_heaps_old_buffer_alloc
		legacyVertexData.resize(0);
		#end
		for (managed in textures)
			managed.texture.dispose();
		textures.resize(0);
		noTexture = null;
		font_texture = null;
		lastVertexCount = 0;
		lastDrawListCount = 0;
		lastVertexStride = 0;
		lastVertexBytes = 0;
		lastPrepareTimeUs = 0;
		framebufferWidth = 0;
		framebufferHeight = 0;
		framebufferScaleX = 1;
		framebufferScaleY = 1;
		#if hlimgui_render_benchmark
		benchmarkSamples = 0;
		#end
		#if hlimgui_cursor
		cursor_map.clear();
		if (Reflect.compareMethods(hxd.System.setCursor, updateCursor))
			hxd.System.setCursor = previousCursorHandler;
		previousCursorHandler = null;
		#end

		initialized = false;
	}

	private function new() {}

	private function updateTextures(textureList:RenderTextureList) {
		for (i in 0...textureList.size) {
			final update = textureList.updates[i];
			switch (update.status) {
				case WantCreate:
					final pixels = texturePixels(update);
					final texture = Texture.fromPixels(pixels);
					texture.preventAutoDispose();
					textures.push({texture: texture, pixels: pixels});
					if (font_texture == null)
						font_texture = texture;
					#if hlimgui_cursor
					buildCursors(pixels);
					#end
					update.textureData.setTexture(texture);
				case WantUpdates:
					final managed = findTexture(update.textureId);
					if (managed == null)
						throw 'Missing managed ImGui texture ${update.uniqueId}';
					managed.pixels = texturePixels(update);
					managed.texture.uploadPixels(managed.pixels);
					update.textureData.setUpdated();
				case WantDestroy:
					final managed = findTexture(update.textureId);
					if (managed != null) {
						managed.texture.dispose();
						textures.remove(managed);
						if (font_texture == managed.texture)
							font_texture = null;
					}
					update.textureData.setDestroyed();
				case Ok | Destroyed:
			}
		}
	}

	private function findTexture(textureId:ImTextureID):Null<ManagedImGuiTexture> {
		final texture:Texture = cast textureId;
		for (managed in textures)
			if (managed.texture == texture)
				return managed;
		return null;
	}

	private function texturePixels(update:RenderTextureData):hxd.Pixels {
		final pixelCount = update.width * update.height;
		if (update.bytesPerPixel == 4)
			return new hxd.Pixels(update.width, update.height, update.pixels.toBytes(pixelCount * 4), hxd.PixelFormat.RGBA);
		if (update.bytesPerPixel != 1)
			throw 'Unsupported ImGui texture format with ${update.bytesPerPixel} bytes per pixel';

		final rgba = haxe.io.Bytes.alloc(pixelCount * 4);
		for (i in 0...pixelCount) {
			final offset = i * 4;
			rgba.set(offset, 0xff);
			rgba.set(offset + 1, 0xff);
			rgba.set(offset + 2, 0xff);
			rgba.set(offset + 3, update.pixels[i]);
		}
		return new hxd.Pixels(update.width, update.height, rgba, hxd.PixelFormat.RGBA);
	}

	#if hlimgui_cursor
	private function buildCursors(pixels:hxd.Pixels) {
		final cursorPixels:hxd.Pixels.PixelsARGB = pixels.clone();
		final fonts = ImGui.getFontAtlas();
		final cursor = new ImCursorData();
		for (i in 0...ImGuiMouseCursor.COUNT) {
			if (!fonts.getMouseCursorTexData(i, cursor))
				continue;
			final width = Std.int(cursor.size.x);
			final height = Std.int(cursor.size.y);
			final fillX = Std.int(cursor.uvFill.x * cursorPixels.width);
			final fillY = Std.int(cursor.uvFill.y * cursorPixels.height);
			final borderX = Std.int(cursor.uvBorder.x * cursorPixels.width);
			final borderY = Std.int(cursor.uvBorder.y * cursorPixels.height);
			final cursorBitmap = new hxd.BitmapData(width + 2, height);
			for (y in 0...height)
				for (x in 0...width) {
					if ((cursorPixels.getPixel(x + borderX, y + borderY) & 0xff000000) != 0) {
						cursorBitmap.setPixel(x, y, 0xffffffff);
					} else if ((cursorPixels.getPixel(x + fillX, y + fillY) & 0xff000000) != 0) {
						cursorBitmap.setPixel(x, y, 0xff000000);
						if (cursorBitmap.getPixel(x + 1, y) == 0x30000000)
							cursorBitmap.setPixel(x + 1, y, 0x57000000);
						else
							cursorBitmap.setPixel(x + 1, y, 0x30000000);
						cursorBitmap.setPixel(x + 2, y, 0x30000000);
					}
				}
			cursor_map[i] = hxd.Cursor.Custom(new hxd.Cursor.CustomCursor([cursorBitmap], 0, Std.int(cursor.offset.x), Std.int(cursor.offset.y)));
		}
	}

	private function updateCursor(cursor:hxd.Cursor) {
		if (ImGui.getCurrentContext() == null) {
			previousCursorHandler(cursor);
			return;
		}

		switch (ImGui.getMouseCursor()) {
			case None:
				hxd.System.setNativeCursor(Hide);
			case Arrow:
				hxd.System.setNativeCursor(cursor);
			case TextInput:
				hxd.System.setNativeCursor(TextInput);
			case ResizeAll:
				hxd.System.setNativeCursor(Move);
			case Hand:
				hxd.System.setNativeCursor(Button);
			// case ResizeNS:
			// case ResizeEW:
			// case ResizeNESW:
			// case ResizeNWSE:
			// case NotAllowed:
			case expected:
				var mappedCursor = cursor_map[expected];
				if (mappedCursor != null)
					cursor = mappedCursor;
				hxd.System.setNativeCursor(cursor);
		}
	}
	#end

	private function renderDrawList(renderList:RenderList) {
		bufferCount = 0;
		lastDrawListCount = renderList.size;
		lastVertexCount = renderList.vertexCount;
		lastPrepareTimeUs = renderList.prepareTimeUs;
		framebufferWidth = renderList.framebufferWidth;
		framebufferHeight = renderList.framebufferHeight;
		framebufferScaleX = renderList.framebufferScaleX;
		framebufferScaleY = renderList.framebufferScaleY;
		#if hlimgui_heaps_old_buffer_alloc
		lastVertexStride = 8 * 4;
		lastVertexBytes = renderList.vertexCount * 8 * 4;
		#else
		lastVertexStride = renderList.size == 0 ? 0 : renderList.lists[0].vertexStride;
		lastVertexBytes = renderList.vertexBytes;
		#end

		#if hlimgui_render_benchmark
		if (++benchmarkSamples % 120 == 0) {
			final bytesPerVertex = lastVertexCount == 0 ? 0 : lastVertexBytes / lastVertexCount;
			Sys.println('hlimgui renderer: vertices=$lastVertexCount, prepare=${lastPrepareTimeUs}us, vertexUpload=$lastVertexBytes bytes, stride=$bytesPerVertex');
		}
		#end

		for (i in 0...renderList.size) {
			var data = renderList.lists[i];

			final vertexCount = data.vertexCount;
			final indexCount = data.indexCount;
			if (data.vertexBufferSize != vertexCount * data.vertexStride)
				throw "Invalid ImGui vertex buffer size";
			#if !hlimgui_heaps_old_buffer_alloc
			if (data.vertexStride != vertexFormat.strideBytes
				|| data.positionOffset != vertexFormat.calculateInputOffset("position")
				|| data.uvOffset != vertexFormat.calculateInputOffset("uv")
				|| data.colorOffset != vertexFormat.calculateInputOffset("color"))
				throw "Unsupported ImDrawVert memory layout";
			#end

			// create or reuse vertex buffer
			if (i == this.vertex_buffers.length) {
				this.vertex_buffers[i] = createVertexBuffer(vertexCount);
				this.index_buffers[i] = new h3d.Indexes(indexCount, true);
			} else {
				if (this.vertex_buffers[i].vertices < vertexCount) {
					final capacity = growCapacity(vertexCount, this.vertex_buffers[i].vertices);
					this.vertex_buffers[i].dispose();
					this.vertex_buffers[i] = createVertexBuffer(capacity);
				}
				if (this.index_buffers[i].count < indexCount) {
					final capacity = growCapacity(indexCount, this.index_buffers[i].count);
					this.index_buffers[i].dispose();
					this.index_buffers[i] = new h3d.Indexes(capacity, true);
				}
			}
			uploadVertices(i, data);
			this.index_buffers[i].uploadBytes(data.indexBuffer.toBytes(data.indexBufferSize), 0, indexCount);
			this.commands[i] = data; // data.commands.sub(0, data.commandCount);
			bufferCount++;
		}
	}

	static inline function growCapacity(required:Int, current:Int):Int {
		return Std.int(Math.max(required, current + (current >> 1)));
	}

	function createVertexBuffer(capacity:Int):h3d.Buffer {
		#if hlimgui_heaps_old_buffer_alloc
		return new h3d.Buffer(capacity, 8, [RawFormat, Dynamic]);
		#else
		return new h3d.Buffer(capacity, vertexFormat, [Dynamic]);
		#end
	}

	function uploadVertices(index:Int, data:RenderData):Void {
		#if hlimgui_heaps_old_buffer_alloc
		var vertices = legacyVertexData[index];
		if (vertices == null)
			vertices = legacyVertexData[index] = new hxd.FloatBuffer();
		vertices.grow(data.vertexCount * 8);
		for (vertex in 0...data.vertexCount) {
			final source = vertex * data.vertexStride;
			final destination = vertex * 8;
			vertices[destination] = data.vertexBuffer.getF32(source + data.positionOffset) - data.displayPosX;
			vertices[destination + 1] = data.vertexBuffer.getF32(source + data.positionOffset + 4) - data.displayPosY;
			vertices[destination + 2] = data.vertexBuffer.getF32(source + data.uvOffset);
			vertices[destination + 3] = data.vertexBuffer.getF32(source + data.uvOffset + 4);
			vertices[destination + 4] = data.vertexBuffer.getUI8(source + data.colorOffset) / 255;
			vertices[destination + 5] = data.vertexBuffer.getUI8(source + data.colorOffset + 1) / 255;
			vertices[destination + 6] = data.vertexBuffer.getUI8(source + data.colorOffset + 2) / 255;
			vertices[destination + 7] = data.vertexBuffer.getUI8(source + data.colorOffset + 3) / 255;
		}
		vertex_buffers[index].uploadFloats(vertices, 0, data.vertexCount);
		#else
		vertex_buffers[index].uploadBytes(data.vertexBuffer.toBytes(data.vertexBufferSize), 0, data.vertexCount);
		#end
	}

	/**
		Helper calling InputText+Build.
	**/
	public function draw(ctx:h2d.RenderContext, obj:ImGuiDrawable) {
		var e = ctx.engine;
		commandData.ctx = ctx;
		commandData.obj = obj;
		for (i in 0...bufferCount) {
			var data = commands[i];
			#if !hlimgui_heaps_old_buffer_alloc
			@:privateAccess {
				final offsetX = data.displayPosX * obj.matA + data.displayPosY * obj.matC;
				final offsetY = data.displayPosX * obj.matB + data.displayPosY * obj.matD;
				obj.positionShader.enabled = offsetX != 0 || offsetY != 0;
				obj.positionShader.displayOffset.set(offsetX, offsetY);
			}
			#end
			var cmdList = data.commands;
			for (j in 0...data.commandCount) {
				var cmd = cmdList[j];
				if (cmd.resetRenderState) {
					e.setRenderZone();
				} else if (cmd.callback != null) {
					e.setRenderZone(); // Make sure to reset clip rect.
					cmd.callback(data, cmd, commandData);
				} else if (cmd.elemCount > 0
					&& ctx.beginDrawObject(obj, cmd.textureID == null ? noTexture : cmd.textureID)
					&& setClipRect(e, ctx, cmd)) {
					e.renderIndexed(vertex_buffers[i], index_buffers[i], Std.int(cmd.indexOffset / 3), Std.int(cmd.elemCount / 3));
				}
			}
		}

		e.setRenderZone();
	}

	function setClipRect(e:h3d.Engine, ctx:h2d.RenderContext, cmd:RenderCommand):Bool {
		if (framebufferWidth <= 0 || framebufferHeight <= 0 || framebufferScaleX <= 0 || framebufferScaleY <= 0)
			return false;

		@:privateAccess final sceneScaleX = ctx.scene.viewportA * e.width * 0.5;
		@:privateAccess final sceneScaleY = ctx.scene.viewportD * e.height * 0.5;
		@:privateAccess final sceneOriginX = (ctx.scene.viewportX + 1) * e.width * 0.5;
		@:privateAccess final sceneOriginY = (ctx.scene.viewportY + 1) * e.height * 0.5;

		final clipMinX = Math.max(0, Math.min(e.width, sceneOriginX + cmd.clipLeft * sceneScaleX / framebufferScaleX));
		final clipMinY = Math.max(0, Math.min(e.height, sceneOriginY + cmd.clipTop * sceneScaleY / framebufferScaleY));
		final clipMaxX = Math.max(0, Math.min(e.width, sceneOriginX + (cmd.clipLeft + cmd.clipWidth) * sceneScaleX / framebufferScaleX));
		final clipMaxY = Math.max(0, Math.min(e.height, sceneOriginY + (cmd.clipTop + cmd.clipHeight) * sceneScaleY / framebufferScaleY));

		final left = Math.floor(clipMinX);
		final top = Math.floor(clipMinY);
		final right = Math.ceil(clipMaxX);
		final bottom = Math.ceil(clipMaxY);
		if (right <= left || bottom <= top)
			return false;

		e.setRenderZone(left, top, right - left, bottom - top);
		return true;
	}

	/**
		A helper method to set the `smooth` flag to `true` and render subsequent contents using bilinear filtering.

		Usage:
		```haxe
		imDrawList.addCallback(ImGuiDrawableBuffers.setSmoothCommand);
		```
	**/
	public static function setSmoothCommand(data:RenderData, command:RenderCommand, cbData:RenderCommandCallbackData) {
		cbData.obj.smooth = true;
	}

	/**
		A helper method to reset the `smooth` flag to use the default smooth value.

		Usage:
		```haxe
		imDrawList.addCallback(ImGuiDrawableBuffers.setSmoothCommand);
		```
	**/
	public static function resetSmoothCommand(data:RenderData, command:RenderCommand, cbData:RenderCommandCallbackData) {
		cbData.obj.smooth = null;
	}

	/**
		A helper method to reset the `smooth` flag to `false` and render subsequent contents using nearest neighbor filtering.

		Usage:
		```haxe
		imDrawList.addCallback(ImGuiDrawableBuffers.setSmoothCommand);
		```
	**/
	public static function setNearestCommand(data:RenderData, command:RenderCommand, cbData:RenderCommandCallbackData) {
		cbData.obj.smooth = false;
	}
}

/**
	Heaps drawable that renders Dear ImGui draw data.
**/
class ImGuiDrawable extends h2d.Drawable {
	var keycode_map:Map<Int, Int>;
	#if multidriver
	var modifier_keys_down:Map<Int, Bool> = [];
	#end
	var wheel_inverted:Bool;
	#if !hlimgui_heaps_old_buffer_alloc
	final positionShader:ImGuiPositionShader;
	#end
	#if !multidriver
	private var eventScene:h2d.Scene;
	#end
	private var scene_size:{width:Int, height:Int};
	private var rendererAcquired:Bool = false;
	private var disposed:Bool = false;

	/**
		Creates a new `ImGuiDrawable` instance.
	**/
	public function new(?parent, ?addDefaultFont = true) {
		super(parent);
		#if !hlimgui_heaps_old_buffer_alloc
		positionShader = addShader(new ImGuiPositionShader());
		positionShader.enabled = false;
		#end
		try {
			ImGuiDrawableBuffers.instance.acquire(addDefaultFont);
			rendererAcquired = true;

			var scene = getScene();
			var io = ImGui.getIO();
			io.DisplaySize.x = scene.width;
			io.DisplaySize.y = scene.height;
			this.scene_size = {width: scene.width, height: scene.height};

			this.keycode_map = [
				KeyCode.TAB => ImGuiKey.Tab,
				KeyCode.LEFT => ImGuiKey.LeftArrow,
				KeyCode.RIGHT => ImGuiKey.RightArrow,
				KeyCode.UP => ImGuiKey.UpArrow,
				KeyCode.DOWN => ImGuiKey.DownArrow,
				KeyCode.PGUP => ImGuiKey.PageUp,
				KeyCode.PGDOWN => ImGuiKey.PageDown,
				KeyCode.HOME => ImGuiKey.Home,
				KeyCode.END => ImGuiKey.End,
				KeyCode.INSERT => ImGuiKey.Insert,
				KeyCode.DELETE => ImGuiKey.Delete,
				KeyCode.BACKSPACE => ImGuiKey.Backspace,
				KeyCode.SPACE => ImGuiKey.Space,
				KeyCode.ENTER => ImGuiKey.Enter,
				KeyCode.ESCAPE => ImGuiKey.Escape,
				KeyCode.LSHIFT => ImGuiKey.LeftShift,
				KeyCode.RSHIFT => ImGuiKey.RightShift,
				KeyCode.LALT => ImGuiKey.LeftAlt,
				KeyCode.RALT => ImGuiKey.RightAlt,
				KeyCode.LCTRL => ImGuiKey.LeftCtrl,
				KeyCode.RCTRL => ImGuiKey.RightCtrl,
				KeyCode.LEFT_WINDOW_KEY => ImGuiKey.LeftSuper,
				KeyCode.RIGHT_WINDOW_KEY => ImGuiKey.RightSuper,
				KeyCode.CONTEXT_MENU => ImGuiKey.Menu,
				KeyCode.QWERTY_QUOTE => ImGuiKey.Apostrophe,
				KeyCode.QWERTY_COMMA => ImGuiKey.Comma,
				KeyCode.QWERTY_MINUS => ImGuiKey.Minus,
				KeyCode.QWERTY_PERIOD => ImGuiKey.Period,
				KeyCode.QWERTY_SLASH => ImGuiKey.Slash,
				KeyCode.QWERTY_SEMICOLON => ImGuiKey.Semicolon,
				KeyCode.QWERTY_EQUALS => ImGuiKey.Equal,
				KeyCode.QWERTY_BRACKET_LEFT => ImGuiKey.LeftBracket,
				KeyCode.QWERTY_BACKSLASH => ImGuiKey.Backslash,
				KeyCode.QWERTY_BRACKET_RIGHT => ImGuiKey.RightBracket,
				KeyCode.QWERTY_TILDE => ImGuiKey.GraveAccent,
				KeyCode.INTL_BACKSLASH => ImGuiKey.Oem102,
				KeyCode.CAPS_LOCK => ImGuiKey.CapsLock,
				KeyCode.SCROLL_LOCK => ImGuiKey.ScrollLock,
				KeyCode.NUM_LOCK => ImGuiKey.NumLock,
				KeyCode.PAUSE_BREAK => ImGuiKey.Pause,
				KeyCode.NUMPAD_DOT => ImGuiKey.KeypadDecimal,
				KeyCode.NUMPAD_DIV => ImGuiKey.KeypadDivide,
				KeyCode.NUMPAD_MULT => ImGuiKey.KeypadMultiply,
				KeyCode.NUMPAD_SUB => ImGuiKey.KeypadSubtract,
				KeyCode.NUMPAD_ADD => ImGuiKey.KeypadAdd,
				KeyCode.NUMPAD_ENTER => ImGuiKey.KeypadEnter,
			];

			for (ko in 0...10) {
				keycode_map[KeyCode.NUMBER_0 + ko] = ImGuiKey.Key0 + ko;
				keycode_map[KeyCode.NUMPAD_0 + ko] = ImGuiKey.Keypad0 + ko;
			}

			for (ko in 0...26)
				keycode_map[KeyCode.A + ko] = ImGuiKey.A + ko;

			for (ko in 0...24)
				keycode_map[KeyCode.F1 + ko] = ImGuiKey.F1 + ko;

			#if !multidriver
			eventScene = scene;
			scene.addEventListener(onEvent);
			#end

			this.wheel_inverted = false;
		} catch (error:Dynamic) {
			dispose();
			throw error;
		}
	}

	/**
		Releases resources owned by this instance.
	**/
	public function dispose() {
		if (disposed)
			return;
		disposed = true;
		#if !multidriver
		if (eventScene != null) {
			eventScene.removeEventListener(onEvent);
			eventScene = null;
		}
		#end
		if (rendererAcquired) {
			rendererAcquired = false;
			ImGuiDrawableBuffers.instance.release();
		}
	}

	/**
		Updates this instance for the current frame.
	**/
	public function update(dt:Float) {
		if (disposed)
			return;
		var io = ImGui.getIO();

		io.DeltaTime = dt > 0 ? dt : 1 / 60;

		var scene = getScene();
		if (scene.width != this.scene_size.width || scene.height != this.scene_size.height) {
			io.DisplaySize.x = scene.width;
			io.DisplaySize.y = scene.height;

			this.scene_size = {width: scene.width, height: scene.height};
		}
		#if hlimgui_cursor
		// Somewhat hacky solution to enforce a cursor: But that's what we can do.
		var cursor = ImGuiDrawableBuffers.instance.cursor_map[ImGui.getMouseCursor()];
		if (cursor != null)
			@:privateAccess scene.events.defaultCursor = cursor;
		#end

		// Update modifier states
		#if !multidriver
		io.addKeyEvent(ImGuiKey.ModShift, Key.isDown(KeyCode.SHIFT));
		io.addKeyEvent(ImGuiKey.ModAlt, Key.isDown(KeyCode.ALT));
		io.addKeyEvent(ImGuiKey.ModCtrl, Key.isDown(KeyCode.CTRL));
		io.addKeyEvent(ImGuiKey.ModSuper, Key.isDown(KeyCode.LEFT_WINDOW_KEY) || Key.isDown(KeyCode.RIGHT_WINDOW_KEY));
		#end

		#if multidriver
		var x = 0;
		var y = 0;
		SdlPlatform.getGlobalMouseState(x, y);
		io.addMousePosEvent(x, y);
		#end
	}

	#if multidriver
	// When in multidriver mode, mouse cooridnates operate in absoluate space instead of relative.
	// Adjust the event accordingly

	/**
		Forwards a platform event to the matching Dear ImGui viewport.
	**/
	public function onMultiWindowEvent(window:hxd.Window, originalEvent:hxd.Event, viewport:ImGuiViewport) {
		if (disposed)
			return;
		var event = new hxd.Event(originalEvent.kind, originalEvent.relX, originalEvent.relY);
		event.button = originalEvent.button;
		event.wheelDelta = originalEvent.wheelDelta;
		event.keyCode = originalEvent.keyCode;
		event.charCode = originalEvent.charCode;

		@:privateAccess
		{
			event.relX += window.window.x;
			event.relY += window.window.y;
		}
		onEvent(event);
		if (!event.propagate)
			originalEvent.propagate = false;

		if (viewport != null) {
			switch (event.kind) {
				case EMove:
					var io = ImGui.getIO();
					if ((io.BackendFlags & ImGuiBackendFlags.HasMouseHoveredViewport) != 0)
						io.addMouseViewportEvent(viewport.ID);
				default:
			}
		}
	}
	#end

	private function onEvent(event:hxd.Event) {
		if (disposed)
			return;
		var io = ImGui.getIO();
		switch (event.kind) {
			#if !multidriver
			case EMove:
				io.addMousePosEvent(event.relX, event.relY);
			#end

			case EPush:
				io.addMouseButtonEvent(event.button, true);

				if (io.WantCaptureMouse)
					event.propagate = false;

			case ERelease:
				io.addMouseButtonEvent(event.button, false);

				if (io.WantCaptureMouse)
					event.propagate = false;

			case EWheel:
				io.addMouseWheelEvent(0, this.wheel_inverted ? event.wheelDelta : -event.wheelDelta);

				if (io.WantCaptureMouse)
					event.propagate = false;

			case EKeyDown:
				var imguiKey = this.keycode_map[event.keyCode];
				if (imguiKey != null)
					io.addKeyEvent(imguiKey, true);

				// In multidriver, we don't use heaps' input system so we need to manage key mods ourself
				#if multidriver
				updateModifiers(event.keyCode, true);
				#end

				if (io.WantCaptureKeyboard)
					event.propagate = false;

			case EKeyUp:
				var imguiKey = this.keycode_map[event.keyCode];
				if (imguiKey != null)
					io.addKeyEvent(imguiKey, false);

				#if multidriver
				updateModifiers(event.keyCode, false);
				#end

				if (io.WantCaptureKeyboard)
					event.propagate = false;

			case ETextInput:
				io.addInputCharacter(event.charCode);
				if (io.WantCaptureKeyboard)
					event.propagate = false;

				#if multidriver
				// It looks goofy to hide these behind multidriver, but the normal model listens for heaps
				// stack events, not window events. Focus events mean something completely different in
				// that context. That said, I don't know if it actually does anything.
				case EFocus:
					io.addFocusEvent(true);
				case EFocusLost:
					modifier_keys_down.clear();
					io.addFocusEvent(false);
				#end

			default:
		}
	}

	#if multidriver
	function updateModifiers(code:Int, down:Bool) {
		var io = ImGui.getIO();
		var modifier:Int;
		var left:Int;
		var right:Int;
		switch (code) {
			case KeyCode.LCTRL | KeyCode.RCTRL:
				modifier = ImGuiKey.ModCtrl;
				left = KeyCode.LCTRL;
				right = KeyCode.RCTRL;
			case KeyCode.LALT | KeyCode.RALT:
				modifier = ImGuiKey.ModAlt;
				left = KeyCode.LALT;
				right = KeyCode.RALT;
			case KeyCode.LSHIFT | KeyCode.RSHIFT:
				modifier = ImGuiKey.ModShift;
				left = KeyCode.LSHIFT;
				right = KeyCode.RSHIFT;
			case KeyCode.LEFT_WINDOW_KEY | KeyCode.RIGHT_WINDOW_KEY:
				modifier = ImGuiKey.ModSuper;
				left = KeyCode.LEFT_WINDOW_KEY;
				right = KeyCode.RIGHT_WINDOW_KEY;
			default:
				return;
		}

		var wasDown = modifier_keys_down[left] == true || modifier_keys_down[right] == true;
		modifier_keys_down[code] = down;
		var isDown = modifier_keys_down[left] == true || modifier_keys_down[right] == true;
		if (wasDown != isDown)
			io.addKeyEvent(modifier, isDown);
	}
	#end

	override function draw(ctx:h2d.RenderContext) {
		if (!disposed)
			ImGuiDrawableBuffers.instance.draw(ctx, this);
	}
}
#end
