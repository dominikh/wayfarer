const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");
const Keyboard = wlroots.Keyboard;
const Surface = wlroots.Surface;
const std = @import("std");
const Pointer = wlroots.Pointer;

/// struct wlr_seat
pub const Seat = extern struct {
    pub extern fn wlr_seat_client_validate_event_serial(client: [*c]Client, serial: u32) bool;
    pub extern fn wlr_seat_create(display: ?*wayland.Display, name: [*:0]const u8) [*c]Seat;
    pub extern fn wlr_seat_destroy(wlr_seat: *Seat) void;
    pub extern fn wlr_seat_get_keyboard(seat: *Seat) [*c]Keyboard;
    pub extern fn wlr_seat_keyboard_clear_focus(wlr_seat: *Seat) void;
    pub extern fn wlr_seat_keyboard_end_grab(wlr_seat: *Seat) void;
    pub extern fn wlr_seat_keyboard_enter(seat: *Seat, surface: [*c]Surface, keycodes: [*c]u32, num_keycodes: usize, modifiers: [*c]Keyboard.Modifiers) void;
    pub extern fn wlr_seat_keyboard_has_grab(seat: *Seat) bool;
    pub extern fn wlr_seat_keyboard_notify_clear_focus(wlr_seat: *Seat) void;
    pub extern fn wlr_seat_keyboard_notify_enter(seat: *Seat, surface: [*c]Surface, keycodes: [*c]u32, num_keycodes: usize, modifiers: [*c]Keyboard.Modifiers) void;
    pub extern fn wlr_seat_keyboard_notify_key(seat: *Seat, time_msec: u32, key: u32, state: u32) void;
    pub extern fn wlr_seat_keyboard_notify_modifiers(seat: *Seat, modifiers: [*c]Keyboard.Modifiers) void;
    pub extern fn wlr_seat_keyboard_send_key(seat: *Seat, time_msec: u32, key: u32, state: u32) void;
    pub extern fn wlr_seat_keyboard_send_modifiers(seat: *Seat, modifiers: [*c]Keyboard.Modifiers) void;
    pub extern fn wlr_seat_keyboard_start_grab(wlr_seat: *Seat, grab: [*c]struct_wlr_seat_keyboard_grab) void;
    pub extern fn wlr_seat_pointer_clear_focus(wlr_seat: *Seat) void;
    pub extern fn wlr_seat_pointer_end_grab(wlr_seat: *Seat) void;
    pub extern fn wlr_seat_pointer_enter(wlr_seat: *Seat, surface: [*c]Surface, sx: f64, sy: f64) void;
    pub extern fn wlr_seat_pointer_has_grab(seat: *Seat) bool;
    pub extern fn wlr_seat_pointer_notify_axis(wlr_seat: *Seat, time_msec: u32, orientation: Pointer.enum_wlr_axis_orientation, value: f64, value_discrete: i32, source: Pointer.enum_wlr_axis_source) void;
    pub extern fn wlr_seat_pointer_notify_button(wlr_seat: *Seat, time_msec: u32, button: u32, state: wlroots.enum_wlr_button_state) u32;
    pub extern fn wlr_seat_pointer_notify_clear_focus(wlr_seat: *Seat) void;
    pub extern fn wlr_seat_pointer_notify_enter(wlr_seat: *Seat, surface: [*c]Surface, sx: f64, sy: f64) void;
    pub extern fn wlr_seat_pointer_notify_frame(wlr_seat: *Seat) void;
    pub extern fn wlr_seat_pointer_notify_motion(wlr_seat: *Seat, time_msec: u32, sx: f64, sy: f64) void;
    pub extern fn wlr_seat_pointer_send_axis(wlr_seat: *Seat, time_msec: u32, orientation: Pointer.enum_wlr_axis_orientation, value: f64, value_discrete: i32, source: Pointer.enum_wlr_axis_source) void;
    pub extern fn wlr_seat_pointer_send_button(wlr_seat: *Seat, time_msec: u32, button: u32, state: enum_wlr_button_state) u32;
    pub extern fn wlr_seat_pointer_send_frame(wlr_seat: *Seat) void;
    pub extern fn wlr_seat_pointer_send_motion(wlr_seat: *Seat, time_msec: u32, sx: f64, sy: f64) void;
    pub extern fn wlr_seat_pointer_start_grab(wlr_seat: *Seat, grab: [*c]struct_wlr_seat_pointer_grab) void;
    pub extern fn wlr_seat_pointer_surface_has_focus(wlr_seat: *Seat, surface: [*c]Surface) bool;
    pub extern fn wlr_seat_pointer_warp(wlr_seat: *Seat, sx: f64, sy: f64) void;
    pub extern fn wlr_seat_request_set_selection(seat: *Seat, client: [*c]Client, source: [*c]struct_wlr_data_source, serial: u32) void;
    pub extern fn wlr_seat_request_start_drag(seat: *Seat, drag: [*c]struct_wlr_drag, origin: [*c]Surface, serial: u32) void;
    pub extern fn wlr_seat_set_capabilities(wlr_seat: *Seat, capabilities: u32) void;
    pub extern fn wlr_seat_set_keyboard(seat: *Seat, dev: [*c]wlroots.InputDevice) void;
    pub extern fn wlr_seat_set_name(wlr_seat: *Seat, name: [*:0]const u8) void;
    pub extern fn wlr_seat_set_selection(seat: *Seat, source: [*c]struct_wlr_data_source, serial: u32) void;
    pub extern fn wlr_seat_start_drag(seat: *Seat, drag: [*c]struct_wlr_drag, serial: u32) void;
    pub extern fn wlr_seat_start_pointer_drag(seat: *Seat, drag: [*c]struct_wlr_drag, serial: u32) void;
    pub extern fn wlr_seat_start_touch_drag(seat: *Seat, drag: [*c]struct_wlr_drag, serial: u32, point: [*c]struct_wlr_touch_point) void;
    pub extern fn wlr_seat_touch_end_grab(wlr_seat: *Seat) void;
    pub extern fn wlr_seat_touch_get_point(seat: *Seat, touch_id: i32) [*c]struct_wlr_touch_point;
    pub extern fn wlr_seat_touch_has_grab(seat: *Seat) bool;
    pub extern fn wlr_seat_touch_notify_down(seat: *Seat, surface: [*c]Surface, time_msec: u32, touch_id: i32, sx: f64, sy: f64) u32;
    pub extern fn wlr_seat_touch_notify_motion(seat: *Seat, time_msec: u32, touch_id: i32, sx: f64, sy: f64) void;
    pub extern fn wlr_seat_touch_notify_up(seat: *Seat, time_msec: u32, touch_id: i32) void;
    pub extern fn wlr_seat_touch_num_points(seat: *Seat) c_int;
    pub extern fn wlr_seat_touch_point_clear_focus(seat: *Seat, time_msec: u32, touch_id: i32) void;
    pub extern fn wlr_seat_touch_point_focus(seat: *Seat, surface: [*c]Surface, time_msec: u32, touch_id: i32, sx: f64, sy: f64) void;
    pub extern fn wlr_seat_touch_send_down(seat: *Seat, surface: [*c]Surface, time_msec: u32, touch_id: i32, sx: f64, sy: f64) u32;
    pub extern fn wlr_seat_touch_send_motion(seat: *Seat, time_msec: u32, touch_id: i32, sx: f64, sy: f64) void;
    pub extern fn wlr_seat_touch_send_up(seat: *Seat, time_msec: u32, touch_id: i32) void;
    pub extern fn wlr_seat_touch_start_grab(wlr_seat: *Seat, grab: [*c]struct_wlr_seat_touch_grab) void;
    pub extern fn wlr_seat_validate_grab_serial(seat: *Seat, serial: u32) bool;
    pub extern fn wlr_seat_validate_pointer_grab_serial(seat: *Seat, origin: [*c]Surface, serial: u32) bool;
    pub extern fn wlr_seat_validate_touch_grab_serial(seat: *Seat, origin: [*c]Surface, serial: u32, point_ptr: [*c][*c]struct_wlr_touch_point) bool;

    /// struct wlr_seat_pointer_grab
    pub const struct_wlr_seat_pointer_grab = extern struct {
        interface: [*c]const wlroots.Pointer.struct_wlr_pointer_grab_interface,
        seat: [*c]Seat,
        data: ?*c_void,
    };

    // struct wlr_seat_touch_grab
    pub const struct_wlr_seat_touch_grab = extern struct {
        pub const struct_wlr_touch_grab_interface = extern struct {
            down: ?fn ([*c]struct_wlr_seat_touch_grab, u32, [*c]struct_wlr_touch_point) callconv(.C) u32,
            up: ?fn ([*c]struct_wlr_seat_touch_grab, u32, [*c]struct_wlr_touch_point) callconv(.C) void,
            motion: ?fn ([*c]struct_wlr_seat_touch_grab, u32, [*c]struct_wlr_touch_point) callconv(.C) void,
            enter: ?fn ([*c]struct_wlr_seat_touch_grab, u32, [*c]struct_wlr_touch_point) callconv(.C) void,
            cancel: ?fn ([*c]struct_wlr_seat_touch_grab) callconv(.C) void,
        };

        interface: [*c]const struct_wlr_touch_grab_interface,
        seat: [*c]Seat,
        data: ?*c_void,
    };

    /// struct wlr_seat_client
    pub const Client = extern struct {
        client: ?*wayland.Client,
        seat: [*c]Seat,
        link: wayland.ListElement(Client, "link"), // wlr_seat::clients
        resources: wayland.List(wayland.Resource, "link"),
        pointers: wayland.List(wayland.Resource, "link"),
        keyboards: wayland.List(wayland.Resource, "link"),
        touches: wayland.List(wayland.Resource, "link"),
        data_devices: wayland.List(wayland.Resource, "link"),
        events: extern struct {
            destroy: wayland.Signal(?*c_void),
        },
        serials: wlroots.struct_wlr_serial_ringset,
    };

    /// struct wlr_seat_pointer_request_set_cursor_event
    pub const struct_wlr_seat_pointer_request_set_cursor_event = extern struct {
        seat_client: [*c]Client,
        surface: [*c]wlroots.Surface,
        serial: u32,
        hotspot_x: i32,
        hotspot_y: i32,
    };

    /// struct wlr_seat_request_set_selection_event
    pub const struct_wlr_seat_request_set_selection_event = extern struct {
        source: [*c]wlroots.struct_wlr_data_source,
        serial: u32,
    };

    /// struct wlr_seat_request_set_primary_selection_event
    pub const struct_wlr_seat_request_set_primary_selection_event = extern struct {
        source: ?*wlroots.struct_wlr_primary_selection_source,
        serial: u32,
    };

    /// struct wlr_seat_request_start_drag_event
    pub const struct_wlr_seat_request_start_drag_event = extern struct {
        drag: [*c]wlroots.struct_wlr_drag,
        origin: [*c]wlroots.Surface,
        serial: u32,
    };

    /// struct wlr_seat_pointer_focus_change_event
    pub const struct_wlr_seat_pointer_focus_change_event = extern struct {
        seat: [*c]Seat,
        old_surface: [*c]wlroots.Surface,
        new_surface: [*c]wlroots.Surface,
        sx: f64,
        sy: f64,
    };

    /// struct wlr_seat_keyboard_focus_change_event
    pub const struct_wlr_seat_keyboard_focus_change_event = extern struct {
        seat: [*c]Seat,
        old_surface: [*c]wlroots.Surface,
        new_surface: [*c]wlroots.Surface,
    };

    /// struct wlr_seat_pointer_state
    pub const struct_wlr_seat_pointer_state = extern struct {
        seat: [*c]Seat,
        focused_client: [*c]Client,
        focused_surface: [*c]wlroots.Surface,
        sx: f64,
        sy: f64,
        grab: [*c]struct_wlr_seat_pointer_grab,
        default_grab: [*c]struct_wlr_seat_pointer_grab,
        buttons: [16]u32,
        button_count: usize,
        grab_button: u32,
        grab_serial: u32,
        grab_time: u32,
        surface_destroy: wayland.Listener(?*c_void),
        events: extern struct {
            focus_change: wayland.Signal(?*c_void),
        },
    };

    /// struct wlr_seat_keyboard_state
    pub const struct_wlr_seat_keyboard_state = extern struct {
        seat: [*c]Seat,
        keyboard: [*c]Keyboard,
        focused_client: [*c]Client,
        focused_surface: [*c]Surface,
        keyboard_destroy: wayland.Listener(?*c_void),
        keyboard_keymap: wayland.Listener(?*c_void),
        keyboard_repeat_info: wayland.Listener(?*c_void),
        surface_destroy: wayland.Listener(?*c_void),
        grab: [*c]wlroots.struct_wlr_seat_keyboard_grab,
        default_grab: [*c]wlroots.struct_wlr_seat_keyboard_grab,
        events: extern struct {
            focus_change: wayland.Signal(?*c_void),
        },
    };

    /// struct wlr_seat_touch_state
    pub const struct_wlr_seat_touch_state = extern struct {
        seat: [*c]Seat,
        touch_points: wayland.List(struct_wlr_touch_point, "link"),
        grab_serial: u32,
        grab_id: u32,
        grab: [*c]struct_wlr_seat_touch_grab,
        default_grab: [*c]struct_wlr_seat_touch_grab,
    };

    /// struct wlr_touch_point
    pub const struct_wlr_touch_point = extern struct {
        touch_id: i32,
        surface: [*c]wlroots.Surface,
        client: [*c]Client,
        focus_surface: [*c]wlroots.Surface,
        focus_client: [*c]Client,
        sx: f64,
        sy: f64,
        surface_destroy: wayland.Listener(?*c_void),
        focus_surface_destroy: wayland.Listener(?*c_void),
        client_destroy: wayland.Listener(?*c_void),
        events: extern struct {
            destroy: wayland.Signal(?*c_void),
        },
        link: wayland.ListElement(struct_wlr_touch_point, "link"),
    };

    global: ?*wayland.Global,
    display: ?*wayland.Display,
    clients: wayland.List(Client, "link"),
    name: [*c]u8,
    capabilities: u32,
    accumulated_capabilities: u32,
    last_event: std.os.timespec,
    selection_source: [*c]wlroots.struct_wlr_data_source,
    selection_serial: u32,
    selection_offers: wayland.List(wlroots.struct_wlr_data_offer, "link"),
    primary_selection_source: ?*wlroots.struct_wlr_primary_selection_source,
    primary_selection_serial: u32,
    drag: [*c]wlroots.struct_wlr_drag,
    drag_source: [*c]wlroots.struct_wlr_data_source,
    drag_serial: u32,
    drag_offers: wayland.List(wlroots.struct_wlr_data_offer, "link"),
    pointer_state: struct_wlr_seat_pointer_state,
    keyboard_state: struct_wlr_seat_keyboard_state,
    touch_state: struct_wlr_seat_touch_state,
    display_destroy: wayland.Listener(?*c_void),
    selection_source_destroy: wayland.Listener(?*c_void),
    primary_selection_source_destroy: wayland.Listener(?*c_void),
    drag_source_destroy: wayland.Listener(?*c_void),
    events: extern struct {
        pointer_grab_begin: wayland.Signal(?*c_void),
        pointer_grab_end: wayland.Signal(?*c_void),
        keyboard_grab_begin: wayland.Signal(?*c_void),
        keyboard_grab_end: wayland.Signal(?*c_void),
        touch_grab_begin: wayland.Signal(?*c_void),
        touch_grab_end: wayland.Signal(?*c_void),
        request_set_cursor: wayland.Signal(*struct_wlr_seat_pointer_request_set_cursor_event),
        request_set_selection: wayland.Signal(?*c_void),
        set_selection: wayland.Signal(?*c_void),
        request_set_primary_selection: wayland.Signal(?*c_void),
        set_primary_selection: wayland.Signal(?*c_void),
        request_start_drag: wayland.Signal(?*c_void),
        start_drag: wayland.Signal(?*c_void),
        destroy: wayland.Signal(?*c_void),
    },
    data: ?*c_void,
};
