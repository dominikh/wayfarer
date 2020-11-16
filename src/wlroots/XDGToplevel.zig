const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_xdg_toplevel
pub const XDGToplevel = extern struct {
    extern fn wlr_xdg_toplevel_send_close(surface: *wlroots.XDGSurface) void;
    extern fn wlr_xdg_toplevel_set_activated(surface: *wlroots.XDGSurface, activated: bool) u32;
    extern fn wlr_xdg_toplevel_set_fullscreen(surface: *wlroots.XDGSurface, fullscreen: bool) u32;
    extern fn wlr_xdg_toplevel_set_maximized(surface: *wlroots.XDGSurface, maximized: bool) u32;
    extern fn wlr_xdg_toplevel_set_resizing(surface: *wlroots.XDGSurface, resizing: bool) u32;
    extern fn wlr_xdg_toplevel_set_size(surface: *wlroots.XDGSurface, width: u32, height: u32) u32;
    extern fn wlr_xdg_toplevel_set_tiled(surface: *wlroots.XDGSurface, tiled_edges: u32) u32;

    pub const Events = struct {
        /// wlr_xdg_toplevel_move_event
        pub const Move = extern struct {
            surface: [*c]wlroots.XDGSurface,
            seat: [*c]wlroots.Seat.Client,
            serial: u32,
        };

        /// struct wlr_xdg_toplevel_resize_event
        pub const Resize = extern struct {
            surface: [*c]wlroots.XDGSurface,
            seat: [*c]wlroots.Seat.Client,
            serial: u32,
            edges: u32,
        };

        /// struct wlr_xdg_toplevel_set_fullscreen_event
        pub const SetFullscreen = extern struct {
            surface: [*c]wlroots.XDGSurface,
            fullscreen: bool,
            output: [*c]wlroots.Output,
        };

        /// struct wlr_xdg_toplevel_show_window_menu_event
        pub const ShowWindowMenu = extern struct {
            surface: [*c]wlroots.XDGSurface,
            seat: [*c]wlroots.Seat.Client,
            serial: u32,
            x: u32,
            y: u32,
        };
    };

    /// struct wlr_xdg_toplevel_state
    pub const struct_wlr_xdg_toplevel_state = extern struct {
        maximized: bool,
        fullscreen: bool,
        resizing: bool,
        activated: bool,
        tiled: u32,
        width: u32,
        height: u32,
        max_width: u32,
        max_height: u32,
        min_width: u32,
        min_height: u32,
        fullscreen_output: [*c]wlroots.Output,
        fullscreen_output_destroy: wayland.Listener(?*c_void),
    };

    resource: [*c]wayland.Resource,
    base: *wlroots.XDGSurface,
    added: bool,
    parent: ?*wlroots.XDGSurface,
    parent_unmap: wayland.Listener(?*c_void),
    client_pending: struct_wlr_xdg_toplevel_state,
    server_pending: struct_wlr_xdg_toplevel_state,
    current: struct_wlr_xdg_toplevel_state,
    title: ?[*:0]u8,
    app_id: ?[*:0]u8,
    events: extern struct {
        request_maximize: wayland.Signal(*wlroots.XDGSurface),
        request_fullscreen: wayland.Signal(?*c_void),
        request_minimize: wayland.Signal(?*c_void),
        request_move: wayland.Signal(*Events.Move),
        request_resize: wayland.Signal(*Events.Resize),
        request_show_window_menu: wayland.Signal(*Events.ShowWindowMenu),
        set_parent: wayland.Signal(?*c_void),
        set_title: wayland.Signal(?*c_void),
        set_app_id: wayland.Signal(?*c_void),
    },

    pub fn SendClose(surface: *wlroots.XDGToplevel) void {
        surface.base.wlr_xdg_toplevel_send_close();
    }

    pub fn SetActivated(surface: *wlroots.XDGToplevel, activated: bool) u32 {
        return wlr_xdg_toplevel_set_activated(surface.base, activated);
    }

    pub fn SetFullscreen(surface: *wlroots.XDGToplevel, fullscreen: bool) u32 {
        return wlr_xdg_toplevel_set_fullscreen(surface.base, fullscreen);
    }

    pub fn SetMaximized(surface: *wlroots.XDGToplevel, maximized: bool) u32 {
        return wlr_xdg_toplevel_set_maximized(surface.base, maximized);
    }

    pub fn SetResizing(surface: *wlroots.XDGToplevel, resizing: bool) u32 {
        return wlr_xdg_toplevel_set_resizing(surface.base, resizing);
    }

    pub fn SetSize(surface: *wlroots.XDGToplevel, width: u32, height: u32) u32 {
        return wlr_xdg_toplevel_set_size(surface.base, width, height);
    }

    pub fn SetTiled(surface: *wlroots.XDGToplevel, tiled_edges: u32) u32 {
        return wlr_xdg_toplevel_set_tiled(surface.base, tiled_edge);
    }
};
