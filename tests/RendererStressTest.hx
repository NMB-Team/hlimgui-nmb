import imgui.ImGui;
import imgui.ImGui.ImGuiCond;
import imgui.ImGui.ImVec2;
import imgui.ImGui.ImVec4;
import imgui.ImGuiDrawable.ImGuiDrawableBuffers;
import imgui.types.Renderer.RenderCommand;
import imgui.types.Renderer.RenderCommandCallbackData;
import imgui.types.Renderer.RenderData;

class RendererStressTest extends imgui.ImGuiApp {
	static inline final RECTANGLE_COUNT = 50000;
	static var callbackCount = 0;

	var redTile:h2d.Tile;
	var greenTile:h2d.Tile;
	var colors:Array<Int>;
	var frame = 0;
	var verified = false;

	override function init() {
		ImGui.fonts.setDefault(hxd.Res.Roboto_Medium, 18);
		redTile = h2d.Tile.fromColor(0xff0000, 64, 64);
		greenTile = h2d.Tile.fromColor(0x00ff00, 64, 64);
		colors = [
			ImGui.colorConvertFloat4ToU32(new ImVec4(1, 0, 0, 1)),
			ImGui.colorConvertFloat4ToU32(new ImVec4(0, 1, 0, 1)),
			ImGui.colorConvertFloat4ToU32(new ImVec4(0, 0, 1, 1)),
			ImGui.colorConvertFloat4ToU32(new ImVec4(1, 1, 0, 1))
		];
		super.init();
	}

	override function update(dt:Float) {
		ImGui.dockSpaceOverViewport();
		drawGeometryWindow();
		drawTableWindow();

		if (frame == 2)
			ImGui.fonts.setDefault(hxd.Res.Karla_Regular, 20);
		if (frame == 4)
			ImGui.fonts.resetDefault();

		final buffers = ImGuiDrawableBuffers.instance;
		if (!verified && frame > 3 && callbackCount > 0) {
			if (buffers.lastVertexCount < RECTANGLE_COUNT * 4)
				throw 'Renderer stress geometry was truncated: ${buffers.lastVertexCount} vertices';
			if (buffers.lastVertexStride != 20)
				throw 'Unexpected ImDrawVert stride: ${buffers.lastVertexStride}';
			if (buffers.lastVertexBytes != buffers.lastVertexCount * buffers.lastVertexStride)
				throw "Uploaded vertex byte count does not match the compact vertex layout";
			if (buffers.lastDrawListCount < 2)
				throw 'Expected multiple draw lists, got ${buffers.lastDrawListCount}';
			verified = true;
		}

		if (frame++ == 8) {
			if (!verified)
				throw "Renderer stress checks did not run";
			Sys.println('renderer stress: vertices=${buffers.lastVertexCount}, drawLists=${buffers.lastDrawListCount}, stride=${buffers.lastVertexStride}, vertexUpload=${buffers.lastVertexBytes} bytes, prepare=${buffers.lastPrepareTimeUs}us, callbacks=$callbackCount');
			hxd.System.exit();
		}
	}

	function drawGeometryWindow() {
		ImGui.setNextWindowSize(new ImVec2(700, 650), ImGuiCond.FirstUseEver);
		if (ImGui.begin("Raw vertex stress")) {
			ImGui.textColored(new ImVec4(1, 0.25, 0.1, 1), "RGBA color and font test");
			ImGui.imageTile(redTile, new ImVec2(64, 64));
			ImGui.sameLine();
			ImGui.imageTile(greenTile, new ImVec2(64, 64));

			final drawList = ImGui.getWindowDrawList();
			final origin = ImGui.getCursorScreenPos();
			final minimum = new ImVec2();
			final maximum = new ImVec2();
			final clipMaximum = new ImVec2(origin.x + 512, origin.y + 420);
			drawList.pushClipRect(origin, clipMaximum, true);
			for (index in 0...RECTANGLE_COUNT) {
				final column = index % 250;
				final row = Std.int(index / 250);
				minimum.x = origin.x + column * 2;
				minimum.y = origin.y + row * 2;
				maximum.x = minimum.x + 1.5;
				maximum.y = minimum.y + 1.5;
				drawList.addRectFilled(minimum, maximum, colors[index & 3]);
			}
			drawList.popClipRect();

			drawList.addCallback(ImGuiDrawableBuffers.setNearestCommand);
			drawList.addRectFilled(origin, new ImVec2(origin.x + 16, origin.y + 16), colors[0]);
			drawList.addCallback(countCallback);
			drawList.addCallback(ImGuiDrawableBuffers.resetSmoothCommand);
			ImGui.dummy(new ImVec2(512, 420));
		}
		ImGui.end();
	}

	function drawTableWindow() {
		if (ImGui.begin("Table and clipping stress")) {
			if (ImGui.beginTable("large-table", 3, 0, new ImVec2(500, 300))) {
				for (row in 0...1000) {
					ImGui.tableNextRow();
					for (column in 0...3) {
						ImGui.tableNextColumn();
						ImGui.text('row $row, column $column');
					}
				}
				ImGui.endTable();
			}
			for (index in 0...100)
				ImGui.button('Button $index');
		}
		ImGui.end();
	}

	static function countCallback(data:RenderData, command:RenderCommand, callbackData:RenderCommandCallbackData) {
		callbackCount++;
	}

	static function main() {
		hxd.Res.initLocal();
		new RendererStressTest();
	}
}
