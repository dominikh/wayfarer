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
                state: ProximityState,
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
                state: wlroots.ButtonState,
            };
        };

        /// enum wlr_tablet_tool_proximity_state
        pub const ProximityState = extern enum(c_int) {
            out,
            in,
        };

        /// enum wlr_tablet_tool_axes
        pub const Axes = struct {
            pub const x: c_int = 1;
            pub const y: c_int = 2;
            pub const distance: c_int = 4;
            pub const pressure: c_int = 8;
            pub const tilt_x: c_int = 16;
            pub const tilt_y: c_int = 32;
            pub const rotation: c_int = 64;
            pub const slider: c_int = 128;
            pub const wheel: c_int = 256;
        };

        /// enum wlr_tablet_tool_type
        pub const Type = extern enum(c_int) {
            pen = 1,
            eraser = 2,
            brush = 3,
            pencil = 4,
            airbrush = 5,
            mouse = 6,
            lens = 7,
            totem = 8,
        };

        /// enum wlr_tablet_tool_tip_state
        pub const TipState = extern enum(c_int) {
            up,
            down,
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
        pub const Events = struct {
            /// struct wlr_event_tablet_pad_button
            pub const Button = extern struct {
                time_msec: u32,
                button: u32,
                state: wlroots.ButtonState,
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
            unknown,
            finger,
        };

        /// enum wlr_tablet_pad_strip_source
        pub const StripSource = extern enum(c_int) {
            unknown,
            finger,
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
        pub const PadImpl = extern struct {
            destroy: ?fn (*Pad) callconv(.C) void,
        };

        impl: ?*PadImpl,
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

        pub extern fn wlr_tablet_pad_init(pad: *Pad, impl: *PadImpl) void;
        pub extern fn wlr_tablet_pad_destroy(pad: *Pad) void;

        pub const init = wlr_tablet_pad_init;
        pub const deinit = wlr_tablet_pad_destroy;
    };

    /// struct wlr_tablet_impl
    pub const Impl = extern struct {
        destroy: ?fn (*Tablet) callconv(.C) void,
    };

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

    extern fn wlr_tablet_init(tablet: *Tablet, impl: *Impl) void;
    extern fn wlr_tablet_destroy(tablet: *Tablet) void;

    pub const init = wlr_tablet_init;
    pub const deinit = wlr_tablet_destroy;
};
