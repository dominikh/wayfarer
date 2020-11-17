const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_cursor
pub const Cursor = extern struct {
    extern fn wlr_cursor_create() ?*Cursor;
    extern fn wlr_cursor_destroy(cur: *Cursor) void;
    extern fn wlr_cursor_warp(cur: *Cursor, dev: ?*wlroots.InputDevice, lx: f64, ly: f64) bool;
    extern fn wlr_cursor_absolute_to_layout_coords(cur: *Cursor, dev: ?*wlroots.InputDevice, x: f64, y: f64, lx: *f64, ly: *f64) void;
    extern fn wlr_cursor_warp_closest(cur: *Cursor, dev: ?*wlroots.InputDevice, x: f64, y: f64) void;
    extern fn wlr_cursor_warp_absolute(cur: *Cursor, dev: ?*wlroots.InputDevice, x: f64, y: f64) void;
    extern fn wlr_cursor_move(cur: *Cursor, dev: ?*wlroots.InputDevice, delta_x: f64, delta_y: f64) void;
    extern fn wlr_cursor_set_image(cur: *Cursor, pixels: [*]const u8, stride: i32, width: u32, height: u32, hotspot_x: i32, hotspot_y: i32, scale: f32) void;
    extern fn wlr_cursor_set_surface(cur: *Cursor, surface: ?*wlroots.Surface, hotspot_x: i32, hotspot_y: i32) void;
    extern fn wlr_cursor_attach_input_device(cur: *Cursor, dev: *wlroots.InputDevice) void;
    extern fn wlr_cursor_detach_input_device(cur: *Cursor, dev: *wlroots.InputDevice) void;
    extern fn wlr_cursor_attach_output_layout(cur: *Cursor, l: *wlroots.Output.Layout) void;
    extern fn wlr_cursor_map_to_output(cur: *Cursor, output: *wlroots.Output) void;
    extern fn wlr_cursor_map_input_to_output(cur: *Cursor, dev: *wlroots.InputDevice, output: *Output) void;
    extern fn wlr_cursor_map_to_region(cur: *Cursor, box: *Box) void;
    extern fn wlr_cursor_map_input_to_region(cur: *Cursor, dev: *wlroots.InputDevice, box: *Box) void;

    // struct wlr_cursor_state
    pub const State = opaque {};

    state: *State,
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

    pub fn init() !*Cursor {
        return wlr_cursor_create() orelse error.Failure;
    }

    pub const deinit = wlr_cursor_destroy;
    pub const warp = wlr_cursor_warp;
    pub const absoluteToLayoutCoords = wlr_cursor_absolute_to_layout_coords;
    pub const warpClosest = wlr_cursor_warp_closest;
    pub const warpAbsolute = wlr_cursor_warp_absolute;
    pub const move = wlr_cursor_move;
    pub const setImage = wlr_cursor_set_image;
    pub const setSurface = wlr_cursor_set_surface;
    pub const attachInputDevice = wlr_cursor_attach_input_device;
    pub const detachInputDevice = wlr_cursor_detach_input_device;
    pub const attachOutputLayout = wlr_cursor_attach_output_layout;
    pub const mapToOutput = wlr_cursor_map_to_output;
    pub const mapInputToOutput = wlr_cursor_map_input_to_output;
    pub const mapToRegion = wlr_cursor_map_to_region;
    pub const mapInputToRegion = wlr_cursor_map_input_to_region;
};
