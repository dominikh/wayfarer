const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_texture
pub const Texture = extern struct {
    /// struct wlr_texture_impl
    pub const Impl = opaque {};

    impl: ?*const Impl,
    width: u32,
    height: u32,

    extern fn wlr_texture_from_pixels(renderer: *wlroots.Renderer, wl_fmt: wayland.enum_wl_shm_format, stride: u32, width: u32, height: u32, data: ?*const c_void) ?*Texture;
    extern fn wlr_texture_from_wl_drm(renderer: *wlroots.Renderer, data: *wayland.Resource) ?*Texture;
    extern fn wlr_texture_from_dmabuf(renderer: *wlroots.Renderer, attribs: *DmabufAttributes) ?*Texture;
    extern fn wlr_texture_get_size(texture: *Texture, width: *c_int, height: *c_int) void;
    extern fn wlr_texture_is_opaque(texture: *Texture) bool;
    extern fn wlr_texture_write_pixels(texture: *Texture, stride: u32, width: u32, height: u32, src_x: u32, src_y: u32, dst_x: u32, dst_y: u32, data: ?*const c_void) bool;
    extern fn wlr_texture_to_dmabuf(texture: *Texture, attribs: *wlroots.DmabufAttributes) bool;
    extern fn wlr_texture_destroy(texture: *Texture) void;

    pub fn fromPixels(renderer: *wlroots.Renderer, wl_fmt: wayland.enum_wl_shm_format, stride: u32, width: u32, height: u32, data: ?*const c_void) !*Texture {
        return renderer.wlr_texture_from_pixels(wl_fmt, stride, width, height, data) orelse error.Failure;
    }

    pub fn fromWlDrm(renderer: *wlroots.Renderer, data: [*c]wayland.Resource) !*Texture {
        return renderer.wlr_texture_from_wl_drm(data) orelse error.Failure;
    }

    pub fn fromDmabuf(renderer: *wlroots.Renderer, attribs: *DmabufAttributes) !*Texture {
        return renderer.wlr_texture_from_dmabuf(attribs) orelse error.Failure;
    }

    pub fn writePixels(texture: *Texture, stride: u32, width: u32, height: u32, src_x: u32, src_y: u32, dst_x: u32, dst_y: u32, data: ?*const c_void) !void {
        return renderer.wlr_texture_write_pixels(stride, width, height, src_x, src_y, dst_x, dst_y, data) orelse error.Failure;
    }

    pub fn toDmabuf(texture: *Texture, attribs: *wlroots.DmabufAttributes) !void {
        return renderer.wlr_texture_to_dmabuf(attribs) orelse error.Failure;
    }

    pub const getSize = wlr_texture_get_size;
    pub const isOpaque = wlr_texture_is_opaque;
    pub const destroy = wlr_texture_destroy;
};
