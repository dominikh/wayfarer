const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_xdg_popup
pub const XDGPopup = extern struct {
    extern fn wlr_xdg_popup_destroy(surface: *wlroots.XDGSurface) void;
    extern fn wlr_xdg_popup_get_anchor_point(popup: *XDGPopup, toplevel_sx: *c_int, toplevel_sy: *c_int) void;
    extern fn wlr_xdg_popup_get_toplevel_coords(popup: *XDGPopup, popup_sx: c_int, popup_sy: c_int, toplevel_sx: *c_int, toplevel_sy: *c_int) void;
    extern fn wlr_xdg_popup_unconstrain_from_box(popup: *XDGPopup, toplevel_sx_box: *wlroots.Box) void;

    /// struct wlr_xdg_popup_grab
    pub const Grab = extern struct {
        client: ?*wayland.Client,
        pointer_grab: wlroots.Seat.struct_wlr_seat_pointer_grab,
        keyboard_grab: wlroots.Seat.struct_wlr_seat_keyboard_grab,
        touch_grab: wlroots.Seat.struct_wlr_seat_touch_grab,
        seat: [*c]wlroots.Seat,
        popups: wayland.List(XDGPopup, "grab_link"),
        link: wayland.ListElement(Grab, "link"), // wlr_xdg_shell::popup_grabs
        seat_destroy: wayland.Listener(?*c_void),
    };

    base: *wlroots.XDGSurface,
    link: wayland.ListElement(XDGPopup, "link"),
    resource: [*c]wayland.Resource,
    committed: bool,
    parent: [*c]wlroots.Surface,
    seat: [*c]wlroots.Seat,
    geometry: wlroots.Box,
    positioner: wlroots.XDGPositioner,
    grab_link: wayland.ListElement(XDGPopup, "grab_link"), // wlr_xdg_popup_grab::popups

    pub const deinit = wlr_xdg_popup_destroy;
    pub const getAnchorPoint = wlr_xdg_popup_get_anchor_point;
    pub const getToplevelCoords = wlr_xdg_popup_get_toplevel_coords;
    pub const unconstrainFromBox = wlr_xdg_popup_unconstrain_from_box;
};
