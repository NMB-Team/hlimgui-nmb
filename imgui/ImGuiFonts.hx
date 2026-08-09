package imgui;

import haxe.io.Bytes;

import imgui.types.ImFont;
import imgui.types.ImFontAtlas.ImFontConfig;
import imgui.types.Pointers.ImContextPtr;

/**
	Options used when loading a font into the current atlas.
**/
typedef ImGuiFontOptions = {
	/**
		Aligns glyph vertices to whole-pixel positions.
	**/
	?pixelSnap:Bool,
	/**
		Horizontal glyph rasterization oversampling factor.
	**/
	?oversampleH:Int,
	/**
		Vertical glyph rasterization oversampling factor.
	**/
	?oversampleV:Int,
	/**
		Merges this font's glyphs into the previously loaded font.
	**/
	?merge:Bool,
	/**
		Font index to load from a TrueType collection.
	**/
	?fontNo:Int
}

private class ImGuiFontEntry {
	/**
		The context.
	**/
	public final context:ImContextPtr;

	/**
		Loaded font owned by this entry.
	**/
	public final font:ImFont;

	/**
		The sources.
	**/
	public final sources:Array<Bytes> = [];

	/**
		Gets or sets additional.
	**/
	public var additional = false;

	/**
		Gets or sets managed default.
	**/
	public var managedDefault = false;

	/**
		Creates a new `ImGuiFontEntry` instance.
	**/
	public function new(context:ImContextPtr, font:ImFont) {
		this.context = context;
		this.font = font;
	}
}

/**
	Manages default and additional fonts for each Dear ImGui context.
**/
class ImGuiFonts {
	/**
		Default font size in pixels. Changing it rebuilds managed fonts.
	**/
	public var size(get, set):Single;

	/**
		Deprecated alias of `size`.
	**/
	public var scale(get, set):Single;

	/**
		Gets or sets dpi scale.
	**/
	public var dpiScale(get, set):Single;

	final entries:Array<ImGuiFontEntry> = [];

	/**
		Creates a new `ImGuiFonts` instance.
	**/
	public function new() {}

	#if heaps
	/**
		Sets default.
	**/
	public function setDefault(resource:hxd.res.Resource, size:Single, ?options:ImGuiFontOptions):ImFont {
		return setDefaultBytes(resource.entry.getBytes(), size, options);
	}

	/**
		Sets default resource.
	**/
	public function setDefaultResource(path:String, size:Single, ?options:ImGuiFontOptions):ImFont {
		return setDefault(resourceLoader().load(path), size, options);
	}

	/**
		Adds an item to this collection.
	**/
	public function add(resource:hxd.res.Resource, ?size:Single, ?options:ImGuiFontOptions):ImFont {
		return addBytes(resource.entry.getBytes(), size, options);
	}

	/**
		Adds resource.
	**/
	public function addResource(path:String, ?size:Single, ?options:ImGuiFontOptions):ImFont {
		return add(resourceLoader().load(path), size, options);
	}

	function resourceLoader():hxd.res.Loader {
		final loader = hxd.res.Loader.currentInstance;
		if (loader == null)
			throw "Heaps resources are not initialized";
		return loader;
	}
	#end

	/**
		Sets default bytes.
	**/
	public function setDefaultBytes(bytes:Bytes, size:Single, ?options:ImGuiFontOptions):ImFont {
		final context = ImGui.ensureContext();
		final oldDefault = findManagedDefault(context);
		final font = addBytesInternal(context, bytes, size, options);
		final entry = find(font, context);
		entry.managedDefault = true;

		ImGui.getIO().FontDefault = font;
		this.size = size;

		if (oldDefault != null && oldDefault != entry) {
			oldDefault.managedDefault = false;
			if (!oldDefault.additional)
				removeEntry(oldDefault);
		}
		return font;
	}

	/**
		Adds bytes.
	**/
	public function addBytes(bytes:Bytes, ?size:Single, ?options:ImGuiFontOptions):ImFont {
		final context = ImGui.ensureContext();
		final font = addBytesInternal(context, bytes, size == null ? defaultSize() : size, options);
		find(font, context).additional = true;
		return font;
	}

	/**
		Removes an item from this collection and returns whether it was present.
	**/
	public function remove(font:ImFont):Bool {
		final context = ImGui.getCurrentContext();
		if (context == null)
			return false;
		final entry = find(font, context);
		if (entry == null)
			return false;
		removeEntry(entry);
		return true;
	}

	/**
		Clears additional.
	**/
	public function clearAdditional():Void {
		final context = ImGui.getCurrentContext();
		if (context == null)
			return;
		for (entry in entries.copy()) {
			if (entry.context != context || !entry.additional)
				continue;
			entry.additional = false;
			if (!entry.managedDefault)
				removeEntry(entry);
		}
	}

	/**
		Resets default.
	**/
	public function resetDefault():Void {
		final context = ImGui.getCurrentContext();
		if (context == null)
			return;
		final oldDefault = findManagedDefault(context);
		if (oldDefault == null) {
			ImGui.getIO().FontDefault = null;
			return;
		}

		final defaultFont = ImGui.getFontAtlas().addFontDefault();
		ImGui.getIO().FontDefault = defaultFont;
		oldDefault.managedDefault = false;
		if (!oldDefault.additional)
			removeEntry(oldDefault);
	}

	/**
		Clear selection.
	**/
	public function clear():Void {
		final context = ImGui.getCurrentContext();
		if (context == null)
			return;
		ImGui.getFontAtlas().clear();
		removeContextEntries(context);
	}

	/**
		Releases resources owned by this instance.
	**/
	public function dispose():Void {
		clear();
	}

	/**
		Runs `action` with the requested temporary state, restoring the previous state afterward.
	**/
	public function with(font:ImFont, size:Single, action:() -> Void):Void {
		ImGui.pushFont(font, size);
		try {
			action();
		} catch (error:Dynamic) {
			ImGui.popFont();
			throw error;
		}
		ImGui.popFont();
	}

	/**
		Runs `action` with the requested temporary font size.
	**/
	public function withSize(size:Single, action:() -> Void):Void {
		with(null, size, action);
	}

	@:noCompletion public function contextDestroyed(context:ImContextPtr):Void {
		if (context != null)
			removeContextEntries(context);
	}

	function addBytesInternal(context:ImContextPtr, bytes:Bytes, size:Single, options:Null<ImGuiFontOptions>):ImFont {
		final config = createConfig(options);
		final font = ImGui.getFontAtlas().addFontFromMemoryTTF(bytes.getData(), bytes.length, size, config);
		if (font == null)
			throw "Dear ImGui could not load the font data";

		var entry = find(font, context);
		if (entry == null) {
			entry = new ImGuiFontEntry(context, font);
			entries.push(entry);
		}
		entry.sources.push(bytes);
		return font;
	}

	function createConfig(options:Null<ImGuiFontOptions>):Null<ImFontConfig> {
		if (options == null)
			return null;
		final config = new ImFontConfig();
		if (options.pixelSnap != null)
			config.setPixelSnapH(options.pixelSnap);
		if (options.oversampleH != null || options.oversampleV != null)
			config.setOversample(options.oversampleH ?? 0, options.oversampleV ?? 0);
		if (options.merge != null)
			config.setMergeMode(options.merge);
		if (options.fontNo != null)
			config.setFontNo(options.fontNo);
		return config;
	}

	function removeEntry(entry:ImGuiFontEntry):Void {
		final currentContext = ImGui.getCurrentContext();
		if (currentContext != entry.context)
			ImGui.setCurrentContext(entry.context);
		ImGui.getFontAtlas().removeFont(entry.font);
		entries.remove(entry);
		if (currentContext != entry.context)
			ImGui.setCurrentContext(currentContext);
	}

	function find(font:ImFont, context:ImContextPtr):Null<ImGuiFontEntry> {
		for (entry in entries)
			if (entry.context == context && entry.font == font)
				return entry;
		return null;
	}

	function findManagedDefault(context:ImContextPtr):Null<ImGuiFontEntry> {
		for (entry in entries)
			if (entry.context == context && entry.managedDefault)
				return entry;
		return null;
	}

	function removeContextEntries(context:ImContextPtr):Void {
		for (entry in entries.copy())
			if (entry.context == context)
				entries.remove(entry);
	}

	function defaultSize():Single {
		final current = get_size();
		return current > 0 ? current : 13;
	}

	function get_size():Single {
		ImGui.ensureContext();
		return ImGui.getStyle().FontSizeBase;
	}

	function set_size(value:Single):Single {
		ImGui.ensureContext();
		ImGui.getStyle().FontSizeBase = value;
		return value;
	}

	function get_scale():Single {
		ImGui.ensureContext();
		return ImGui.getStyle().FontScaleMain;
	}

	function set_scale(value:Single):Single {
		ImGui.ensureContext();
		ImGui.getStyle().FontScaleMain = value;
		return value;
	}

	function get_dpiScale():Single {
		ImGui.ensureContext();
		return ImGui.getStyle().FontScaleDpi;
	}

	function set_dpiScale(value:Single):Single {
		ImGui.ensureContext();
		ImGui.getStyle().FontScaleDpi = value;
		return value;
	}
}
