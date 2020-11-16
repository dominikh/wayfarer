const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_texture
pub const Texture = extern struct {
    /// struct wlr_texture_impl
    pub const Impl = opaque {};

    impl: ?*const Impl,
    width: u32,
    height: u32,

    pub extern fn wlr_texture_from_pixels(renderer: *wlroots.Renderer, wl_fmt: wayland.enum_wl_shm_format, stride: u32, width: u32, height: u32, data: ?*const c_void) [*c]Texture;
    pub extern fn wlr_texture_from_wl_drm(renderer: *wlroots.Renderer, data: [*c]wayland.Resource) [*c]Texture;
    pub extern fn wlr_texture_from_dmabuf(renderer: *wlroots.Renderer, attribs: [*c]DmabufAttributes) [*c]Texture;
    pub extern fn wlr_texture_get_size(texture: *Texture, width: *c_int, height: *c_int) void;
    pub extern fn wlr_texture_is_opaque(texture: *Texture) bool;
    pub extern fn wlr_texture_write_pixels(texture: *Texture, stride: u32, width: u32, height: u32, src_x: u32, src_y: u32, dst_x: u32, dst_y: u32, data: ?*const c_void) bool;
    pub extern fn wlr_texture_to_dmabuf(texture: *Texture, attribs: [*c]wlroots.DmabufAttributes) bool;
    pub extern fn wlr_texture_destroy(texture: *Texture) void;
};
