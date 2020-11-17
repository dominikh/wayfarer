const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_backend
pub const Backend = extern struct {
    extern fn wlr_backend_autocreate(display: *wayland.Display, create_renderer_func: ?wlroots.Renderer.wlr_renderer_create_func_t) ?*Backend;
    extern fn wlr_backend_start(backend: *Backend) bool;
    extern fn wlr_backend_destroy(backend: *Backend) void;
    extern fn wlr_backend_get_renderer(backend: *Backend) *wlroots.Renderer;
    extern fn wlr_backend_get_session(backend: *Backend) ?*wlroots.Session;
    extern fn wlr_backend_get_presentation_clock(backend: *Backend) clockid_t;
    extern fn wlr_multi_backend_create(display: *wayland.Display) ?*Backend;
    extern fn wlr_multi_backend_add(multi: *Backend, backend: *Backend) bool;
    extern fn wlr_multi_backend_remove(multi: *Backend, backend: *Backend) void;
    extern fn wlr_backend_is_multi(backend: *Backend) bool;
    extern fn wlr_multi_is_empty(backend: *Backend) bool;
    extern fn wlr_multi_for_each_backend(backend: *Backend, callback: fn (*Backend, ?*c_void) callconv(.C) void, data: ?*c_void) void;

    /// struct wlr_backend_impl
    pub const Impl = opaque {};

    impl: ?*const Impl,
    events: extern struct {
        destroy: wayland.Signal(*Backend),
        new_input: wayland.Signal(*wlroots.InputDevice),
        new_output: wayland.Signal(*wlroots.Output),
    },

    pub fn autocreate(display: *wayland.Display, create_renderer_func: ?wlroots.Renderer.wlr_renderer_create_func_t) !*Backend {
        return wlr_backend_autocreate(display, create_renderer_func) orelse error.Failure;
    }

    pub fn start(backend: *Backend) !void {
        if (!backend.wlr_backend_start()) {
            return error.Failure;
        }
    }

    pub fn multiBackendCreate(display: *wayland.Display) !*Backend {
        return wlr_multi_backend_create(display) orelse error.Failure;
    }

    pub const deinit = wlr_backend_destroy;
    pub const getRenderer = wlr_backend_get_renderer;
    pub const getSession = wlr_backend_get_session;
    pub const getPresentationClock = wlr_backend_get_presentation_clock;
    pub const multiBackendAdd = wlr_multi_backend_add;
    pub const multiBackendRemove = wlr_multi_backend_remove;
    pub const isMulti = wlr_backend_is_multi;
    pub const multiIsEmpty = wlr_multi_is_empty;
    pub const multiForEachBackend = wlr_multi_for_each_backend;
};
