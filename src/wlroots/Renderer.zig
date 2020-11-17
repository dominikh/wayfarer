const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");
const egl = @import("../egl.zig");

/// struct wlr_renderer
pub const Renderer = extern struct {
    /// struct wlr_renderer_impl
    pub const Impl = opaque {};

    /// enum wlr_renderer_read_pixels_flags
    pub const ReadPixelsFlags = struct {
        pub const y_invert: c_int = 1;
    };

    extern fn wlr_renderer_autocreate(egl: *wlroots.EGL, platform: egl.EGLenum, remote_display: ?*c_void, config_attribs: *egl.EGLint, visual_id: egl.EGLint) ?*Renderer;
    extern fn wlr_renderer_begin(r: *Renderer, width: c_int, height: c_int) void;
    extern fn wlr_renderer_end(r: *Renderer) void;
    extern fn wlr_renderer_clear(r: *Renderer, color: *const [4]f32) void;
    extern fn wlr_renderer_scissor(r: *Renderer, box: ?*const wlroots.Box) void;
    extern fn wlr_render_texture(r: *Renderer, texture: *wlroots.Texture, projection: *const [9]f32, x: c_int, y: c_int, alpha: f32) bool;
    extern fn wlr_render_texture_with_matrix(r: *Renderer, texture: *wlroots.Texture, matrix: *const [9]f32, alpha: f32) bool;
    extern fn wlr_render_subtexture_with_matrix(r: *Renderer, texture: *wlroots.Texture, box: *const wlroots.FBox, matrix: *const [9]f32, alpha: f32) bool;
    extern fn wlr_render_rect(r: *Renderer, box: *const wlroots.Box, color: *const [4]f32, projection: *const [9]f32) void;
    extern fn wlr_render_quad_with_matrix(r: *Renderer, color: *const [4]f32, matrix: *const [9]f32) void;
    extern fn wlr_render_ellipse(r: *Renderer, box: *const wlroots.Box, color: *const [4]f32, projection: *const [9]f32) void;
    extern fn wlr_render_ellipse_with_matrix(r: *Renderer, color: *const [4]f32, matrix: *const [9]f32) void;
    extern fn wlr_renderer_get_formats(r: *Renderer, len: *usize) [*]const wayland.struct_wl_shm.enum_wl_shm_format;
    extern fn wlr_renderer_resource_is_wl_drm_buffer(renderer: *Renderer, buffer: *wayland.Resource) bool;
    extern fn wlr_renderer_wl_drm_buffer_get_size(renderer: *Renderer, buffer: *wayland.Resource, width: *c_int, height: *c_int) void;
    extern fn wlr_renderer_get_dmabuf_formats(renderer: *Renderer) *const wlroots.struct_wlr_drm_format_set;
    extern fn wlr_renderer_read_pixels(r: *Renderer, fmt: wayland.struct_wl_shm.enum_wl_shm_format, flags: ?*u32, stride: u32, width: u32, height: u32, src_x: u32, src_y: u32, dst_x: u32, dst_y: u32, data: ?*c_void) bool;
    extern fn wlr_renderer_blit_dmabuf(r: *Renderer, dst: *wlroots.DmabufAttributes, src: *wlroots.DmabufAttributes) bool;
    extern fn wlr_renderer_format_supported(r: *Renderer, fmt: wayland.struct_wl_shm.enum_wl_shm_format) bool;
    extern fn wlr_renderer_init_wl_display(r: *Renderer, wl_display: *wayland.Display) bool;
    extern fn wlr_renderer_destroy(renderer: *Renderer) void;

    pub const wlr_renderer_create_func_t = fn (*wlroots.EGL, egl.EGLenum, ?*c_void, *egl.EGLint, egl.EGLint) callconv(.C) ?*Renderer;

    impl: ?*const Impl,
    rendering: bool,
    events: extern struct {
        destroy: wayland.Signal(?*c_void),
    },

    pub fn initDisplay(renderer: *Renderer, dsp: *wayland.Display) !void {
        if (!wlr_renderer_init_wl_display(renderer, dsp)) {
            return error.Failure;
        }
    }

    pub fn autocreate(_egl: *wlroots.EGL, platform: egl.EGLenum, remote_display: ?*c_void, config_attribs: *egl.EGLint, visual_id: egl.EGLint) !*Renderer {
        return wlr_renderer_autocreate(_egl, platform, remote_display, config_attribs, visual_id) orelse error.Failure;
    }

    pub fn renderTextureWithMatrix(r: *Renderer, texture: *wlroots.Texture, matrix: wlroots.Matrix, alpha: f32) !void {
        if (!r.wlr_render_texture_with_matrix(texture, matrix.linear(), alpha)) {
            return error.Failure;
        }
    }

    pub fn renderSubtextureWithMatrix(r: *Renderer, texture: *wlroots.Texture, box: wlroots.FBox, matrix: wlroots.Matrix, alpha: f32) !void {
        if (!r.wlr_render_subtexture_with_matrix(texture, &box, matrix.linear(), alpha)) {
            return error.Failure;
        }
    }

    pub fn getFormats(r: *Renderer) []const wayland.struct_wl_shm.enum_wl_shm_format {
        var len: usize = undefined;
        const ptr = r.wlr_renderer_get_formats(&len);
        return ptr[0..len];
    }

    pub fn clear(r: *Renderer, color: [4]f32) void {
        r.wlr_renderer_clear(&color);
    }

    pub fn renderTexture(r: *Renderer, texture: *wlroots.Texture, projection: wlroots.Matrix, x: c_int, y: c_int, alpha: f32) !void {
        if (!r.wlr_render_texture(texture, projection.linear(), x, y, alpha)) {
            return error.Failure;
        }
    }

    pub fn renderRect(r: *Renderer, box: wlroots.Box, color: [4]f32, projection: wlroots.Matrix) void {
        r.wlr_render_rect(&box, &color, projection.linear());
    }

    pub fn renderQuadWithMatrix(r: *Renderer, color: [4]f32, matrix: wlroots.Matrix) void {
        r.wlr_render_quad_with_matrix(&color, matrix.linear());
    }

    pub fn renderEllipse(r: *Renderer, box: wlroots.Box, color: [4]f32, projection: wlroots.Matrix) void {
        r.wlr_render_ellipse(&box, &color, projection.linear());
    }

    pub fn renderEllipseWithMatrix(r: *Renderer, color: [4]f32, matrix: wlroots.Matrix) void {
        r.wlr_render_ellipse_with_matrix(&color, matrix.linear());
    }

    pub fn scissor(r: *Renderer, box: wlroots.Box) void {
        r.wlr_renderer_scissor(&box);
    }

    pub const begin = wlr_renderer_begin;
    pub const end = wlr_renderer_end;
    pub const resourceIsWlDrmBuffer = wlr_renderer_resource_is_wl_drm_buffer;
    pub const wlDrmBufferGetSize = wlr_renderer_wl_drm_buffer_get_size;
    pub const getDmabufFormats = wlr_renderer_get_dmabuf_formats;
    pub const readPixels = wlr_renderer_read_pixels;
    pub const blitDmabuf = wlr_renderer_blit_dmabuf;
    pub const formatSupported = wlr_renderer_format_supported;
    pub const initWlDisplay = wlr_renderer_init_wl_display;
    pub const destroy = wlr_renderer_destroy;
};
