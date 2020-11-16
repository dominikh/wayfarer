const std = @import("std");

fn TypeOfField(comptime T: type, comptime field: []const u8) type {
    return std.meta.fieldInfo(T, field).field_type;
}

pub const struct_wl_array = extern struct {
    size: usize,
    alloc: usize,
    data: ?*c_void,
};

pub extern fn wl_display_add_global(display: ?*Display, interface: [*c]const Interface, data: ?*c_void, bind: wl_global_bind_func_t) ?*Global;
pub extern fn wl_display_remove_global(display: ?*Display, global: ?*Global) void;
pub extern fn wl_shm_buffer_get(resource: [*c]Resource) ?*struct_wl_shm_buffer;
pub extern fn wl_shm_buffer_begin_access(buffer: ?*struct_wl_shm_buffer) void;
pub extern fn wl_shm_buffer_end_access(buffer: ?*struct_wl_shm_buffer) void;
pub extern fn wl_shm_buffer_get_data(buffer: ?*struct_wl_shm_buffer) ?*c_void;
pub extern fn wl_shm_buffer_get_stride(buffer: ?*struct_wl_shm_buffer) i32;
pub extern fn wl_shm_buffer_get_format(buffer: ?*struct_wl_shm_buffer) u32;
pub extern fn wl_shm_buffer_get_width(buffer: ?*struct_wl_shm_buffer) i32;
pub extern fn wl_shm_buffer_get_height(buffer: ?*struct_wl_shm_buffer) i32;
pub extern fn wl_shm_buffer_ref_pool(buffer: ?*struct_wl_shm_buffer) ?*struct_wl_shm_pool;
pub extern fn wl_shm_pool_unref(pool: ?*struct_wl_shm_pool) void;
pub extern fn wl_shm_buffer_create(client: ?*Client, id: u32, width: i32, height: i32, stride: i32, format: u32) ?*struct_wl_shm_buffer;
pub extern fn wl_log_set_handler_server(handler: wl_log_func_t) void;
pub extern fn wl_protocol_logger_destroy(logger: ?*struct_wl_protocol_logger) void;

pub fn wl_registry_send_global(arg_resource_: [*c]Resource, arg_name: u32, arg_interface: [*c]const u8, arg_version: u32) callconv(.C) void {
    var resource_ = arg_resource_;
    var name = arg_name;
    var interface = arg_interface;
    var version = arg_version;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 0)), name, interface, version);
}
pub fn wl_registry_send_global_remove(arg_resource_: [*c]Resource, arg_name: u32) callconv(.C) void {
    var resource_ = arg_resource_;
    var name = arg_name;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 1)), name);
}
pub fn wl_shm_send_format(arg_resource_: [*c]Resource, arg_format: u32) callconv(.C) void {
    var resource_ = arg_resource_;
    var format = arg_format;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 0)), format);
}
pub fn wl_buffer_send_release(arg_resource_: [*c]Resource) callconv(.C) void {
    var resource_ = arg_resource_;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 0)));
}
pub fn wl_data_offer_send_offer(arg_resource_: [*c]Resource, arg_mime_type: [*c]const u8) callconv(.C) void {
    var resource_ = arg_resource_;
    var mime_type = arg_mime_type;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 0)), mime_type);
}
pub fn wl_data_offer_send_source_actions(arg_resource_: [*c]Resource, arg_source_actions: u32) callconv(.C) void {
    var resource_ = arg_resource_;
    var source_actions = arg_source_actions;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 1)), source_actions);
}
pub fn wl_data_offer_send_action(arg_resource_: [*c]Resource, arg_dnd_action: u32) callconv(.C) void {
    var resource_ = arg_resource_;
    var dnd_action = arg_dnd_action;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 2)), dnd_action);
}
pub fn wl_data_source_send_target(arg_resource_: [*c]Resource, arg_mime_type: [*c]const u8) callconv(.C) void {
    var resource_ = arg_resource_;
    var mime_type = arg_mime_type;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 0)), mime_type);
}
pub fn wl_data_source_send_send(arg_resource_: [*c]Resource, arg_mime_type: [*c]const u8, arg_fd: i32) callconv(.C) void {
    var resource_ = arg_resource_;
    var mime_type = arg_mime_type;
    var fd = arg_fd;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 1)), mime_type, fd);
}
pub fn wl_data_source_send_cancelled(arg_resource_: [*c]Resource) callconv(.C) void {
    var resource_ = arg_resource_;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 2)));
}
pub fn wl_data_source_send_dnd_drop_performed(arg_resource_: [*c]Resource) callconv(.C) void {
    var resource_ = arg_resource_;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 3)));
}
pub fn wl_data_source_send_dnd_finished(arg_resource_: [*c]Resource) callconv(.C) void {
    var resource_ = arg_resource_;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 4)));
}
pub fn wl_data_source_send_action(arg_resource_: [*c]Resource, arg_dnd_action: u32) callconv(.C) void {
    var resource_ = arg_resource_;
    var dnd_action = arg_dnd_action;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 5)), dnd_action);
}
pub fn wl_data_device_send_data_offer(arg_resource_: [*c]Resource, arg_id: [*c]Resource) callconv(.C) void {
    var resource_ = arg_resource_;
    var id = arg_id;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 0)), id);
}
pub fn wl_data_device_send_enter(arg_resource_: [*c]Resource, arg_serial: u32, arg_surface: [*c]Resource, arg_x: wl_fixed_t, arg_y: wl_fixed_t, arg_id: [*c]Resource) callconv(.C) void {
    var resource_ = arg_resource_;
    var serial = arg_serial;
    var surface = arg_surface;
    var x = arg_x;
    var y = arg_y;
    var id = arg_id;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 1)), serial, surface, x, y, id);
}
pub fn wl_data_device_send_leave(arg_resource_: [*c]Resource) callconv(.C) void {
    var resource_ = arg_resource_;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 2)));
}
pub fn wl_data_device_send_motion(arg_resource_: [*c]Resource, arg_time_1: u32, arg_x: wl_fixed_t, arg_y: wl_fixed_t) callconv(.C) void {
    var resource_ = arg_resource_;
    var time_1 = arg_time_1;
    var x = arg_x;
    var y = arg_y;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 3)), time_1, x, y);
}
pub fn wl_data_device_send_drop(arg_resource_: [*c]Resource) callconv(.C) void {
    var resource_ = arg_resource_;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 4)));
}
pub fn wl_data_device_send_selection(arg_resource_: [*c]Resource, arg_id: [*c]Resource) callconv(.C) void {
    var resource_ = arg_resource_;
    var id = arg_id;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 5)), id);
}
pub fn wl_shell_surface_send_ping(arg_resource_: [*c]Resource, arg_serial: u32) callconv(.C) void {
    var resource_ = arg_resource_;
    var serial = arg_serial;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 0)), serial);
}
pub fn wl_shell_surface_send_configure(arg_resource_: [*c]Resource, arg_edges: u32, arg_width: i32, arg_height: i32) callconv(.C) void {
    var resource_ = arg_resource_;
    var edges = arg_edges;
    var width = arg_width;
    var height = arg_height;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 1)), edges, width, height);
}
pub fn wl_shell_surface_send_popup_done(arg_resource_: [*c]Resource) callconv(.C) void {
    var resource_ = arg_resource_;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 2)));
}
pub fn wl_pointer_send_enter(arg_resource_: [*c]Resource, arg_serial: u32, arg_surface: [*c]Resource, arg_surface_x: wl_fixed_t, arg_surface_y: wl_fixed_t) callconv(.C) void {
    var resource_ = arg_resource_;
    var serial = arg_serial;
    var surface = arg_surface;
    var surface_x = arg_surface_x;
    var surface_y = arg_surface_y;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 0)), serial, surface, surface_x, surface_y);
}
pub fn wl_pointer_send_leave(arg_resource_: [*c]Resource, arg_serial: u32, arg_surface: [*c]Resource) callconv(.C) void {
    var resource_ = arg_resource_;
    var serial = arg_serial;
    var surface = arg_surface;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 1)), serial, surface);
}
pub fn wl_pointer_send_motion(arg_resource_: [*c]Resource, arg_time_1: u32, arg_surface_x: wl_fixed_t, arg_surface_y: wl_fixed_t) callconv(.C) void {
    var resource_ = arg_resource_;
    var time_1 = arg_time_1;
    var surface_x = arg_surface_x;
    var surface_y = arg_surface_y;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 2)), time_1, surface_x, surface_y);
}
pub fn wl_pointer_send_button(arg_resource_: [*c]Resource, arg_serial: u32, arg_time_1: u32, arg_button: u32, arg_state: u32) callconv(.C) void {
    var resource_ = arg_resource_;
    var serial = arg_serial;
    var time_1 = arg_time_1;
    var button = arg_button;
    var state = arg_state;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 3)), serial, time_1, button, state);
}
pub fn wl_pointer_send_axis(arg_resource_: [*c]Resource, arg_time_1: u32, arg_axis: u32, arg_value: wl_fixed_t) callconv(.C) void {
    var resource_ = arg_resource_;
    var time_1 = arg_time_1;
    var axis = arg_axis;
    var value = arg_value;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 4)), time_1, axis, value);
}
pub fn wl_pointer_send_frame(arg_resource_: [*c]Resource) callconv(.C) void {
    var resource_ = arg_resource_;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 5)));
}
pub fn wl_pointer_send_axis_source(arg_resource_: [*c]Resource, arg_axis_source: u32) callconv(.C) void {
    var resource_ = arg_resource_;
    var axis_source = arg_axis_source;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 6)), axis_source);
}
pub fn wl_pointer_send_axis_stop(arg_resource_: [*c]Resource, arg_time_1: u32, arg_axis: u32) callconv(.C) void {
    var resource_ = arg_resource_;
    var time_1 = arg_time_1;
    var axis = arg_axis;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 7)), time_1, axis);
}
pub fn wl_pointer_send_axis_discrete(arg_resource_: [*c]Resource, arg_axis: u32, arg_discrete: i32) callconv(.C) void {
    var resource_ = arg_resource_;
    var axis = arg_axis;
    var discrete = arg_discrete;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 8)), axis, discrete);
}
pub fn wl_keyboard_send_keymap(arg_resource_: [*c]Resource, arg_format: u32, arg_fd: i32, arg_size: u32) callconv(.C) void {
    var resource_ = arg_resource_;
    var format = arg_format;
    var fd = arg_fd;
    var size = arg_size;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 0)), format, fd, size);
}
pub fn wl_keyboard_send_enter(arg_resource_: [*c]Resource, arg_serial: u32, arg_surface: [*c]Resource, arg_keys: [*c]struct_wl_array) callconv(.C) void {
    var resource_ = arg_resource_;
    var serial = arg_serial;
    var surface = arg_surface;
    var keys = arg_keys;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 1)), serial, surface, keys);
}
pub fn wl_keyboard_send_leave(arg_resource_: [*c]Resource, arg_serial: u32, arg_surface: [*c]Resource) callconv(.C) void {
    var resource_ = arg_resource_;
    var serial = arg_serial;
    var surface = arg_surface;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 2)), serial, surface);
}
pub fn wl_keyboard_send_key(arg_resource_: [*c]Resource, arg_serial: u32, arg_time_1: u32, arg_key: u32, arg_state: u32) callconv(.C) void {
    var resource_ = arg_resource_;
    var serial = arg_serial;
    var time_1 = arg_time_1;
    var key = arg_key;
    var state = arg_state;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 3)), serial, time_1, key, state);
}
pub fn wl_keyboard_send_modifiers(arg_resource_: [*c]Resource, arg_serial: u32, arg_mods_depressed: u32, arg_mods_latched: u32, arg_mods_locked: u32, arg_group: u32) callconv(.C) void {
    var resource_ = arg_resource_;
    var serial = arg_serial;
    var mods_depressed = arg_mods_depressed;
    var mods_latched = arg_mods_latched;
    var mods_locked = arg_mods_locked;
    var group = arg_group;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 4)), serial, mods_depressed, mods_latched, mods_locked, group);
}
pub fn wl_keyboard_send_repeat_info(arg_resource_: [*c]Resource, arg_rate: i32, arg_delay: i32) callconv(.C) void {
    var resource_ = arg_resource_;
    var rate = arg_rate;
    var delay = arg_delay;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 5)), rate, delay);
}
pub fn wl_touch_send_down(arg_resource_: [*c]Resource, arg_serial: u32, arg_time_1: u32, arg_surface: [*c]Resource, arg_id: i32, arg_x: wl_fixed_t, arg_y: wl_fixed_t) callconv(.C) void {
    var resource_ = arg_resource_;
    var serial = arg_serial;
    var time_1 = arg_time_1;
    var surface = arg_surface;
    var id = arg_id;
    var x = arg_x;
    var y = arg_y;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 0)), serial, time_1, surface, id, x, y);
}
pub fn wl_touch_send_up(arg_resource_: [*c]Resource, arg_serial: u32, arg_time_1: u32, arg_id: i32) callconv(.C) void {
    var resource_ = arg_resource_;
    var serial = arg_serial;
    var time_1 = arg_time_1;
    var id = arg_id;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 1)), serial, time_1, id);
}
pub fn wl_touch_send_motion(arg_resource_: [*c]Resource, arg_time_1: u32, arg_id: i32, arg_x: wl_fixed_t, arg_y: wl_fixed_t) callconv(.C) void {
    var resource_ = arg_resource_;
    var time_1 = arg_time_1;
    var id = arg_id;
    var x = arg_x;
    var y = arg_y;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 2)), time_1, id, x, y);
}
pub fn wl_touch_send_frame(arg_resource_: [*c]Resource) callconv(.C) void {
    var resource_ = arg_resource_;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 3)));
}
pub fn wl_touch_send_cancel(arg_resource_: [*c]Resource) callconv(.C) void {
    var resource_ = arg_resource_;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 4)));
}
pub fn wl_touch_send_shape(arg_resource_: [*c]Resource, arg_id: i32, arg_major_1: wl_fixed_t, arg_minor_2: wl_fixed_t) callconv(.C) void {
    var resource_ = arg_resource_;
    var id = arg_id;
    var major_1 = arg_major_1;
    var minor_2 = arg_minor_2;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 5)), id, major_1, minor_2);
}
pub fn wl_touch_send_orientation(arg_resource_: [*c]Resource, arg_id: i32, arg_orientation: wl_fixed_t) callconv(.C) void {
    var resource_ = arg_resource_;
    var id = arg_id;
    var orientation = arg_orientation;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 6)), id, orientation);
}
pub fn wl_output_send_geometry(arg_resource_: [*c]Resource, arg_x: i32, arg_y: i32, arg_physical_width: i32, arg_physical_height: i32, arg_subpixel: i32, arg_make: [*c]const u8, arg_model: [*c]const u8, arg_transform: i32) callconv(.C) void {
    var resource_ = arg_resource_;
    var x = arg_x;
    var y = arg_y;
    var physical_width = arg_physical_width;
    var physical_height = arg_physical_height;
    var subpixel = arg_subpixel;
    var make = arg_make;
    var model = arg_model;
    var transform = arg_transform;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 0)), x, y, physical_width, physical_height, subpixel, make, model, transform);
}
pub fn wl_output_send_mode(arg_resource_: [*c]Resource, arg_flags: u32, arg_width: i32, arg_height: i32, arg_refresh: i32) callconv(.C) void {
    var resource_ = arg_resource_;
    var flags = arg_flags;
    var width = arg_width;
    var height = arg_height;
    var refresh = arg_refresh;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 1)), flags, width, height, refresh);
}
pub fn wl_output_send_done(arg_resource_: [*c]Resource) callconv(.C) void {
    var resource_ = arg_resource_;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 2)));
}
pub fn wl_output_send_scale(arg_resource_: [*c]Resource, arg_factor: i32) callconv(.C) void {
    var resource_ = arg_resource_;
    var factor = arg_factor;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 3)), factor);
}
pub fn wl_fixed_to_int(arg_f: wl_fixed_t) callconv(.C) c_int {
    var f = arg_f;
    return @divTrunc(f, @as(c_int, 256));
}
pub fn wl_fixed_from_int(arg_i: c_int) callconv(.C) wl_fixed_t {
    var i = arg_i;
    return (i * @as(c_int, 256));
}
pub fn wl_signal_init(arg_signal: [*c]Signal(?*c_void)) callconv(.C) void {
    var signal = arg_signal;
    wl_list_init(&signal.*.listener_list);
}
pub fn wl_signal_add(arg_signal: [*c]Signal(?*c_void), arg_listener: [*c]wl.Listener(?*c_void)) callconv(.C) void {
    var signal = arg_signal;
    var listener = arg_listener;
    wl_list_insert(signal.*.listener_list.prev, &listener.*.link);
} // /nix/store/whnib2lxbpd9x8srzbfqyg6bkkyffy7r-zig-8b9195282e99427964119431b6f4e535eeb4d9ba/lib/zig/include/stddef.h:104:24: warning: TODO implement translation of stmt class OffsetOfExprClass

pub const enum_wl_subcompositor_error = extern enum(c_int) {
    WL_SUBCOMPOSITOR_ERROR_BAD_SURFACE = 0,
    _,
};
pub const struct_wl_subcompositor_interface = extern struct {
    destroy: ?fn (?*Client, [*c]Resource) callconv(.C) void,
    get_subsurface: ?fn (?*Client, [*c]Resource, u32, [*c]Resource, [*c]Resource) callconv(.C) void,
};

pub const struct_wl_buffer = opaque {};
pub extern const wl_display_interface: Interface;
pub extern const wl_registry_interface: Interface;
pub extern const wl_callback_interface: Interface;
pub extern const wl_compositor_interface: Interface;
pub extern const wl_shm_pool_interface: Interface;
pub extern const wl_shm_interface: Interface;
pub extern const wl_buffer_interface: Interface;
pub extern const wl_data_offer_interface: Interface;
pub extern const wl_data_source_interface: Interface;
pub extern const wl_data_device_interface: Interface;
pub extern const wl_data_device_manager_interface: Interface;
pub extern const wl_shell_interface: Interface;
pub extern const wl_shell_surface_interface: Interface;
pub extern const wl_surface_interface: Interface;
pub extern const wl_pointer_interface: Interface;
pub extern const wl_keyboard_interface: Interface;
pub extern const wl_touch_interface: Interface;
pub extern const wl_output_interface: Interface;
pub extern const wl_region_interface: Interface;
pub extern const wl_subcompositor_interface: Interface;
pub extern const wl_subsurface_interface: Interface;
pub const enum_wl_display_error = extern enum(c_int) {
    WL_DISPLAY_ERROR_INVALID_OBJECT = 0,
    WL_DISPLAY_ERROR_INVALID_METHOD = 1,
    WL_DISPLAY_ERROR_NO_MEMORY = 2,
    WL_DISPLAY_ERROR_IMPLEMENTATION = 3,
    _,
};
pub const struct_wl_display_interface = extern struct {
    sync: ?fn (?*Client, [*c]Resource, u32) callconv(.C) void,
    get_registry: ?fn (?*Client, [*c]Resource, u32) callconv(.C) void,
};
pub const struct_wl_registry_interface = extern struct {
    bind: ?fn (?*Client, [*c]Resource, u32, [*c]const u8, u32, u32) callconv(.C) void,
};
pub const struct_wl_shm_pool_interface = extern struct {
    create_buffer: ?fn (?*Client, [*c]Resource, u32, i32, i32, i32, i32, u32) callconv(.C) void,
    destroy: ?fn (?*Client, [*c]Resource) callconv(.C) void,
    resize: ?fn (?*Client, [*c]Resource, i32) callconv(.C) void,
};
pub const struct_wl_shm_interface = extern struct {
    create_pool: ?fn (?*Client, [*c]Resource, u32, i32, i32) callconv(.C) void,
};
pub const struct_wl_buffer_interface = extern struct {
    destroy: ?fn (?*Client, [*c]Resource) callconv(.C) void,
};
pub const enum_wl_data_offer_error = extern enum(c_int) {
    WL_DATA_OFFER_ERROR_INVALID_FINISH = 0,
    WL_DATA_OFFER_ERROR_INVALID_ACTION_MASK = 1,
    WL_DATA_OFFER_ERROR_INVALID_ACTION = 2,
    WL_DATA_OFFER_ERROR_INVALID_OFFER = 3,
    _,
};
pub const struct_wl_data_offer_interface = extern struct {
    accept: ?fn (?*Client, [*c]Resource, u32, [*c]const u8) callconv(.C) void,
    receive: ?fn (?*Client, [*c]Resource, [*c]const u8, i32) callconv(.C) void,
    destroy: ?fn (?*Client, [*c]Resource) callconv(.C) void,
    finish: ?fn (?*Client, [*c]Resource) callconv(.C) void,
    set_actions: ?fn (?*Client, [*c]Resource, u32, u32) callconv(.C) void,
};
pub const enum_wl_data_source_error = extern enum(c_int) {
    WL_DATA_SOURCE_ERROR_INVALID_ACTION_MASK = 0,
    WL_DATA_SOURCE_ERROR_INVALID_SOURCE = 1,
    _,
};
pub const struct_wl_data_source_interface = extern struct {
    offer: ?fn (?*Client, [*c]Resource, [*c]const u8) callconv(.C) void,
    destroy: ?fn (?*Client, [*c]Resource) callconv(.C) void,
    set_actions: ?fn (?*Client, [*c]Resource, u32) callconv(.C) void,
};
pub const enum_wl_data_device_error = extern enum(c_int) {
    WL_DATA_DEVICE_ERROR_ROLE = 0,
    _,
};
pub const struct_wl_data_device_interface = extern struct {
    start_drag: ?fn (?*Client, [*c]Resource, [*c]Resource, [*c]Resource, [*c]Resource, u32) callconv(.C) void,
    set_selection: ?fn (?*Client, [*c]Resource, [*c]Resource, u32) callconv(.C) void,
    release: ?fn (?*Client, [*c]Resource) callconv(.C) void,
};
pub const enum_wl_data_device_manager_dnd_action = extern enum(c_int) {
    WL_DATA_DEVICE_MANAGER_DND_ACTION_NONE = 0,
    WL_DATA_DEVICE_MANAGER_DND_ACTION_COPY = 1,
    WL_DATA_DEVICE_MANAGER_DND_ACTION_MOVE = 2,
    WL_DATA_DEVICE_MANAGER_DND_ACTION_ASK = 4,
    _,
};
pub const struct_wl_data_device_manager_interface = extern struct {
    create_data_source: ?fn (?*Client, [*c]Resource, u32) callconv(.C) void,
    get_data_device: ?fn (?*Client, [*c]Resource, u32, [*c]Resource) callconv(.C) void,
};
pub const enum_wl_shell_error = extern enum(c_int) {
    WL_SHELL_ERROR_ROLE = 0,
    _,
};
pub const struct_wl_shell_interface = extern struct {
    get_shell_surface: ?fn (?*Client, [*c]Resource, u32, [*c]Resource) callconv(.C) void,
};
pub const enum_wl_shell_surface_resize = extern enum(c_int) {
    WL_SHELL_SURFACE_RESIZE_NONE = 0,
    WL_SHELL_SURFACE_RESIZE_TOP = 1,
    WL_SHELL_SURFACE_RESIZE_BOTTOM = 2,
    WL_SHELL_SURFACE_RESIZE_LEFT = 4,
    WL_SHELL_SURFACE_RESIZE_TOP_LEFT = 5,
    WL_SHELL_SURFACE_RESIZE_BOTTOM_LEFT = 6,
    WL_SHELL_SURFACE_RESIZE_RIGHT = 8,
    WL_SHELL_SURFACE_RESIZE_TOP_RIGHT = 9,
    WL_SHELL_SURFACE_RESIZE_BOTTOM_RIGHT = 10,
    _,
};
pub const enum_wl_shell_surface_transient = extern enum(c_int) {
    WL_SHELL_SURFACE_TRANSIENT_INACTIVE = 1,
    _,
};
pub const enum_wl_shell_surface_fullscreen_method = extern enum(c_int) {
    WL_SHELL_SURFACE_FULLSCREEN_METHOD_DEFAULT = 0,
    WL_SHELL_SURFACE_FULLSCREEN_METHOD_SCALE = 1,
    WL_SHELL_SURFACE_FULLSCREEN_METHOD_DRIVER = 2,
    WL_SHELL_SURFACE_FULLSCREEN_METHOD_FILL = 3,
    _,
};
pub const struct_wl_shell_surface_interface = extern struct {
    pong: ?fn (?*Client, [*c]Resource, u32) callconv(.C) void,
    move: ?fn (?*Client, [*c]Resource, [*c]Resource, u32) callconv(.C) void,
    resize: ?fn (?*Client, [*c]Resource, [*c]Resource, u32, u32) callconv(.C) void,
    set_toplevel: ?fn (?*Client, [*c]Resource) callconv(.C) void,
    set_transient: ?fn (?*Client, [*c]Resource, [*c]Resource, i32, i32, u32) callconv(.C) void,
    set_fullscreen: ?fn (?*Client, [*c]Resource, u32, u32, [*c]Resource) callconv(.C) void,
    set_popup: ?fn (?*Client, [*c]Resource, [*c]Resource, u32, [*c]Resource, i32, i32, u32) callconv(.C) void,
    set_maximized: ?fn (?*Client, [*c]Resource, [*c]Resource) callconv(.C) void,
    set_title: ?fn (?*Client, [*c]Resource, [*c]const u8) callconv(.C) void,
    set_class: ?fn (?*Client, [*c]Resource, [*c]const u8) callconv(.C) void,
};
pub const enum_wl_pointer_error = extern enum(c_int) {
    WL_POINTER_ERROR_ROLE = 0,
    _,
};
pub const enum_wl_pointer_button_state = extern enum(c_int) {
    WL_POINTER_BUTTON_STATE_RELEASED = 0,
    WL_POINTER_BUTTON_STATE_PRESSED = 1,
    _,
};
pub const enum_wl_pointer_axis = extern enum(c_int) {
    WL_POINTER_AXIS_VERTICAL_SCROLL = 0,
    WL_POINTER_AXIS_HORIZONTAL_SCROLL = 1,
    _,
};
pub const enum_wl_pointer_axis_source = extern enum(c_int) {
    WL_POINTER_AXIS_SOURCE_WHEEL = 0,
    WL_POINTER_AXIS_SOURCE_FINGER = 1,
    WL_POINTER_AXIS_SOURCE_CONTINUOUS = 2,
    WL_POINTER_AXIS_SOURCE_WHEEL_TILT = 3,
    _,
};
pub const struct_wl_pointer_interface = extern struct {
    set_cursor: ?fn (?*Client, [*c]Resource, u32, [*c]Resource, i32, i32) callconv(.C) void,
    release: ?fn (?*Client, [*c]Resource) callconv(.C) void,
};
pub const enum_wl_keyboard_keymap_format = extern enum(c_int) {
    WL_KEYBOARD_KEYMAP_FORMAT_NO_KEYMAP = 0,
    WL_KEYBOARD_KEYMAP_FORMAT_XKB_V1 = 1,
    _,
};
pub const enum_wl_keyboard_key_state = extern enum(c_int) {
    WL_KEYBOARD_KEY_STATE_RELEASED = 0,
    WL_KEYBOARD_KEY_STATE_PRESSED = 1,
    _,
};
pub const struct_wl_keyboard_interface = extern struct {
    release: ?fn (?*Client, [*c]Resource) callconv(.C) void,
};
pub const struct_wl_touch_interface = extern struct {
    release: ?fn (?*Client, [*c]Resource) callconv(.C) void,
};
pub const struct_wl_region_interface = extern struct {
    destroy: ?fn (?*Client, [*c]Resource) callconv(.C) void,
    add: ?fn (?*Client, [*c]Resource, i32, i32, i32, i32) callconv(.C) void,
    subtract: ?fn (?*Client, [*c]Resource, i32, i32, i32, i32) callconv(.C) void,
};

pub const enum_wl_subsurface_error = extern enum(c_int) {
    WL_SUBSURFACE_ERROR_BAD_SURFACE = 0,
    _,
};
pub const struct_wl_subsurface_interface = extern struct {
    destroy: ?fn (?*Client, [*c]Resource) callconv(.C) void,
    set_position: ?fn (?*Client, [*c]Resource, i32, i32) callconv(.C) void,
    place_above: ?fn (?*Client, [*c]Resource, [*c]Resource) callconv(.C) void,
    place_below: ?fn (?*Client, [*c]Resource, [*c]Resource) callconv(.C) void,
    set_sync: ?fn (?*Client, [*c]Resource) callconv(.C) void,
    set_desync: ?fn (?*Client, [*c]Resource) callconv(.C) void,
};
pub const wl_fixed_t = i32;
pub const wl_fixed_to_double = @compileError("unable to translate function"); // /nix/store/zrzyhci4155qm17b4ijvmrxzhy1hssa9-wayland-1.18.0/include/wayland-util.h:614:1
// /nix/store/zrzyhci4155qm17b4ijvmrxzhy1hssa9-wayland-1.18.0/include/wayland-util.h:636:2: warning: TODO implement translation of DeclStmt kind Record
pub const wl_fixed_from_double = @compileError("unable to translate function"); // /nix/store/zrzyhci4155qm17b4ijvmrxzhy1hssa9-wayland-1.18.0/include/wayland-util.h:634:1
pub const union_wl_argument = extern union {
    i: i32,
    u: u32,
    f: wl_fixed_t,
    s: [*c]const u8,
    o: [*c]Object,
    n: u32,
    a: [*c]struct_wl_array,
    h: i32,
};
pub const wl_dispatcher_func_t = ?fn (?*const c_void, ?*c_void, u32, [*c]const Message, [*c]union_wl_argument) callconv(.C) c_int;
pub const enum_wl_iterator_result = extern enum(c_int) {
    WL_ITERATOR_STOP,
    WL_ITERATOR_CONTINUE,
    _,
};
const enum_unnamed_20 = extern enum(c_int) {
    WL_EVENT_READABLE = 1,
    WL_EVENT_WRITABLE = 2,
    WL_EVENT_HANGUP = 4,
    WL_EVENT_ERROR = 8,
    _,
};
pub const wl_global_bind_func_t = ?fn (?*Client, ?*c_void, u32, u32) callconv(.C) void;
pub const wl_signal_get = @compileError("unable to translate function"); // /nix/store/zrzyhci4155qm17b4ijvmrxzhy1hssa9-wayland-1.18.0/include/wayland-server-core.h:454:1
// /nix/store/whnib2lxbpd9x8srzbfqyg6bkkyffy7r-zig-8b9195282e99427964119431b6f4e535eeb4d9ba/lib/zig/include/stddef.h:104:24: warning: TODO implement translation of stmt class OffsetOfExprClass
pub const wl_signal_emit = @compileError("unable to translate function"); // /nix/store/zrzyhci4155qm17b4ijvmrxzhy1hssa9-wayland-1.18.0/include/wayland-server-core.h:473:1

pub const struct_wl_shm_pool = opaque {};
pub const enum_wl_protocol_logger_type = extern enum(c_int) {
    WL_PROTOCOL_LOGGER_REQUEST,
    WL_PROTOCOL_LOGGER_EVENT,
    _,
};
pub const struct_wl_protocol_logger_message = extern struct {
    resource: [*c]Resource,
    message_opcode: c_int,
    message: [*c]const Message,
    arguments_count: c_int,
    arguments: [*c]const union_wl_argument,
};
pub const wl_protocol_logger_func_t = ?fn (?*c_void, enum_wl_protocol_logger_type, [*c]const struct_wl_protocol_logger_message) callconv(.C) void;
pub const struct_wl_protocol_logger = opaque {};

pub const EventLoop = opaque {
    pub extern fn wl_event_loop_create() ?*EventLoop;
    pub extern fn wl_event_loop_destroy(loop: ?*EventLoop) void;
    pub extern fn wl_event_loop_add_fd(loop: ?*EventLoop, fd: c_int, mask: u32, func: wl_event_loop_fd_func_t, data: ?*c_void) ?*EventSource;
    pub extern fn wl_event_loop_add_timer(loop: ?*EventLoop, func: wl_event_loop_timer_func_t, data: ?*c_void) ?*EventSource;
    pub extern fn wl_event_loop_add_signal(loop: ?*EventLoop, signal_number: c_int, func: wl_event_loop_signal_func_t, data: ?*c_void) ?*EventSource;
    pub extern fn wl_event_loop_dispatch(loop: ?*EventLoop, timeout: c_int) c_int;
    pub extern fn wl_event_loop_dispatch_idle(loop: ?*EventLoop) void;
    pub extern fn wl_event_loop_add_idle(loop: ?*EventLoop, func: wl_event_loop_idle_func_t, data: ?*c_void) ?*EventSource;
    pub extern fn wl_event_loop_get_fd(loop: ?*EventLoop) c_int;
    pub const wl_notify_func_t = ?fn ([*c]wl.Listener(?*c_void), ?*c_void) callconv(.C) void;
    pub extern fn wl_event_loop_add_destroy_listener(loop: ?*EventLoop, listener: [*c]wl.Listener(?*c_void)) void;
    pub extern fn wl_event_loop_get_destroy_listener(loop: ?*EventLoop, notify: wl_notify_func_t) [*c]wl.Listener(?*c_void);

    pub const wl_event_loop_fd_func_t = ?fn (c_int, u32, ?*c_void) callconv(.C) c_int;
    pub const wl_event_loop_timer_func_t = ?fn (?*c_void) callconv(.C) c_int;
    pub const wl_event_loop_signal_func_t = ?fn (c_int, ?*c_void) callconv(.C) c_int;
    pub const wl_event_loop_idle_func_t = ?fn (?*c_void) callconv(.C) void;
};

pub const EventSource = opaque {
    pub extern fn wl_event_source_fd_update(source: ?*EventSource, mask: u32) c_int;
    pub extern fn wl_event_source_timer_update(source: ?*EventSource, ms_delay: c_int) c_int;
    pub extern fn wl_event_source_remove(source: ?*EventSource) c_int;
    pub extern fn wl_event_source_check(source: ?*EventSource) void;
};

pub const Client = opaque {
    pub extern fn wl_client_create(display: ?*Display, fd: c_int) ?*Client;
    pub extern fn wl_client_get_link(client: ?*Client) [*c]struct_wl_list;
    pub extern fn wl_client_from_link(link: [*c]struct_wl_list) ?*Client;
    pub extern fn wl_client_destroy(client: ?*Client) void;
    pub extern fn wl_client_flush(client: ?*Client) void;
    pub extern fn wl_client_get_credentials(client: ?*Client, pid: [*c]pid_t, uid: [*c]uid_t, gid: [*c]gid_t) void;
    pub extern fn wl_client_get_fd(client: ?*Client) c_int;
    pub extern fn wl_client_add_destroy_listener(client: ?*Client, listener: [*c]wl.Listener(?*c_void)) void;
    pub extern fn wl_client_get_destroy_listener(client: ?*Client, notify: wl_notify_func_t) [*c]wl.Listener(?*c_void);
    pub extern fn wl_client_get_object(client: ?*Client, id: u32) [*c]Resource;
    pub extern fn wl_client_post_no_memory(client: ?*Client) void;
    pub extern fn wl_client_post_implementation_error(client: ?*Client, msg: [*c]const u8, ...) void;
    pub extern fn wl_client_add_resource_created_listener(client: ?*Client, listener: [*c]wl.Listener(?*c_void)) void;
    pub const wl_client_for_each_resource_iterator_func_t = ?fn ([*c]Resource, ?*c_void) callconv(.C) enum_wl_iterator_result;
    pub extern fn wl_client_for_each_resource(client: ?*Client, iterator: wl_client_for_each_resource_iterator_func_t, user_data: ?*c_void) void;
    pub extern fn wl_client_get_display(client: ?*Client) ?*Display;
    pub extern fn wl_client_add_resource(client: ?*Client, resource: [*c]Resource) u32;
    pub extern fn wl_client_add_object(client: ?*Client, interface: [*c]const Interface, implementation: ?*const c_void, id: u32, data: ?*c_void) [*c]Resource;
    pub extern fn wl_client_new_object(client: ?*Client, interface: [*c]const Interface, implementation: ?*const c_void, data: ?*c_void) [*c]Resource;
};

pub const Global = opaque {
    pub extern fn wl_global_create(display: ?*Display, interface: [*c]const Interface, version: c_int, data: ?*c_void, bind: wl_global_bind_func_t) ?*Global;
    pub extern fn wl_global_remove(global: ?*Global) void;
    pub extern fn wl_global_destroy(global: ?*Global) void;
    pub extern fn wl_global_get_interface(global: ?*const Global) [*c]const Interface;
    pub extern fn wl_global_get_user_data(global: ?*const Global) ?*c_void;
    pub extern fn wl_global_set_user_data(global: ?*Global, data: ?*c_void) void;
};

pub const Display = opaque {
    pub extern fn wl_display_create() ?*Display;
    pub extern fn wl_display_destroy(display: *Display) void;
    pub extern fn wl_display_get_event_loop(display: *Display) *EventLoop;
    pub extern fn wl_display_add_socket(display: *Display, name: [*:0]const u8) c_int;
    pub extern fn wl_display_add_socket_auto(display: *Display) [*c]const u8;
    pub extern fn wl_display_add_socket_fd(display: *Display, sock_fd: c_int) c_int;
    pub extern fn wl_display_terminate(display: *Display) void;
    pub extern fn wl_display_run(display: *Display) void;
    pub extern fn wl_display_flush_clients(display: *Display) void;
    pub extern fn wl_display_destroy_clients(display: *Display) void;
    pub extern fn wl_display_get_serial(display: *Display) u32;
    pub extern fn wl_display_next_serial(display: *Display) u32;
    pub extern fn wl_display_add_destroy_listener(display: *Display, listener: [*c]wl.Listener(?*c_void)) void;
    pub extern fn wl_display_add_client_created_listener(display: *Display, listener: [*c]wl.Listener(?*c_void)) void;
    pub extern fn wl_display_get_destroy_listener(display: *Display, notify: wl_notify_func_t) [*c]wl.Listener(?*c_void);
    pub const wl_display_global_filter_func_t = ?fn (?*const Client, ?*const Global, ?*c_void) callconv(.C) bool;
    pub extern fn wl_display_set_global_filter(display: *Display, filter: wl_display_global_filter_func_t, data: ?*c_void) void;
    pub extern fn wl_display_get_client_list(display: *Display) [*c]struct_wl_list;
    pub extern fn wl_display_init_shm(display: *Display) c_int;
    pub extern fn wl_display_add_shm_format(display: *Display, format: u32) [*c]u32;
    pub extern fn wl_display_add_protocol_logger(display: *Display, wl_protocol_logger_func_t, user_data: ?*c_void) ?*struct_wl_protocol_logger;

    pub fn create() !*Display {
        return wl_display_create() orelse error.Failure;
    }

    pub const destroy = wl_display_destroy;
    pub const getEventLoop = wl_display_get_event_loop;
};

pub const Message = extern struct {
    name: [*c]const u8,
    signature: [*c]const u8,
    types: [*c][*c]const Interface,
};

pub const Interface = extern struct {
    name: [*c]const u8,
    version: c_int,
    method_count: c_int,
    methods: [*c]const Message,
    event_count: c_int,
    events: [*c]const Message,
};

pub const Object = extern struct {
    interface: [*c]const Interface,
    implementation: ?*const c_void,
    id: u32,
};

pub fn Signal(comptime T: type) type {
    return extern struct {
        listener_list: List(Listener(T), "link"),

        pub fn add(sig: *@This(), listener: *Listener(T)) void {
            sig.listener_list.prev.insert(&listener.link);
        }
    };
}

pub fn Listener(comptime T: type) type {
    // TODO(dh): verify that T is a pointer type
    return extern struct {
        const Self = @This();
        const alignment = if (T == void)
            1
        else
            @alignOf(T);

        link: List(Self, "link") = .{},
        notify: fn (*Self, ?*align(alignment) c_void) callconv(.C) void = undefined,

        pub const NotifyFn = if (T == void)
            fn (*Self) void
        else
            fn (*Self, T) void;

        // TODO(dh): if we already need wrappers, then we might as well handle errors and panics
        pub fn setNotify(self: *Self, comptime notify: NotifyFn) void {
            self.notify = if (T == void)
                struct {
                    fn wrapper(listener: *Self, _: ?*c_void) callconv(.C) void {
                        notify(listener);
                    }
                }.wrapper
            else
                struct {
                    fn wrapper(listener: *Self, data: ?*align(alignment) c_void) callconv(.C) void {
                        // TODO(dh): support optional data
                        notify(listener, @ptrCast(T, data.?));
                    }
                }.wrapper;
        }
    };
}

pub const ListElement = List;
pub fn List(comptime T: type, comptime element_link_field: []const u8) type {
    return extern struct {
        const Self = @This();

        prev: *@This() = undefined,
        next: *@This() = undefined,

        const elem = T;

        pub fn Iterator(comptime forward: bool) type {
            return struct {
                head: *Self,
                cur: *Self,

                pub fn hasMore(iter: *@This()) bool {
                    if (forward) {
                        return iter.cur.next != iter.head;
                    } else {
                        return iter.cur.prev != iter.head;
                    }
                }
                pub fn next(iter: *@This()) ?*Self.elem {
                    if (!iter.hasMore()) {
                        return null;
                    }

                    if (forward) {
                        iter.cur = iter.cur.next;
                        return iter.cur.container();
                    } else {
                        iter.cur = iter.cur.prev;
                        return iter.cur.container();
                    }
                }
            };
        }

        pub fn init(self: *@This()) void {
            self.prev = self;
            self.next = self;
        }

        pub fn isEmpty(self: *const @This()) bool {
            return self.next == self;
        }

        pub fn iterate(self: *@This()) Iterator(true) {
            return .{
                .head = self,
                .cur = self,
            };
        }

        pub fn iterate_reverse(self: *@This()) Iterator(false) {
            return .{
                .head = self,
                .cur = self,
            };
        }

        pub fn insert(list: *@This(), elm: *@This()) void {
            elm.prev = list;
            elm.next = list.next;
            list.next = elm;
            elm.next.prev = elm;
        }

        pub fn remove(elm: *@This()) void {
            elm.prev.next = elm.next;
            elm.next.prev = elm.prev;
            elm.next = elm;
            elm.prev = elm;
        }

        pub fn container(elm: *@This()) *T {
            // look up the actual type of the link field, because we
            // have to stay compatible with C structs that use
            // wl_list, not our safe version
            const dst_type: type = TypeOfField(T, element_link_field);

            // 'elm' is field 'field' in 'T'
            return @fieldParentPtr(T, element_link_field, @ptrCast(*dst_type, elm));
        }
    };
}

pub const Callback = opaque {
    pub fn wl_callback_send_done(arg_resource_: [*c]Resource, arg_callback_data: u32) callconv(.C) void {
        var resource_ = arg_resource_;
        var callback_data = arg_callback_data;
        wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 0)), callback_data);
    }
};

pub const Compositor = opaque {
    pub const struct_wl_compositor_interface = extern struct {
        create_surface: ?fn (?*Client, [*c]Resource, u32) callconv(.C) void,
        create_region: ?fn (?*Client, [*c]Resource, u32) callconv(.C) void,
    };
};

pub const struct_wl_data_device = opaque {};
pub const struct_wl_data_device_manager = opaque {};
pub const struct_wl_data_offer = opaque {};
pub const struct_wl_data_source = opaque {};
pub const struct_wl_keyboard = opaque {};

pub const Output = opaque {
    pub const Subpixel = extern enum(c_int) {
        WL_OUTPUT_SUBPIXEL_UNKNOWN = 0,
        WL_OUTPUT_SUBPIXEL_NONE = 1,
        WL_OUTPUT_SUBPIXEL_HORIZONTAL_RGB = 2,
        WL_OUTPUT_SUBPIXEL_HORIZONTAL_BGR = 3,
        WL_OUTPUT_SUBPIXEL_VERTICAL_RGB = 4,
        WL_OUTPUT_SUBPIXEL_VERTICAL_BGR = 5,
        _,
    };
    pub const Transform = extern enum(c_int) {
        Normal = 0,
        @"90" = 1,
        @"180" = 2,
        @"270" = 3,
        Flipped = 4,
        Flipped90 = 5,
        Flipped180 = 6,
        Flipped270 = 7,
        _,
    };
    pub const struct_wl_output_interface = extern struct {
        release: ?fn (?*Client, [*c]Resource) callconv(.C) void,
    };
};

pub const struct_wl_pointer = opaque {};
pub const struct_wl_region = opaque {};
pub const struct_wl_registry = opaque {};

pub const struct_wl_seat = opaque {
    pub extern const wl_seat_interface: Interface;

    pub const enum_wl_seat_capability = extern enum(c_int) {
        WL_SEAT_CAPABILITY_POINTER = 1,
        WL_SEAT_CAPABILITY_KEYBOARD = 2,
        WL_SEAT_CAPABILITY_TOUCH = 4,
        _,
    };
    pub const struct_wl_seat_interface = extern struct {
        get_pointer: ?fn (?*Client, [*c]Resource, u32) callconv(.C) void,
        get_keyboard: ?fn (?*Client, [*c]Resource, u32) callconv(.C) void,
        get_touch: ?fn (?*Client, [*c]Resource, u32) callconv(.C) void,
        release: ?fn (?*Client, [*c]Resource) callconv(.C) void,
    };
    pub fn wl_seat_send_capabilities(arg_resource_: [*c]Resource, arg_capabilities: u32) callconv(.C) void {
        var resource_ = arg_resource_;
        var capabilities = arg_capabilities;
        wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 0)), capabilities);
    }
    pub fn wl_seat_send_name(arg_resource_: [*c]Resource, arg_name: [*c]const u8) callconv(.C) void {
        var resource_ = arg_resource_;
        var name = arg_name;
        wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 1)), name);
    }
};

pub const struct_wl_shell = opaque {};
pub const struct_wl_shell_surface = opaque {};

pub const struct_wl_shm = opaque {
    pub const enum_wl_shm_error = extern enum(c_int) {
        WL_SHM_ERROR_INVALID_FORMAT = 0,
        WL_SHM_ERROR_INVALID_STRIDE = 1,
        WL_SHM_ERROR_INVALID_FD = 2,
        _,
    };

    pub const enum_wl_shm_format = extern enum(c_int) {
        WL_SHM_FORMAT_ARGB8888 = 0,
        WL_SHM_FORMAT_XRGB8888 = 1,
        WL_SHM_FORMAT_C8 = 538982467,
        WL_SHM_FORMAT_RGB332 = 943867730,
        WL_SHM_FORMAT_BGR233 = 944916290,
        WL_SHM_FORMAT_XRGB4444 = 842093144,
        WL_SHM_FORMAT_XBGR4444 = 842089048,
        WL_SHM_FORMAT_RGBX4444 = 842094674,
        WL_SHM_FORMAT_BGRX4444 = 842094658,
        WL_SHM_FORMAT_ARGB4444 = 842093121,
        WL_SHM_FORMAT_ABGR4444 = 842089025,
        WL_SHM_FORMAT_RGBA4444 = 842088786,
        WL_SHM_FORMAT_BGRA4444 = 842088770,
        WL_SHM_FORMAT_XRGB1555 = 892424792,
        WL_SHM_FORMAT_XBGR1555 = 892420696,
        WL_SHM_FORMAT_RGBX5551 = 892426322,
        WL_SHM_FORMAT_BGRX5551 = 892426306,
        WL_SHM_FORMAT_ARGB1555 = 892424769,
        WL_SHM_FORMAT_ABGR1555 = 892420673,
        WL_SHM_FORMAT_RGBA5551 = 892420434,
        WL_SHM_FORMAT_BGRA5551 = 892420418,
        WL_SHM_FORMAT_RGB565 = 909199186,
        WL_SHM_FORMAT_BGR565 = 909199170,
        WL_SHM_FORMAT_RGB888 = 875710290,
        WL_SHM_FORMAT_BGR888 = 875710274,
        WL_SHM_FORMAT_XBGR8888 = 875709016,
        WL_SHM_FORMAT_RGBX8888 = 875714642,
        WL_SHM_FORMAT_BGRX8888 = 875714626,
        WL_SHM_FORMAT_ABGR8888 = 875708993,
        WL_SHM_FORMAT_RGBA8888 = 875708754,
        WL_SHM_FORMAT_BGRA8888 = 875708738,
        WL_SHM_FORMAT_XRGB2101010 = 808669784,
        WL_SHM_FORMAT_XBGR2101010 = 808665688,
        WL_SHM_FORMAT_RGBX1010102 = 808671314,
        WL_SHM_FORMAT_BGRX1010102 = 808671298,
        WL_SHM_FORMAT_ARGB2101010 = 808669761,
        WL_SHM_FORMAT_ABGR2101010 = 808665665,
        WL_SHM_FORMAT_RGBA1010102 = 808665426,
        WL_SHM_FORMAT_BGRA1010102 = 808665410,
        WL_SHM_FORMAT_YUYV = 1448695129,
        WL_SHM_FORMAT_YVYU = 1431918169,
        WL_SHM_FORMAT_UYVY = 1498831189,
        WL_SHM_FORMAT_VYUY = 1498765654,
        WL_SHM_FORMAT_AYUV = 1448433985,
        WL_SHM_FORMAT_NV12 = 842094158,
        WL_SHM_FORMAT_NV21 = 825382478,
        WL_SHM_FORMAT_NV16 = 909203022,
        WL_SHM_FORMAT_NV61 = 825644622,
        WL_SHM_FORMAT_YUV410 = 961959257,
        WL_SHM_FORMAT_YVU410 = 961893977,
        WL_SHM_FORMAT_YUV411 = 825316697,
        WL_SHM_FORMAT_YVU411 = 825316953,
        WL_SHM_FORMAT_YUV420 = 842093913,
        WL_SHM_FORMAT_YVU420 = 842094169,
        WL_SHM_FORMAT_YUV422 = 909202777,
        WL_SHM_FORMAT_YVU422 = 909203033,
        WL_SHM_FORMAT_YUV444 = 875713881,
        WL_SHM_FORMAT_YVU444 = 875714137,
        WL_SHM_FORMAT_R8 = 538982482,
        WL_SHM_FORMAT_R16 = 540422482,
        WL_SHM_FORMAT_RG88 = 943212370,
        WL_SHM_FORMAT_GR88 = 943215175,
        WL_SHM_FORMAT_RG1616 = 842221394,
        WL_SHM_FORMAT_GR1616 = 842224199,
        WL_SHM_FORMAT_XRGB16161616F = 1211388504,
        WL_SHM_FORMAT_XBGR16161616F = 1211384408,
        WL_SHM_FORMAT_ARGB16161616F = 1211388481,
        WL_SHM_FORMAT_ABGR16161616F = 1211384385,
        WL_SHM_FORMAT_XYUV8888 = 1448434008,
        WL_SHM_FORMAT_VUY888 = 875713878,
        WL_SHM_FORMAT_VUY101010 = 808670550,
        WL_SHM_FORMAT_Y210 = 808530521,
        WL_SHM_FORMAT_Y212 = 842084953,
        WL_SHM_FORMAT_Y216 = 909193817,
        WL_SHM_FORMAT_Y410 = 808531033,
        WL_SHM_FORMAT_Y412 = 842085465,
        WL_SHM_FORMAT_Y416 = 909194329,
        WL_SHM_FORMAT_XVYU2101010 = 808670808,
        WL_SHM_FORMAT_XVYU12_16161616 = 909334104,
        WL_SHM_FORMAT_XVYU16161616 = 942954072,
        WL_SHM_FORMAT_Y0L0 = 810299481,
        WL_SHM_FORMAT_X0L0 = 810299480,
        WL_SHM_FORMAT_Y0L2 = 843853913,
        WL_SHM_FORMAT_X0L2 = 843853912,
        WL_SHM_FORMAT_YUV420_8BIT = 942691673,
        WL_SHM_FORMAT_YUV420_10BIT = 808539481,
        WL_SHM_FORMAT_XRGB8888_A8 = 943805016,
        WL_SHM_FORMAT_XBGR8888_A8 = 943800920,
        WL_SHM_FORMAT_RGBX8888_A8 = 943806546,
        WL_SHM_FORMAT_BGRX8888_A8 = 943806530,
        WL_SHM_FORMAT_RGB888_A8 = 943798354,
        WL_SHM_FORMAT_BGR888_A8 = 943798338,
        WL_SHM_FORMAT_RGB565_A8 = 943797586,
        WL_SHM_FORMAT_BGR565_A8 = 943797570,
        WL_SHM_FORMAT_NV24 = 875714126,
        WL_SHM_FORMAT_NV42 = 842290766,
        WL_SHM_FORMAT_P210 = 808530512,
        WL_SHM_FORMAT_P010 = 808530000,
        WL_SHM_FORMAT_P012 = 842084432,
        WL_SHM_FORMAT_P016 = 909193296,
        _,
    };
};

pub const struct_wl_subcompositor = opaque {};
pub const struct_wl_subsurface = opaque {};

pub const struct_wl_surface = opaque {
    pub const enum_wl_surface_error = extern enum(c_int) {
        WL_SURFACE_ERROR_INVALID_SCALE = 0,
        WL_SURFACE_ERROR_INVALID_TRANSFORM = 1,
        _,
    };
    pub const struct_wl_surface_interface = extern struct {
        destroy: ?fn (?*Client, [*c]Resource) callconv(.C) void,
        attach: ?fn (?*Client, [*c]Resource, [*c]Resource, i32, i32) callconv(.C) void,
        damage: ?fn (?*Client, [*c]Resource, i32, i32, i32, i32) callconv(.C) void,
        frame: ?fn (?*Client, [*c]Resource, u32) callconv(.C) void,
        set_opaque_region: ?fn (?*Client, [*c]Resource, [*c]Resource) callconv(.C) void,
        set_input_region: ?fn (?*Client, [*c]Resource, [*c]Resource) callconv(.C) void,
        commit: ?fn (?*Client, [*c]Resource) callconv(.C) void,
        set_buffer_transform: ?fn (?*Client, [*c]Resource, i32) callconv(.C) void,
        set_buffer_scale: ?fn (?*Client, [*c]Resource, i32) callconv(.C) void,
        damage_buffer: ?fn (?*Client, [*c]Resource, i32, i32, i32, i32) callconv(.C) void,
    };
    pub fn wl_surface_send_enter(arg_resource_: [*c]Resource, arg_output: [*c]Resource) callconv(.C) void {
        var resource_ = arg_resource_;
        var output = arg_output;
        wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 0)), output);
    }
    pub fn wl_surface_send_leave(arg_resource_: [*c]Resource, arg_output: [*c]Resource) callconv(.C) void {
        var resource_ = arg_resource_;
        var output = arg_output;
        wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 1)), output);
    }
};

pub const Resource = extern struct {
    pub extern fn wl_resource_post_event(resource: [*c]Resource, opcode: u32, ...) void;
    pub extern fn wl_resource_post_event_array(resource: [*c]Resource, opcode: u32, args: [*c]union_wl_argument) void;
    pub extern fn wl_resource_queue_event(resource: [*c]Resource, opcode: u32, ...) void;
    pub extern fn wl_resource_queue_event_array(resource: [*c]Resource, opcode: u32, args: [*c]union_wl_argument) void;
    pub extern fn wl_resource_post_error(resource: [*c]Resource, code: u32, msg: [*c]const u8, ...) void;
    pub extern fn wl_resource_post_no_memory(resource: [*c]Resource) void;
    pub extern fn wl_resource_create(client: ?*Client, interface: [*c]const Interface, version: c_int, id: u32) [*c]Resource;
    pub extern fn wl_resource_set_implementation(resource: [*c]Resource, implementation: ?*const c_void, data: ?*c_void, destroy: DestroyFunc) void;
    pub extern fn wl_resource_set_dispatcher(resource: [*c]Resource, dispatcher: wl_dispatcher_func_t, implementation: ?*const c_void, data: ?*c_void, destroy: DestroyFunc) void;
    pub extern fn wl_resource_destroy(resource: [*c]Resource) void;
    pub extern fn wl_resource_get_id(resource: [*c]Resource) u32;
    pub extern fn wl_resource_get_link(resource: [*c]Resource) [*c]struct_wl_list;
    pub extern fn wl_resource_from_link(resource: [*c]struct_wl_list) [*c]Resource;
    pub extern fn wl_resource_find_for_client(list: [*c]struct_wl_list, client: ?*Client) [*c]Resource;
    pub extern fn wl_resource_get_client(resource: [*c]Resource) ?*Client;
    pub extern fn wl_resource_set_user_data(resource: [*c]Resource, data: ?*c_void) void;
    pub extern fn wl_resource_get_user_data(resource: [*c]Resource) ?*c_void;
    pub extern fn wl_resource_get_version(resource: [*c]Resource) c_int;
    pub extern fn wl_resource_set_destructor(resource: [*c]Resource, destroy: DestroyFunc) void;
    pub extern fn wl_resource_instance_of(resource: [*c]Resource, interface: [*c]const Interface, implementation: ?*const c_void) c_int;
    pub extern fn wl_resource_get_class(resource: [*c]Resource) [*c]const u8;
    pub extern fn wl_resource_add_destroy_listener(resource: [*c]Resource, listener: [*c]wl.Listener(?*c_void)) void;
    pub extern fn wl_resource_get_destroy_listener(resource: [*c]Resource, notify: wl_notify_func_t) [*c]wl.Listener(?*c_void);
    pub const struct_wl_shm_buffer = opaque {};

    pub const DestroyFunc = ?fn ([*c]Resource) callconv(.C) void;

    object: Object,
    destroy: DestroyFunc,
    link: ListElement(Resource, "link"),
    destroy_signal: Signal(?*c_void),
    client: ?*Client,
    data: ?*c_void,
};

pub const struct_wl_touch = opaque {};

pub const struct_xdg_popup = opaque {};
pub const struct_xdg_positioner = opaque {};
pub const struct_xdg_surface = opaque {};
pub const struct_xdg_toplevel = opaque {};
pub const struct_xdg_wm_base = opaque {};
pub extern const xdg_wm_base_interface: struct_wl_interface;
pub extern const xdg_positioner_interface: struct_wl_interface;
pub extern const xdg_surface_interface: struct_wl_interface;
pub extern const xdg_toplevel_interface: struct_wl_interface;
pub extern const xdg_popup_interface: struct_wl_interface;
pub const enum_xdg_wm_base_error = extern enum(c_int) {
    XDG_WM_BASE_ERROR_ROLE = 0,
    XDG_WM_BASE_ERROR_DEFUNCT_SURFACES = 1,
    XDG_WM_BASE_ERROR_NOT_THE_TOPMOST_POPUP = 2,
    XDG_WM_BASE_ERROR_INVALID_POPUP_PARENT = 3,
    XDG_WM_BASE_ERROR_INVALID_SURFACE_STATE = 4,
    XDG_WM_BASE_ERROR_INVALID_POSITIONER = 5,
    _,
};
pub const struct_xdg_wm_base_interface = extern struct {
    destroy: ?fn (?*wayland.Client, [*c]struct_wl_resource) callconv(.C) void,
    create_positioner: ?fn (?*wayland.Client, [*c]struct_wl_resource, u32) callconv(.C) void,
    get_xdg_surface: ?fn (?*wayland.Client, [*c]struct_wl_resource, u32, [*c]struct_wl_resource) callconv(.C) void,
    pong: ?fn (?*wayland.Client, [*c]struct_wl_resource, u32) callconv(.C) void,
};
pub fn xdg_wm_base_send_ping(arg_resource_: [*c]struct_wl_resource, arg_serial: u32) callconv(.C) void {
    var resource_ = arg_resource_;
    var serial = arg_serial;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 0)), serial);
}
pub const enum_xdg_positioner_error = extern enum(c_int) {
    XDG_POSITIONER_ERROR_INVALID_INPUT = 0,
    _,
};
pub const enum_xdg_positioner_anchor = extern enum(c_int) {
    XDG_POSITIONER_ANCHOR_NONE = 0,
    XDG_POSITIONER_ANCHOR_TOP = 1,
    XDG_POSITIONER_ANCHOR_BOTTOM = 2,
    XDG_POSITIONER_ANCHOR_LEFT = 3,
    XDG_POSITIONER_ANCHOR_RIGHT = 4,
    XDG_POSITIONER_ANCHOR_TOP_LEFT = 5,
    XDG_POSITIONER_ANCHOR_BOTTOM_LEFT = 6,
    XDG_POSITIONER_ANCHOR_TOP_RIGHT = 7,
    XDG_POSITIONER_ANCHOR_BOTTOM_RIGHT = 8,
    _,
};
pub const enum_xdg_positioner_gravity = extern enum(c_int) {
    XDG_POSITIONER_GRAVITY_NONE = 0,
    XDG_POSITIONER_GRAVITY_TOP = 1,
    XDG_POSITIONER_GRAVITY_BOTTOM = 2,
    XDG_POSITIONER_GRAVITY_LEFT = 3,
    XDG_POSITIONER_GRAVITY_RIGHT = 4,
    XDG_POSITIONER_GRAVITY_TOP_LEFT = 5,
    XDG_POSITIONER_GRAVITY_BOTTOM_LEFT = 6,
    XDG_POSITIONER_GRAVITY_TOP_RIGHT = 7,
    XDG_POSITIONER_GRAVITY_BOTTOM_RIGHT = 8,
    _,
};
pub const enum_xdg_positioner_constraint_adjustment = extern enum(c_int) {
    XDG_POSITIONER_CONSTRAINT_ADJUSTMENT_NONE = 0,
    XDG_POSITIONER_CONSTRAINT_ADJUSTMENT_SLIDE_X = 1,
    XDG_POSITIONER_CONSTRAINT_ADJUSTMENT_SLIDE_Y = 2,
    XDG_POSITIONER_CONSTRAINT_ADJUSTMENT_FLIP_X = 4,
    XDG_POSITIONER_CONSTRAINT_ADJUSTMENT_FLIP_Y = 8,
    XDG_POSITIONER_CONSTRAINT_ADJUSTMENT_RESIZE_X = 16,
    XDG_POSITIONER_CONSTRAINT_ADJUSTMENT_RESIZE_Y = 32,
    _,
};
pub const struct_xdg_positioner_interface = extern struct {
    destroy: ?fn (?*wayland.Client, [*c]struct_wl_resource) callconv(.C) void,
    set_size: ?fn (?*wayland.Client, [*c]struct_wl_resource, i32, i32) callconv(.C) void,
    set_anchor_rect: ?fn (?*wayland.Client, [*c]struct_wl_resource, i32, i32, i32, i32) callconv(.C) void,
    set_anchor: ?fn (?*wayland.Client, [*c]struct_wl_resource, u32) callconv(.C) void,
    set_gravity: ?fn (?*wayland.Client, [*c]struct_wl_resource, u32) callconv(.C) void,
    set_constraint_adjustment: ?fn (?*wayland.Client, [*c]struct_wl_resource, u32) callconv(.C) void,
    set_offset: ?fn (?*wayland.Client, [*c]struct_wl_resource, i32, i32) callconv(.C) void,
    set_reactive: ?fn (?*wayland.Client, [*c]struct_wl_resource) callconv(.C) void,
    set_parent_size: ?fn (?*wayland.Client, [*c]struct_wl_resource, i32, i32) callconv(.C) void,
    set_parent_configure: ?fn (?*wayland.Client, [*c]struct_wl_resource, u32) callconv(.C) void,
};
pub const enum_xdg_surface_error = extern enum(c_int) {
    XDG_SURFACE_ERROR_NOT_CONSTRUCTED = 1,
    XDG_SURFACE_ERROR_ALREADY_CONSTRUCTED = 2,
    XDG_SURFACE_ERROR_UNCONFIGURED_BUFFER = 3,
    _,
};
pub const struct_xdg_surface_interface = extern struct {
    destroy: ?fn (?*wayland.Client, [*c]struct_wl_resource) callconv(.C) void,
    get_toplevel: ?fn (?*wayland.Client, [*c]struct_wl_resource, u32) callconv(.C) void,
    get_popup: ?fn (?*wayland.Client, [*c]struct_wl_resource, u32, [*c]struct_wl_resource, [*c]struct_wl_resource) callconv(.C) void,
    set_window_geometry: ?fn (?*wayland.Client, [*c]struct_wl_resource, i32, i32, i32, i32) callconv(.C) void,
    ack_configure: ?fn (?*wayland.Client, [*c]struct_wl_resource, u32) callconv(.C) void,
};
pub fn xdg_surface_send_configure(arg_resource_: [*c]struct_wl_resource, arg_serial: u32) callconv(.C) void {
    var resource_ = arg_resource_;
    var serial = arg_serial;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 0)), serial);
}
pub const enum_xdg_toplevel_resize_edge = extern enum(c_int) {
    XDG_TOPLEVEL_RESIZE_EDGE_NONE = 0,
    XDG_TOPLEVEL_RESIZE_EDGE_TOP = 1,
    XDG_TOPLEVEL_RESIZE_EDGE_BOTTOM = 2,
    XDG_TOPLEVEL_RESIZE_EDGE_LEFT = 4,
    XDG_TOPLEVEL_RESIZE_EDGE_TOP_LEFT = 5,
    XDG_TOPLEVEL_RESIZE_EDGE_BOTTOM_LEFT = 6,
    XDG_TOPLEVEL_RESIZE_EDGE_RIGHT = 8,
    XDG_TOPLEVEL_RESIZE_EDGE_TOP_RIGHT = 9,
    XDG_TOPLEVEL_RESIZE_EDGE_BOTTOM_RIGHT = 10,
    _,
};
pub const enum_xdg_toplevel_state = extern enum(c_int) {
    XDG_TOPLEVEL_STATE_MAXIMIZED = 1,
    XDG_TOPLEVEL_STATE_FULLSCREEN = 2,
    XDG_TOPLEVEL_STATE_RESIZING = 3,
    XDG_TOPLEVEL_STATE_ACTIVATED = 4,
    XDG_TOPLEVEL_STATE_TILED_LEFT = 5,
    XDG_TOPLEVEL_STATE_TILED_RIGHT = 6,
    XDG_TOPLEVEL_STATE_TILED_TOP = 7,
    XDG_TOPLEVEL_STATE_TILED_BOTTOM = 8,
    _,
};
pub const struct_xdg_toplevel_interface = extern struct {
    destroy: ?fn (?*wayland.Client, [*c]struct_wl_resource) callconv(.C) void,
    set_parent: ?fn (?*wayland.Client, [*c]struct_wl_resource, [*c]struct_wl_resource) callconv(.C) void,
    set_title: ?fn (?*wayland.Client, [*c]struct_wl_resource, [*c]const u8) callconv(.C) void,
    set_app_id: ?fn (?*wayland.Client, [*c]struct_wl_resource, [*c]const u8) callconv(.C) void,
    show_window_menu: ?fn (?*wayland.Client, [*c]struct_wl_resource, [*c]struct_wl_resource, u32, i32, i32) callconv(.C) void,
    move: ?fn (?*wayland.Client, [*c]struct_wl_resource, [*c]struct_wl_resource, u32) callconv(.C) void,
    resize: ?fn (?*wayland.Client, [*c]struct_wl_resource, [*c]struct_wl_resource, u32, u32) callconv(.C) void,
    set_max_size: ?fn (?*wayland.Client, [*c]struct_wl_resource, i32, i32) callconv(.C) void,
    set_min_size: ?fn (?*wayland.Client, [*c]struct_wl_resource, i32, i32) callconv(.C) void,
    set_maximized: ?fn (?*wayland.Client, [*c]struct_wl_resource) callconv(.C) void,
    unset_maximized: ?fn (?*wayland.Client, [*c]struct_wl_resource) callconv(.C) void,
    set_fullscreen: ?fn (?*wayland.Client, [*c]struct_wl_resource, [*c]struct_wl_resource) callconv(.C) void,
    unset_fullscreen: ?fn (?*wayland.Client, [*c]struct_wl_resource) callconv(.C) void,
    set_minimized: ?fn (?*wayland.Client, [*c]struct_wl_resource) callconv(.C) void,
};
pub fn xdg_toplevel_send_configure(arg_resource_: [*c]struct_wl_resource, arg_width: i32, arg_height: i32, arg_states: [*c]struct_wl_array) callconv(.C) void {
    var resource_ = arg_resource_;
    var width = arg_width;
    var height = arg_height;
    var states = arg_states;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 0)), width, height, states);
}
pub fn xdg_toplevel_send_close(arg_resource_: [*c]struct_wl_resource) callconv(.C) void {
    var resource_ = arg_resource_;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 1)));
}
pub const enum_xdg_popup_error = extern enum(c_int) {
    XDG_POPUP_ERROR_INVALID_GRAB = 0,
    _,
};
pub const struct_xdg_popup_interface = extern struct {
    destroy: ?fn (?*wayland.Client, [*c]struct_wl_resource) callconv(.C) void,
    grab: ?fn (?*wayland.Client, [*c]struct_wl_resource, [*c]struct_wl_resource, u32) callconv(.C) void,
    reposition: ?fn (?*wayland.Client, [*c]struct_wl_resource, [*c]struct_wl_resource, u32) callconv(.C) void,
};
pub fn xdg_popup_send_configure(arg_resource_: [*c]struct_wl_resource, arg_x: i32, arg_y: i32, arg_width: i32, arg_height: i32) callconv(.C) void {
    var resource_ = arg_resource_;
    var x = arg_x;
    var y = arg_y;
    var width = arg_width;
    var height = arg_height;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 0)), x, y, width, height);
}
pub fn xdg_popup_send_popup_done(arg_resource_: [*c]struct_wl_resource) callconv(.C) void {
    var resource_ = arg_resource_;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 1)));
}
pub fn xdg_popup_send_repositioned(arg_resource_: [*c]struct_wl_resource, arg_token: u32) callconv(.C) void {
    var resource_ = arg_resource_;
    var token = arg_token;
    wl_resource_post_event(resource_, @bitCast(u32, @as(c_int, 2)), token);
}

pub const WL_DISPLAY_ERROR = 0;
pub const WL_DISPLAY_DELETE_ID = 1;
pub const WL_DISPLAY_ERROR_SINCE_VERSION = 1;
pub const WL_DISPLAY_DELETE_ID_SINCE_VERSION = 1;
pub const WL_DISPLAY_SYNC_SINCE_VERSION = 1;
pub const WL_DISPLAY_GET_REGISTRY_SINCE_VERSION = 1;
pub const WL_REGISTRY_GLOBAL = 0;
pub const WL_REGISTRY_GLOBAL_REMOVE = 1;
pub const WL_REGISTRY_GLOBAL_SINCE_VERSION = 1;
pub const WL_REGISTRY_GLOBAL_REMOVE_SINCE_VERSION = 1;
pub const WL_REGISTRY_BIND_SINCE_VERSION = 1;
pub const WL_CALLBACK_DONE = 0;
pub const WL_CALLBACK_DONE_SINCE_VERSION = 1;
pub const WL_COMPOSITOR_CREATE_SURFACE_SINCE_VERSION = 1;
pub const WL_COMPOSITOR_CREATE_REGION_SINCE_VERSION = 1;
pub const WL_SHM_POOL_CREATE_BUFFER_SINCE_VERSION = 1;
pub const WL_SHM_POOL_DESTROY_SINCE_VERSION = 1;
pub const WL_SHM_POOL_RESIZE_SINCE_VERSION = 1;
pub const WL_SHM_FORMAT = 0;
pub const WL_SHM_FORMAT_SINCE_VERSION = 1;
pub const WL_SHM_CREATE_POOL_SINCE_VERSION = 1;
pub const WL_BUFFER_RELEASE = 0;
pub const WL_BUFFER_RELEASE_SINCE_VERSION = 1;
pub const WL_BUFFER_DESTROY_SINCE_VERSION = 1;
pub const WL_DATA_OFFER_OFFER = 0;
pub const WL_DATA_OFFER_SOURCE_ACTIONS = 1;
pub const WL_DATA_OFFER_ACTION = 2;
pub const WL_DATA_OFFER_OFFER_SINCE_VERSION = 1;
pub const WL_DATA_OFFER_SOURCE_ACTIONS_SINCE_VERSION = 3;
pub const WL_DATA_OFFER_ACTION_SINCE_VERSION = 3;
pub const WL_DATA_OFFER_ACCEPT_SINCE_VERSION = 1;
pub const WL_DATA_OFFER_RECEIVE_SINCE_VERSION = 1;
pub const WL_DATA_OFFER_DESTROY_SINCE_VERSION = 1;
pub const WL_DATA_OFFER_FINISH_SINCE_VERSION = 3;
pub const WL_DATA_OFFER_SET_ACTIONS_SINCE_VERSION = 3;
pub const WL_DATA_SOURCE_TARGET = 0;
pub const WL_DATA_SOURCE_SEND = 1;
pub const WL_DATA_SOURCE_CANCELLED = 2;
pub const WL_DATA_SOURCE_DND_DROP_PERFORMED = 3;
pub const WL_DATA_SOURCE_DND_FINISHED = 4;
pub const WL_DATA_SOURCE_ACTION = 5;
pub const WL_DATA_SOURCE_TARGET_SINCE_VERSION = 1;
pub const WL_DATA_SOURCE_SEND_SINCE_VERSION = 1;
pub const WL_DATA_SOURCE_CANCELLED_SINCE_VERSION = 1;
pub const WL_DATA_SOURCE_DND_DROP_PERFORMED_SINCE_VERSION = 3;
pub const WL_DATA_SOURCE_DND_FINISHED_SINCE_VERSION = 3;
pub const WL_DATA_SOURCE_ACTION_SINCE_VERSION = 3;
pub const WL_DATA_SOURCE_OFFER_SINCE_VERSION = 1;
pub const WL_DATA_SOURCE_DESTROY_SINCE_VERSION = 1;
pub const WL_DATA_SOURCE_SET_ACTIONS_SINCE_VERSION = 3;
pub const WL_DATA_DEVICE_DATA_OFFER = 0;
pub const WL_DATA_DEVICE_ENTER = 1;
pub const WL_DATA_DEVICE_LEAVE = 2;
pub const WL_DATA_DEVICE_MOTION = 3;
pub const WL_DATA_DEVICE_DROP = 4;
pub const WL_DATA_DEVICE_SELECTION = 5;
pub const WL_DATA_DEVICE_DATA_OFFER_SINCE_VERSION = 1;
pub const WL_DATA_DEVICE_ENTER_SINCE_VERSION = 1;
pub const WL_DATA_DEVICE_LEAVE_SINCE_VERSION = 1;
pub const WL_DATA_DEVICE_MOTION_SINCE_VERSION = 1;
pub const WL_DATA_DEVICE_DROP_SINCE_VERSION = 1;
pub const WL_DATA_DEVICE_SELECTION_SINCE_VERSION = 1;
pub const WL_DATA_DEVICE_START_DRAG_SINCE_VERSION = 1;
pub const WL_DATA_DEVICE_SET_SELECTION_SINCE_VERSION = 1;
pub const WL_DATA_DEVICE_RELEASE_SINCE_VERSION = 2;
pub const WL_DATA_DEVICE_MANAGER_CREATE_DATA_SOURCE_SINCE_VERSION = 1;
pub const WL_DATA_DEVICE_MANAGER_GET_DATA_DEVICE_SINCE_VERSION = 1;
pub const WL_SHELL_GET_SHELL_SURFACE_SINCE_VERSION = 1;
pub const WL_SHELL_SURFACE_PING = 0;
pub const WL_SHELL_SURFACE_CONFIGURE = 1;
pub const WL_SHELL_SURFACE_POPUP_DONE = 2;
pub const WL_SHELL_SURFACE_PING_SINCE_VERSION = 1;
pub const WL_SHELL_SURFACE_CONFIGURE_SINCE_VERSION = 1;
pub const WL_SHELL_SURFACE_POPUP_DONE_SINCE_VERSION = 1;
pub const WL_SHELL_SURFACE_PONG_SINCE_VERSION = 1;
pub const WL_SHELL_SURFACE_MOVE_SINCE_VERSION = 1;
pub const WL_SHELL_SURFACE_RESIZE_SINCE_VERSION = 1;
pub const WL_SHELL_SURFACE_SET_TOPLEVEL_SINCE_VERSION = 1;
pub const WL_SHELL_SURFACE_SET_TRANSIENT_SINCE_VERSION = 1;
pub const WL_SHELL_SURFACE_SET_FULLSCREEN_SINCE_VERSION = 1;
pub const WL_SHELL_SURFACE_SET_POPUP_SINCE_VERSION = 1;
pub const WL_SHELL_SURFACE_SET_MAXIMIZED_SINCE_VERSION = 1;
pub const WL_SHELL_SURFACE_SET_TITLE_SINCE_VERSION = 1;
pub const WL_SHELL_SURFACE_SET_CLASS_SINCE_VERSION = 1;
pub const WL_SURFACE_ENTER = 0;
pub const WL_SURFACE_LEAVE = 1;
pub const WL_SURFACE_ENTER_SINCE_VERSION = 1;
pub const WL_SURFACE_LEAVE_SINCE_VERSION = 1;
pub const WL_SURFACE_DESTROY_SINCE_VERSION = 1;
pub const WL_SURFACE_ATTACH_SINCE_VERSION = 1;
pub const WL_SURFACE_DAMAGE_SINCE_VERSION = 1;
pub const WL_SURFACE_FRAME_SINCE_VERSION = 1;
pub const WL_SURFACE_SET_OPAQUE_REGION_SINCE_VERSION = 1;
pub const WL_SURFACE_SET_INPUT_REGION_SINCE_VERSION = 1;
pub const WL_SURFACE_COMMIT_SINCE_VERSION = 1;
pub const WL_SURFACE_SET_BUFFER_TRANSFORM_SINCE_VERSION = 2;
pub const WL_SURFACE_SET_BUFFER_SCALE_SINCE_VERSION = 3;
pub const WL_SURFACE_DAMAGE_BUFFER_SINCE_VERSION = 4;
pub const WL_SEAT_CAPABILITIES = 0;
pub const WL_SEAT_NAME = 1;
pub const WL_SEAT_CAPABILITIES_SINCE_VERSION = 1;
pub const WL_SEAT_NAME_SINCE_VERSION = 2;
pub const WL_SEAT_GET_POINTER_SINCE_VERSION = 1;
pub const WL_SEAT_GET_KEYBOARD_SINCE_VERSION = 1;
pub const WL_SEAT_GET_TOUCH_SINCE_VERSION = 1;
pub const WL_SEAT_RELEASE_SINCE_VERSION = 5;
pub const WL_POINTER_AXIS_SOURCE_WHEEL_TILT_SINCE_VERSION = 6;
pub const WL_POINTER_ENTER = 0;
pub const WL_POINTER_LEAVE = 1;
pub const WL_POINTER_MOTION = 2;
pub const WL_POINTER_BUTTON = 3;
pub const WL_POINTER_AXIS = 4;
pub const WL_POINTER_FRAME = 5;
pub const WL_POINTER_AXIS_SOURCE = 6;
pub const WL_POINTER_AXIS_STOP = 7;
pub const WL_POINTER_AXIS_DISCRETE = 8;
pub const WL_POINTER_ENTER_SINCE_VERSION = 1;
pub const WL_POINTER_LEAVE_SINCE_VERSION = 1;
pub const WL_POINTER_MOTION_SINCE_VERSION = 1;
pub const WL_POINTER_BUTTON_SINCE_VERSION = 1;
pub const WL_POINTER_AXIS_SINCE_VERSION = 1;
pub const WL_POINTER_FRAME_SINCE_VERSION = 5;
pub const WL_POINTER_AXIS_SOURCE_SINCE_VERSION = 5;
pub const WL_POINTER_AXIS_STOP_SINCE_VERSION = 5;
pub const WL_POINTER_AXIS_DISCRETE_SINCE_VERSION = 5;
pub const WL_POINTER_SET_CURSOR_SINCE_VERSION = 1;
pub const WL_POINTER_RELEASE_SINCE_VERSION = 3;
pub const WL_KEYBOARD_KEYMAP = 0;
pub const WL_KEYBOARD_ENTER = 1;
pub const WL_KEYBOARD_LEAVE = 2;
pub const WL_KEYBOARD_KEY = 3;
pub const WL_KEYBOARD_MODIFIERS = 4;
pub const WL_KEYBOARD_REPEAT_INFO = 5;
pub const WL_KEYBOARD_KEYMAP_SINCE_VERSION = 1;
pub const WL_KEYBOARD_ENTER_SINCE_VERSION = 1;
pub const WL_KEYBOARD_LEAVE_SINCE_VERSION = 1;
pub const WL_KEYBOARD_KEY_SINCE_VERSION = 1;
pub const WL_KEYBOARD_MODIFIERS_SINCE_VERSION = 1;
pub const WL_KEYBOARD_REPEAT_INFO_SINCE_VERSION = 4;
pub const WL_KEYBOARD_RELEASE_SINCE_VERSION = 3;
pub const WL_TOUCH_DOWN = 0;
pub const WL_TOUCH_UP = 1;
pub const WL_TOUCH_MOTION = 2;
pub const WL_TOUCH_FRAME = 3;
pub const WL_TOUCH_CANCEL = 4;
pub const WL_TOUCH_SHAPE = 5;
pub const WL_TOUCH_ORIENTATION = 6;
pub const WL_TOUCH_DOWN_SINCE_VERSION = 1;
pub const WL_TOUCH_UP_SINCE_VERSION = 1;
pub const WL_TOUCH_MOTION_SINCE_VERSION = 1;
pub const WL_TOUCH_FRAME_SINCE_VERSION = 1;
pub const WL_TOUCH_CANCEL_SINCE_VERSION = 1;
pub const WL_TOUCH_SHAPE_SINCE_VERSION = 6;
pub const WL_TOUCH_ORIENTATION_SINCE_VERSION = 6;
pub const WL_TOUCH_RELEASE_SINCE_VERSION = 3;
pub const WL_OUTPUT_GEOMETRY = 0;
pub const WL_OUTPUT_MODE = 1;
pub const WL_OUTPUT_DONE = 2;
pub const WL_OUTPUT_SCALE = 3;
pub const WL_OUTPUT_GEOMETRY_SINCE_VERSION = 1;
pub const WL_OUTPUT_MODE_SINCE_VERSION = 1;
pub const WL_OUTPUT_DONE_SINCE_VERSION = 2;
pub const WL_OUTPUT_SCALE_SINCE_VERSION = 2;
pub const WL_OUTPUT_RELEASE_SINCE_VERSION = 3;
pub const WL_REGION_DESTROY_SINCE_VERSION = 1;
pub const WL_REGION_ADD_SINCE_VERSION = 1;
pub const WL_REGION_SUBTRACT_SINCE_VERSION = 1;
pub const WL_SUBCOMPOSITOR_DESTROY_SINCE_VERSION = 1;
pub const WL_SUBCOMPOSITOR_GET_SUBSURFACE_SINCE_VERSION = 1;
pub const WL_SUBSURFACE_DESTROY_SINCE_VERSION = 1;
pub const WL_SUBSURFACE_SET_POSITION_SINCE_VERSION = 1;
pub const WL_SUBSURFACE_PLACE_ABOVE_SINCE_VERSION = 1;
pub const WL_SUBSURFACE_PLACE_BELOW_SINCE_VERSION = 1;
pub const WL_SUBSURFACE_SET_SYNC_SINCE_VERSION = 1;
pub const WL_SUBSURFACE_SET_DESYNC_SINCE_VERSION = 1;
pub const XDG_WM_BASE_PING = 0;
pub const XDG_WM_BASE_PING_SINCE_VERSION = 1;
pub const XDG_WM_BASE_DESTROY_SINCE_VERSION = 1;
pub const XDG_WM_BASE_CREATE_POSITIONER_SINCE_VERSION = 1;
pub const XDG_WM_BASE_GET_XDG_SURFACE_SINCE_VERSION = 1;
pub const XDG_WM_BASE_PONG_SINCE_VERSION = 1;
pub const XDG_POSITIONER_DESTROY_SINCE_VERSION = 1;
pub const XDG_POSITIONER_SET_SIZE_SINCE_VERSION = 1;
pub const XDG_POSITIONER_SET_ANCHOR_RECT_SINCE_VERSION = 1;
pub const XDG_POSITIONER_SET_ANCHOR_SINCE_VERSION = 1;
pub const XDG_POSITIONER_SET_GRAVITY_SINCE_VERSION = 1;
pub const XDG_POSITIONER_SET_CONSTRAINT_ADJUSTMENT_SINCE_VERSION = 1;
pub const XDG_POSITIONER_SET_OFFSET_SINCE_VERSION = 1;
pub const XDG_POSITIONER_SET_REACTIVE_SINCE_VERSION = 3;
pub const XDG_POSITIONER_SET_PARENT_SIZE_SINCE_VERSION = 3;
pub const XDG_POSITIONER_SET_PARENT_CONFIGURE_SINCE_VERSION = 3;
pub const XDG_SURFACE_CONFIGURE = 0;
pub const XDG_SURFACE_CONFIGURE_SINCE_VERSION = 1;
pub const XDG_SURFACE_DESTROY_SINCE_VERSION = 1;
pub const XDG_SURFACE_GET_TOPLEVEL_SINCE_VERSION = 1;
pub const XDG_SURFACE_GET_POPUP_SINCE_VERSION = 1;
pub const XDG_SURFACE_SET_WINDOW_GEOMETRY_SINCE_VERSION = 1;
pub const XDG_SURFACE_ACK_CONFIGURE_SINCE_VERSION = 1;
pub const XDG_TOPLEVEL_STATE_TILED_LEFT_SINCE_VERSION = 2;
pub const XDG_TOPLEVEL_STATE_TILED_RIGHT_SINCE_VERSION = 2;
pub const XDG_TOPLEVEL_STATE_TILED_TOP_SINCE_VERSION = 2;
pub const XDG_TOPLEVEL_STATE_TILED_BOTTOM_SINCE_VERSION = 2;
pub const XDG_TOPLEVEL_CONFIGURE = 0;
pub const XDG_TOPLEVEL_CLOSE = 1;
pub const XDG_TOPLEVEL_CONFIGURE_SINCE_VERSION = 1;
pub const XDG_TOPLEVEL_CLOSE_SINCE_VERSION = 1;
pub const XDG_TOPLEVEL_DESTROY_SINCE_VERSION = 1;
pub const XDG_TOPLEVEL_SET_PARENT_SINCE_VERSION = 1;
pub const XDG_TOPLEVEL_SET_TITLE_SINCE_VERSION = 1;
pub const XDG_TOPLEVEL_SET_APP_ID_SINCE_VERSION = 1;
pub const XDG_TOPLEVEL_SHOW_WINDOW_MENU_SINCE_VERSION = 1;
pub const XDG_TOPLEVEL_MOVE_SINCE_VERSION = 1;
pub const XDG_TOPLEVEL_RESIZE_SINCE_VERSION = 1;
pub const XDG_TOPLEVEL_SET_MAX_SIZE_SINCE_VERSION = 1;
pub const XDG_TOPLEVEL_SET_MIN_SIZE_SINCE_VERSION = 1;
pub const XDG_TOPLEVEL_SET_MAXIMIZED_SINCE_VERSION = 1;
pub const XDG_TOPLEVEL_UNSET_MAXIMIZED_SINCE_VERSION = 1;
pub const XDG_TOPLEVEL_SET_FULLSCREEN_SINCE_VERSION = 1;
pub const XDG_TOPLEVEL_UNSET_FULLSCREEN_SINCE_VERSION = 1;
pub const XDG_TOPLEVEL_SET_MINIMIZED_SINCE_VERSION = 1;
pub const XDG_POPUP_CONFIGURE = 0;
pub const XDG_POPUP_POPUP_DONE = 1;
pub const XDG_POPUP_REPOSITIONED = 2;
pub const XDG_POPUP_CONFIGURE_SINCE_VERSION = 1;
pub const XDG_POPUP_POPUP_DONE_SINCE_VERSION = 1;
pub const XDG_POPUP_REPOSITIONED_SINCE_VERSION = 3;
pub const XDG_POPUP_DESTROY_SINCE_VERSION = 1;
pub const XDG_POPUP_GRAB_SINCE_VERSION = 1;
pub const XDG_POPUP_REPOSITION_SINCE_VERSION = 3;
