const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_switch
pub const Switch = extern struct {
    /// enum wlr_switch_type
    pub const Type = extern enum(c_int) {
        Lid = 1,
        TabletMode = 2,
        _,
    };

    /// enum wlr_switch_state
    pub const State = extern enum(c_int) {
        Off = 0,
        On = 1,
        Toggle = 2,
        _,
    };

    pub const Events = struct {
        /// struct wlr_event_switch_toggle
        pub const Toggle = extern struct {
            device: *wlroots.InputDevice,
            time_msec: u32,
            switch_type: Type,
            switch_state: State,
        };
    };

    /// struct wlr_switch_impl
    pub const Impl = opaque {};

    impl: ?*Impl,
    events: extern struct {
        toggle: wayland.Signal(*Events.Toggle),
    },
    data: ?*c_void,
};
