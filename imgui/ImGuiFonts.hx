package imgui;

import haxe.io.Bytes;
import imgui.types.ImFont;
import imgui.types.ImFontAtlas.ImFontConfig;
import imgui.types.Pointers.ImContextPtr;

typedef ImGuiFontOptions = {
	?pixelSnap: Bool,
	?oversampleH: Int,
	?oversampleV: Int,
	?merge: Bool,
	?fontNo: Int
}

private class ImGuiFontEntry {
	public final context: ImContextPtr;
	public final font: ImFont;
	public final sources: Array<Bytes> = [];
	public var additional = false;
	public var managedDefault = false;

	public function new(context: ImContextPtr, font: ImFont) {
		this.context = context;
		this.font = font;
	}
}

class ImGuiFonts {
	public var size(get, set): Single;
	public var scale(get, set): Single;
	public var dpiScale(get, set): Single;

	final entries: Array<ImGuiFontEntry> = [];

	public function new() {}

	#if heaps
	public function setDefault(resource: hxd.res.Resource, size: Single, ?options: ImGuiFontOptions): ImFont {
		return setDefaultBytes(resource.entry.getBytes(), size, options);
	}

	public function setDefaultResource(path: String, size: Single, ?options: ImGuiFontOptions): ImFont {
		return setDefault(resourceLoader().load(path), size, options);
	}

	public function add(resource: hxd.res.Resource, ?size: Single, ?options: ImGuiFontOptions): ImFont {
		return addBytes(resource.entry.getBytes(), size, options);
	}

	public function addResource(path: String, ?size: Single, ?options: ImGuiFontOptions): ImFont {
		return add(resourceLoader().load(path), size, options);
	}

	function resourceLoader(): hxd.res.Loader {
		final loader = hxd.res.Loader.currentInstance;
		if (loader == null) throw "Heaps resources are not initialized";
		return loader;
	}
	#end

	public function setDefaultBytes(bytes: Bytes, size: Single, ?options: ImGuiFontOptions): ImFont {
		final context = ImGui.ensureContext();
		final oldDefault = findManagedDefault(context);
		final font = addBytesInternal(context, bytes, size, options);
		final entry = find(font, context);
		entry.managedDefault = true;

		ImGui.getIO().FontDefault = font;
		this.size = size;

		if (oldDefault != null && oldDefault != entry) {
			oldDefault.managedDefault = false;
			if (!oldDefault.additional) removeEntry(oldDefault);
		}
		return font;
	}

	public function addBytes(bytes: Bytes, ?size: Single, ?options: ImGuiFontOptions): ImFont {
		final context = ImGui.ensureContext();
		final font = addBytesInternal(context, bytes, size == null ? defaultSize() : size, options);
		find(font, context).additional = true;
		return font;
	}

	public function remove(font: ImFont): Bool {
		final context = ImGui.getCurrentContext();
		if (context == null) return false;
		final entry = find(font, context);
		if (entry == null) return false;
		removeEntry(entry);
		return true;
	}

	public function clearAdditional(): Void {
		final context = ImGui.getCurrentContext();
		if (context == null) return;
		for (entry in entries.copy()) {
			if (entry.context != context || !entry.additional) continue;
			entry.additional = false;
			if (!entry.managedDefault) removeEntry(entry);
		}
	}

	public function resetDefault(): Void {
		final context = ImGui.getCurrentContext();
		if (context == null) return;
		final oldDefault = findManagedDefault(context);
		if (oldDefault == null) {
			ImGui.getIO().FontDefault = null;
			return;
		}

		final defaultFont = ImGui.getFontAtlas().addFontDefault();
		ImGui.getIO().FontDefault = defaultFont;
		oldDefault.managedDefault = false;
		if (!oldDefault.additional) removeEntry(oldDefault);
	}

	public function clear(): Void {
		final context = ImGui.getCurrentContext();
		if (context == null) return;
		ImGui.getFontAtlas().clear();
		removeContextEntries(context);
	}

	public function dispose(): Void {
		clear();
	}

	public function with(font: ImFont, size: Single, action: () -> Void): Void {
		ImGui.pushFont(font, size);
		try {
			action();
		} catch (error: Dynamic) {
			ImGui.popFont();
			throw error;
		}
		ImGui.popFont();
	}

	public function withSize(size: Single, action: () -> Void): Void {
		with(null, size, action);
	}

	@:noCompletion public function contextDestroyed(context: ImContextPtr): Void {
		if (context != null) removeContextEntries(context);
	}

	function addBytesInternal(context: ImContextPtr, bytes: Bytes, size: Single, options: Null<ImGuiFontOptions>): ImFont {
		final config = createConfig(options);
		final font = ImGui.getFontAtlas().addFontFromMemoryTTF(bytes.getData(), bytes.length, size, config);
		if (font == null) throw "Dear ImGui could not load the font data";

		var entry = find(font, context);
		if (entry == null) {
			entry = new ImGuiFontEntry(context, font);
			entries.push(entry);
		}
		entry.sources.push(bytes);
		return font;
	}

	function createConfig(options: Null<ImGuiFontOptions>): Null<ImFontConfig> {
		if (options == null) return null;
		final config = new ImFontConfig();
		if (options.pixelSnap != null) config.setPixelSnapH(options.pixelSnap);
		if (options.oversampleH != null || options.oversampleV != null)
			config.setOversample(options.oversampleH ?? 0, options.oversampleV ?? 0);
		if (options.merge != null) config.setMergeMode(options.merge);
		if (options.fontNo != null) config.setFontNo(options.fontNo);
		return config;
	}

	function removeEntry(entry: ImGuiFontEntry): Void {
		final currentContext = ImGui.getCurrentContext();
		if (currentContext != entry.context) ImGui.setCurrentContext(entry.context);
		ImGui.getFontAtlas().removeFont(entry.font);
		entries.remove(entry);
		if (currentContext != entry.context) ImGui.setCurrentContext(currentContext);
	}

	function find(font: ImFont, context: ImContextPtr): Null<ImGuiFontEntry> {
		for (entry in entries)
			if (entry.context == context && entry.font == font) return entry;
		return null;
	}

	function findManagedDefault(context: ImContextPtr): Null<ImGuiFontEntry> {
		for (entry in entries)
			if (entry.context == context && entry.managedDefault) return entry;
		return null;
	}

	function removeContextEntries(context: ImContextPtr): Void {
		for (entry in entries.copy())
			if (entry.context == context) entries.remove(entry);
	}

	function defaultSize(): Single {
		final current = get_size();
		return current > 0 ? current : 13;
	}

	function get_size(): Single {
		ImGui.ensureContext();
		return ImGui.getStyle().FontSizeBase;
	}

	function set_size(value: Single): Single {
		ImGui.ensureContext();
		ImGui.getStyle().FontSizeBase = value;
		return value;
	}

	function get_scale(): Single {
		ImGui.ensureContext();
		return ImGui.getStyle().FontScaleMain;
	}

	function set_scale(value: Single): Single {
		ImGui.ensureContext();
		ImGui.getStyle().FontScaleMain = value;
		return value;
	}

	function get_dpiScale(): Single {
		ImGui.ensureContext();
		return ImGui.getStyle().FontScaleDpi;
	}

	function set_dpiScale(value: Single): Single {
		ImGui.ensureContext();
		ImGui.getStyle().FontScaleDpi = value;
		return value;
	}
}
