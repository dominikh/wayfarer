const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_subsurface
pub const Subsurface = extern struct {
    pub extern fn wlr_subsurface_create(surface: [*c]wlroots.Surface, parent: [*c]wlroots.Surface, version: u32, id: u32, resource_list: [*c]wayland.List(wayland.Resource, "link")) [*c]Subsurface;
    pub extern fn wlr_subsurface_from_wlr_surface(surface: [*c]wlroots.Surface) [*c]Subsurface;

    /// struct wlr_subsurface_state
    pub const State = extern struct {
        x: i32,
        y: i32,
    };

    resource: [*c]wayland.Resource,
    surface: [*c]wlroots.Surface,
    parent: [*c]wlroots.Surface,
    current: State,
    pending: State,
    cached: wlroots.Surface.State,
    has_cache: bool,
    synchronized: bool,
    reordered: bool,
    mapped: bool,
    parent_link: wayland.ListElement(Subsurface, "parent_link"),
    parent_pending_link: wayland.ListElement(Subsurface, "parent_pending_link"),
    surface_destroy: wayland.Listener(?*c_void),
    parent_destroy: wayland.Listener(?*c_void),
    events: extern struct {
        destroy: wayland.Signal(*Subsurface),
        map: wayland.Signal(*Subsurface),
        unmap: wayland.Signal(*Subsurface),
    },
    data: ?*c_void,
};
