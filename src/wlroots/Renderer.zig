const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");
const egl = @import("../egl.zig");

/// struct wlr_renderer
pub const Renderer = extern struct {
    /// struct wlr_renderer_impl
    pub const struct_wlr_renderer_impl = opaque {};

    /// enum wlr_renderer_read_pixels_flags
    pub const enum_wlr_renderer_read_pixels_flags = extern enum(c_int) {
        WLR_RENDERER_READ_PIXELS_Y_INVERT = 1,
        _,
    };

    pub extern fn wlr_renderer_autocreate(egl: [*c]wlroots.struct_wlr_egl, platform: egl.EGLenum, remote_display: ?*c_void, config_attribs: [*c]egl.EGLint, visual_id: egl.EGLint) [*c]Renderer;
    pub extern fn wlr_renderer_begin(r: *Renderer, width: c_int, height: c_int) void;
    pub extern fn wlr_renderer_end(r: *Renderer) void;
    pub extern fn wlr_renderer_clear(r: *Renderer, color: *const [4]f32) void;
    pub extern fn wlr_renderer_scissor(r: *Renderer, box: [*c]Box) void;
    pub extern fn wlr_render_texture(r: *Renderer, texture: [*c]wlroots.Texture, projection: [*c]const f32, x: c_int, y: c_int, alpha: f32) bool;
    pub extern fn wlr_render_texture_with_matrix(r: *Renderer, texture: [*c]wlroots.Texture, matrix: *const [9]f32, alpha: f32) bool;
    pub extern fn wlr_render_subtexture_with_matrix(r: *Renderer, texture: [*c]wlroots.Texture, box: [*c]const FBox, matrix: *const [9]f32, alpha: f32) bool;
    pub extern fn wlr_render_rect(r: *Renderer, box: [*c]const Box, color: *const [4]f32, projection: [*c]const f32) void;
    pub extern fn wlr_render_quad_with_matrix(r: *Renderer, color: *const [4]f32, matrix: *const [9]f32) void;
    pub extern fn wlr_render_ellipse(r: *Renderer, box: [*c]const Box, color: *const [4]f32, projection: [*c]const f32) void;
    pub extern fn wlr_render_ellipse_with_matrix(r: *Renderer, color: *const [4]f32, matrix: *const [9]f32) void;
    pub extern fn wlr_renderer_get_formats(r: *Renderer, len: [*c]usize) [*c]const enum_wl_shm_format;
    pub extern fn wlr_renderer_resource_is_wl_drm_buffer(renderer: *Renderer, buffer: [*c]wayland.Resource) bool;
    pub extern fn wlr_renderer_wl_drm_buffer_get_size(renderer: *Renderer, buffer: [*c]wayland.Resource, width: [*c]c_int, height: [*c]c_int) void;
    pub extern fn wlr_renderer_get_dmabuf_formats(renderer: *Renderer) [*c]const struct_wlr_drm_format_set;
    pub extern fn wlr_renderer_read_pixels(r: *Renderer, fmt: enum_wl_shm_format, flags: [*c]u32, stride: u32, width: u32, height: u32, src_x: u32, src_y: u32, dst_x: u32, dst_y: u32, data: ?*c_void) bool;
    pub extern fn wlr_renderer_blit_dmabuf(r: *Renderer, dst: [*c]struct_wlr_dmabuf_attributes, src: [*c]struct_wlr_dmabuf_attributes) bool;
    pub extern fn wlr_renderer_format_supported(r: *Renderer, fmt: enum_wl_shm_format) bool;
    pub extern fn wlr_renderer_init_wl_display(r: *Renderer, wl_display: ?*wayland.Display) bool;
    pub extern fn wlr_renderer_destroy(renderer: *Renderer) void;

    pub const wlr_renderer_create_func_t = ?fn ([*c]wlroots.struct_wlr_egl, egl.EGLenum, ?*c_void, [*c]egl.EGLint, egl.EGLint) callconv(.C) [*c]Renderer;

    impl: ?*const struct_wlr_renderer_impl,
    rendering: bool,
    events: extern struct {
        destroy: wayland.Signal(?*c_void),
    },

    pub fn initDisplay(renderer: *Renderer, dsp: *wayland.Display) !void {
        if (!wlr_renderer_init_wl_display(renderer, dsp)) {
            return error.Failure;
        }
    }

    pub const begin = wlr_renderer_begin;
    pub const clear = wlr_renderer_clear;
    pub const end = wlr_renderer_end;

    pub fn renderTextureWithMatrix(renderer: *Renderer, tex: *wlroots.Texture, m: wlroots.Matrix, alpha: f32) !void {
        if (!wlr_render_texture_with_matrix(renderer, tex, @ptrCast(*const [9]f32, &m.data), alpha)) {
            return error.Failure;
        }
    }
};
