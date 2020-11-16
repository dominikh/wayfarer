const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_client_buffer
pub const ClientBuffer = extern struct {
    pub extern fn wlr_client_buffer_apply_damage(buffer: [*c]ClientBuffer, resource: [*c]wayland.Resource, damage: [*c]pixman.pixman_region32_t) [*c]ClientBuffer;
    pub extern fn wlr_client_buffer_import(renderer: *wlroots.Renderer, resource: [*c]wayland.Resource) [*c]ClientBuffer;

    base: wlroots.Buffer,
    resource: [*c]wayland.Resource,
    resource_released: bool,
    texture: [*c]wlroots.Texture,
    resource_destroy: wayland.Listener(?*c_void),
    release: wayland.Listener(?*c_void),
};
