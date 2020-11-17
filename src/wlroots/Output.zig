const std = @import("std");
const wayland = @import("../wayland.zig");
usingnamespace @import("../pixman.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_output
pub const Output = extern struct {
    extern fn wlr_output_enable(output: *Output, enable: bool) void;
    extern fn wlr_output_create_global(output: *Output) void;
    extern fn wlr_output_destroy_global(output: *Output) void;
    extern fn wlr_output_preferred_mode(output: *Output) ?*Mode;
    extern fn wlr_output_set_mode(output: *Output, mode: *Mode) void;
    extern fn wlr_output_set_custom_mode(output: *Output, width: i32, height: i32, refresh: i32) void;
    extern fn wlr_output_set_transform(output: *Output, transform: wayland.Output.Transform) void;
    extern fn wlr_output_enable_adaptive_sync(output: *Output, enabled: bool) void;
    extern fn wlr_output_set_scale(output: *Output, scale: f32) void;
    extern fn wlr_output_set_subpixel(output: *Output, subpixel: wayland.Output.Subpixel) void;
    extern fn wlr_output_set_description(output: *Output, desc: [*:0]const u8) void;
    extern fn wlr_output_schedule_done(output: *Output) void;
    extern fn wlr_output_destroy(output: *Output) void;
    extern fn wlr_output_transformed_resolution(output: *Output, width: *c_int, height: *c_int) void;
    extern fn wlr_output_effective_resolution(output: *Output, width: *c_int, height: *c_int) void;
    extern fn wlr_output_attach_render(output: *Output, buffer_age: ?*c_int) bool;
    extern fn wlr_output_attach_buffer(output: *Output, buffer: *wlroots.Buffer) void;
    extern fn wlr_output_preferred_read_format(output: *Output, fmt: *wayland.struct_wl_shm.enum_wl_shm_format) bool;
    extern fn wlr_output_set_damage(output: *Output, damage: *pixman_region32_t) void;
    extern fn wlr_output_test(output: *Output) bool;
    extern fn wlr_output_commit(output: *Output) bool;
    extern fn wlr_output_rollback(output: *Output) void;
    extern fn wlr_output_schedule_frame(output: *Output) void;
    extern fn wlr_output_get_gamma_size(output: *Output) usize;
    extern fn wlr_output_set_gamma(output: *Output, size: usize, r: *const u16, g: *const u16, b: *const u16) void;
    extern fn wlr_output_export_dmabuf(output: *Output, attribs: *wlroots.DmabufAttributes) bool;
    extern fn wlr_output_from_resource(resource: *wayland.Resource) ?*Output;
    extern fn wlr_output_lock_attach_render(output: *Output, lock: bool) void;
    extern fn wlr_output_lock_software_cursors(output: *Output, lock: bool) void;
    extern fn wlr_output_render_software_cursors(output: *Output, damage: ?*pixman_region32_t) void;
    extern fn wlr_output_cursor_create(output: *Output) ?*OutputCursor;
    extern fn wlr_output_cursor_set_image(cursor: *OutputCursor, pixels: [*]const u8, stride: i32, width: u32, height: u32, hotspot_x: i32, hotspot_y: i32) bool;
    extern fn wlr_output_cursor_set_surface(cursor: *OutputCursor, surface: *wlroots.Surface, hotspot_x: i32, hotspot_y: i32) void;
    extern fn wlr_output_cursor_move(cursor: *OutputCursor, x: f64, y: f64) bool;
    extern fn wlr_output_cursor_destroy(cursor: *OutputCursor) void;
    extern fn wlr_output_transform_invert(tr: wayland.Output.Transform) wayland.Output.Transform;
    extern fn wlr_output_transform_compose(tr_a: wayland.Output.Transform, tr_b: wayland.Output.Transform) wayland.Output.Transform;

    /// enum wl_output_mode
    pub const enum_wl_output_mode = extern enum(c_int) {
        current = 1,
        preferred = 2,
    };

    /// struct wlr_output_cursor
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

    /// enum wlr_output_state_field
    pub const StateField = struct {
        pub const buffer: c_int = 1;
        pub const damage: c_int = 2;
        pub const mode: c_int = 4;
        pub const enabled: c_int = 8;
        pub const scale: c_int = 16;
        pub const transform: c_int = 32;
        pub const adaptive_sync_enabled: c_int = 64;
        pub const gamma_lut: c_int = 128;
    };

    /// struct wlr_output_event_damage
    pub const struct_wlr_output_event_damage = extern struct {
        output: *Output,
        damage: [*c]pixman_region32_t,
    };

    /// struct wlr_output_event_precommit
    pub const struct_wlr_output_event_precommit = extern struct {
        output: *Output,
        when: [*c]std.os.timespec,
    };

    /// enum wlr_output_present_flag
    pub const enum_wlr_output_present_flag = struct {
        pub const vsync: c_int = 1;
        pub const hw_clock: c_int = 2;
        pub const hw_completion: c_int = 4;
        pub const zero_copy: c_int = 8;
    };

    /// struct wlr_output_event_present
    pub const struct_wlr_output_event_present = extern struct {
        output: *Output,
        commit_seq: u32,
        when: [*c]std.os.timespec,
        seq: c_uint,
        refresh: c_int,
        flags: u32,
    };

    /// struct wlr_output_layout
    pub const Layout = extern struct {
        /// enum wlr_direction
        pub const Direction = struct {
            pub const up: c_int = 1;
            pub const down: c_int = 2;
            pub const left: c_int = 4;
            pub const right: c_int = 8;
        };

        extern fn wlr_output_layout_create() ?*Layout;
        extern fn wlr_output_layout_destroy(layout: *Layout) void;
        extern fn wlr_output_layout_get(layout: *Layout, reference: *Output) ?*LayoutOutput;
        extern fn wlr_output_layout_output_at(layout: *Layout, lx: f64, ly: f64) ?*Output;
        extern fn wlr_output_layout_add(layout: *Layout, output: *Output, lx: c_int, ly: c_int) void;
        extern fn wlr_output_layout_move(layout: *Layout, output: *Output, lx: c_int, ly: c_int) void;
        extern fn wlr_output_layout_remove(layout: *Layout, output: *Output) void;
        extern fn wlr_output_layout_output_coords(layout: *Layout, reference: *Output, lx: *f64, ly: *f64) void;
        extern fn wlr_output_layout_contains_point(layout: *Layout, reference: *Output, lx: c_int, ly: c_int) bool;
        extern fn wlr_output_layout_intersects(layout: *Layout, reference: *Output, target_lbox: *const wlroots.Box) bool;
        extern fn wlr_output_layout_closest_point(layout: *Layout, reference: ?*Output, lx: f64, ly: f64, dest_lx: *f64, dest_ly: *f64) void;
        extern fn wlr_output_layout_get_box(layout: *Layout, reference: ?*Output) *wlroots.Box;
        extern fn wlr_output_layout_add_auto(layout: *Layout, output: *Output) void;
        extern fn wlr_output_layout_get_center_output(layout: *Layout) ?*Output;
        extern fn wlr_output_layout_adjacent_output(layout: *Layout, direction: c_int, reference: *Output, ref_lx: f64, ref_ly: f64) ?*Output;
        extern fn wlr_output_layout_farthest_output(layout: *Layout, direction: c_int, reference: *Output, ref_lx: f64, ref_ly: f64) ?*Output;

        /// struct_wlr_output_layout_state
        pub const struct_wlr_output_layout_state = opaque {};

        /// struct wlr_output_layout_output
        pub const LayoutOutput = extern struct {
            /// struct wlr_output_layout_output_state
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

        pub fn init() !*Layout {
            return wlr_output_layout_create() orelse error.Failure;
        }

        pub const deinit = wlr_output_layout_destroy;
        pub const get = wlr_output_layout_get;
        pub const outputAt = wlr_output_layout_output_at;
        pub const add = wlr_output_layout_add;
        pub const move = wlr_output_layout_move;
        pub const remove = wlr_output_layout_remove;
        pub const outputCoords = wlr_output_layout_output_coords;
        pub const containsPoint = wlr_output_layout_contains_point;
        pub const intersects = wlr_output_layout_intersects;
        pub const closestPoint = wlr_output_layout_closest_point;
        pub const getBox = wlr_output_layout_get_box;
        pub const addAuto = wlr_output_layout_add_auto;
        pub const getCenterOutput = wlr_output_layout_get_center_output;
        pub const adjacentOutput = wlr_output_layout_adjacent_output;
        pub const farthestOutput = wlr_output_layout_farthest_output;
    };

    /// struct wlr_output_mode
    pub const Mode = extern struct {
        width: i32,
        height: i32,
        refresh: i32,
        preferred: bool,
        link: wayland.ListElement(Mode, "link"),
    };

    /// struct wlr_output_impl
    pub const Impl = opaque {};

    /// enum wlr_output_adaptive_sync_status
    pub const enum_wlr_output_adaptive_sync_status = extern enum(c_int) {
        disabled,
        enabled,
        unknown,
    };

    /// struct wlr_output_state
    pub const State = extern struct {
        pub const BufferType = extern enum(c_int) {
            render,
            scanout,
        };
        pub const ModeType = extern enum(c_int) {
            fixed,
            custom,
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

    pub const enable = wlr_output_enable;
    pub const createGlobal = wlr_output_create_global;
    pub const destroyGlobal = wlr_output_destroy_global;
    pub const preferredMode = wlr_output_preferred_mode;
    pub const setMode = wlr_output_set_mode;
    pub const setCustomMode = wlr_output_set_custom_mode;
    pub const setTransform = wlr_output_set_transform;
    pub const enableAdaptiveSync = wlr_output_enable_adaptive_sync;
    pub const setScale = wlr_output_set_scale;
    pub const setSubpixel = wlr_output_set_subpixel;
    pub const setDescription = wlr_output_set_description;
    pub const scheduleDone = wlr_output_schedule_done;
    pub const destroy = wlr_output_destroy;
    pub const transformedResolution = wlr_output_transformed_resolution;
    pub const effectiveResolution = wlr_output_effective_resolution;
    pub const attachRender = wlr_output_attach_render;
    pub const attachBuffer = wlr_output_attach_buffer;
    pub const preferredReadFormat = wlr_output_preferred_read_format;
    pub const setDamage = wlr_output_set_damage;
    pub const @"test" = wlr_output_test;
    pub const commit = wlr_output_commit;
    pub const rollback = wlr_output_rollback;
    pub const scheduleFrame = wlr_output_schedule_frame;
    pub const getGammaSize = wlr_output_get_gamma_size;
    pub const setGamma = wlr_output_set_gamma;
    pub const exportDmabuf = wlr_output_export_dmabuf;
    pub const fromResource = wlr_output_from_resource;
    pub const lockAttachRender = wlr_output_lock_attach_render;
    pub const lockSoftwareCursors = wlr_output_lock_software_cursors;
    pub const renderSoftwareCursors = wlr_output_render_software_cursors;
    pub const cursorSetImage = wlr_output_cursor_set_image;
    pub const cursorSetSurface = wlr_output_cursor_set_surface;
    pub const cursorMove = wlr_output_cursor_move;
    pub const cursorDestroy = wlr_output_cursor_destroy;
    pub const transformInvert = wlr_output_transform_invert;
    pub const transformCompose = wlr_output_transform_compose;

    pub fn cursorCreate(output: *Output) !*OutputCursor {
        return wlr_output_cursor_create(output) orelse error.Failure;
    }
};
