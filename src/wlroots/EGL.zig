const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");
const egl = @import("../egl.zig");

/// struct wlr_egl
pub const EGL = extern struct {
    /// struct_wlr_egl_context
    pub const Context = extern struct {
        display: egl.EGLDisplay,
        context: egl.EGLContext,
        draw_surface: egl.EGLSurface,
        read_surface: egl.EGLSurface,
    };

    // TODO
    pub extern fn wlr_egl_init(egl: [*c]EGL, platform: egl.EGLenum, remote_display: ?*c_void, config_attribs: [*c]const egl.EGLint, visual_id: egl.EGLint) bool;
    pub extern fn wlr_egl_finish(egl: [*c]EGL) void;
    pub extern fn wlr_egl_bind_display(egl: [*c]EGL, local_display: ?*wayland.Display) bool;
    pub extern fn wlr_egl_create_surface(egl: [*c]EGL, window: ?*c_void) egl.EGLSurface;
    pub extern fn wlr_egl_create_image_from_wl_drm(egl: [*c]EGL, data: [*c]wayland.Resource, fmt: [*c]egl.EGLint, width: [*c]c_int, height: [*c]c_int, inverted_y: [*c]bool) egl.EGLImageKHR;
    pub extern fn wlr_egl_create_image_from_dmabuf(egl: [*c]EGL, attributes: [*c]wlroots.DmabufAttributes, external_only: [*c]bool) egl.EGLImageKHR;
    pub extern fn wlr_egl_get_dmabuf_formats(egl: [*c]EGL) [*c]const wlroots.struct_wlr_drm_format_set;
    pub extern fn wlr_egl_export_image_to_dmabuf(egl: [*c]EGL, image: egl.EGLImageKHR, width: i32, height: i32, flags: u32, attribs: [*c]wlroots.DmabufAttributes) bool;
    pub extern fn wlr_egl_destroy_image(egl: [*c]EGL, image: egl.EGLImageKHR) bool;
    pub extern fn wlr_egl_make_current(egl: [*c]EGL, surface: egl.EGLSurface, buffer_age: [*c]c_int) bool;
    pub extern fn wlr_egl_unset_current(egl: [*c]EGL) bool;
    pub extern fn wlr_egl_is_current(egl: [*c]EGL) bool;
    pub extern fn wlr_egl_save_context(context: [*c]Context) void;
    pub extern fn wlr_egl_restore_context(context: [*c]Context) bool;
    pub extern fn wlr_egl_swap_buffers(egl: [*c]EGL, surface: egl.EGLSurface, damage: [*c]pixman_region32_t) bool;
    pub extern fn wlr_egl_destroy_surface(egl: [*c]EGL, surface: egl.EGLSurface) bool;

    platform: egl.EGLenum,
    display: egl.EGLDisplay,
    config: egl.EGLConfig,
    context: egl.EGLContext,
    exts: extern struct {
        bind_wayland_display_wl: bool,
        buffer_age_ext: bool,
        image_base_khr: bool,
        image_dma_buf_export_mesa: bool,
        image_dmabuf_import_ext: bool,
        image_dmabuf_import_modifiers_ext: bool,
        swap_buffers_with_damage: bool,
    },
    procs: extern struct {
        eglGetPlatformDisplayEXT: egl.PFNEGLGETPLATFORMDISPLAYEXTPROC,
        eglCreatePlatformWindowSurfaceEXT: egl.PFNEGLCREATEPLATFORMWINDOWSURFACEEXTPROC,
        eglCreateImageKHR: egl.PFNEGLCREATEIMAGEKHRPROC,
        eglDestroyImageKHR: egl.PFNEGLDESTROYIMAGEKHRPROC,
        eglQueryWaylandBufferWL: egl.PFNEGLQUERYWAYLANDBUFFERWLPROC,
        eglBindWaylandDisplayWL: egl.PFNEGLBINDWAYLANDDISPLAYWLPROC,
        eglUnbindWaylandDisplayWL: egl.PFNEGLUNBINDWAYLANDDISPLAYWLPROC,
        eglSwapBuffersWithDamage: egl.PFNEGLSWAPBUFFERSWITHDAMAGEEXTPROC,
        eglQueryDmaBufFormatsEXT: egl.PFNEGLQUERYDMABUFFORMATSEXTPROC,
        eglQueryDmaBufModifiersEXT: egl.PFNEGLQUERYDMABUFMODIFIERSEXTPROC,
        eglExportDMABUFImageQueryMESA: egl.PFNEGLEXPORTDMABUFIMAGEQUERYMESAPROC,
        eglExportDMABUFImageMESA: egl.PFNEGLEXPORTDMABUFIMAGEMESAPROC,
        eglDebugMessageControlKHR: egl.PFNEGLDEBUGMESSAGECONTROLKHRPROC,
    },
    wl_display: ?*wayland.Display,
    dmabuf_formats: wlroots.struct_wlr_drm_format_set,
    external_only_dmabuf_formats: [*c][*c]egl.EGLBoolean,
};
