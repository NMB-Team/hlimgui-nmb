import imgui.ImGuiDrawable;
import imgui.ImGui;
import imgui.ImGui.ImGuiMultiSelectIO;
import imgui.ImGui.ImGuiMultiSelectFlags;
import imgui.ImGui.ImGuiSelectionRequestType;
import imgui.ImGui.ImGuiTableColumnFlags;
import imgui.ImGui.ImGuiTableFlags;
import imgui.ImGui.ImGuiMod;
import imgui.ImGui.ImGuiKey;

// Sample with a simplified ImGuiApp that handles imgui presentation and update automatically
class Main extends imgui.ImGuiApp {
	static var selected = false;

	override function update(dt:Float) {
		ImGui.showDemoWindow();

		if (ImGui.begin("Modern API")) {
			ImGui.separatorText("Text and shortcuts");
			ImGui.textLink("Example");
			if (ImGui.beginItemTooltip()) {
				ImGui.text("Item tooltip");
				ImGui.endTooltip();
			}
			if (ImGui.shortcut(ImGuiMod.Ctrl | ImGuiKey.S)) {
				// Save action.
			}

			var viewport = ImGui.getMainViewport();
			ImGui.text('Main viewport: ${viewport.ID}');

			var multiSelect = ImGui.beginMultiSelect(ImGuiMultiSelectFlags.None, selected ? 1 : 0, 1);
			applySelectionRequests(multiSelect);
			ImGui.setNextItemSelectionUserData(0);
			if (ImGui.selectable("Selectable item", selected))
				selected = !selected;
			applySelectionRequests(ImGui.endMultiSelect());

			if (ImGui.beginTable("Modern table", 1, ImGuiTableFlags.Sortable)) {
				ImGui.tableSetupColumn("Name", ImGuiTableColumnFlags.AngledHeader);
				ImGui.tableAngledHeadersRow();
				ImGui.tableNextColumn();
				ImGui.text("Row");
				var sortSpecs = ImGui.tableGetSortSpecs();
				if (sortSpecs != null && sortSpecs.specsDirty)
					sortSpecs.specsDirty = false;
				ImGui.endTable();
			}
		}
		ImGui.end();
	}

	static function applySelectionRequests(io:ImGuiMultiSelectIO):Void {
		for (index in 0...io.requestsCount) {
			var request = io.getRequest(index);
			switch (request.type) {
				case ImGuiSelectionRequestType.SetAll:
					selected = request.selected;
				case ImGuiSelectionRequestType.SetRange:
					if (request.rangeFirstItem.toInt() == 0 || request.rangeLastItem.toInt() == 0)
						selected = request.selected;
				case ImGuiSelectionRequestType.None:
			}
		}
	}

	// Compile-time coverage for the modern image APIs and Heaps tile helpers.
	static function drawImages(texture:h3d.mat.Texture, tile:h2d.Tile):Void {
		var size = new imgui.ImGui.ImVec2(32, 32);
		ImGui.image(texture, size);
		ImGui.imageWithBg(texture, size);
		ImGui.imageButton("image", texture, size);
		ImGui.imageTile(tile, size);
		ImGui.imageTileButton("tile", tile, size);
	}

	// Compile-time coverage for resource, memory, sizing, scoped use, and removal font APIs.
	static function fontApiCoverage(resource:hxd.res.Resource, bytes:haxe.io.Bytes):Void {
		final mono = ImGui.fonts.add(resource, 16, {pixelSnap: true, oversampleH: 2, oversampleV: 1});
		ImGui.fonts.setDefault(resource, 18);
		ImGui.fonts.addResource("fonts/mono.ttf", 16);
		ImGui.fonts.setDefaultResource("fonts/main.ttf", 18);
		ImGui.fonts.addBytes(bytes, 16);
		ImGui.fonts.setDefaultBytes(bytes, 18);
		ImGui.fonts.size = 18;
		ImGui.fonts.scale = 1.25;
		ImGui.pushFont(mono);
		ImGui.popFont();
		ImGui.pushFont(mono, 18);
		ImGui.popFont();
		ImGui.fonts.with(mono, 14, () -> ImGui.text("Additional font"));
		ImGui.fonts.withSize(22, () -> ImGui.text("Larger text"));
		ImGui.fonts.remove(mono);
		ImGui.fonts.clearAdditional();
		ImGui.fonts.resetDefault();
		ImGui.getFontAtlas().addFontDefaultVector();
		ImGui.getFontAtlas().addFontDefaultBitmap();
		ImGui.getFontAtlas().compactCache();
	}

	static function main() {
		new Main();
	}
}
// Sample with just ImGuiDrawable and manual handling of imgui presentation and update:
/*
	class Main extends hxd.App {
		var drawable:ImGuiDrawable;

		override function init() {
			this.drawable = new ImGuiDrawable(this.s2d);
		}

		override function update(dt:Float) {
			drawable.update(dt);

			ImGui.newFrame();

			ImGui.showDemoWindow();

			ImGui.render();
		}

		override function onResize() {
			ImGui.setDisplaySize(this.s2d.width, this.s2d.height);
		}

		static function main() {
			new Main();
		}
	}
 */
