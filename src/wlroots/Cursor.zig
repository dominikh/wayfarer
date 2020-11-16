const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_cursor
pub const Cursor = extern struct {
    pub extern fn wlr_cursor_create() [*c]Cursor;
    pub extern fn wlr_cursor_destroy(cur: [*c]Cursor) void;
    pub extern fn wlr_cursor_warp(cur: [*c]Cursor, dev: [*c]wlroots.InputDevice, lx: f64, ly: f64) bool;
    pub extern fn wlr_cursor_absolute_to_layout_coords(cur: [*c]Cursor, dev: [*c]wlroots.InputDevice, x: f64, y: f64, lx: [*c]f64, ly: [*c]f64) void;
    pub extern fn wlr_cursor_warp_closest(cur: [*c]Cursor, dev: [*c]wlroots.InputDevice, x: f64, y: f64) void;
    pub extern fn wlr_cursor_warp_absolute(cur: [*c]Cursor, dev: [*c]wlroots.InputDevice, x: f64, y: f64) void;
    pub extern fn wlr_cursor_move(cur: [*c]Cursor, dev: [*c]wlroots.InputDevice, delta_x: f64, delta_y: f64) void;
    pub extern fn wlr_cursor_set_image(cur: [*c]Cursor, pixels: [*]const u8, stride: i32, width: u32, height: u32, hotspot_x: i32, hotspot_y: i32, scale: f32) void;
    pub extern fn wlr_cursor_set_surface(cur: [*c]Cursor, surface: [*c]wlroots.Surface, hotspot_x: i32, hotspot_y: i32) void;
    pub extern fn wlr_cursor_attach_input_device(cur: [*c]Cursor, dev: [*c]wlroots.InputDevice) void;
    pub extern fn wlr_cursor_detach_input_device(cur: [*c]Cursor, dev: [*c]wlroots.InputDevice) void;
    pub extern fn wlr_cursor_attach_output_layout(cur: [*c]Cursor, l: [*c]wlroots.Output.Layout) void;
    pub extern fn wlr_cursor_map_to_output(cur: [*c]Cursor, output: *wlroots.Output) void;
    pub extern fn wlr_cursor_map_input_to_output(cur: [*c]Cursor, dev: [*c]wlroots.Input.Device, output: *Output) void;
    pub extern fn wlr_cursor_map_to_region(cur: [*c]Cursor, box: [*c]Box) void;
    pub extern fn wlr_cursor_map_input_to_region(cur: [*c]Cursor, dev: [*c]wlroots.InputDevice, box: [*c]Box) void;

    pub const struct_wlr_cursor_state = opaque {};

    state: ?*struct_wlr_cursor_state,
    x: f64,
    y: f64,
    events: extern struct {
        motion: wayland.Signal(*wlroots.Pointer.Events.Motion),
        motion_absolute: wayland.Signal(*wlroots.Pointer.Events.MotionAbsolute),
        button: wayland.Signal(*wlroots.Pointer.Events.Button),
        axis: wayland.Signal(*wlroots.Pointer.Events.Axis),
        frame: wayland.Signal(*Cursor),
        swipe_begin: wayland.Signal(*wlroots.Pointer.Events.SwipeBegin),
        swipe_update: wayland.Signal(*wlroots.Pointer.Events.SwipeUpdate),
        swipe_end: wayland.Signal(*wlroots.Pointer.Events.SwipeEnd),
        pinch_begin: wayland.Signal(*wlroots.Pointer.Events.PinchBegin),
        pinch_update: wayland.Signal(*wlroots.Pointer.Events.PinchUpdate),
        pinch_end: wayland.Signal(*wlroots.Pointer.Events.PinchEnd),

        touch_up: wayland.Signal(*wlroots.Touch.Events.Up),
        touch_down: wayland.Signal(*wlroots.Touch.Events.Down),
        touch_motion: wayland.Signal(*wlroots.Touch.Events.Motion),
        touch_cancel: wayland.Signal(*wlroots.Touch.Events.Cancel),
        tablet_tool_axis: wayland.Signal(*wlroots.Tablet.Tool.Events.Axis),
        tablet_tool_proximity: wayland.Signal(*wlroots.Tablet.Tool.Events.Proximity),
        tablet_tool_tip: wayland.Signal(*wlroots.Tablet.Tool.Events.Tip),
        tablet_tool_button: wayland.Signal(*wlroots.Tablet.Tool.Events.Button),
    },
    data: ?*c_void,
};
