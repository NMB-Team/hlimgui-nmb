package imgui;

#if heaps
import imgui.ImGui;

#if limen
import limen.platform.Platform as SdlPlatform;
#elseif hlsdl
import sdl.Sdl as SdlPlatform;
#end

/**
	A simplified Heaps App that can be used to get Imgui integrated without much hassle.

	It uses a separate 2D scene to render ImGui contents, as well as prioritises imgui as recepient for input events.

	Usage example:
	```haxe
	class MyGameApp extends #if hlimgui imgui.ImGuiApp #else hxd.App #end {

	// Use your regular App setup.

	}
	```
**/
class ImGuiApp extends hxd.App {
	var imguiInitialized = false;
	var imguiScene:ImGuiScene;
	var imguiDrawable:imgui.ImGuiDrawable;

	/**
		Called right after ImGui.newFrame().
		Input events for the current frame have already been processed.
	**/
	function onNewFrame() {}

	/**
		Called right before ImGui.render() allowing to inject some extra ImGui code right before rendering.
	**/
	function beforeRender() {}

	function initImgui() {
		imguiInitialized = true;
		var s = new ImGuiScene();
		imguiScene = s;
		sevents.addScene(s, 0);
		// Drawable have to be initialized after scene was added to the scene events.
		imguiDrawable = s.init();

		#if multidriver
		var pio = ImGui.getPlatformIO();
		var io = ImGui.getIO();
		io.ConfigFlags |= ViewportsEnable;
		io.BackendFlags |= ImGuiBackendFlags.PlatformHasViewports;
		io.BackendFlags |= ImGuiBackendFlags.RendererHasViewports;
		io.BackendFlags |= ImGuiBackendFlags.HasMouseHoveredViewport;

		// Set up the main window hooks.
		var v = pio.setMainViewport(hxd.Window.getInstance());
		if (v != null) {
			var w = hxd.Window.getInstance();

			w.onMove = () -> {
				v.PlatformRequestMove = true;
			}

			@:privateAccess
			{
				var d = imguiDrawable;
				w.addEventTarget((e:hxd.Event) -> {
					d.onMultiWindowEvent(w, e, v);
				});
			}

			w.addResizeEvent(() -> {
				v.PlatformRequestResize = true;
			});
		}

		#if (hlsdl || limen)
		// This hint allows a focus click to also send events. Without this, you have to click a window
		// once before you can interact with it, which feels really bad.
		SdlPlatform.setHint("SDL_MOUSE_FOCUS_CLICKTHROUGH", "1");
		io.ConfigDockingTransparentPayload = true;

		for (d in SdlPlatform.getDisplays()) {
			#if limen
			pio.addMonitor({
				x: d.width,
				y: d.height
			}, {
				x: d.x,
				y: d.y
			});
			#else
			pio.addMonitor({
				x: d.right - d.left,
				y: d.bottom - d.top
			}, {
				x: d.left,
				y: d.top
			});
			#end
		}
		#else
		// @todo: need to pass position in.
		for (m in hxd.Window.getMonitors()) {
			pio.addMonitor({x: m.width, y: m.height}, {x: 0, y: 0});
		}
		#end

		pio.Platform_CreateWindow = (v:ImGuiViewport) -> {
			@:privateAccess
			{
				#if hldx
				var w = new hxd.Window("ImGui Viewport", 100, 100, {fixed: false});
				var e = new h3d.Engine();
				e.window = w;
				var d3dDriver = new DirectXDriver();
				e.driver = d3dDriver;
				d3dDriver.window = w.window;
				d3dDriver.reset();
				d3dDriver.init(e.onCreate, !e.hardware);
				#elseif (hlsdl || limen)
				var mainWindow = hxd.Window.inst;
				var w = new hxd.Window("ImGui Viewport", 100, 100, {fixed: false, hidden: true});
				w.displayMode = hxd.Window.DisplayMode.Borderless;
				var e = h3d.Engine.getCurrent();
				// Disable vsync on these windows; else we end up waiting for vblank for every individual window.
				w.vsync = false;

				#if hlsdl
				@:privateAccess
				{
					w.window.visible = false;
					// !! HACK !!
					// Heaps always creates a new context when you create a window. That's perfectly reasonable
					// if multi driver was what we wanted, but it isn't, so slam the context.
					// Additionally, store off the created context so we can set it back during window destroy
					// since heaps always destroys the context alongside the window
					v.PlatformHandleRaw = cast w.window.glctx;
					w.window.glctx = mainWindow.window.glctx;
				}
				#else
				@:privateAccess w.window.visible = false;
				#end
				#end

				w.onClose = () -> {
					v.PlatformRequestClose = true;
					return false;
				}

				w.onMove = () -> {
					v.PlatformRequestMove = true;
				}

				// Get a handle to our drawable and add events. Yes it's gross.
				@:privateAccess
				{
					var d = imguiDrawable;
					w.addEventTarget((e:hxd.Event) -> {
						d.onMultiWindowEvent(w, e, v);
						// Window events should NEVER propagate down; heaps isn't listening for them so we need to
						// do this to prevent the OS chime from playing on key press.
						// There is an argument for leaving this up to the implementer to decide (this behavior
						// may be desirable at times) but this is less annoying for now.
						e.propagate = false;
					});
				}

				w.addResizeEvent(() -> {
					v.PlatformRequestResize = true;
				});

				v.PlatformHandle = w;
			}
		};

		pio.Platform_DestroyWindow = (v:ImGuiViewport) -> {
			@:privateAccess
			{
				var w = v.PlatformHandle;
				#if hlsdl
				// !! HACK !!
				// We stored off glctx so we could restore it here and destroy it when the window
				// is destroyed. We need to do this so we don't accidentally destoy our main
				// ctx, these are just junk contexts we created because heaps does it automatically
				if (w != null)
					w.window.glctx = cast v.PlatformHandleRaw;
				#end

				if (w != null)
					w.close();

				// Avoid pumping SDL events from inside an ImGui destroy callback.
				// In multidriver mode that can re-enter Heaps window routing while
				// the viewport window is only partially torn down.

				v.RendererUserData = null;
				v.PlatformUserData = null;
				v.PlatformHandle = null;
			}
		};

		pio.Platform_ShowWindow = (v:ImGuiViewport) -> {
			#if (hlsdl || limen)
			if (v.PlatformHandle != null)
				@:privateAccess v.PlatformHandle.window.visible = true;
			#end
		};

		pio.Platform_SetWindowPos = (v:ImGuiViewport, size:ImVec2) -> {
			if (v.PlatformHandle == null)
				return;

			#if hldx
			var w:dx.Window = @:privateAccess v.PlatformHandle.window;
			w.setPosition(cast size.x, cast size.y);
			#elseif (hlsdl || limen)
			@:privateAccess v.PlatformHandle.window.setPosition(cast size.x, cast size.y);
			#end
		};

		pio.Platform_GetWindowPos = (v:ImGuiViewport, pos:ImGuiVec2Struct) -> {
			#if (hlsdl || limen)
			@:privateAccess
			{
				if (v.PlatformHandle != null) {
					pos.x = v.PlatformHandle.window.x;
					pos.y = v.PlatformHandle.window.y;
				} else {
					pos.x = v.Pos.x;
					pos.y = v.Pos.y;
				}
			}
			#else
			pos.x = 0;
			pos.y = 0;
			#end
		};

		pio.Platform_SetWindowSize = (v:ImGuiViewport, size:ImVec2) -> {
			if (v.PlatformHandle == null)
				return;

			if (v.PlatformHandle.width == size.x && v.PlatformHandle.height == size.y)
				return;

			v.PlatformHandle.resize(cast size.x, cast size.y);
		};

		pio.Platform_GetWindowSize = (v:ImGuiViewport, size:ImGuiVec2Struct) -> {
			var window:hxd.Window = v.PlatformHandle;
			if (window != null) {
				size.x = window.width;
				size.y = window.height;
			} else {
				size.x = v.Size.x;
				size.y = v.Size.y;
			}
		};

		pio.Platform_SetWindowFocus = (v:ImGuiViewport) -> {
			// @todo
		};

		pio.Platform_GetWindowFocus = (v:ImGuiViewport) -> {
			return v.PlatformHandle != null && v.PlatformHandle.isFocused;
		};

		pio.Platform_GetWindowMinimized = (v:ImGuiViewport) -> {
			return false; // @todo
		};

		pio.Platform_SetWindowTitle = (v:ImGuiViewport, title:hl.Bytes) -> {
			if (v.PlatformHandle == null)
				return;

			var str = @:privateAccess String.fromUTF8(title);
			v.PlatformHandle.title = str;
		};

		pio.Platform_SetWindowAlpha = (v:ImGuiViewport, alpha:Single) -> {
			#if (hlsdl || limen)
			if (v.PlatformHandle != null)
				@:privateAccess v.PlatformHandle.window.opacity = alpha;
			#end
		};

		pio.Renderer_RenderWindow = (v:ImGuiViewport, arg:Dynamic) -> {
			if (!v.PlatformWindowCreated || v.PlatformHandle == null)
				return;

			var oldWin = hxd.Window.getInstance();

			var e:h3d.Engine = h3d.Engine.getCurrent();
			var w = v.PlatformHandle;

			w.setCurrent();

			var s2d = imguiDrawable.getScene();

			@:privateAccess
			{
				var oldW = e.width;
				var oldH = e.height;
				var oldSceneWidth = s2d.width;
				var oldSceneHeight = s2d.height;
				var oldScaleMode = s2d.scaleMode;

				e.window = w;
				e.resize(w.width, w.height);

				@:privateAccess s2d.window = w;

				s2d.width = w.width;
				s2d.height = w.height;
				s2d.scaleMode = Fixed(w.width, w.height, 1);
				if ((v.Flags & ImGuiViewportFlags.NoRendererClear) == 0) {
					e.setRenderZone();
					e.clear(e.backgroundColor == null ? 0 : e.backgroundColor, 1, 0);
				}
				s2d.render(e);
				s2d.width = oldSceneWidth;
				s2d.height = oldSceneHeight;

				// w.window.present();

				e.resize(oldW, oldH);
				e.window = oldWin;
				s2d.scaleMode = oldScaleMode;
			}

			oldWin.setCurrent();
		};

		pio.Renderer_SwapBuffers = (v:ImGuiViewport, arg:Dynamic) -> {
			if (!v.PlatformWindowCreated || v.PlatformHandle == null)
				return;

			var oldWin = hxd.Window.getInstance();
			var w = v.PlatformHandle;
			w.setCurrent();
			#if !limen
			@:privateAccess w.window.present();
			#end
			oldWin.setCurrent();
		};
		#end
	}

	override function setup() {
		super.setup();
		if (!imguiInitialized)
			initImgui();
	}

	override function onResize() {
		if (imguiScene != null) {
			imguiScene.checkResize();
			var io = ImGui.getIO();
			io.DisplaySize.x = imguiScene.width;
			io.DisplaySize.y = imguiScene.height;
		}
		super.onResize();
	}

	override function setScene2D(s2d:h2d.Scene, disposePrevious:Bool = true) {
		// Ensure that if we set new s2d - imgui scene still prioritized by input events.
		super.setScene2D(s2d, disposePrevious);
		sevents.removeScene(imguiScene);
		sevents.addScene(imguiScene, 0);
	}

	override function init() {
		if (!imguiInitialized)
			initImgui();
		super.init();
	}

	// Main loop is completely overriden because Heaps have no proper way to inject non-standard scenes into an update loop.
	override function mainLoop() {
		hxd.Timer.update();

		var dt = hxd.Timer.dt; // fetch again in case it's been modified in update()

		if (imguiDrawable != null)
			imguiDrawable.update(hxd.Timer.dt);

		sevents.checkEvents();

		if (isDisposed)
			return;

		ImGui.newFrame();
		onNewFrame();
		update(hxd.Timer.dt);

		if (isDisposed) {
			ImGui.endFrame();
			return;
		}

		dt = hxd.Timer.dt;

		s2d?.setElapsedTime(dt);
		s3d?.setElapsedTime(dt);
		imguiScene?.setElapsedTime(dt);

		engine.render(this);
	}

	/**
		Renders the application scenes, Dear ImGui draw data, and enabled platform viewports.
	**/
	override public function render(e:h3d.Engine) {
		super.render(e);
		beforeRender();
		ImGui.render();
		imguiScene.render(e);

		// Viewports
		var io = ImGui.getIO();
		if ((io.ConfigFlags & ImGuiConfigFlags.ViewportsEnable) != 0) {
			ImGui.updatePlatformWindows();
			ImGui.renderPlatformWindowsDefault(null, e);
		}
	}

	override function dispose() {
		if (imguiScene != null)
			imguiScene.dispose();
		super.dispose();
	}
}

private class ImGuiScene extends h2d.Scene {
	var overlay:h2d.Interactive;
	var drawable:imgui.ImGuiDrawable;

	/**
		Creates a new `ImGuiScene` instance.
	**/
	public function new() {
		super();
		overlay = new h2d.Interactive(width, height, this);
		overlay.cursor = Default;
	}

	/**
		Initializes this instance.
	**/
	public function init() {
		drawable = new imgui.ImGuiDrawable(this);
		return drawable;
	}

	/**
		Routes mouse and keyboard events to Dear ImGui and returns the capture overlay when ImGui consumes them.
	**/
	override public function handleEvent(e:hxd.Event, last:hxd.SceneEvents.Interactive):hxd.SceneEvents.Interactive {
		if (last == overlay)
			return null;
		@:privateAccess drawable.onEvent(e);
		var io = ImGui.getIO();
		return if (io.WantCaptureMouse
			&& (e.kind == EPush || e.kind == ERelease || e.kind == EWheel || e.kind == EMove || e.kind == ECheck)
			|| io.WantCaptureKeyboard
			&& (e.kind == EKeyDown || e.kind == EKeyUp || e.kind == ETextInput)) overlay; else null;
	}

	/**
		Resizes the input-capture overlay to match the scene.
	**/
	override public function checkResize() {
		super.checkResize();
		overlay.width = width;
		overlay.height = height;
	}

	/**
		Ignores scene listeners because input is forwarded manually.
	**/
	override public function addEventListener(f:hxd.Event -> Void) {
		return; // Prevent drawable from adding listeners as we manually handle it.
	}
}
#end
