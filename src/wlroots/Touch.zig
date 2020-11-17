const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_touch
pub const Touch = extern struct {
    /// struct wlr_touch_impl
    pub const Impl = extern struct {
        destroy: ?fn (*Touch) callconv(.C) void,
    };

    pub const Events = struct {
        /// struct wlr_event_touch_down
        pub const Down = extern struct {
            device: *wlroots.InputDevice,
            time_msec: u32,
            touch_id: i32,
            x: f64,
            y: f64,
        };

        /// struct wlr_event_touch_up
        pub const Up = extern struct {
            device: *wlroots.InputDevice,
            time_msec: u32,
            touch_id: i32,
        };

        /// struct wlr_event_touch_motion
        pub const Motion = extern struct {
            device: *wlroots.InputDevice,
            time_msec: u32,
            touch_id: i32,
            x: f64,
            y: f64,
        };

        /// struct wlr_event_touch_cancel
        pub const Cancel = extern struct {
            device: *wlroots.InputDevice,
            time_msec: u32,
            touch_id: i32,
        };
    };

    extern fn wlr_touch_init(touch: *Touch, impl: *Impl) void;
    extern fn wlr_touch_destroy(touch: *Touch) void;

    impl: ?*const Impl,
    events: extern struct {
        down: wayland.Signal(*Events.Down),
        up: wayland.Signal(*Events.Up),
        motion: wayland.Signal(*Events.Motion),
        cancel: wayland.Signal(*Events.Cancel),
    },
    data: ?*c_void,

    pub const init = wlr_touch_init;
    pub const deinit = wlr_touch_destroy;
};
