#pragma once

#include <algorithm>
#include <cmath>

struct FramebufferClipRect {
	int left;
	int top;
	int width;
	int height;
	bool visible;
};

inline FramebufferClipRect makeFramebufferClipRect(
	float clip_left,
	float clip_top,
	float clip_right,
	float clip_bottom,
	float display_pos_x,
	float display_pos_y,
	float framebuffer_scale_x,
	float framebuffer_scale_y,
	int framebuffer_width,
	int framebuffer_height
) {
	if (framebuffer_width <= 0 || framebuffer_height <= 0)
		return {0, 0, 0, 0, false};

	// logical coordinates -> viewport-local coordinates -> framebuffer pixels
	float left = (clip_left - display_pos_x) * framebuffer_scale_x;
	float top = (clip_top - display_pos_y) * framebuffer_scale_y;
	float right = (clip_right - display_pos_x) * framebuffer_scale_x;
	float bottom = (clip_bottom - display_pos_y) * framebuffer_scale_y;

	left = std::clamp(left, 0.0f, float(framebuffer_width));
	top = std::clamp(top, 0.0f, float(framebuffer_height));
	right = std::clamp(right, 0.0f, float(framebuffer_width));
	bottom = std::clamp(bottom, 0.0f, float(framebuffer_height));

	if (right <= left || bottom <= top)
		return {0, 0, 0, 0, false};

	const int pixel_left = int(std::floor(left));
	const int pixel_top = int(std::floor(top));
	const int pixel_right = int(std::ceil(right));
	const int pixel_bottom = int(std::ceil(bottom));
	return {pixel_left, pixel_top, pixel_right - pixel_left, pixel_bottom - pixel_top, true};
}
