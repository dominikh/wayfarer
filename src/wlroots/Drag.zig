const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_drag
pub const Drag = extern struct {
    /// enum wlr_drag_grab_type
    pub const Type = extern enum(c_int) {
        keyboard,
        keyboard_pointer,
        keyboard_touch,
    };

    pub const Events = struct {
        /// struct wlr_drag_motion_event
        pub const Motion = extern struct {
            drag: *Drag,
            time: u32,
            sx: f64,
            sy: f64,
        };

        /// struct wlr_drag_drop_event
        pub const Drop = extern struct {
            drag: *Drag,
            time: u32,
        };
    };

    /// struct wlr_drag_icon
    pub const Icon = extern struct {
        drag: [*c]Drag,
        surface: [*c]wlroots.Surface,
        mapped: bool,
        events: extern struct {
            map: wayland.Signal(?*c_void),
            unmap: wayland.Signal(?*c_void),
            destroy: wayland.Signal(?*c_void),
        },
        surface_destroy: wayland.Listener(?*c_void),
        data: ?*c_void,
    };

    grab_type: Type,
    keyboard_grab: wlroots.Seat.KeyboardGrab,
    pointer_grab: wlroots.Seat.PointerGrab,
    touch_grab: wlroots.Seat.TouchGrab,
    seat: [*c]wlroots.Seat,
    seat_client: [*c]wlroots.Seat.Client,
    focus_client: [*c]wlroots.Seat.Client,
    icon: [*c]Icon,
    focus: [*c]wlroots.Surface,
    source: [*c]wlroots.DataSource,
    started: bool,
    dropped: bool,
    cancelling: bool,
    grab_touch_id: i32,
    touch_id: i32,
    events: extern struct {
        focus: wayland.Signal(?*c_void),
        motion: wayland.Signal(*Events.Motion),
        drop: wayland.Signal(*Events.Drop),
        destroy: wayland.Signal(?*c_void),
    },
    point_destroy: wayland.Listener(?*c_void),
    source_destroy: wayland.Listener(?*c_void),
    seat_client_destroy: wayland.Listener(?*c_void),
    icon_destroy: wayland.Listener(?*c_void),
    data: ?*c_void,
};
