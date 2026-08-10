import imgui.ImGui;
import imgui.ImGuiDrawable;
import imgui.ImGuiDrawable.ImGuiDrawableBuffers;

class RendererLifecycleTest extends hxd.App {
	var active:ImGuiDrawable;
	var frame = 0;
	var renderAttempts = 0;

	override function init() {
		active = createDrawable();
		assertRendererState(1, true);
	}

	override function update(dt:Float) {
		final buffers = ImGuiDrawableBuffers.instance;
		if (frame > 0 && buffers.lastVertexCount == 0) {
			if (++renderAttempts > 10)
				throw 'Renderer produced no vertices after $renderAttempts frames';
			renderActive(dt);
			return;
		}
		renderAttempts = 0;

		switch (frame) {
			case 1:
				assertRendered("initial drawable");
				disposeDrawable(active);
				active.dispose();
				assertRendererState(0, false);
				if (ImGui.getCurrentContext() == null)
					throw "Renderer disposal destroyed the ImGui context";
				active = createDrawable();
				assertRendererState(1, true);
			case 2:
				assertRendered("sequential drawable");
				final remaining = createDrawable();
				assertRendererState(2, true);
				disposeDrawable(active);
				active = remaining;
				assertRendererState(1, true);
			case 3:
				assertRendered("second owner");
				disposeDrawable(active);
				final first = createDrawable();
				final second = createDrawable();
				assertRendererState(2, true);
				disposeDrawable(second);
				active = first;
				assertRendererState(1, true);
			case 4:
				assertRendered("first owner after reverse disposal");
				disposeDrawable(active);
				assertRendererState(0, false);
				active = createDrawable();
			case 5:
				assertRendered("drawable before context destruction");
				ImGui.destroyContext();
				disposeDrawable(active);
				assertRendererState(0, false);
				active = createDrawable();
				if (ImGui.getCurrentContext() == null)
					throw "Renderer reinitialization did not recreate an ImGui context";
			case 6 | 7:
				assertRendered('repeated lifecycle ${frame - 5}');
				disposeDrawable(active);
				assertRendererState(0, false);
				active = createDrawable();
			case 8:
				assertRendered("repeated lifecycle 3");
				disposeDrawable(active);
				assertRendererState(0, false);

				buffers.initialize();
				buffers.initialize();
				assertRendererState(1, true);
				buffers.dispose();
				buffers.dispose();
				assertRendererState(0, false);
				var underflowRejected = false;
				try {
					buffers.release();
				} catch (_:Dynamic) {
					underflowRejected = true;
				}
				if (!underflowRejected)
					throw "Renderer ownership underflow was not rejected";

				var constructionFailed = false;
				try {
					new ImGuiDrawable();
				} catch (_:Dynamic) {
					constructionFailed = true;
				}
				if (!constructionFailed)
					throw "Expected unattached ImGui drawable construction to fail";
				assertRendererState(0, false);

				ImGui.destroyContext();
				Sys.println("renderer lifecycle: passed");
				hxd.System.exit();
			default:
		}

		if (frame < 8)
			renderActive(dt);
		frame++;
	}

	function renderActive(dt:Float) {
		active.update(dt);
		ImGui.newFrame();
		ImGui.begin('Renderer lifecycle ${frame + 1}');
		ImGui.text("Renderer lifecycle regression test");
		ImGui.end();
		ImGui.render();
	}

	function createDrawable():ImGuiDrawable {
		final listenerCount = eventListenerCount();
		final drawable = new ImGuiDrawable(s2d);
		if (eventListenerCount() != listenerCount + 1)
			throw "ImGui drawable did not install exactly one event listener";
		@:privateAccess {
			final noTexture = ImGuiDrawableBuffers.instance.noTexture;
			if (noTexture == null || noTexture.isDisposed())
				throw "Renderer fallback texture was not recreated";
		}
		return drawable;
	}

	function disposeDrawable(drawable:ImGuiDrawable) {
		final listenerCount = eventListenerCount();
		drawable.dispose();
		if (eventListenerCount() != listenerCount - 1)
			throw "Disposed ImGui drawable retained its event listener";
		drawable.remove();
	}

	function assertRendered(label:String) {
		if (ImGuiDrawableBuffers.instance.lastVertexCount == 0)
			throw '$label did not produce renderer vertices';
	}

	function assertRendererState(expectedOwners:Int, expectedInitialized:Bool) {
		@:privateAccess {
			final buffers = ImGuiDrawableBuffers.instance;
			if (buffers.ownerCount != expectedOwners)
				throw 'Expected $expectedOwners renderer owners, got ${buffers.ownerCount}';
			if (buffers.initialized != expectedInitialized)
				throw 'Expected renderer initialized=$expectedInitialized, got ${buffers.initialized}';
			if (expectedInitialized) {
				if (buffers.noTexture == null || buffers.noTexture.isDisposed())
					throw "Initialized renderer has no valid fallback texture";
			} else if (buffers.bufferCount != 0
				|| buffers.vertex_buffers.length != 0
				|| buffers.index_buffers.length != 0
				|| buffers.commands.length != 0
				|| buffers.noTexture != null
				|| buffers.managedTextures.iterator().hasNext()
				|| buffers.font_texture != null) {
				throw "Final renderer release retained reusable state";
			}
			if (ImGui.getCurrentContext() != null) {
				final flags = ImGui.getIO().BackendFlags;
				final rendererFlags = ImGuiBackendFlags.RendererHasTextures | ImGuiBackendFlags.RendererHasVtxOffset;
				if (((flags & rendererFlags) != 0) != expectedInitialized)
					throw "ImGui renderer backend flags do not match renderer lifetime";
			}
		}
	}

	function eventListenerCount():Int {
		return @:privateAccess s2d.eventListeners.length;
	}

	static function main() {
		new RendererLifecycleTest();
	}
}
