const wayland = @import("../wayland.zig");
usingnamespace @import("../pixman.zig");
const wlroots = @import("../wlroots.zig");

pub const Output = extern struct {
    pub extern fn wlr_output_enable(output: *Output, enable: bool) void;
    pub extern fn wlr_output_create_global(output: *Output) void;
    pub extern fn wlr_output_destroy_global(output: *Output) void;
    pub extern fn wlr_output_preferred_mode(output: *Output) [*c]Mode;
    pub extern fn wlr_output_set_mode(output: *Output, mode: [*c]Mode) void;
    pub extern fn wlr_output_set_custom_mode(output: *Output, width: i32, height: i32, refresh: i32) void;
    pub extern fn wlr_output_set_transform(output: *Output, transform: wayland.Output.Transform) void;
    pub extern fn wlr_output_enable_adaptive_sync(output: *Output, enabled: bool) void;
    pub extern fn wlr_output_set_scale(output: *Output, scale: f32) void;
    pub extern fn wlr_output_set_subpixel(output: *Output, subpixel: wayland.Output.Subpixel) void;
    pub extern fn wlr_output_set_description(output: *Output, desc: [*c]const u8) void;
    pub extern fn wlr_output_schedule_done(output: *Output) void;
    pub extern fn wlr_output_destroy(output: *Output) void;
    pub extern fn wlr_output_transformed_resolution(output: *Output, width: [*c]c_int, height: [*c]c_int) void;
    pub extern fn wlr_output_effective_resolution(output: *Output, width: [*c]c_int, height: [*c]c_int) void;
    pub extern fn wlr_output_attach_render(output: *Output, buffer_age: [*c]c_int) bool;
    pub extern fn wlr_output_attach_buffer(output: *Output, buffer: [*c]wlroots.Buffer) void;
    pub extern fn wlr_output_preferred_read_format(output: *Output, fmt: [*c]enum_wl_shm_format) bool;
    pub extern fn wlr_output_set_damage(output: *Output, damage: [*c]pixman_region32_t) void;
    pub extern fn wlr_output_test(output: *Output) bool;
    pub extern fn wlr_output_commit(output: *Output) bool;
    pub extern fn wlr_output_rollback(output: *Output) void;
    pub extern fn wlr_output_schedule_frame(output: *Output) void;
    pub extern fn wlr_output_get_gamma_size(output: *Output) usize;
    pub extern fn wlr_output_set_gamma(output: *Output, size: usize, r: [*c]const u16, g: [*c]const u16, b: [*c]const u16) void;
    pub extern fn wlr_output_export_dmabuf(output: *Output, attribs: [*c]struct_wlr_dmabuf_attributes) bool;
    pub extern fn wlr_output_from_resource(resource: [*c]wayland.Resource) [*c]Output;
    pub extern fn wlr_output_lock_attach_render(output: *Output, lock: bool) void;
    pub extern fn wlr_output_lock_software_cursors(output: *Output, lock: bool) void;
    pub extern fn wlr_output_render_software_cursors(output: *Output, damage: [*c]pixman_region32_t) void;
    pub extern fn wlr_output_cursor_create(output: *Output) [*c]OutputCursor;
    pub extern fn wlr_output_cursor_set_image(cursor: [*c]OutputCursor, pixels: [*c]const u8, stride: i32, width: u32, height: u32, hotspot_x: i32, hotspot_y: i32) bool;
    pub extern fn wlr_output_cursor_set_surface(cursor: [*c]OutputCursor, surface: [*c]Surface, hotspot_x: i32, hotspot_y: i32) void;
    pub extern fn wlr_output_cursor_move(cursor: [*c]OutputCursor, x: f64, y: f64) bool;
    pub extern fn wlr_output_cursor_destroy(cursor: [*c]OutputCursor) void;
    pub extern fn wlr_output_transform_invert(tr: wayland.Output.Transform) wayland.Output.Transform;
    pub extern fn wlr_output_transform_compose(tr_a: wayland.Output.Transform, tr_b: wayland.Output.Transform) wayland.Output.Transform;

    pub const enum_wl_output_mode = extern enum(c_int) {
        WL_OUTPUT_MODE_CURRENT = 1,
        WL_OUTPUT_MODE_PREFERRED = 2,
        _,
    };

    pub const OutputCursor = extern struct {
        output: [*c]Output,
        x: f64,
        y: f64,
        enabled: bool,
        visible: bool,
        width: u32,
        height: u32,
        hotspot_x: i32,
        hotspot_y: i32,
        link: wayland.ListElement(OutputCursor, "link"),
        texture: [*c]wlroots.Texture,
        surface: [*c]wlroots.Surface,
        surface_commit: wayland.Listener(?*c_void),
        surface_destroy: wayland.Listener(?*c_void),
        events: extern struct {
            destroy: wayland.Signal(?*c_void),
        },
    };

    pub const StateField = extern enum(c_int) {
        WLR_OUTPUT_STATE_BUFFER = 1,
        WLR_OUTPUT_STATE_DAMAGE = 2,
        WLR_OUTPUT_STATE_MODE = 4,
        WLR_OUTPUT_STATE_ENABLED = 8,
        WLR_OUTPUT_STATE_SCALE = 16,
        WLR_OUTPUT_STATE_TRANSFORM = 32,
        WLR_OUTPUT_STATE_ADAPTIVE_SYNC_ENABLED = 64,
        WLR_OUTPUT_STATE_GAMMA_LUT = 128,
        _,
    };
    pub const struct_wlr_output_event_damage = extern struct {
        output: *Output,
        damage: [*c]pixman_region32_t,
    };
    pub const struct_wlr_output_event_precommit = extern struct {
        output: *Output,
        when: [*c]std.os.timespec,
    };
    pub const enum_wlr_output_present_flag = extern enum(c_int) {
        WLR_OUTPUT_PRESENT_VSYNC = 1,
        WLR_OUTPUT_PRESENT_HW_CLOCK = 2,
        WLR_OUTPUT_PRESENT_HW_COMPLETION = 4,
        WLR_OUTPUT_PRESENT_ZERO_COPY = 8,
        _,
    };
    pub const struct_wlr_output_event_present = extern struct {
        output: *Output,
        commit_seq: u32,
        when: [*c]std.os.timespec,
        seq: c_uint,
        refresh: c_int,
        flags: u32,
    };

    pub const Layout = extern struct {
        pub const Direction = extern enum(c_int) {
            Up = 1,
            Down = 2,
            Left = 4,
            Right = 8,
            _,
        };

        pub extern fn wlr_output_layout_create() [*c]Layout;
        pub extern fn wlr_output_layout_destroy(layout: [*c]Layout) void;
        pub extern fn wlr_output_layout_get(layout: [*c]Layout, reference: [*c]Output) [*c]LayoutOutput;
        pub extern fn wlr_output_layout_output_at(layout: [*c]Layout, lx: f64, ly: f64) [*c]Output;
        pub extern fn wlr_output_layout_add(layout: [*c]Layout, output: *Output, lx: c_int, ly: c_int) void;
        pub extern fn wlr_output_layout_move(layout: [*c]Layout, output: *Output, lx: c_int, ly: c_int) void;
        pub extern fn wlr_output_layout_remove(layout: [*c]Layout, output: *Output) void;
        pub extern fn wlr_output_layout_output_coords(layout: [*c]Layout, reference: [*c]Output, lx: [*c]f64, ly: [*c]f64) void;
        pub extern fn wlr_output_layout_contains_point(layout: [*c]Layout, reference: [*c]Output, lx: c_int, ly: c_int) bool;
        pub extern fn wlr_output_layout_intersects(layout: [*c]Layout, reference: [*c]Output, target_lbox: [*c]const wlroots.Box) bool;
        pub extern fn wlr_output_layout_closest_point(layout: [*c]Layout, reference: [*c]Output, lx: f64, ly: f64, dest_lx: [*c]f64, dest_ly: [*c]f64) void;
        pub extern fn wlr_output_layout_get_box(layout: [*c]Layout, reference: [*c]Output) [*c]wlroots.Box;
        pub extern fn wlr_output_layout_add_auto(layout: [*c]Layout, output: *Output) void;
        pub extern fn wlr_output_layout_get_center_output(layout: [*c]Layout) [*c]Output;
        pub extern fn wlr_output_layout_adjacent_output(layout: [*c]Layout, direction: Direction, reference: [*c]Output, ref_lx: f64, ref_ly: f64) [*c]Output;
        pub extern fn wlr_output_layout_farthest_output(layout: [*c]Layout, direction: Direction, reference: [*c]Output, ref_lx: f64, ref_ly: f64) [*c]Output;

        pub const struct_wlr_output_layout_state = opaque {};
        pub const LayoutOutput = extern struct {
            pub const struct_wlr_output_layout_output_state = opaque {};

            output: [*c]Output,
            x: c_int,
            y: c_int,
            link: wayland.ListElement(LayoutOutput, "link"),
            state: ?*struct_wlr_output_layout_output_state,
            events: extern struct {
                destroy: wayland.Signal(?*c_void),
            },
        };

        // XXX make sure this list type is correct
        outputs: wayland.List(LayoutOutput, "link"),
        state: ?*struct_wlr_output_layout_state,
        events: extern struct {
            add: wayland.Signal(?*c_void),
            change: wayland.Signal(?*c_void),
            destroy: wayland.Signal(?*c_void),
        },
        data: ?*c_void,
    };

    pub const Mode = extern struct {
        width: i32,
        height: i32,
        refresh: i32,
        preferred: bool,
        link: wayland.ListElement(Mode, "link"),
    };

    pub const Impl = opaque {};
    pub const enum_wlr_output_adaptive_sync_status = extern enum(c_int) {
        WLR_OUTPUT_ADAPTIVE_SYNC_DISABLED,
        WLR_OUTPUT_ADAPTIVE_SYNC_ENABLED,
        WLR_OUTPUT_ADAPTIVE_SYNC_UNKNOWN,
        _,
    };

    pub const State = extern struct {
        pub const BufferType = extern enum(c_int) {
            WLR_OUTPUT_STATE_BUFFER_RENDER,
            WLR_OUTPUT_STATE_BUFFER_SCANOUT,
            _,
        };
        pub const ModeType = extern enum(c_int) {
            WLR_OUTPUT_STATE_MODE_FIXED,
            WLR_OUTPUT_STATE_MODE_CUSTOM,
            _,
        };

        committed: u32,
        damage: pixman_region32_t,
        enabled: bool,
        scale: f32,
        transform: wayland.Output.Transform,
        adaptive_sync_enabled: bool,
        buffer_type: BufferType,
        buffer: [*c]wlroots.Buffer,
        mode_type: ModeType,
        mode: [*c]Mode,
        custom_mode: extern struct {
            width: i32,
            height: i32,
            refresh: i32,
        },
        gamma_lut: [*c]u16,
        gamma_lut_size: usize,
    };

    impl: ?*const Impl,
    backend: [*c]wlroots.Backend,
    display: ?*wayland.Display,
    global: ?*wayland.Global,
    resources: wayland.List(wayland.Resource, "link"),
    name: [24]u8,
    description: [*c]u8,
    make: [56]u8,
    model: [16]u8,
    serial: [16]u8,
    phys_width: i32,
    phys_height: i32,
    modes: wayland.List(Mode, "link"),
    current_mode: [*c]Mode,
    width: i32,
    height: i32,
    refresh: i32,
    enabled: bool,
    scale: f32,
    subpixel: wayland.Output.Subpixel,
    transform: wayland.Output.Transform,
    adaptive_sync_status: enum_wlr_output_adaptive_sync_status,
    needs_frame: bool,
    frame_pending: bool,
    transform_matrix: [9]f32,
    pending: State,
    commit_seq: u32,
    events: extern struct {
        frame: wayland.Signal(*Output),
        damage: wayland.Signal(?*c_void),
        needs_frame: wayland.Signal(?*c_void),
        precommit: wayland.Signal(?*c_void),
        commit: wayland.Signal(?*c_void),
        present: wayland.Signal(?*c_void),
        enable: wayland.Signal(?*c_void),
        mode: wayland.Signal(?*c_void),
        scale: wayland.Signal(?*c_void),
        transform: wayland.Signal(?*c_void),
        description: wayland.Signal(?*c_void),
        destroy: wayland.Signal(*Output),
    },
    idle_frame: ?*wayland.EventSource,
    idle_done: ?*wayland.EventSource,
    attach_render_locks: c_int,
    cursors: wayland.List(OutputCursor, "link"),
    hardware_cursor: [*c]OutputCursor,
    software_cursor_locks: c_int,
    display_destroy: wayland.Listener(?*c_void),
    data: ?*c_void,
};
