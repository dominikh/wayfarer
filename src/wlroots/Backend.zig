const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_backend
pub const Backend = extern struct {
    pub extern fn wlr_backend_autocreate(display: ?*wayland.Display, create_renderer_func: wlroots.Renderer.wlr_renderer_create_func_t) ?*Backend;
    pub extern fn wlr_backend_start(backend: [*c]Backend) bool;
    pub extern fn wlr_backend_destroy(backend: [*c]Backend) void;
    pub extern fn wlr_backend_get_renderer(backend: *Backend) *wlroots.Renderer;
    pub extern fn wlr_backend_get_session(backend: [*c]Backend) [*c]wlroots.Session;
    pub extern fn wlr_backend_get_presentation_clock(backend: [*c]Backend) clockid_t;
    pub extern fn wlr_multi_backend_create(display: ?*wayland.Display) [*c]Backend;
    pub extern fn wlr_multi_backend_add(multi: [*c]Backend, backend: [*c]Backend) bool;
    pub extern fn wlr_multi_backend_remove(multi: [*c]Backend, backend: [*c]Backend) void;
    pub extern fn wlr_backend_is_multi(backend: [*c]Backend) bool;
    pub extern fn wlr_multi_is_empty(backend: [*c]Backend) bool;
    pub extern fn wlr_multi_for_each_backend(backend: [*c]Backend, callback: ?fn ([*c]Backend, ?*c_void) callconv(.C) void, data: ?*c_void) void;

    pub const Impl = opaque {};

    impl: ?*const Impl,
    events: extern struct {
        destroy: wayland.Signal(*Backend),
        new_input: wayland.Signal(*wlroots.InputDevice),
        new_output: wayland.Signal(*wlroots.Output),
    },

    pub fn autocreate(dsp: *wayland.Display) !*Backend {
        return wlr_backend_autocreate(dsp, null) orelse error.Failure;
    }

    pub const destroy = wlr_backend_destroy;
    pub const getRenderer = wlr_backend_get_renderer;
};
