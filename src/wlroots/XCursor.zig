const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_xcursor
pub const XCursor = extern struct {
    pub extern fn wlr_xcursor_frame(cursor: [*c]XCursor, time: u32) c_int;
    pub extern fn wlr_xcursor_get_resize_name(edges: enum_wlr_edges) [*c]const u8;

    /// struct wlr_xcursor_manager
    pub const Manager = extern struct {
        pub extern fn wlr_xcursor_manager_create(name: ?[*:0]const u8, size: u32) [*c]Manager;
        pub extern fn wlr_xcursor_manager_destroy(manager: [*c]Manager) void;
        pub extern fn wlr_xcursor_manager_get_xcursor(manager: [*c]Manager, name: [*:0]const u8, scale: f32) [*c]XCursor;
        pub extern fn wlr_xcursor_manager_load(manager: [*c]Manager, scale: f32) bool;
        pub extern fn wlr_xcursor_manager_set_cursor_image(manager: [*c]Manager, name: [*:0]const u8, cursor: [*c]wlroots.Cursor) void;

        /// struct wlr_xcursor_manager_theme
        pub const ManagerTheme = extern struct {
            scale: f32,
            theme: [*c]Theme,
            link: wayland.ListElement(ManagerTheme, "link"),
        };

        name: [*c]u8,
        size: u32,
        scaled_themes: wayland.List(ManagerTheme, "link"),
    };

    /// struct wlr_xcursor_theme
    pub const Theme = extern struct {
        pub extern fn wlr_xcursor_theme_destroy(theme: [*c]Theme) void;
        pub extern fn wlr_xcursor_theme_get_cursor(theme: [*c]Theme, name: [*:0]const u8) [*c]XCursor;
        pub extern fn wlr_xcursor_theme_load(name: [*:0]const u8, size: c_int) [*c]Theme;

        cursor_count: c_uint,
        cursors: [*c][*c]XCursor,
        name: [*c]u8,
        size: c_int,
    };

    /// struct wlr_xcursor_image
    pub const Image = extern struct {
        width: u32,
        height: u32,
        hotspot_x: u32,
        hotspot_y: u32,
        delay: u32,
        buffer: [*c]u8,
    };

    image_count: c_uint,
    images: [*]*Image,
    name: [*:0]u8,
    total_delay: u32,
};
