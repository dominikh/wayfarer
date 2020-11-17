const wayland = @import("../wayland.zig");

/// struct wlr_data_source
pub const DataSource = extern struct {
    /// struct wlr_data_source_impl
    pub const Impl = extern struct {
        send: ?fn ([*c]DataSource, [*c]const u8, i32) callconv(.C) void,
        accept: ?fn ([*c]DataSource, u32, [*c]const u8) callconv(.C) void,
        destroy: ?fn ([*c]DataSource) callconv(.C) void,
        dnd_drop: ?fn ([*c]DataSource) callconv(.C) void,
        dnd_finish: ?fn ([*c]DataSource) callconv(.C) void,
        dnd_action: ?fn ([*c]DataSource, wayland.enum_wl_data_device_manager_dnd_action) callconv(.C) void,
    };

    extern fn wlr_data_source_accept(source: *DataSource, serial: u32, mime_type: [*:0]const u8) void;
    extern fn wlr_data_source_destroy(source: *DataSource) void;
    extern fn wlr_data_source_dnd_action(source: *DataSource, action: wayland.enum_wl_data_device_manager_dnd_action) void;
    extern fn wlr_data_source_dnd_drop(source: *DataSource) void;
    extern fn wlr_data_source_dnd_finish(source: *DataSource) void;
    extern fn wlr_data_source_init(source: *DataSource, impl: [*c]const Impl) void;
    extern fn wlr_data_source_send(source: *DataSource, mime_type: [*:0]const u8, fd: i32) void;

    impl: [*c]const Impl,
    mime_types: wayland.struct_wl_array,
    actions: i32,
    accepted: bool,
    current_dnd_action: wayland.enum_wl_data_device_manager_dnd_action,
    compositor_action: u32,
    events: extern struct {
        destroy: wayland.Signal(?*c_void),
    },

    pub const accept = wlr_data_source_accept;
    pub const deinit = wlr_data_source_destroy;
    pub const dndAction = wlr_data_source_dnd_action;
    pub const dndDrop = wlr_data_source_dnd_drop;
    pub const dndFinish = wlr_data_source_dnd_finish;
    pub const init = wlr_data_source_init;
    pub const send = wlr_data_source_send;
};
