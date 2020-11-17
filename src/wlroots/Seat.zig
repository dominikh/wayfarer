const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");
const std = @import("std");

/// struct wlr_seat
pub const Seat = extern struct {
    extern fn wlr_seat_client_validate_event_serial(client: *Client, serial: u32) bool;
    extern fn wlr_seat_create(display: *wayland.Display, name: [*:0]const u8) ?*Seat;
    extern fn wlr_seat_destroy(wlr_seat: *Seat) void;
    extern fn wlr_seat_get_keyboard(seat: *Seat) ?*wlroots.Keyboard;
    extern fn wlr_seat_keyboard_clear_focus(wlr_seat: *Seat) void;
    extern fn wlr_seat_keyboard_end_grab(wlr_seat: *Seat) void;
    extern fn wlr_seat_keyboard_enter(seat: *Seat, surface: *wlroots.Surface, keycodes: [*]u32, num_keycodes: usize, modifiers: *wlroots.Keyboard.Modifiers) void;
    extern fn wlr_seat_keyboard_has_grab(seat: *Seat) bool;
    extern fn wlr_seat_keyboard_notify_clear_focus(wlr_seat: *Seat) void;
    extern fn wlr_seat_keyboard_notify_enter(seat: *Seat, surface: *wlroots.Surface, keycodes: [*]u32, num_keycodes: usize, modifiers: *wlroots.Keyboard.Modifiers) void;
    extern fn wlr_seat_keyboard_notify_key(seat: *Seat, time_msec: u32, key: u32, state: u32) void;
    extern fn wlr_seat_keyboard_notify_modifiers(seat: *Seat, modifiers: *wlroots.Keyboard.Modifiers) void;
    extern fn wlr_seat_keyboard_send_key(seat: *Seat, time_msec: u32, key: u32, state: u32) void;
    extern fn wlr_seat_keyboard_send_modifiers(seat: *Seat, modifiers: *wlroots.Keyboard.Modifiers) void;
    extern fn wlr_seat_keyboard_start_grab(wlr_seat: *Seat, grab: *KeyboardGrab) void;
    extern fn wlr_seat_pointer_clear_focus(wlr_seat: *Seat) void;
    extern fn wlr_seat_pointer_end_grab(wlr_seat: *Seat) void;
    extern fn wlr_seat_pointer_enter(wlr_seat: *Seat, surface: *wlroots.Surface, sx: f64, sy: f64) void;
    extern fn wlr_seat_pointer_has_grab(seat: *Seat) bool;
    extern fn wlr_seat_pointer_notify_axis(wlr_seat: *Seat, time_msec: u32, orientation: wlroots.Pointer.AxisOrientation, value: f64, value_discrete: i32, source: wlroots.Pointer.AxisSource) void;
    extern fn wlr_seat_pointer_notify_button(wlr_seat: *Seat, time_msec: u32, button: u32, state: wlroots.ButtonState) u32;
    extern fn wlr_seat_pointer_notify_clear_focus(wlr_seat: *Seat) void;
    extern fn wlr_seat_pointer_notify_enter(wlr_seat: *Seat, surface: *wlroots.Surface, sx: f64, sy: f64) void;
    extern fn wlr_seat_pointer_notify_frame(wlr_seat: *Seat) void;
    extern fn wlr_seat_pointer_notify_motion(wlr_seat: *Seat, time_msec: u32, sx: f64, sy: f64) void;
    extern fn wlr_seat_pointer_send_axis(wlr_seat: *Seat, time_msec: u32, orientation: wlroots.Pointer.AxisOrientation, value: f64, value_discrete: i32, source: wlroots.Pointer.AxisSource) void;
    extern fn wlr_seat_pointer_send_button(wlr_seat: *Seat, time_msec: u32, button: u32, state: wlroots.ButtonState) u32;
    extern fn wlr_seat_pointer_send_frame(wlr_seat: *Seat) void;
    extern fn wlr_seat_pointer_send_motion(wlr_seat: *Seat, time_msec: u32, sx: f64, sy: f64) void;
    extern fn wlr_seat_pointer_start_grab(wlr_seat: *Seat, grab: *PointerGrab) void;
    extern fn wlr_seat_pointer_surface_has_focus(wlr_seat: *Seat, surface: *wlroots.Surface) bool;
    extern fn wlr_seat_pointer_warp(wlr_seat: *Seat, sx: f64, sy: f64) void;
    extern fn wlr_seat_request_set_selection(seat: *Seat, client: *Client, source: *wlroots.DataSource, serial: u32) void;
    extern fn wlr_seat_request_start_drag(seat: *Seat, drag: *wlroots.Drag, origin: *wlroots.Surface, serial: u32) void;
    extern fn wlr_seat_set_capabilities(wlr_seat: *Seat, capabilities: u32) void;
    extern fn wlr_seat_set_keyboard(seat: *Seat, dev: *wlroots.InputDevice) void;
    extern fn wlr_seat_set_name(wlr_seat: *Seat, name: [*:0]const u8) void;
    extern fn wlr_seat_set_selection(seat: *Seat, source: *wlroots.DataSource, serial: u32) void;
    extern fn wlr_seat_start_drag(seat: *Seat, drag: *wlroots.Drag, serial: u32) void;
    extern fn wlr_seat_start_pointer_drag(seat: *Seat, drag: *wlroots.Drag, serial: u32) void;
    extern fn wlr_seat_start_touch_drag(seat: *Seat, drag: *wlroots.Drag, serial: u32, point: *struct_wlr_touch_point) void;
    extern fn wlr_seat_touch_end_grab(wlr_seat: *Seat) void;
    extern fn wlr_seat_touch_get_point(seat: *Seat, touch_id: i32) ?*struct_wlr_touch_point;
    extern fn wlr_seat_touch_has_grab(seat: *Seat) bool;
    extern fn wlr_seat_touch_notify_down(seat: *Seat, surface: *wlroots.Surface, time_msec: u32, touch_id: i32, sx: f64, sy: f64) u32;
    extern fn wlr_seat_touch_notify_motion(seat: *Seat, time_msec: u32, touch_id: i32, sx: f64, sy: f64) void;
    extern fn wlr_seat_touch_notify_up(seat: *Seat, time_msec: u32, touch_id: i32) void;
    extern fn wlr_seat_touch_num_points(seat: *Seat) c_int;
    extern fn wlr_seat_touch_point_clear_focus(seat: *Seat, time_msec: u32, touch_id: i32) void;
    extern fn wlr_seat_touch_point_focus(seat: *Seat, surface: *wlroots.Surface, time_msec: u32, touch_id: i32, sx: f64, sy: f64) void;
    extern fn wlr_seat_touch_send_down(seat: *Seat, surface: *wlroots.Surface, time_msec: u32, touch_id: i32, sx: f64, sy: f64) u32;
    extern fn wlr_seat_touch_send_motion(seat: *Seat, time_msec: u32, touch_id: i32, sx: f64, sy: f64) void;
    extern fn wlr_seat_touch_send_up(seat: *Seat, time_msec: u32, touch_id: i32) void;
    extern fn wlr_seat_touch_start_grab(wlr_seat: *Seat, grab: *TouchGrab) void;
    extern fn wlr_seat_validate_grab_serial(seat: *Seat, serial: u32) bool;
    extern fn wlr_seat_validate_pointer_grab_serial(seat: *Seat, origin: *wlroots.Surface, serial: u32) bool;
    extern fn wlr_seat_validate_touch_grab_serial(seat: *Seat, origin: *wlroots.Surface, serial: u32, point_ptr: ?**struct_wlr_touch_point) bool;

    /// struct wlr_seat_pointer_grab
    pub const PointerGrab = extern struct {
        interface: [*c]const wlroots.Pointer.GrabInterface,
        seat: [*c]Seat,
        data: ?*c_void,
    };

    /// struct wlr_seat_keyboard_grab
    pub const KeyboardGrab = extern struct {
        /// struct wlr_keyboard_grab_interface
        pub const Interface = extern struct {
            enter: ?fn ([*c]KeyboardGrab, [*c]wlroots.Surface, [*c]u32, usize, [*c]wlroots.Keyboard.Modifiers) callconv(.C) void,
            clear_focus: ?fn ([*c]KeyboardGrab) callconv(.C) void,
            key: ?fn ([*c]KeyboardGrab, u32, u32, u32) callconv(.C) void,
            modifiers: ?fn ([*c]KeyboardGrab, [*c]wlroots.Keyboard.Modifiers) callconv(.C) void,
            cancel: ?fn ([*c]KeyboardGrab) callconv(.C) void,
        };

        interface: [*c]const Interface,
        seat: [*c]Seat,
        data: ?*c_void,
    };

    // struct wlr_seat_touch_grab
    pub const TouchGrab = extern struct {
        pub const struct_wlr_touch_grab_interface = extern struct {
            down: ?fn ([*c]TouchGrab, u32, [*c]struct_wlr_touch_point) callconv(.C) u32,
            up: ?fn ([*c]TouchGrab, u32, [*c]struct_wlr_touch_point) callconv(.C) void,
            motion: ?fn ([*c]TouchGrab, u32, [*c]struct_wlr_touch_point) callconv(.C) void,
            enter: ?fn ([*c]TouchGrab, u32, [*c]struct_wlr_touch_point) callconv(.C) void,
            cancel: ?fn ([*c]TouchGrab) callconv(.C) void,
        };

        interface: [*c]const struct_wlr_touch_grab_interface,
        seat: [*c]Seat,
        data: ?*c_void,
    };

    /// struct wlr_seat_client
    pub const Client = extern struct {
        // TODO make available
        extern fn wlr_seat_client_validate_event_serial(client: *Client, serial: u32) bool;
        extern fn wlr_seat_client_for_wl_client(wlr_seat: *Seat, wl_client: ?*wayland.Client) [*c]struct_wlr_seat_client;
        extern fn wlr_seat_client_from_pointer_resource(resource: *wayland.Resource) [*c]struct_wlr_seat_client;
        extern fn wlr_seat_client_from_resource(resource: *wayland.Resource) [*c]struct_wlr_seat_client;
        extern fn wlr_seat_client_next_serial(client: *struct_wlr_seat_client) u32;

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
        serials: wlroots.SerialRingset,
    };

    pub const Events = struct {
        /// struct wlr_seat_pointer_request_set_cursor_event
        pub const RequestSetCursor = extern struct {
            seat_client: [*c]Client,
            surface: [*c]wlroots.Surface,
            serial: u32,
            hotspot_x: i32,
            hotspot_y: i32,
        };

        /// struct wlr_seat_request_set_selection_event
        pub const RequestSetSelection = extern struct {
            source: [*c]wlroots.DataSource,
            serial: u32,
        };

        /// struct wlr_seat_request_set_primary_selection_event
        pub const RequestSetPrimarySelection = extern struct {
            source: ?*wlroots.PrimarySelectionSource,
            serial: u32,
        };

        /// struct wlr_seat_request_start_drag_event
        pub const RequestStartDrag = extern struct {
            drag: [*c]wlroots.Drag,
            origin: [*c]wlroots.Surface,
            serial: u32,
        };

        /// struct wlr_seat_pointer_focus_change_event
        pub const PointerFocusChange = extern struct {
            seat: [*c]Seat,
            old_surface: [*c]wlroots.Surface,
            new_surface: [*c]wlroots.Surface,
            sx: f64,
            sy: f64,
        };

        /// struct wlr_seat_keyboard_focus_change_event
        pub const KeyboardFocusChange = extern struct {
            seat: [*c]Seat,
            old_surface: [*c]wlroots.Surface,
            new_surface: [*c]wlroots.Surface,
        };
    };

    /// struct wlr_seat_pointer_state
    pub const struct_wlr_seat_pointer_state = extern struct {
        seat: [*c]Seat,
        focused_client: [*c]Client,
        focused_surface: [*c]wlroots.Surface,
        sx: f64,
        sy: f64,
        grab: [*c]PointerGrab,
        default_grab: [*c]PointerGrab,
        buttons: [16]u32,
        button_count: usize,
        grab_button: u32,
        grab_serial: u32,
        grab_time: u32,
        surface_destroy: wayland.Listener(?*c_void),
        events: extern struct {
            focus_change: wayland.Signal(*Events.PointerFocusChange),
        },
    };

    /// struct wlr_seat_keyboard_state
    pub const struct_wlr_seat_keyboard_state = extern struct {
        seat: [*c]Seat,
        keyboard: [*c]wlroots.Keyboard,
        focused_client: [*c]Client,
        focused_surface: [*c]wlroots.Surface,
        keyboard_destroy: wayland.Listener(?*c_void),
        keyboard_keymap: wayland.Listener(?*c_void),
        keyboard_repeat_info: wayland.Listener(?*c_void),
        surface_destroy: wayland.Listener(?*c_void),
        grab: [*c]KeyboardGrab,
        default_grab: [*c]KeyboardGrab,
        events: extern struct {
            focus_change: wayland.Signal(*Events.KeyboardFocusChange),
        },
    };

    /// struct wlr_seat_touch_state
    pub const struct_wlr_seat_touch_state = extern struct {
        seat: [*c]Seat,
        touch_points: wayland.List(struct_wlr_touch_point, "link"),
        grab_serial: u32,
        grab_id: u32,
        grab: [*c]TouchGrab,
        default_grab: [*c]TouchGrab,
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
    display: *wayland.Display,
    clients: wayland.List(Client, "link"),
    name: [*c]u8,
    capabilities: u32,
    accumulated_capabilities: u32,
    last_event: std.os.timespec,
    selection_source: [*c]wlroots.DataSource,
    selection_serial: u32,
    selection_offers: wayland.List(wlroots.DataOffer, "link"),
    primary_selection_source: ?*wlroots.PrimarySelectionSource,
    primary_selection_serial: u32,
    drag: [*c]wlroots.Drag,
    drag_source: [*c]wlroots.DataSource,
    drag_serial: u32,
    drag_offers: wayland.List(wlroots.DataOffer, "link"),
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
        request_set_cursor: wayland.Signal(*Events.RequestSetCursor),
        request_set_selection: wayland.Signal(*Events.RequestSetSelection),
        set_selection: wayland.Signal(?*c_void),
        request_set_primary_selection: wayland.Signal(*Events.RequestSetPrimarySelection),
        set_primary_selection: wayland.Signal(?*c_void),
        request_start_drag: wayland.Signal(*Events.RequestStartDrag),
        start_drag: wayland.Signal(?*c_void),
        destroy: wayland.Signal(?*c_void),
    },
    data: ?*c_void,

    pub fn init(display: *wayland.Display, name: [*:0]const u8) !*Seat {
        return wlr_seat_create(display, name) orelse error.Failure;
    }

    pub fn keyboardEnter(seat: *Seat, surface: *wlroots.Surface, keycodes: []u32, modifiers: *wlroots.Keyboard.Modifiers) void {
        wlr_seat_keyboard_enter(seat, surface, keycodes.ptr, keycodes.len, modifiers);
    }

    pub fn keyboardNotifyEnter(seat: *Seat, surface: *wlroots.Surface, keycodes: []u32, modifiers: *wlroots.Keyboard.Modifiers) void {
        wlr_seat_keyboard_notify_enter(seat, surface, keycodes.ptr, keycodes.len, modifiers);
    }

    pub const deinit = wlr_seat_destroy;
    pub const getKeyboard = wlr_seat_get_keyboard;
    pub const setCapabilities = wlr_seat_set_capabilities;
    pub const setKeyboard = wlr_seat_set_keyboard;
    pub const setName = wlr_seat_set_name;
    pub const setSelection = wlr_seat_set_selection;
    pub const keyboardClearFocus = wlr_seat_keyboard_clear_focus;
    pub const keyboardEndGrab = wlr_seat_keyboard_end_grab;
    pub const keyboardHasGrab = wlr_seat_keyboard_has_grab;
    pub const keyboardNotifyClearFocus = wlr_seat_keyboard_notify_clear_focus;

    pub fn keyboardNotifyKey(seat: *Seat, time_msec: u32, key: u32, state: wlroots.Keyboard.enum_wlr_key_state) void {
        wlr_seat_keyboard_notify_key(seat, time_msec, key, @intCast(u32, @enumToInt(state)));
    }

    pub const keyboardNotifyModifiers = wlr_seat_keyboard_notify_modifiers;
    pub const keyboardSendKey = wlr_seat_keyboard_send_key;
    pub const keyboardSendModifiers = wlr_seat_keyboard_send_modifiers;
    pub const keyboardStartGrab = wlr_seat_keyboard_start_grab;
    pub const pointerClearFocus = wlr_seat_pointer_clear_focus;
    pub const pointerEndGrab = wlr_seat_pointer_end_grab;
    pub const pointerEnter = wlr_seat_pointer_enter;
    pub const pointerHasGrab = wlr_seat_pointer_has_grab;
    pub const pointerNotifyAxis = wlr_seat_pointer_notify_axis;
    pub const pointerNotifyButton = wlr_seat_pointer_notify_button;
    pub const pointerNotifyClearFocus = wlr_seat_pointer_notify_clear_focus;
    pub const pointerNotifyEnter = wlr_seat_pointer_notify_enter;
    pub const pointerNotifyFrame = wlr_seat_pointer_notify_frame;
    pub const pointerNotifyMotion = wlr_seat_pointer_notify_motion;
    pub const pointerSendAxis = wlr_seat_pointer_send_axis;
    pub const pointerSendButton = wlr_seat_pointer_send_button;
    pub const pointerSendFrame = wlr_seat_pointer_send_frame;
    pub const pointerSendMotion = wlr_seat_pointer_send_motion;
    pub const pointerStartGrab = wlr_seat_pointer_start_grab;
    pub const pointerSurfaceHasFocus = wlr_seat_pointer_surface_has_focus;
    pub const pointerWarp = wlr_seat_pointer_warp;
    pub const requestSetSelection = wlr_seat_request_set_selection;
    pub const requestStartDrag = wlr_seat_request_start_drag;
    pub const startDrag = wlr_seat_start_drag;
    pub const startPointerDrag = wlr_seat_start_pointer_drag;
    pub const startTouchDrag = wlr_seat_start_touch_drag;
    pub const touchEndGrab = wlr_seat_touch_end_grab;
    pub const touchGetPoint = wlr_seat_touch_get_point;
    pub const touchHasGrab = wlr_seat_touch_has_grab;
    pub const touchNotifyDown = wlr_seat_touch_notify_down;
    pub const touchNotifyMotion = wlr_seat_touch_notify_motion;
    pub const touchNotifyUp = wlr_seat_touch_notify_up;
    pub const touchNumPoints = wlr_seat_touch_num_points;
    pub const touchPointClearFocus = wlr_seat_touch_point_clear_focus;
    pub const touchPointFocus = wlr_seat_touch_point_focus;
    pub const touchSendDown = wlr_seat_touch_send_down;
    pub const touchSendMotion = wlr_seat_touch_send_motion;
    pub const touchSendUp = wlr_seat_touch_send_up;
    pub const touchStartGrab = wlr_seat_touch_start_grab;
    pub const validateGrabSerial = wlr_seat_validate_grab_serial;
    pub const validatePointerGrabSerial = wlr_seat_validate_pointer_grab_serial;
    pub const validateTouchGrabSerial = wlr_seat_validate_touch_grab_serial;
};
