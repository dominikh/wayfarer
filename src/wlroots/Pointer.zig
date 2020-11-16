const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_pointer
pub const Pointer = extern struct {
    /// struct wlr_pointer_impl
    pub const Impl = opaque {};

    /// struct wlr_pointer_grab_interface
    pub const struct_wlr_pointer_grab_interface = extern struct {
        enter: ?fn ([*c]wlroots.Seat.struct_wlr_seat_pointer_grab, [*c]wlroots.Surface, f64, f64) callconv(.C) void,
        clear_focus: ?fn ([*c]wlroots.Seat.struct_wlr_seat_pointer_grab) callconv(.C) void,
        motion: ?fn ([*c]wlroots.Seat.struct_wlr_seat_pointer_grab, u32, f64, f64) callconv(.C) void,
        button: ?fn ([*c]wlroots.Seat.struct_wlr_seat_pointer_grab, u32, u32, wlroots.enum_wlr_button_state) callconv(.C) u32,
        axis: ?fn ([*c]wlroots.Seat.struct_wlr_seat_pointer_grab, u32, enum_wlr_axis_orientation, f64, i32, enum_wlr_axis_source) callconv(.C) void,
        frame: ?fn ([*c]wlroots.Seat.struct_wlr_seat_pointer_grab) callconv(.C) void,
        cancel: ?fn ([*c]wlroots.Seat.struct_wlr_seat_pointer_grab) callconv(.C) void,
    };

    /// enum wlr_axis_source
    pub const enum_wlr_axis_source = extern enum(c_int) {
        WLR_AXIS_SOURCE_WHEEL,
        WLR_AXIS_SOURCE_FINGER,
        WLR_AXIS_SOURCE_CONTINUOUS,
        WLR_AXIS_SOURCE_WHEEL_TILT,
        _,
    };

    /// enum wlr_axis_orientation
    pub const enum_wlr_axis_orientation = extern enum(c_int) {
        WLR_AXIS_ORIENTATION_VERTICAL,
        WLR_AXIS_ORIENTATION_HORIZONTAL,
        _,
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
            state: wlroots.enum_wlr_button_state,
        };

        /// struct wlr_event_pointer_axis
        pub const Axis = extern struct {
            device: [*c]wlroots.InputDevice,
            time_msec: u32,
            source: enum_wlr_axis_source,
            orientation: enum_wlr_axis_orientation,
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
