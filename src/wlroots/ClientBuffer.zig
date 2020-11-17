const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");
const pixman = @import("../pixman.zig");

/// struct wlr_client_buffer
pub const ClientBuffer = extern struct {
    extern fn wlr_client_buffer_apply_damage(buffer: *ClientBuffer, resource: *wayland.Resource, damage: *pixman.pixman_region32_t) ?*ClientBuffer;
    extern fn wlr_client_buffer_import(renderer: *wlroots.Renderer, resource: [*c]wayland.Resource) *ClientBuffer;

    base: wlroots.Buffer,
    resource: [*c]wayland.Resource,
    resource_released: bool,
    texture: [*c]wlroots.Texture,
    resource_destroy: wayland.Listener(?*c_void),
    release: wayland.Listener(?*c_void),

    pub fn applyDamage(buffer: *ClientBuffer, resource: *wayland.Resource, damage: *pixman.pixman_region32_t) !*ClientBuffer {
        if (buffer.wlr_client_buffer_apply_damage(resource, damage)) |ret| {
            return ret;
        } else {
            return error.Failure;
        }
    }

    pub const import = wlr_client_buffer_import;
};
