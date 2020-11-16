const wayland = @import("../wayland.zig");
usingnamespace @import("../pixman.zig");
const wlroots = @import("../wlroots.zig");
const std = @import("std");

/// struct wlr_surface
pub const Surface = extern struct {
    pub extern fn wlr_surface_is_subsurface(surface: [*c]Surface) bool;
    pub extern fn wlr_surface_create(client: ?*wayland.Client, version: u32, id: u32, renderer: *wlroots.Renderer, resource_list: [*c]wayland.struct_wl_list) [*c]Surface;
    pub extern fn wlr_surface_set_role(surface: [*c]Surface, role: [*c]const Role, role_data: ?*c_void, error_resource: [*c]wayland.Resource, error_code: u32) bool;
    pub extern fn wlr_surface_has_buffer(surface: [*c]Surface) bool;
    pub extern fn wlr_surface_get_texture(surface: [*c]Surface) [*c]wlroots.Texture;
    pub extern fn wlr_surface_get_root_surface(surface: [*c]Surface) [*c]Surface;
    pub extern fn wlr_surface_point_accepts_input(surface: [*c]Surface, sx: f64, sy: f64) bool;
    pub extern fn wlr_surface_surface_at(surface: [*c]Surface, sx: f64, sy: f64, sub_x: [*c]f64, sub_y: [*c]f64) [*c]Surface;
    pub extern fn wlr_surface_send_enter(surface: [*c]Surface, output: [*c]Output) void;
    pub extern fn wlr_surface_send_leave(surface: [*c]Surface, output: [*c]Output) void;
    pub extern fn wlr_surface_send_frame_done(surface: [*c]Surface, when: [*c]const std.os.timespec) void;
    pub extern fn wlr_surface_get_extends(surface: [*c]Surface, box: [*c]wlroots.Box) void;
    pub extern fn wlr_surface_from_resource(resource: [*c]wayland.Resource) [*c]Surface;
    pub extern fn wlr_surface_for_each_surface(surface: [*c]Surface, iterator: IteratorFunc, user_data: ?*c_void) void;
    pub extern fn wlr_surface_get_effective_damage(surface: [*c]Surface, damage: [*c]pixman_region32_t) void;
    pub extern fn wlr_surface_get_buffer_source_box(surface: [*c]Surface, box: [*c]Fwlroots.Box) void;
    pub extern fn wlr_surface_accepts_touch(wlr_seat: *Seat, surface: [*c]Surface) bool;
    pub extern fn wlr_surface_is_xdg_surface(surface: [*c]Surface) bool;

    /// enum wlr_surface_state_field
    pub const enum_wlr_surface_state_field = extern enum(c_int) {
        WLR_SURFACE_STATE_BUFFER = 1,
        WLR_SURFACE_STATE_SURFACE_DAMAGE = 2,
        WLR_SURFACE_STATE_BUFFER_DAMAGE = 4,
        WLR_SURFACE_STATE_OPAQUE_REGION = 8,
        WLR_SURFACE_STATE_INPUT_REGION = 16,
        WLR_SURFACE_STATE_TRANSFORM = 32,
        WLR_SURFACE_STATE_SCALE = 64,
        WLR_SURFACE_STATE_FRAME_CALLBACK_LIST = 128,
        WLR_SURFACE_STATE_VIEWPORT = 256,
        _,
    };

    /// wlr_surface_iterator_func_t
    pub const IteratorFunc = fn (*Surface, c_int, c_int, ?*c_void) callconv(.C) void;

    /// struct wlr_surface_state
    pub const State = extern struct {
        committed: u32,
        buffer_resource: [*c]wayland.Resource,
        dx: i32,
        dy: i32,
        surface_damage: pixman_region32_t,
        buffer_damage: pixman_region32_t,
        @"opaque": pixman_region32_t,
        input: pixman_region32_t,
        transform: wayland.Output.Transform,
        scale: i32,
        frame_callback_list: wayland.List(wayland.Resource, "link"),
        width: c_int,
        height: c_int,
        buffer_width: c_int,
        buffer_height: c_int,
        viewport: extern struct {
            has_src: bool,
            has_dst: bool,
            src: wlroots.FBox,
            dst_width: c_int,
            dst_height: c_int,
        },
        buffer_destroy: wayland.Listener(?*c_void),
    };

    /// struct wlr_surface_role
    pub const Role = extern struct {
        name: [*:0]const u8,
        commit: ?fn ([*c]Surface) callconv(.C) void,
        precommit: ?fn ([*c]Surface) callconv(.C) void,
    };

    resource: [*c]wayland.Resource,
    renderer: *wlroots.Renderer,
    buffer: [*c]wlroots.ClientBuffer,
    sx: c_int,
    sy: c_int,
    buffer_damage: pixman_region32_t,
    opaque_region: pixman_region32_t,
    input_region: pixman_region32_t,
    current: State,
    pending: State,
    previous: State,
    role: [*c]const Role,
    role_data: ?*c_void,
    events: extern struct {
        commit: wayland.Signal(?*c_void),
        new_subsurface: wayland.Signal(?*c_void),
        destroy: wayland.Signal(?*c_void),
    },
    subsurfaces: wayland.List(wlroots.Subsurface, "parent_link"),
    subsurface_pending_list: wayland.List(wlroots.Subsurface, "parent_pending_link"),
    renderer_destroy: wayland.Listener(?*c_void),
    data: ?*c_void,
};
