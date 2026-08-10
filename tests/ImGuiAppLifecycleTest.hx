import imgui.ImGui;
import imgui.ImGuiDrawable.ImGuiDrawableBuffers;

class ImGuiAppLifecycleTest extends imgui.ImGuiApp {
	var frame = 0;

	override function update(dt:Float) {
		ImGui.begin("ImGuiApp lifecycle");
		ImGui.text("ImGuiApp disposal regression test");
		ImGui.end();

		if (frame++ != 2)
			return;
		dispose();
		@:privateAccess {
			final buffers = ImGuiDrawableBuffers.instance;
			if (buffers.ownerCount != 0 || buffers.initialized)
				throw "ImGuiApp disposal retained renderer ownership";
		}
		if (ImGui.getCurrentContext() == null)
			throw "ImGuiApp disposal destroyed the ImGui context";
		Sys.println("imgui app lifecycle: passed");
		hxd.System.exit();
	}

	static function main() {
		new ImGuiAppLifecycleTest();
	}
}
