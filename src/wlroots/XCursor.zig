const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_xcursor
pub const XCursor = extern struct {
    extern fn wlr_xcursor_frame(cursor: *XCursor, time: u32) c_int;
    extern fn wlr_xcursor_get_resize_name(edges: wlroots.enum_wlr_edges) [*:0]const u8;

    /// struct wlr_xcursor_manager
    pub const Manager = extern struct {
        extern fn wlr_xcursor_manager_create(name: ?[*:0]const u8, size: u32) ?*Manager;
        extern fn wlr_xcursor_manager_destroy(manager: *Manager) void;
        extern fn wlr_xcursor_manager_get_xcursor(manager: *Manager, name: [*:0]const u8, scale: f32) ?*XCursor;
        extern fn wlr_xcursor_manager_load(manager: *Manager, scale: f32) bool;
        extern fn wlr_xcursor_manager_set_cursor_image(manager: *Manager, name: [*:0]const u8, cursor: *wlroots.Cursor) void;

        /// struct wlr_xcursor_manager_theme
        pub const ManagerTheme = extern struct {
            scale: f32,
            theme: [*c]Theme,
            link: wayland.ListElement(ManagerTheme, "link"),
        };

        name: [*c]u8,
        size: u32,
        scaled_themes: wayland.List(ManagerTheme, "link"),

        pub fn init(name: ?[*:0]const u8, size: u32) !*Manager {
            return wlr_xcursor_manager_create(name, size) orelse error.Failure;
        }

        pub fn load(manager: *Manager, scale: f32) !void {
            if (!manager.wlr_xcursor_manager_load(scale)) {
                return error.Failure;
            }
        }

        pub const deinit = wlr_xcursor_manager_destroy;
        pub const getXcursor = wlr_xcursor_manager_get_xcursor;
        pub const setCursorImage = wlr_xcursor_manager_set_cursor_image;
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

    pub const frame = wlr_xcursor_frame;
    pub const getResizeName = wlr_xcursor_get_resize_name;
};
