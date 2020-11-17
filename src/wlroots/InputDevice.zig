const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_input_device
pub const InputDevice = extern struct {
    /// struct wlr_input_device_impl
    pub const Impl = opaque {};

    /// enum wlr_input_device_type
    pub const Type = extern enum(c_int) {
        keyboard,
        pointer,
        touch,
        tablet_tool,
        tablet_pad,
        @"switch",
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

    pub fn device(self: *InputDevice) union(Type) {
        keyboard: *wlroots.Keyboard,
        pointer: *wlroots.Pointer,
        touch: *wlroots.Touch,
        tablet_tool: *wlroots.Tablet,
        tablet_pad: *wlroots.Tablet.Pad,
        @"switch": *wlroots.Switch,
    } {
        return switch (self.type) {
            .keyboard => .{ .keyboard = self.unnamed_0.keyboard },
            .pointer => .{ .pointer = self.unnamed_0.pointer },
            .touch => .{ .touch = self.unnamed_0.touch },
            .tablet_tool => .{ .tablet_tool = self.unnamed_0.tablet },
            .tablet_pad => .{ .tablet_pad = self.unnamed_0.tablet_pad },
            .@"switch" => .{ .@"switch" = self.unnamed_0.switch_device },
        };
    }
};
