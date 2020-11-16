const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");
const udev = @import("../udev.zig");

/// struct wlr_session
pub const Session = extern struct {
    pub extern fn wlr_session_create(disp: ?*wayland.Display) [*c]Session;
    pub extern fn wlr_session_destroy(session: [*c]Session) void;
    pub extern fn wlr_session_open_file(session: [*c]Session, path: [*:0]const u8) c_int;
    pub extern fn wlr_session_close_file(session: [*c]Session, fd: c_int) void;
    pub extern fn wlr_session_signal_add(session: [*c]Session, fd: c_int, listener: [*c]wayland.Listener(?*c_void)) void;
    pub extern fn wlr_session_change_vt(session: [*c]Session, vt: c_uint) bool;
    pub extern fn wlr_session_find_gpus(session: [*c]Session, ret_len: usize, ret: [*c]c_int) usize;

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
};
