package imgui;

import imgui.types.Renderer;
import imgui.types.ImFontAtlas;

#if heaps
import h2d.Tile;

import h3d.mat.Texture;

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

/**
	Owns reusable Heaps buffers and textures used by the Dear ImGui renderer.
**/
class ImGuiDrawableBuffers {
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

	var noTexture:Texture;
	final textures:Array<ManagedImGuiTexture> = [];

	var commandData:RenderCommandCallbackData = @:privateAccess new RenderCommandCallbackData();

	private var initialized:Bool;

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
		Initializes this instance and its native resources.
	**/
	public function initialize(addDefaultFont:Bool = true) {
		if (this.initialized) {
			return;
		}

		ImGui.provideTypes();
		ImGui.ensureContext();
		ImGui.setRenderCallback(renderDrawList);
		ImGui.setTextureCallback(updateTextures);

		var io = ImGui.getIO();
		io.BackendFlags |= ImGuiBackendFlags.RendererHasTextures;

		noTexture = Tile.fromColor(0xffffff).getTexture();
		this.initialized = true;
	}

	/**
		Releases resources owned by this instance.
	**/
	public function dispose() {
		for (index_buffer in this.index_buffers) {
			index_buffer.dispose();
		}
		this.index_buffers = [];

		for (vertex_buffer in this.vertex_buffers) {
			vertex_buffer.dispose();
		}
		this.vertex_buffers = [];
		this.commands = [];

		ImGui.setRenderCallback(null);
		ImGui.setTextureCallback(null);
		ImGui.invalidateRendererTextures();
		for (managed in textures)
			managed.texture.dispose();
		textures.resize(0);
		font_texture = null;
		#if hlimgui_cursor
		cursor_map.clear();
		#end

		this.initialized = false;
	}

	private function new() {
		this.initialized = false;
	}

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
	#end

	private function renderDrawList(renderList:RenderList) {
		bufferCount = 0;

		for (i in 0...renderList.size) {
			var data = renderList.lists[i];

			final vertexStride = 8;
			var vertexCount = Std.int(data.vertexBufferSize / (vertexStride * 4)); // data.vertexBufferSize>>5;
			var indexCount = data.indexBufferSize >> 2;
			// if (vertexCount == 0) continue;

			// create or reuse vertex buffer
			if (i == this.vertex_buffers.length) {
				#if hlimgui_heaps_old_buffer_alloc
				this.vertex_buffers[i] = new h3d.Buffer(vertexCount, vertexStride, [RawFormat, Dynamic]);
				#else
				this.vertex_buffers[i] = new h3d.Buffer(vertexCount, hxd.BufferFormat.H2D, [Dynamic]);
				#end
				this.index_buffers[i] = new h3d.Indexes(indexCount, true);
			} else {
				if (this.vertex_buffers[i].vertices < vertexCount) {
					this.vertex_buffers[i].dispose();
					#if hlimgui_heaps_old_buffer_alloc
					this.vertex_buffers[i] = new h3d.Buffer(vertexCount, vertexStride, [RawFormat, Dynamic]);
					#else
					this.vertex_buffers[i] = new h3d.Buffer(vertexCount, hxd.BufferFormat.H2D, [Dynamic]);
					#end
				}
				if (this.index_buffers[i].count < indexCount) {
					this.index_buffers[i].dispose();
					this.index_buffers[i] = new h3d.Indexes(indexCount, true);
				}
			}
			this.vertex_buffers[i].uploadBytes(data.vertexBuffer.toBytes(data.vertexBufferSize), 0, vertexCount);
			this.index_buffers[i].uploadBytes(data.indexBuffer.toBytes(data.indexBufferSize), 0, indexCount);
			this.commands[i] = data; // data.commands.sub(0, data.commandCount);
			bufferCount++;
		}
	}

	/**
		Helper calling InputText+Build.
	**/
	public function draw(ctx:h2d.RenderContext, obj:h2d.Drawable) {
		var e = ctx.engine;
		commandData.ctx = ctx;
		commandData.obj = obj;
		for (i in 0...bufferCount) {
			var data = commands[i];
			var cmdList = data.commands;
			for (j in 0...data.commandCount) {
				var cmd = cmdList[j];
				if (cmd.callback != null) {
					e.setRenderZone(); // Makre sure to reset clip rect.
					cmd.callback(data, cmd, commandData);
				} else if (cmd.elemCount > 0 && ctx.beginDrawObject(obj, cmd.textureID == null ? noTexture : cmd.textureID)) {
					e.setRenderZone(cmd.clipLeft, cmd.clipTop, cmd.clipWidth, cmd.clipHeight);
					e.renderIndexed(vertex_buffers[i], index_buffers[i], Std.int(cmd.indexOffset / 3), Std.int(cmd.elemCount / 3));
				}
			}
		}

		e.setRenderZone();
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
	var wheel_inverted:Bool;
	#if hlimgui_cursor
	var cursorMap:Map<ImGuiMouseCursor, hxd.Cursor> = [];
	#end
	private var scene_size:{width:Int, height:Int};

	/**
		Creates a new `ImGuiDrawable` instance.
	**/
	public function new(?parent, ?addDefaultFont = true) {
		super(parent);
		ImGuiDrawableBuffers.instance.initialize(addDefaultFont);

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
			KeyCode.NUMPAD_ENTER => ImGuiKey.KeypadEnter,
			KeyCode.LSHIFT => ImGuiKey.LeftShift,
			KeyCode.RSHIFT => ImGuiKey.RightShift,
			KeyCode.LALT => ImGuiKey.LeftAlt,
			KeyCode.RALT => ImGuiKey.RightAlt,
			KeyCode.LCTRL => ImGuiKey.LeftCtrl,
			KeyCode.RCTRL => ImGuiKey.RightCtrl,
			KeyCode.F1 => ImGuiKey.F1,
			KeyCode.F2 => ImGuiKey.F2,
			KeyCode.F3 => ImGuiKey.F3,
			KeyCode.F4 => ImGuiKey.F4,
			KeyCode.F5 => ImGuiKey.F5,
			KeyCode.F6 => ImGuiKey.F6,
			KeyCode.F7 => ImGuiKey.F7,
			KeyCode.F8 => ImGuiKey.F8,
			KeyCode.F9 => ImGuiKey.F9,
			KeyCode.F10 => ImGuiKey.F10,
			KeyCode.F11 => ImGuiKey.F11,
			KeyCode.F12 => ImGuiKey.F12,
		];

		// Add letters
		for (ko in 0...26)
			keycode_map[KeyCode.A + ko] = ImGuiKey.A + ko;

		#if !multidriver
		scene.addEventListener(onEvent);
		#end

		#if hlimgui_cursor
		hxd.System.setCursor = updateCursor;
		#end

		this.wheel_inverted = false;
	}

	/**
		Releases resources owned by this instance.
	**/
	public function dispose() {
		ImGuiDrawableBuffers.instance.dispose();
	}

	/**
		Updates this instance for the current frame.
	**/
	public function update(dt:Float) {
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
		// ImGui.addKeyEvent( ImGuiKey.ModSuper, Key.isDown( KeyCode.SUPER ) ); // Unsupported currently.
		#end

		#if multidriver
		var x = 0;
		var y = 0;
		SdlPlatform.getGlobalMouseState(x, y);
		io.addMousePosEvent(x, y);
		#end
	}

	#if hlimgui_cursor
	function updateCursor(cursor:hxd.Cursor) {
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
				var cur = ImGuiDrawableBuffers.instance.cursor_map[expected];
				if (cur != null)
					cursor = cur;
				hxd.System.setNativeCursor(cursor);
		}
	}
	#end

	#if multidriver
	// When in multidriver mode, mouse cooridnates operate in absoluate space instead of relative.
	// Adjust the event accordingly

	/**
		Forwards a platform event to the matching Dear ImGui viewport.
	**/
	public function onMultiWindowEvent(window:hxd.Window, originalEvent:hxd.Event, viewport:ImGuiViewport) {
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
				if (this.keycode_map.exists(event.keyCode))
					io.addKeyEvent(this.keycode_map[event.keyCode], true);

				// In multidriver, we don't use heaps' input system so we need to manage key mods ourself
				#if multidriver
				updateModifiers(event.keyCode, true);
				#end

				if (io.WantCaptureKeyboard)
					event.propagate = false;

			case EKeyUp:
				if (this.keycode_map.exists(event.keyCode))
					io.addKeyEvent(this.keycode_map[event.keyCode], false);

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
					io.addFocusEvent(false);
				#end

			default:
		}
	}

	function updateModifiers(code:Int, down:Bool) {
		var io = ImGui.getIO();
		switch (code) {
			case KeyCode.LCTRL | KeyCode.RCTRL:
				io.addKeyEvent(ImGuiKey.ModCtrl, down);
			case KeyCode.LALT | KeyCode.RALT:
				io.addKeyEvent(ImGuiKey.ModAlt, down);
			case KeyCode.LSHIFT | KeyCode.RSHIFT:
				io.addKeyEvent(ImGuiKey.ModShift, down);
		}
	}

	override function draw(ctx:h2d.RenderContext) {
		ImGuiDrawableBuffers.instance.draw(ctx, this);
	}
}
#end
