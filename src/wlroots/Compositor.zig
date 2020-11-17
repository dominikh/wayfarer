const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_compositor
pub const Compositor = extern struct {
    extern fn wlr_compositor_create(display: *wayland.Display, renderer: *wlroots.Renderer) ?*Compositor;

    global: ?*wayland.Global,
    renderer: *wlroots.Renderer,
    subcompositor: wlroots.Subcompositor,
    display_destroy: wayland.Listener(?*c_void),
    events: extern struct {
        new_surface: wayland.Signal(*wlroots.Surface),
        destroy: wayland.Signal(*Compositor),
    },

    pub fn init(display: *wayland.Display, renderer: *wlroots.Renderer) !*Compositor {
        return wlr_compositor_create(display, renderer) orelse error.Failure;
    }
};
