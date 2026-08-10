import imgui.ImGui;
import imgui.types.ImFont;

class FontApiTest extends imgui.ImGuiApp {
	static var pakPath:String;

	var additional:ImFont;
	var lateFont:ImFont;
	var frame = 0;

	override function init() {
		ImGui.fonts.setDefault(hxd.Res.Roboto_Medium, 18);
		additional = ImGui.fonts.addResource("Cousine-Regular.ttf", 16);

		if (!additional.isLoaded())
			throw "Additional font was not loaded";

		if (!additional.hasGlyph("A".code))
			throw "Additional font does not contain expected ASCII glyph";

		trace('Loaded font: ${additional.getDebugName()}');

		hl.Gc.major();
		super.init();
	}

	override function update(dt:Float) {
		ImGui.begin("Font API test");
		ImGui.text("Default font");
		if (additional != null)
			ImGui.fonts.with(additional, 14, () -> ImGui.text("Additional font"));
		if (lateFont != null)
			ImGui.fonts.with(lateFont, 17, () -> ImGui.text("Late-loaded font"));
		ImGui.end();

		switch (frame++) {
			case 2:
				ImGui.fonts.setDefault(hxd.Res.Karla_Regular, 20);
				hl.Gc.major();
			case 4:
				ImGui.fonts.remove(additional);
				additional = null;
			case 6:
				lateFont = ImGui.fonts.addBytes(hxd.Res.DroidSans.entry.getBytes(), 16);
				hl.Gc.major();
			case 8:
				ImGui.fonts.size = 22;
			case 9:
				ImGui.getFontAtlas().compactCache();
			case 10:
				ImGui.fonts.resetDefault();
			case 12:
				if (pakPath != null) {
					hxd.res.Loader.currentInstance.dispose();
					hxd.res.Loader.currentInstance = null;
					if (sys.FileSystem.exists(pakPath))
						sys.FileSystem.deleteFile(pakPath);
				}
				hxd.System.exit();
			default:
		}
	}

	static function main() {
		#if font_api_pak
		final pakBase = "font-api-test-res";
		pakPath = pakBase + ".pak";
		hxd.fmt.pak.Build.make("extension/lib/imgui/misc/fonts", pakBase);
		hxd.Res.initPak("font-api-test-res");
		#else
		hxd.Res.initLocal();
		#end
		new FontApiTest();
	}
}
