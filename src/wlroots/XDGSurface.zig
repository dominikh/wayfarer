const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_xdg_surface
pub const XDGSurface = extern struct {
    extern fn wlr_xdg_surface_for_each_popup(surface: *XDGSurface, iterator: wlroots.Surface.IteratorFunc, user_data: ?*c_void) void;
    extern fn wlr_xdg_surface_for_each_surface(surface: *XDGSurface, iterator: wlroots.Surface.IteratorFunc, user_data: ?*c_void) void;
    extern fn wlr_xdg_surface_from_popup_resource(resource: *wayland.Resource) ?*XDGSurface;
    extern fn wlr_xdg_surface_from_resource(resource: *wayland.Resource) ?*XDGSurface;
    extern fn wlr_xdg_surface_from_toplevel_resource(resource: *wayland.Resource) ?*XDGSurface;
    extern fn wlr_xdg_surface_from_wlr_surface(surface: *Surface) ?*XDGSurface;
    extern fn wlr_xdg_surface_get_geometry(surface: *XDGSurface, box: *wlroots.Box) void;
    extern fn wlr_xdg_surface_ping(surface: *XDGSurface) void;
    extern fn wlr_xdg_surface_schedule_configure(surface: *XDGSurface) u32;
    extern fn wlr_xdg_surface_surface_at(surface: *XDGSurface, sx: f64, sy: f64, sub_x: *f64, sub_y: *f64) ?*wlroots.Surface;

    /// struct wlr_xdg_surface_configure
    pub const SurfaceConfigure = extern struct {
        surface: [*c]XDGSurface,
        link: wayland.ListElement(SurfaceConfigure, "link"), // wlr_xdg_surface::configure_list
        serial: u32,
        toplevel_state: [*c]wlroots.XDGToplevel.State,
    };

    /// enum wlr_xdg_surface_role
    pub const Role = extern enum(c_int) {
        WLR_XDG_SURFACE_ROLE_NONE,
        WLR_XDG_SURFACE_ROLE_TOPLEVEL,
        WLR_XDG_SURFACE_ROLE_POPUP,
        _,
    };

    client: *wlroots.XDGClient,
    resource: [*c]wayland.Resource,
    surface: *wlroots.Surface,
    link: wayland.ListElement(XDGSurface, "link"), // wlr_xdg_client::surfaces
    role: Role,
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
    configure_list: wayland.List(SurfaceConfigure, "link"),
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

    // TODO(dh): provide type-safe versions of forEach
    pub const forEachSurface = wlr_xdg_surface_for_each_surface;
    pub const forEachPopup = wlr_xdg_surface_for_each_popup;
    pub const fromPopupResource = wlr_xdg_surface_from_popup_resource;
    pub const fromResource = wlr_xdg_surface_from_resource;
    pub const fromToplevelResource = wlr_xdg_surface_from_toplevel_resource;
    pub const fromWlrSurface = wlr_xdg_surface_from_wlr_surface;
    pub const getGeometry = wlr_xdg_surface_get_geometry;
    pub const ping = wlr_xdg_surface_ping;
    pub const scheduleConfigure = wlr_xdg_surface_schedule_configure;
    pub const surfaceAt = wlr_xdg_surface_surface_at;
};
