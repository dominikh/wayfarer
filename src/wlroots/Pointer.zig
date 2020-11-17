const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_pointer
pub const Pointer = extern struct {
    /// struct wlr_pointer_impl
    pub const Impl = opaque {};

    /// struct wlr_pointer_grab_interface
    pub const GrabInterface = extern struct {
        enter: ?fn ([*c]wlroots.Seat.PointerGrab, [*c]wlroots.Surface, f64, f64) callconv(.C) void,
        clear_focus: ?fn ([*c]wlroots.Seat.PointerGrab) callconv(.C) void,
        motion: ?fn ([*c]wlroots.Seat.PointerGrab, u32, f64, f64) callconv(.C) void,
        button: ?fn ([*c]wlroots.Seat.PointerGrab, u32, u32, wlroots.ButtonState) callconv(.C) u32,
        axis: ?fn ([*c]wlroots.Seat.PointerGrab, u32, AxisOrientation, f64, i32, AxisSource) callconv(.C) void,
        frame: ?fn ([*c]wlroots.Seat.PointerGrab) callconv(.C) void,
        cancel: ?fn ([*c]wlroots.Seat.PointerGrab) callconv(.C) void,
    };

    /// enum wlr_axis_source
    pub const AxisSource = extern enum(c_int) {
        wheel,
        finger,
        continuous,
        wheel_tilt,
    };

    /// enum wlr_axis_orientation
    pub const AxisOrientation = extern enum(c_int) {
        vertical,
        horizontal,
    };

    pub const Events = struct {
        /// struct wlr_event_pointer_motion
        pub const Motion = extern struct {
            device: [*c]wlroots.InputDevice,
            time_msec: u32,
            delta_x: f64,
            delta_y: f64,
            unaccel_dx: f64,
            unaccel_dy: f64,
        };

        /// struct wlr_event_pointer_motion_absolute
        pub const MotionAbsolute = extern struct {
            device: [*c]wlroots.InputDevice,
            time_msec: u32,
            x: f64,
            y: f64,
        };

        /// struct wlr_event_pointer_button
        pub const Button = extern struct {
            device: [*c]wlroots.InputDevice,
            time_msec: u32,
            button: u32,
            state: wlroots.ButtonState,
        };

        /// struct wlr_event_pointer_axis
        pub const Axis = extern struct {
            device: [*c]wlroots.InputDevice,
            time_msec: u32,
            source: AxisSource,
            orientation: AxisOrientation,
            delta: f64,
            delta_discrete: i32,
        };

        /// struct wlr_event_pointer_swipe_begin
        pub const SwipeBegin = extern struct {
            device: [*c]wlroots.InputDevice,
            time_msec: u32,
            fingers: u32,
        };

        /// struct wlr_event_pointer_swipe_update
        pub const SwipeUpdate = extern struct {
            device: [*c]wlroots.InputDevice,
            time_msec: u32,
            fingers: u32,
            dx: f64,
            dy: f64,
        };

        /// struct wlr_event_pointer_swipe_end
        pub const SwipeEnd = extern struct {
            device: [*c]wlroots.InputDevice,
            time_msec: u32,
            cancelled: bool,
        };

        /// struct wlr_event_pointer_pinch_begin
        pub const PinchBegin = extern struct {
            device: [*c]wlroots.InputDevice,
            time_msec: u32,
            fingers: u32,
        };

        /// struct wlr_event_pointer_pinch_update
        pub const PinchUpdate = extern struct {
            device: [*c]wlroots.InputDevice,
            time_msec: u32,
            fingers: u32,
            dx: f64,
            dy: f64,
            scale: f64,
            rotation: f64,
        };

        /// struct wlr_event_pointer_pinch_end
        pub const PinchEnd = extern struct {
            device: [*c]wlroots.InputDevice,
            time_msec: u32,
            cancelled: bool,
        };
    };

    impl: ?*const Impl,
    events: extern struct {
        motion: wayland.Signal(*Events.Motion),
        motion_absolute: wayland.Signal(*Events.MotionAbsolute),
        button: wayland.Signal(*Events.Button),
        axis: wayland.Signal(*Events.Axis),
        frame: wayland.Signal(*Pointer),
        swipe_begin: wayland.Signal(*Events.SwipeBegin),
        swipe_update: wayland.Signal(*Events.SwipeUpdate),
        swipe_end: wayland.Signal(*Events.SwipeEnd),
        pinch_begin: wayland.Signal(*Events.PinchBegin),
        pinch_update: wayland.Signal(*Events.PinchUpdate),
        pinch_end: wayland.Signal(*Events.PinchEnd),
    },
    data: ?*c_void,
};
