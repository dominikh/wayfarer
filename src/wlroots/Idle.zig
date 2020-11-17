const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_idle
pub const Idle = extern struct {
    /// struct wlr_idle_timeout
    pub const Timeout = extern struct {
        resource: [*c]wayland.Resource,
        link: wayland.ListElement(Timeout, "link"),
        seat: [*c]wlroots.Seat,
        idle_source: ?*wayland.EventSource,
        idle_state: bool,
        enabled: bool,
        timeout: u32,
        events: extern struct {
            idle: wayland.Signal(*Timeout),
            @"resume": wayland.Signal(*Timeout),
            destroy: wayland.Signal(void),
        },
        input_listener: wayland.Listener(?*c_void),
        seat_destroy: wayland.Listener(?*c_void),
        data: ?*c_void,

        extern fn wlr_idle_timeout_create(idle: *Idle, seat: *wlroots.Seat, timeout: u32) ?*Timeout;
        extern fn wlr_idle_timeout_destroy(timeout: *Timeout) void;

        pub fn init(idle: *Idle, seat: *wlroots.Seat, timeout: u32) !*Timeout {
            return wlr_idle_timeout_create(idle, seat, timeout) orelse error.Failure;
        }

        pub const deinit = wlr_idle_timeout_destroy;
    };

    extern fn wlr_idle_create(display: *wayland.Display) ?*Idle;
    extern fn wlr_idle_notify_activity(idle: *Idle, seat: *wlroots.Seat) void;
    extern fn wlr_idle_set_enabled(idle: *Idle, seat: *wlroots.Seat, enabled: bool) void;

    pub fn init(display: *wayland.Display) !*Idle {
        return wlr_idle_create(display) orelse error.Failure;
    }

    pub const notifyActivity = wlr_idle_notify_activity;
    pub const setEnabled = wlr_idle_set_enabled;

    global: ?*wayland.Global,
    idle_timers: wayland.List(Timeout, "link"),
    event_loop: ?*wayland.EventLoop,
    enabled: bool,
    display_destroy: wayland.Listener(?*c_void),
    events: extern struct {
        activity_notify: wayland.Signal(*wlroots.Seat),
        destroy: wayland.Signal(*Idle),
    },
    data: ?*c_void,
};
