const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_input_device
pub const InputDevice = extern struct {
    /// struct wlr_input_device_impl
    pub const Impl = opaque {};

    /// enum wlr_input_device_type
    pub const Type = extern enum(c_int) {
        Keyboard,
        Pointer,
        Touch,
        TabletTool,
        TabletPad,
        Switch,
        _,
    };

    impl: ?*const Impl,
    type: Type,
    vendor: c_uint,
    product: c_uint,
    name: [*c]u8,
    width_mm: f64,
    height_mm: f64,
    output_name: [*c]u8,
    unnamed_0: extern union {
        _device: ?*c_void,
        keyboard: *wlroots.Keyboard,
        pointer: *wlroots.Pointer,
        switch_device: *wlroots.Switch,
        touch: *wlroots.Touch,
        tablet: *wlroots.Tablet,
        tablet_pad: *wlroots.Tablet.Pad,
    },
    events: extern struct {
        destroy: wayland.Signal(?*c_void),
    },
    data: ?*c_void,
    link: wayland.ListElement(InputDevice, "link"),
};
