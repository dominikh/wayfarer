const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

pub const Tablet = extern struct {
    /// struct wlr_tablet_tool
    pub const Tool = extern struct {
        pub const Events = struct {
            /// struct wlr_event_tablet_tool_axis
            pub const Axis = extern struct {
                device: [*c]wlroots.InputDevice,
                tool: [*c]Tool,
                time_msec: u32,
                updated_axes: u32,
                x: f64,
                y: f64,
                dx: f64,
                dy: f64,
                pressure: f64,
                distance: f64,
                tilt_x: f64,
                tilt_y: f64,
                rotation: f64,
                slider: f64,
                wheel_delta: f64,
            };

            /// struct wlr_event_tablet_tool_proximity
            pub const Proximity = extern struct {
                device: [*c]wlroots.InputDevice,
                tool: [*c]Tool,
                time_msec: u32,
                x: f64,
                y: f64,
                state: enum_wlr_tablet_tool_proximity_state,
            };

            /// struct wlr_event_tablet_tool_tip
            pub const Tip = extern struct {
                device: [*c]wlroots.InputDevice,
                tool: [*c]Tool,
                time_msec: u32,
                x: f64,
                y: f64,
                state: TipState,
            };

            /// struct wlr_event_tablet_tool_button
            pub const Button = extern struct {
                device: [*c]wlroots.InputDevice,
                tool: [*c]Tool,
                time_msec: u32,
                button: u32,
                state: wlroots.enum_wlr_button_state,
            };
        };

        /// enum wlr_tablet_tool_proximity_state
        pub const enum_wlr_tablet_tool_proximity_state = extern enum(c_int) {
            WLR_TABLET_TOOL_PROXIMITY_OUT,
            WLR_TABLET_TOOL_PROXIMITY_IN,
            _,
        };

        /// enum wlr_tablet_tool_axes
        pub const Axes = struct {
            pub const WLR_TABLET_TOOL_AXIS_X: c_int = 1;
            pub const WLR_TABLET_TOOL_AXIS_Y: c_int = 2;
            pub const WLR_TABLET_TOOL_AXIS_DISTANCE: c_int = 4;
            pub const WLR_TABLET_TOOL_AXIS_PRESSURE: c_int = 8;
            pub const WLR_TABLET_TOOL_AXIS_TILT_X: c_int = 16;
            pub const WLR_TABLET_TOOL_AXIS_TILT_Y: c_int = 32;
            pub const WLR_TABLET_TOOL_AXIS_ROTATION: c_int = 64;
            pub const WLR_TABLET_TOOL_AXIS_SLIDER: c_int = 128;
            pub const WLR_TABLET_TOOL_AXIS_WHEEL: c_int = 256;
        };

        /// enum wlr_tablet_tool_type
        pub const Type = extern enum(c_int) {
            WLR_TABLET_TOOL_TYPE_PEN = 1,
            WLR_TABLET_TOOL_TYPE_ERASER = 2,
            WLR_TABLET_TOOL_TYPE_BRUSH = 3,
            WLR_TABLET_TOOL_TYPE_PENCIL = 4,
            WLR_TABLET_TOOL_TYPE_AIRBRUSH = 5,
            WLR_TABLET_TOOL_TYPE_MOUSE = 6,
            WLR_TABLET_TOOL_TYPE_LENS = 7,
            WLR_TABLET_TOOL_TYPE_TOTEM = 8,
        };

        /// enum wlr_tablet_tool_tip_state
        pub const TipState = extern enum(c_int) {
            WLR_TABLET_TOOL_TIP_UP,
            WLR_TABLET_TOOL_TIP_DOWN,
        };

        type: Type,
        hardware_serial: u64,
        hardware_wacom: u64,
        tilt: bool,
        pressure: bool,
        distance: bool,
        rotation: bool,
        slider: bool,
        wheel: bool,
        events: extern struct {
            destroy: wayland.Signal(?*c_void),
        },
        data: ?*c_void,
    };

    /// struct wlr_tablet_pad
    pub const Pad = extern struct {
        const Events = struct {
            /// struct wlr_event_tablet_pad_button
            pub const Button = extern struct {
                time_msec: u32,
                button: u32,
                state: wlroots.enum_wlr_button_state,
                mode: c_uint,
                group: c_uint,
            };

            /// struct wlr_event_tablet_pad_ring
            pub const Ring = extern struct {
                time_msec: u32,
                source: RingSource,
                ring: u32,
                position: f64,
                mode: c_uint,
            };

            /// struct wlr_event_tablet_pad_strip
            pub const Strip = extern struct {
                time_msec: u32,
                source: StripSource,
                strip: u32,
                position: f64,
                mode: c_uint,
            };
        };

        /// enum wlr_tablet_pad_ring_source
        pub const RingSource = extern enum(c_int) {
            WLR_TABLET_PAD_RING_SOURCE_UNKNOWN,
            WLR_TABLET_PAD_RING_SOURCE_FINGER,
        };

        /// enum wlr_tablet_pad_strip_source
        pub const StripSource = extern enum(c_int) {
            WLR_TABLET_PAD_STRIP_SOURCE_UNKNOWN,
            WLR_TABLET_PAD_STRIP_SOURCE_FINGER,
        };

        /// struct wlr_tablet_pad_group
        pub const Group = extern struct {
            link: wayland.ListElement(Group, "link"),
            button_count: usize,
            buttons: [*]c_uint,
            strip_count: usize,
            strips: [*]c_uint,
            ring_count: usize,
            rings: [*]c_uint,
            mode_count: c_uint,
        };

        /// struct wlr_tablet_pad_impl
        pub const Impl = opaque {};

        impl: ?*Impl,
        events: extern struct {
            button: wayland.Signal(*Events.Button),
            ring: wayland.Signal(*Events.Ring),
            strip: wayland.Signal(*Events.Strip),
            attach_tablet: wayland.Signal(*wlroots.InputDevice),
        },
        button_count: usize,
        ring_count: usize,
        strip_count: usize,
        groups: wayland.List(Group, "link"),
        paths: wlroots.List,
        data: ?*c_void,
    };

    /// struct wlr_tablet_impl
    pub const Impl = opaque {};

    impl: ?*Impl,
    events: extern struct {
        axis: wayland.Signal(*Tool.Events.Axis),
        proximity: wayland.Signal(*Tool.Events.Proximity),
        tip: wayland.Signal(*Tool.Events.Tip),
        button: wayland.Signal(*Tool.Events.Button),
    },
    name: [*c]u8,
    paths: wlroots.List,
    data: ?*c_void,
};
