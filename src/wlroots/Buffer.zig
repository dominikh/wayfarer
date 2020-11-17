const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_buffer
pub const Buffer = extern struct {
    /// struct wlr_buffer_impl
    pub const Impl = extern struct {
        destroy: fn (*Buffer) callconv(.C) void,
        get_dmabuf: ?fn (*Buffer, [*]wlroots.DmabufAttributes) callconv(.C) bool,
    };

    extern fn wlr_buffer_init(buffer: *Buffer, impl: *const Impl, width: c_int, height: c_int) void;
    extern fn wlr_buffer_drop(buffer: *Buffer) void;
    extern fn wlr_buffer_lock(buffer: *Buffer) *Buffer;
    extern fn wlr_buffer_unlock(buffer: *Buffer) void;
    extern fn wlr_buffer_get_dmabuf(buffer: *Buffer, attribs: *wlroots.DmabufAttributes) bool;

    impl: [*c]const Impl,
    width: c_int,
    height: c_int,
    dropped: bool,
    n_locks: usize,
    events: extern struct {
        destroy: wayland.Signal(void),
        release: wayland.Signal(void),
    },

    pub const init = wlr_buffer_init;
    pub const drop = wlr_buffer_drop;
    pub const lock = wlr_buffer_lock;
    pub const unlock = wlr_buffer_unlock;
    pub const get_dmabuf = wlr_buffer_get_dmabuf;
};
