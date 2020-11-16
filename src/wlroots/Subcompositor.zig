const wayland = @import("../wayland.zig");

/// struct wlr_subcompositor
pub const Subcompositor = extern struct {
    global: ?*wayland.Global,
};
