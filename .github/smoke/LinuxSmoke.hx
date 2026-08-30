import hl.Abstract;

@:hlNative("hlimgui")
private class Native {
	public static function createContext():Abstract<"imcontext"> {
		return null;
	}

	public static function destroyContext(context:Abstract<"imcontext">):Void {}
}

class LinuxSmoke {
	static function main() {
		final context = Native.createContext();
		if (context == null)
			throw "Failed to create an ImGui context";
		Native.destroyContext(context);
		Sys.println("hlimgui loaded successfully");
	}
}
