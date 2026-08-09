package imgui.types;

import imgui.types.Renderer;
import imgui.ImGuiUtils;
import imgui.ImGui;
import imgui.types.Pointers;

/**
	Low-level drawing API for submitting shapes, text, and images.
**/
@:hlNative("hlimgui", "drawlist_")
abstract ImDrawList(ImDrawListPtr) from ImDrawListPtr to ImDrawListPtr {
	/**
		Creates a new `ImDrawList` instance.
	**/
	public inline function new(ptr:ImDrawListPtr) {
		this = ptr;
	}

	// Note: Because how HL interprets optional values (i.e. `_REF(_T)`)
	// and default value given to them is silently ignored, instead providing a nullptr,
	// all calls that have default values that are not nulls are inline wrappers.

	/**
		Render-level scissoring. This is passed down to your render function but not used for CPU-side coarse clipping. Prefer using higher-level ImGui.PushClipRect() to affect logic (hit-testing and widget culling)
	**/
	public function pushClipRect(clipRectMin:ImVec2, clipRectMax:ImVec2, intersectWithCurrentClipRect:Bool = false) {}

	/**
		Pushes clip rectangle full screen onto its stack.
	**/
	public function pushClipRectFullScreen() {}

	/**
		Pops clip rectangle from its stack.
	**/
	public function popClipRect() {}

	/**
		Pushes texture id onto its stack.
	**/
	public function pushTextureId(textureId:ImTextureRef) {}

	/**
		Pops texture id from its stack.
	**/
	public function popTextureId() {}

	/**
		Returns clip rectangle min.
	**/
	public function getClipRectMin():ImVec2 {
		return null;
	}

	/**
		Returns clip rectangle max.
	**/
	public function getClipRectMax():ImVec2 {
		return null;
	}

	/**
		Adds line.
	**/
	public function addLine(p1:ImVec2, p2:ImVec2, col:ImU32, thickness:Single = 1.0) {}

	/**
		A: upper-left, b: lower-right (== upper-left + size)
	**/
	public function addRect(pMin:ImVec2, pMax:ImVec2, col:ImU32, rounding:Single = 0.0, roundingCorners:ImDrawFlags = ImDrawFlags.None, thickness:Single = 1.0) {}

	/**
		A: upper-left, b: lower-right (== upper-left + size)
	**/
	public function addRectFilled(pMin:ImVec2, pMax:ImVec2, col:ImU32, rounding:Single = 0.0, roundingCorners:ImDrawFlags = ImDrawFlags.None) {}

	/**
		Adds rectangle filled multi color.
	**/
	public function addRectFilledMultiColor(pMin:ImVec2, pMax:ImVec2, col_upr_left:ImU32, col_upr_right:ImU32, col_bot_right:ImU32, col_bot_left:ImU32) {}

	/**
		Adds quad.
	**/
	public function addQuad(p1:ImVec2, p2:ImVec2, p3:ImVec2, p4:ImVec2, col:ImU32, thickness:Single = 1.0) {}

	/**
		Adds quad filled.
	**/
	public function addQuadFilled(p1:ImVec2, p2:ImVec2, p3:ImVec2, p4:ImVec2, col:ImU32) {}

	/**
		Adds triangle.
	**/
	public function addTriangle(p1:ImVec2, p2:ImVec2, p3:ImVec2, col:ImU32, thickness:Single = 1.0) {}

	/**
		Adds triangle filled.
	**/
	public function addTriangleFilled(p1:ImVec2, p2:ImVec2, p3:ImVec2, col:ImU32) {}

	/**
		Adds circle.
	**/
	public function addCircle(center:ImVec2, radius:Single, col:ImU32, num_segments:Int = 0, thickness:Single = 1.0) {}

	/**
		Adds circle filled.
	**/
	public function addCircleFilled(center:ImVec2, radius:Single, col:ImU32, num_segments:Int = 0) {}

	/**
		Adds ngon.
	**/
	public function addNgon(center:ImVec2, radius:Single, col:ImU32, num_segments:Int, thickness:Single = 1.0) {}

	/**
		Adds ngon filled.
	**/
	public function addNgonFilled(center:ImVec2, radius:Single, col:ImU32, num_segments:Int) {}

	/**
		Adds poly line.
	**/
	public function addPolyLine(points:hl.NativeArray<ImVec2>, col:ImU32, closed:Bool, thickness:Single = 1.0) {}

	/**
		Adds convex poly filled.
	**/
	public function addConvexPolyFilled(points:hl.NativeArray<ImVec2>, col:ImU32) {}

	/**
		Cubic Bezier (4 control points)
	**/
	public function addBezierCubic(p1:ImVec2, p2:ImVec2, p3:ImVec2, p4:ImVec2, col:ImU32, thickness:Single, num_segments:Int = 0) {}

	/**
		Quadratic Bezier (3 control points)
	**/
	public function addBezierQuadratic(p1:ImVec2, p2:ImVec2, p3:ImVec2, col:ImU32, thickness:Single, num_segments:Int = 0) {}

	/**
		Add string (each character of the UTF-8 string are added)
	**/
	public function addText(pos:ImVec2, col:ImU32, text:String) {}

	/**
		Adds text2.
	**/
	public function addText2(font:ImFont, fontSize:Single, pos:ImVec2, col:ImU32, text:String, wrapWidth:Single = 0.0, ?cpuFineClipRect:ImVec4) {}

	/**
		Adds image.
	**/
	public function addImage(textureRef:ImTextureRef, pMin:ImVec2, pMax:ImVec2, ?uvMin:ImVec2, ?uvMax:ImVec2, col:Int = 0xffffffff) {}

	/**
		Adds image quad.
	**/
	public function addImageQuad(textureRef:ImTextureRef, p1:ImVec2, p2:ImVec2, p3:ImVec2, p4:ImVec2, ?uv1:ImVec2, ?uv2:ImVec2, ?uv3:ImVec2, ?uv4:ImVec2, col:Int = 0xffffffff) {}

	/**
		Adds image rounded.
	**/
	public function addImageRounded(textureRef:ImTextureRef, pMin:ImVec2, pMax:ImVec2, uvMin:ImVec2, uvMax:ImVec2, col:Int, rounding:Single, roundingCorners:ImDrawFlags = RoundCornersDefault_) {}

	@:deprecated("Use addBezuerrCubic")

	/**
		Adds bezier curve.
	**/
	public inline function addBezierCurve(p1:ImVec2, p2:ImVec2, p3:ImVec2, p4:ImVec2, col:ImU32, thickness:Single = 1.0, num_segments:Int = 0) {
		addBezierCubic(p1, p2, p3, p4, col, thickness, num_segments);
	}

	// Stateful path API, add points then finish with pathFillConvex() or pathStroke()

	/**
		Clears the current draw path.
	**/
	public function pathClear() {}

	/**
		Adds a point to the current draw path.
	**/
	public function pathLineTo(pos:ImVec2) {}

	/**
		Adds a point unless it duplicates the previous path point.
	**/
	public function pathLineToMergeDuplicate(pos:ImVec2) {}

	/**
		Fills the current path as a convex polygon.
	**/
	public function pathFillConvex(col:Int) {}

	/**
		OBSOLETED in 1.92.8: NEW FUNCTION SIGNATURE HAS 'thickness' AND 'flags' SWAPPED.
	**/
	public function pathStroke(col:Int, flags:ImDrawFlags = 0, thickness:Single = 1.0) {}

	/**
		Adds an arc to the current draw path.
	**/
	public function pathArcTo(center:ImVec2, radius:Single, a_min:Single, a_max:Single, num_segments:Int = 0) {}

	// Use precomputed angles for a 12 steps circle

	/**
		Use precomputed angles for a 12 steps circle.
	**/
	public function pathArcToFast(center:ImVec2, radius:Single, a_min_of_12:Int, a_max_of_12:Int) {}

	/**
		Cubic Bezier (4 control points)
	**/
	public function pathBezierCubicCurveTo(p2:ImVec2, p3:ImVec2, p4:ImVec2, num_segments:Int = 0) {}

	/**
		Quadratic Bezier (3 control points)
	**/
	public function pathBezierQuadraticCurveTo(p2:ImVec2, p3:ImVec2, num_segments:Int = 0) {}

	/**
		Adds a rectangle to the current draw path.
	**/
	public function pathRect(rect_min:ImVec2, rect_max:ImVec2, rounding:Single = 0.0, flags:ImDrawFlags = 0) {}

	// Advanced

	/**
		Adds callback.
	**/
	public function addCallback(callback:RenderCommandCallback, ?data:Dynamic) {}

	/**
		This is useful if you need to forcefully create a new draw call (to allow for dependent rendering / blending). Otherwise primitives are merged into the same draw-call as much as possible.
	**/
	public function addDrawCmd() {}

	// public function cloneOutput(): ImDrawList; // TODO
	#if heaps
	// Helper methods for Heaps: Use Tile instead of Texture to pass image segments easily.

	/**
		Adds tile.
	**/
	public inline function addTile(tile:h2d.Tile, pMin:ImVec2, ?pMax:ImVec2, col:Int = 0xffffffff, honorDxDy = false) @:privateAccess {
		if (pMax == null)
			pMax = ImTypeCache.vec2(pMin.x + tile.width, pMin.y + tile.height);
		if (honorDxDy) {
			pMin.x += tile.dx;
			pMin.y += tile.dy;
			pMax.x += tile.dx;
			pMax.y += tile.dy;
		}
		addImage(tile.getTexture(), pMin, pMax, ImTypeCache.vec2(tile.u, tile.v), ImTypeCache.vec2(tile.u2, tile.v2), col);
	}

	/**
		Adds tile quad.
	**/
	public inline function addTileQuad(tile:h2d.Tile, p1:ImVec2, p2:ImVec2, p3:ImVec2, p4:ImVec2, col:Int = 0xffffffff) @:privateAccess {
		addImageQuad(tile.getTexture(), p1, p2, p3, p4, ImTypeCache.vec2(tile.u, tile.v), ImTypeCache.vec2(tile.u2, tile.v), ImTypeCache.vec2(tile.u2, tile.v2), ImTypeCache.vec2(tile.u2, tile.v), col);
	}

	/**
		Adds tile rounded.
	**/
	public inline function addTileRounded(tile:h2d.Tile, pMin:ImVec2, ?pMax:ImVec2, col:Int, rounding:Single, roundingCorners:ImDrawFlags = -1, honorDxDy = false) @:privateAccess {
		if (pMax == null)
			pMax = ImTypeCache.vec2(pMin.x + tile.width, pMin.y + tile.height);
		if (honorDxDy) {
			pMin.x += tile.dx;
			pMin.y += tile.dy;
			pMax.x += tile.dx;
			pMax.y += tile.dy;
		}
		addImageRounded(tile.getTexture(), pMin, pMax, ImTypeCache.vec2(tile.u, tile.v), ImTypeCache.vec2(tile.u2, tile.v2), col, rounding, roundingCorners);
	}
	#end
}

@:struct private class ImDrawListSplitterStruct {
	@:noCompletion var finalizer:HLFinalizer; // [HL] GC finalizer
	var _current:Int; // Current channel number (0)
	var _count:Int; // Number of active channels (1+)
	var _channels:ImVector; // Draw channels (not resized down so _Count might be < Channels.Size)
}

/**
	Splits a draw list into channels that can be reordered and merged.
**/
@:hlNative("hlimgui", "drawlistsplitter_") @:forward
abstract ImDrawListSplitter(ImDrawListSplitterStruct) from ImDrawListSplitterStruct to ImDrawListSplitterStruct {
	static function init():ImDrawListSplitterStruct {
		return null;
	}

	/**
		Creates a new `ImDrawListSplitter` instance.
	**/
	public inline function new()
		this = init();

	/**
		Clear selection.
	**/
	public function clear() {}

	/**
		Clears free memory.
	**/
	public function clearFreeMemory() {}

	/**
		Splits the draw list into the requested number of channels.
	**/
	public function split(drawList:ImDrawList, count:Int) {}

	/**
		Merges split draw-list channels back together.
	**/
	public function merge(drawList:ImDrawList) {}

	/**
		Sets current channel.
	**/
	public function setCurrentChannel(drawList:ImDrawList, channelIdx:Int) {}
}
