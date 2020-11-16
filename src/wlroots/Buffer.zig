const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_buffer
pub const Buffer = extern struct {
    /// struct wlr_buffer_impl
    pub const Impl = extern struct {
        destroy: fn (*Buffer) callconv(.C) void,
        get_dmabuf: ?fn (*Buffer, [*]wlroots.DmabufAttributes) callconv(.C) bool,
    };

    pub extern fn wlr_buffer_init(buffer: *Buffer, impl: [*c]const Impl, width: c_int, height: c_int) void;
    pub extern fn wlr_buffer_drop(buffer: *Buffer) void;
    pub extern fn wlr_buffer_lock(buffer: *Buffer) [*c]Buffer;
    pub extern fn wlr_buffer_unlock(buffer: *Buffer) void;
    pub extern fn wlr_buffer_get_dmabuf(buffer: *Buffer, attribs: [*c]wlroots.DmabufAttributes) bool;

    impl: [*c]const Impl,
    width: c_int,
    height: c_int,
    dropped: bool,
    n_locks: usize,
    events: extern struct {
        destroy: wayland.Signal(void),
        release: wayland.Signal(void),
    },
};
