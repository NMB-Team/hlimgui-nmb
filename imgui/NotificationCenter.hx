package imgui;

import imgui.ImGui.ImGuiCol;
import imgui.ImGui.ImGuiStyleVar;
import imgui.ImGui.ImGuiWindowFlags;
import imgui.ImGui.ImVec2;
import imgui.ImGui.ImVec4;
import imgui.ImGuiUtils.ImTypeCache;

/**
	Visual category of a notification.
**/
enum abstract NotificationKind(Int) from Int to Int {
	var Neutral = 0;
	var Info;
	var Success;
	var Warning;
	var Error;
}

/**
	Screen corner used to stack notifications.
**/
enum abstract NotificationPlacement(Int) from Int to Int {
	var TopLeft = 0;
	var TopRight;
	var BottomLeft;
	var BottomRight;
}

/**
	A notification lifecycle or action callback.
**/
typedef NotificationCallback = Void -> Void;

/**
	Callbacks invoked by notification lifecycle transitions.
**/
typedef NotificationCallbacks = {
	@:optional var start:NotificationCallback;
	@:optional var finish:NotificationCallback;
}

/**
	Optional action displayed below a notification message.
**/
typedef NotificationAction = {
	var label:String;
	var callback:NotificationCallback;
	@:optional var dismiss:Bool;
}

/**
	Transforms normalized animation progress. A null callback keeps linear progress.
**/
typedef NotificationEase = Float -> Float;

/**
	Options applied when a notification is created or replaced.
**/
typedef NotificationOptions = {
	@:optional var title:String;
	@:optional var duration:Float;
	@:optional var dismissible:Bool;
	@:optional var callbacks:NotificationCallbacks;
	@:optional var action:NotificationAction;
	@:optional var key:String;
}

/**
	Configurable notification layout, timing, and colors.
**/
class NotificationStyle {
	public var placement = NotificationPlacement.BottomRight;
	public var maxVisible = 4;
	public var maxQueued = 128;
	public var width:Single = 360;
	public var margin:Single = 16;
	public var gap:Single = 10;
	public var rounding:Single = 7;
	public var borderSize:Single = 1;
	public var slideDistance:Single = 24;
	public var progressHeight:Single = 3;
	public var fadeIn = 0.18;
	public var fadeOut = 0.22;
	public var reflowDuration = 0.18;
	public var enterEase:Null<NotificationEase>;
	public var exitEase:Null<NotificationEase>;
	public var reflowEase:Null<NotificationEase>;
	public var pauseOnHover = true;
	public var padding = new ImVec2(14, 11);
	public var neutral = new ImVec4(0.72, 0.75, 0.82, 1);
	public var info = new ImVec4(0.25, 0.62, 1, 1);
	public var success = new ImVec4(0.25, 0.82, 0.49, 1);
	public var warning = new ImVec4(1, 0.7, 0.2, 1);
	public var error = new ImVec4(1, 0.32, 0.32, 1);

	public function new() {}
}

private enum abstract NotificationPhase(Int) {
	var Queued = 0;
	var Visible;
	var Dismissing;
}

/**
	A live notification returned by `NotificationCenter`.

	Its content and presentation fields can be updated while it is queued or visible.
**/
@:allow(imgui.NotificationCenter)
class Notification {
	public final id:Int;
	public final key:Null<String>;
	public var title:Null<String>;
	public var message:String;
	public var kind:NotificationKind;
	public var duration:Float;
	public var dismissible:Bool;
	public var callbacks:Null<NotificationCallbacks>;
	public var action:Null<NotificationAction>;
	public var isDismissed(get, never):Bool;

	final owner:NotificationCenter;
	var startedAt:Null<Float>;
	var pausedLifetime = 0.;
	var dismissedAt:Null<Float>;
	var phase = NotificationPhase.Queued;
	var stackInitialized = false;
	var stackFrom = 0.;
	var stackTarget = 0.;
	var stackChangedAt = 0.;

	private function new(owner:NotificationCenter, id:Int, key:Null<String>) {
		this.owner = owner;
		this.id = id;
		this.key = key;
	}

	/**
		Starts the dismissal animation.
	**/
	public inline function dismiss():Void {
		owner.dismiss(this);
	}

	/**
		Restarts this notification's lifetime, including when it is being dismissed.
	**/
	public inline function restart():Void {
		owner.restart(this);
	}

	@:noCompletion
	inline function get_isDismissed():Bool {
		return phase == NotificationPhase.Dismissing;
	}
}

/**
	Owns notification state and renders a non-blocking stack into the main viewport.

	`ImGui.notifications` is rendered automatically by `ImGui.render()`. Additional centers can
	be rendered explicitly when an application needs independent queues or styles.
**/
class NotificationCenter {
	public final style:NotificationStyle;
	public var length(get, never):Int;

	final notifications:Array<Notification> = [];
	var nextId = 1;
	var renderedFrame = -1;

	public function new(?style:NotificationStyle) {
		this.style = style == null ? new NotificationStyle() : style;
	}

	/**
		Shows an informational notification.
	**/
	public inline function show(message:String, ?options:NotificationOptions):Notification {
		return push(message, NotificationKind.Info, options);
	}

	public inline function success(message:String, ?options:NotificationOptions):Notification {
		return push(message, NotificationKind.Success, options);
	}

	public inline function warning(message:String, ?options:NotificationOptions):Notification {
		return push(message, NotificationKind.Warning, options);
	}

	public inline function error(message:String, ?options:NotificationOptions):Notification {
		return push(message, NotificationKind.Error, options);
	}

	/**
		Queues a notification of any kind. A matching non-null key replaces and restarts the existing notification.
	**/
	public function push(message:String, kind:NotificationKind = NotificationKind.Neutral, ?options:NotificationOptions):Notification {
		final key = options == null ? null : options.key;
		var notification = key == null ? null : find(key);

		if (notification == null) {
			notification = new Notification(this, nextId++, key);
			enqueue(notification);
		}

		notification.message = message;
		notification.title = options == null ? null : options.title;
		notification.kind = kind;
		notification.duration = options == null || options.duration == null ? 4.0 : options.duration;
		notification.dismissible = options == null || options.dismissible == null ? true : options.dismissible;
		notification.callbacks = options == null ? null : options.callbacks;
		notification.action = options == null ? null : options.action;
		restart(notification);
		return notification;
	}

	/**
		Returns a queued notification by its deduplication key.
	**/
	public function find(key:String):Null<Notification> {
		for (notification in notifications) {
			if (notification.key == key)
				return notification;
		}
		return null;
	}

	/**
		Starts the dismissal animation for a notification owned by this center.
	**/
	public function dismiss(notification:Notification):Void {
		if (notification.owner != this)
			return;
		notification.phase = NotificationPhase.Dismissing;
		if (notification.startedAt == null) {
			notifications.remove(notification);
			return;
		}
	}

	/**
		Restarts a notification owned by this center.
	**/
	public function restart(notification:Notification):Void {
		if (notification.owner != this)
			return;
		if (!notifications.contains(notification)) {
			enqueue(notification);
			notification.stackInitialized = false;
		}
		notification.startedAt = null;
		notification.pausedLifetime = 0;
		notification.dismissedAt = null;
		notification.phase = NotificationPhase.Queued;
	}

	/**
		Dismisses every notification. Pending notifications are removed without being shown.
	**/
	public function dismissAll():Void {
		var index = notifications.length;
		while (index-- > 0)
			dismiss(notifications[index]);
	}

	/**
		Removes every notification immediately.
	**/
	public function clear():Void {
		for (notification in notifications)
			notification.phase = NotificationPhase.Dismissing;
		notifications.resize(0);
	}

	private function enqueue(notification:Notification):Void {
		if (style.maxQueued > 0) {
			while (notifications.length >= style.maxQueued) {
				final removed = notifications.shift();
				removed.phase = NotificationPhase.Dismissing;
			}
		}
		notifications.push(notification);
	}

	/**
		Renders the visible notifications. Repeated calls in one frame are ignored.
	**/
	public function render():Void {
		if (notifications.length == 0 || style.maxVisible <= 0 || ImGui.getCurrentContext() == null)
			return;

		final frame = ImGui.getFrameCount();
		if (renderedFrame == frame)
			return;
		renderedFrame = frame;

		final now = ImGui.getTime();
		var callbacks:Null<Array<NotificationCallback>> = removeFinished(now);
		if (notifications.length == 0) {
			runCallbacks(callbacks);
			return;
		}

		final viewport = ImGui.getMainViewport();
		final left = style.placement == NotificationPlacement.TopLeft || style.placement == NotificationPlacement.BottomLeft;
		final top = style.placement == NotificationPlacement.TopLeft || style.placement == NotificationPlacement.TopRight;
		final anchorX:Single = left ? viewport.WorkPos.x + style.margin : viewport.WorkPos.x + viewport.WorkSize.x - style.margin;
		final anchorY:Single = top ? viewport.WorkPos.y + style.margin : viewport.WorkPos.y + viewport.WorkSize.y - style.margin;
		final pivotX:Single = left ? 0 : 1;
		final pivotY:Single = top ? 0 : 1;
		var targetStackOffset:Single = 0;
		var shown = 0;

		for (notification in notifications) {
			if (shown == style.maxVisible)
				break;
			if (notification.startedAt == null) {
				notification.startedAt = now;
				notification.phase = NotificationPhase.Visible;
				final startCallback = notification.callbacks == null ? null : notification.callbacks.start;
				if (startCallback != null) {
					if (callbacks == null)
						callbacks = [];
					callbacks.push(startCallback);
				}
			}
			if (notification.phase == NotificationPhase.Dismissing && notification.dismissedAt == null)
				notification.dismissedAt = now;

			final visibility = getVisibility(notification, now);
			final opacity:Single = cast Math.max(0, Math.min(1, visibility));
			final slide:Single = cast(style.slideDistance * (1 - visibility));
			final stackOffset = getStackOffset(notification, targetStackOffset, now);
			final x:Single = anchorX + (left ? -slide : slide);
			final y:Single = anchorY + (top ? stackOffset : -stackOffset);
			final accent = colorFor(notification.kind);
			final minimum = ImTypeCache.vec2(style.width, 0);
			final maximum = ImTypeCache.vec2(style.width, ImGui.FLT_MAX);

			ImGui.setNextWindowViewport(viewport.ID);
			ImGui.setNextWindowPos(ImTypeCache.vec2(x, y), 0, ImTypeCache.vec2(pivotX, pivotY));
			ImGui.setNextWindowSizeConstraints(minimum, maximum);
			ImGui.pushStyleVar(ImGuiStyleVar.Alpha, opacity);
			ImGui.pushStyleVar(ImGuiStyleVar.WindowPadding, style.padding);
			ImGui.pushStyleVar(ImGuiStyleVar.WindowRounding, style.rounding);
			ImGui.pushStyleVar(ImGuiStyleVar.WindowBorderSize, style.borderSize);
			ImGui.pushStyleColor(ImGuiCol.Border, accent);
			ImGui.pushStyleColor(ImGuiCol.Button, ImTypeCache.vec4(accent.x, accent.y, accent.z, 0.45));
			ImGui.pushStyleColor(ImGuiCol.ButtonHovered, ImTypeCache.vec4(accent.x, accent.y, accent.z, 0.7));
			ImGui.pushStyleColor(ImGuiCol.ButtonActive, accent);

			var closeClicked = false;
			var actionClicked = false;
			final flags = ImGuiWindowFlags.AlwaysAutoResize | ImGuiWindowFlags.NoDecoration | ImGuiWindowFlags.NoMove | ImGuiWindowFlags.NoSavedSettings | ImGuiWindowFlags.NoFocusOnAppearing | ImGuiWindowFlags.NoNav | ImGuiWindowFlags.NoDocking;
			if (ImGui.begin('##hlimgui-notification-${notification.id}', null, flags)) {
				final title = notification.title == null ? defaultTitle(notification.kind) : notification.title;
				if (title.length > 0) {
					ImGui.textColored(accent, title);
					if (notification.dismissible)
						ImGui.sameLine();
				}

				if (notification.dismissible) {
					final closeWidth = ImGui.getFrameHeight();
					final closeHeight = ImGui.getTextLineHeight();
					ImGui.setCursorPosX(ImGui.getWindowContentRegionMax().x - closeWidth);
					closeClicked = ImGui.button("##dismiss", ImTypeCache.vec2(closeWidth, closeHeight));
					final closeMin = ImGui.getItemRectMin();
					final closeMax = ImGui.getItemRectMax();
					final centerX:Single = (closeMin.x + closeMax.x) * 0.5;
					final centerY:Single = (closeMin.y + closeMax.y) * 0.5;
					final radius:Single = closeHeight * 0.24;
					final color = ImGui.getColorU32(ImGui.getStyleColorVec4(ImGuiCol.Text));
					final drawList = ImGui.getWindowDrawList();
					drawList.addLine(ImTypeCache.vec2(centerX - radius, centerY - radius), ImTypeCache.vec2(centerX + radius, centerY + radius), color, 1.25);
					drawList.addLine(ImTypeCache.vec2(centerX - radius, centerY + radius), ImTypeCache.vec2(centerX + radius, centerY - radius), color, 1.25);
				}

				ImGui.textWrapped(notification.message);
				if (notification.action != null)
					actionClicked = ImGui.button(notification.action.label + "##action");

				if (style.pauseOnHover && notification.phase != NotificationPhase.Dismissing && ImGui.isWindowHovered())
					notification.pausedLifetime += ImGui.getIO().DeltaTime;

				if (style.progressHeight > 0 && notification.duration > 0) {
					final position = ImGui.getWindowPos();
					final size = ImGui.getWindowSize();
					final remaining = notification.phase == NotificationPhase.Dismissing ? 0 : Math.max(0, 1 - getLifetime(notification, now) / notification.duration);
					final barY:Single = position.y + size.y - style.progressHeight;
					ImGui.getWindowDrawList()
						.addRectFilled(ImTypeCache.vec2(position.x, barY), ImTypeCache.vec2(cast(position.x + size.x * remaining), position.y + size.y), ImGui.getColorU32(accent));
				}
				targetStackOffset += ImGui.getWindowHeight() + style.gap;
			}
			ImGui.end();
			ImGui.popStyleColor(4);
			ImGui.popStyleVar(4);

			if (notification.phase != NotificationPhase.Dismissing
				&& notification.duration > 0
				&& getLifetime(notification, now) >= notification.duration) {
				notification.phase = NotificationPhase.Dismissing;
				notification.dismissedAt = now;
			}

			if (closeClicked)
				dismiss(notification);

			if (actionClicked) {
				final action = notification.action;
				if (action.dismiss == null || action.dismiss)
					dismiss(notification);
				if (callbacks == null)
					callbacks = [];
				callbacks.push(action.callback);
			}
			shown++;
		}

		callbacks = removeFinished(now, callbacks);
		runCallbacks(callbacks);
	}

	@:noCompletion
	private function get_length():Int {
		return notifications.length;
	}

	private function removeFinished(now:Float, ?callbacks:Array<NotificationCallback>):Null<Array<NotificationCallback>> {
		var index = notifications.length;
		while (index-- > 0) {
			final notification = notifications[index];
			final dismissedAt = notification.dismissedAt;
			if (dismissedAt != null && now - dismissedAt >= style.fadeOut) {
				notifications.splice(index, 1);
				final finishCallback = notification.callbacks == null ? null : notification.callbacks.finish;
				if (finishCallback != null) {
					if (callbacks == null)
						callbacks = [];
					callbacks.push(finishCallback);
				}
			}
		}
		return callbacks;
	}

	private function runCallbacks(callbacks:Null<Array<NotificationCallback>>):Void {
		if (callbacks == null)
			return;
		for (callback in callbacks)
			callback();
	}

	private function getVisibility(notification:Notification, now:Float):Float {
		if (notification.dismissedAt != null) {
			final progress = style.fadeOut <= 0 ? 1 : Math.min(1, (now - notification.dismissedAt) / style.fadeOut);
			return 1 - applyEase(style.exitEase, progress);
		}
		final progress = style.fadeIn <= 0 ? 1 : Math.min(1, (now - notification.startedAt) / style.fadeIn);
		return applyEase(style.enterEase, progress);
	}

	private inline function applyEase(ease:Null<NotificationEase>, progress:Float):Float {
		return ease == null ? progress : ease(progress);
	}

	private function getLifetime(notification:Notification, now:Float):Float {
		return Math.max(0, now - notification.startedAt - notification.pausedLifetime);
	}

	private function getStackOffset(notification:Notification, target:Single, now:Float):Single {
		if (!notification.stackInitialized) {
			notification.stackInitialized = true;
			notification.stackFrom = target;
			notification.stackTarget = target;
			notification.stackChangedAt = now;
		}

		var current = interpolateStackOffset(notification, now);
		if (notification.stackTarget != target) {
			notification.stackFrom = current;
			notification.stackTarget = target;
			notification.stackChangedAt = now;
			current = notification.stackFrom;
		}
		return cast current;
	}

	private function interpolateStackOffset(notification:Notification, now:Float):Float {
		if (style.reflowDuration <= 0)
			return notification.stackTarget;
		final progress = Math.min(1, (now - notification.stackChangedAt) / style.reflowDuration);
		return notification.stackFrom + (notification.stackTarget - notification.stackFrom) * applyEase(style.reflowEase, progress);
	}

	private function colorFor(kind:NotificationKind):ImVec4 {
		return switch kind {
			case NotificationKind.Info: style.info;
			case NotificationKind.Success: style.success;
			case NotificationKind.Warning: style.warning;
			case NotificationKind.Error: style.error;
			default: style.neutral;
		}
	}

	private function defaultTitle(kind:NotificationKind):String {
		return switch kind {
			case NotificationKind.Info: "Info";
			case NotificationKind.Success: "Success";
			case NotificationKind.Warning: "Warning";
			case NotificationKind.Error: "Error";
			default: "Notification";
		}
	}
}
