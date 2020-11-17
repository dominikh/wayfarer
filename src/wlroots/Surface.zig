const wayland = @import("../wayland.zig");
usingnamespace @import("../pixman.zig");
const wlroots = @import("../wlroots.zig");
const std = @import("std");

/// struct wlr_surface
pub const Surface = extern struct {
    extern fn wlr_surface_is_subsurface(surface: *Surface) bool;
    extern fn wlr_surface_create(client: *wayland.Client, version: u32, id: u32, renderer: *wlroots.Renderer, resource_list: ?*wayland.List(wayland.Resource, "link")) ?*Surface;
    extern fn wlr_surface_set_role(surface: *Surface, role: *const Role, role_data: ?*c_void, error_resource: *wayland.Resource, error_code: u32) bool;
    extern fn wlr_surface_has_buffer(surface: *Surface) bool;
    extern fn wlr_surface_get_texture(surface: *Surface) ?*wlroots.Texture;
    extern fn wlr_surface_get_root_surface(surface: *Surface) *Surface;
    extern fn wlr_surface_point_accepts_input(surface: *Surface, sx: f64, sy: f64) bool;
    extern fn wlr_surface_surface_at(surface: *Surface, sx: f64, sy: f64, sub_x: *f64, sub_y: *f64) ?*Surface;
    extern fn wlr_surface_send_enter(surface: *Surface, output: *wlroots.Output) void;
    extern fn wlr_surface_send_leave(surface: *Surface, output: *wlroots.Output) void;
    extern fn wlr_surface_send_frame_done(surface: *Surface, when: *const std.os.timespec) void;
    extern fn wlr_surface_get_extends(surface: *Surface, box: *wlroots.Box) void;
    extern fn wlr_surface_from_resource(resource: *wayland.Resource) ?*Surface;
    extern fn wlr_surface_for_each_surface(surface: *Surface, iterator: IteratorFunc, user_data: ?*c_void) void;
    extern fn wlr_surface_get_effective_damage(surface: *Surface, damage: *pixman_region32_t) void;
    extern fn wlr_surface_get_buffer_source_box(surface: *Surface, box: *wlroots.FBox) void;
    extern fn wlr_surface_accepts_touch(wlr_seat: *wlroots.Seat, surface: *Surface) bool;
    extern fn wlr_surface_is_xdg_surface(surface: *Surface) bool;

    /// enum wlr_surface_state_field
    pub const StateField = struct {
        pub const WLR_SURFACE_STATE_BUFFER: c_int = 1;
        pub const WLR_SURFACE_STATE_SURFACE_DAMAGE: c_int = 2;
        pub const WLR_SURFACE_STATE_BUFFER_DAMAGE: c_int = 4;
        pub const WLR_SURFACE_STATE_OPAQUE_REGION: c_int = 8;
        pub const WLR_SURFACE_STATE_INPUT_REGION: c_int = 16;
        pub const WLR_SURFACE_STATE_TRANSFORM: c_int = 32;
        pub const WLR_SURFACE_STATE_SCALE: c_int = 64;
        pub const WLR_SURFACE_STATE_FRAME_CALLBACK_LIST: c_int = 128;
        pub const WLR_SURFACE_STATE_VIEWPORT: c_int = 256;
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

    pub fn init(client: *wayland.Client, version: u32, id: u32, renderer: *wlroots.Renderer, resource_list: ?*wayland.List(wayland.Resource, "link")) !*Surface {
        return wlr_surface_create(client, version, id, renderer, resource_list) orelse error.Failure;
    }

    pub const isSubsurface = wlr_surface_is_subsurface;
    pub const setRole = wlr_surface_set_role;
    pub const hasBuffer = wlr_surface_has_buffer;
    pub const getTexture = wlr_surface_get_texture;
    pub const getRootSurface = wlr_surface_get_root_surface;
    pub const pointAcceptsInput = wlr_surface_point_accepts_input;
    pub const surfaceAt = wlr_surface_surface_at;
    pub const sendEnter = wlr_surface_send_enter;
    pub const sendLeave = wlr_surface_send_leave;
    pub const sendFrameDone = wlr_surface_send_frame_done;
    pub const getExtends = wlr_surface_get_extends;
    pub const fromResource = wlr_surface_from_resource;
    pub const forEachSurface = wlr_surface_for_each_surface;
    pub const getEffectiveDamage = wlr_surface_get_effective_damage;
    pub const getBufferSourceBox = wlr_surface_get_buffer_source_box;
    pub const acceptsTouch = wlr_surface_accepts_touch;
    pub const isXdgSurface = wlr_surface_is_xdg_surface;
};
