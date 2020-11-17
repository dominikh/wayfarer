const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");
const udev = @import("../udev.zig");

/// struct wlr_session
pub const Session = extern struct {
    extern fn wlr_session_create(disp: *wayland.Display) ?*Session;
    extern fn wlr_session_destroy(session: *Session) void;
    extern fn wlr_session_open_file(session: *Session, path: [*:0]const u8) c_int;
    extern fn wlr_session_close_file(session: *Session, fd: c_int) void;
    extern fn wlr_session_signal_add(session: *Session, fd: c_int, listener: *wayland.Listener(?*c_void)) void;
    extern fn wlr_session_change_vt(session: *Session, vt: c_uint) bool;
    extern fn wlr_session_find_gpus(session: *Session, ret_len: usize, ret: *c_int) usize;

    /// struct wlr_session_impl
    pub const struct_session_impl = opaque {};

    impl: ?*const struct_session_impl,
    session_signal: wayland.Signal(?*c_void),
    active: bool,
    vtnr: c_uint,
    seat: [256]u8,
    udev: ?*udev.struct_udev,
    mon: ?*udev.struct_udev_monitor,
    udev_event: ?*wayland.EventSource,
    // XXX audit the list type
    devices: wayland.List(wayland.Resource, "link"),
    display_destroy: wayland.Listener(?*c_void),
    events: extern struct {
        destroy: wayland.Signal(?*c_void),
    },

    pub fn init(disp: *wayland.Display) !*Session {
        return wlr_session_create(disp) orelse error.Failure;
    }

    pub const destroy = wlr_session_destroy;
    pub const open_file = wlr_session_open_file;
    pub const close_file = wlr_session_close_file;
    // TODO(dh): type-safe listener
    pub const signal_add = wlr_session_signal_add;
    pub const change_vt = wlr_session_change_vt;
    pub const find_gpus = wlr_session_find_gpus;
};
