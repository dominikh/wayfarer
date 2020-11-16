const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_xdg_positioner
pub const XDGPositioner = extern struct {
    pub extern fn wlr_positioner_invert_x(positioner: *XDGPositioner) void;
    pub extern fn wlr_positioner_invert_y(positioner: *XDGPositioner) void;
    pub extern fn wlr_xdg_positioner_get_geometry(positioner: *XDGPositioner) Box;

    resource: [*c]wayland.Resource,
    anchor_rect: wlroots.Box,
    anchor: wayland.enum_xdg_positioner_anchor,
    gravity: wayland.enum_xdg_positioner_gravity,
    constraint_adjustment: wayland.enum_xdg_positioner_constraint_adjustment,
    size: extern struct {
        width: i32,
        height: i32,
    },
    offset: extern struct {
        x: i32,
        y: i32,
    },
};
