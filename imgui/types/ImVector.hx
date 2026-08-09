package imgui.types;

@:keep
@:struct class ImVector {
	/**
		Number of initialized elements.
	**/
	public var size:Int;

	/**
		Gets or sets capacity.
	**/
	public var capacity:Int;

	/**
		Gets or sets data.
	**/
	public var data:hl.Bytes;
}
