const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_xdg_surface
pub const XDGSurface = extern struct {
    pub extern fn wlr_xdg_surface_for_each_popup(surface: [*c]XDGSurface, iterator: wlroots.Surface.IteratorFunc, user_data: ?*c_void) void;
    pub extern fn wlr_xdg_surface_for_each_surface(surface: [*c]XDGSurface, iterator: wlroots.Surface.IteratorFunc, user_data: ?*c_void) void;
    pub extern fn wlr_xdg_surface_from_popup_resource(resource: [*c]wayland.Resource) [*c]XDGSurface;
    pub extern fn wlr_xdg_surface_from_resource(resource: [*c]wayland.Resource) [*c]XDGSurface;
    pub extern fn wlr_xdg_surface_from_toplevel_resource(resource: [*c]wayland.Resource) [*c]XDGSurface;
    pub extern fn wlr_xdg_surface_from_wlr_surface(surface: [*c]Surface) [*c]XDGSurface;
    pub extern fn wlr_xdg_surface_get_geometry(surface: [*c]XDGSurface, box: [*c]wlroots.Box) void;
    pub extern fn wlr_xdg_surface_ping(surface: [*c]XDGSurface) void;
    pub extern fn wlr_xdg_surface_schedule_configure(surface: [*c]XDGSurface) u32;
    pub extern fn wlr_xdg_surface_surface_at(surface: [*c]XDGSurface, sx: f64, sy: f64, sub_x: [*c]f64, sub_y: [*c]f64) [*c]wlroots.Surface;

    /// struct wlr_xdg_surface_configure
    pub const struct_wlr_xdg_surface_configure = extern struct {
        surface: [*c]XDGSurface,
        link: wayland.ListElement(struct_wlr_xdg_surface_configure, "link"), // wlr_xdg_surface::configure_list
        serial: u32,
        toplevel_state: [*c]wlroots.XDGToplevel.struct_wlr_xdg_toplevel_state,
    };

    /// enum wlr_xdg_surface_role
    pub const enum_wlr_xdg_surface_role = extern enum(c_int) {
        WLR_XDG_SURFACE_ROLE_NONE,
        WLR_XDG_SURFACE_ROLE_TOPLEVEL,
        WLR_XDG_SURFACE_ROLE_POPUP,
        _,
    };

    client: [*c]wlroots.XDGClient,
    resource: [*c]wayland.Resource,
    surface: *wlroots.Surface,
    link: wayland.ListElement(XDGSurface, "link"), // wlr_xdg_client::surfaces
    role: enum_wlr_xdg_surface_role,
    unnamed_0: extern union {
        toplevel: *wlroots.XDGToplevel,
        popup: *wlroots.XDGPopup,
    },
    popups: wayland.List(wlroots.XDGPopup, "link"),
    added: bool,
    configured: bool,
    mapped: bool,
    configure_serial: u32,
    configure_idle: ?*wayland.EventSource,
    configure_next_serial: u32,
    configure_list: wayland.List(struct_wlr_xdg_surface_configure, "link"),
    has_next_geometry: bool,
    next_geometry: wlroots.Box,
    geometry: wlroots.Box,
    surface_destroy: wayland.Listener(?*c_void),
    surface_commit: wayland.Listener(?*c_void),
    events: extern struct {
        destroy: wayland.Signal(*XDGSurface),
        ping_timeout: wayland.Signal(?*c_void),
        new_popup: wayland.Signal(?*c_void),
        map: wayland.Signal(*XDGSurface),
        unmap: wayland.Signal(*XDGSurface),
        configure: wayland.Signal(?*c_void),
        ack_configure: wayland.Signal(?*c_void),
    },
    data: ?*c_void,

    // TODO(dh): provide a type-safe, generic version of this
    pub const forEachSurface = wlr_xdg_surface_for_each_surface;
};
