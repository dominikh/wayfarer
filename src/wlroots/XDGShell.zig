const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_xdg_shell
pub const XDGShell = extern struct {
    extern fn wlr_xdg_shell_create(display: *wayland.Display) ?*XDGShell;

    global: ?*wayland.Global,
    clients: wayland.List(wlroots.XDGClient, "link"),
    popup_grabs: wayland.List(wlroots.XDGPopup.Grab, "link"),
    ping_timeout: u32,
    display_destroy: wayland.Listener(?*c_void),
    events: extern struct {
        new_surface: wayland.Signal(*wlroots.XDGSurface),
        destroy: wayland.Signal(?*c_void),
    },
    data: ?*c_void,

    pub fn init(display: *wayland.Display) !*XDGShell {
        return wlr_xdg_shell_create(display) orelse error.Failure;
    }
};
