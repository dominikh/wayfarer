const wayland = @import("wayland.zig");
const egl = @import("egl.zig");

pub const Keyboard = @import("wlroots/Keyboard.zig").Keyboard;
pub const Pointer = @import("wlroots/Pointer.zig").Pointer;
pub const Tablet = @import("wlroots/Tablet.zig").Tablet;
pub const Cursor = @import("wlroots/Cursor.zig").Cursor;
pub const Seat = @import("wlroots/Seat.zig").Seat;
pub const Surface = @import("wlroots/Surface.zig").Surface;
pub const Output = @import("wlroots/Output.zig").Output;
pub const XDGToplevel = @import("wlroots/XDGToplevel.zig").XDGToplevel;
pub const Switch = @import("wlroots/Switch.zig").Switch;
pub const XDGSurface = @import("wlroots/XDGSurface.zig").XDGSurface;
pub const Backend = @import("wlroots/Backend.zig").Backend;
pub const Renderer = @import("wlroots/Renderer.zig").Renderer;

pub extern fn wlr_data_device_manager_create(display: ?*wayland.Display) [*c]struct_wlr_data_device_manager;
pub extern fn wlr_data_source_accept(source: [*c]struct_wlr_data_source, serial: u32, mime_type: [*:0]const u8) void;
pub extern fn wlr_data_source_destroy(source: [*c]struct_wlr_data_source) void;
pub extern fn wlr_data_source_dnd_action(source: [*c]struct_wlr_data_source, action: wayland.enum_wl_data_device_manager_dnd_action) void;
pub extern fn wlr_data_source_dnd_drop(source: [*c]struct_wlr_data_source) void;
pub extern fn wlr_data_source_dnd_finish(source: [*c]struct_wlr_data_source) void;
pub extern fn wlr_data_source_init(source: [*c]struct_wlr_data_source, impl: [*c]const struct_wlr_data_source_impl) void;
pub extern fn wlr_data_source_send(source: [*c]struct_wlr_data_source, mime_type: [*:0]const u8, fd: i32) void;
pub extern fn wlr_drag_create(seat_client: [*c]struct_wlr_seat_client, source: [*c]struct_wlr_data_source, icon_surface: [*c]Surface) [*c]struct_wlr_drag;
pub extern fn wlr_drm_format_set_add(set: [*c]struct_wlr_drm_format_set, format: u32, modifier: u64) bool;
pub extern fn wlr_drm_format_set_finish(set: [*c]struct_wlr_drm_format_set) void;
pub extern fn wlr_drm_format_set_get(set: [*c]const struct_wlr_drm_format_set, format: u32) ?*const struct_wlr_drm_format;
pub extern fn wlr_drm_format_set_has(set: [*c]const struct_wlr_drm_format_set, format: u32, modifier: u64) bool;
pub extern fn wlr_log_get_verbosity() enum_wlr_log_importance;
pub extern fn wlr_log_init(verbosity: enum_wlr_log_importance, callback: wlr_log_func_t) void;
pub extern fn wlr_resource_get_buffer_size(resource: [*c]wayland.Resource, renderer: *Renderer, width: [*c]c_int, height: [*c]c_int) bool;
pub extern fn wlr_resource_is_buffer(resource: [*c]wayland.Resource) bool;
pub extern fn wlr_seat_client_for_wl_client(wlr_seat: *Seat, wl_client: ?*wayland.Client) [*c]struct_wlr_seat_client;
pub extern fn wlr_seat_client_from_pointer_resource(resource: [*c]wayland.Resource) [*c]struct_wlr_seat_client;
pub extern fn wlr_seat_client_from_resource(resource: [*c]wayland.Resource) [*c]struct_wlr_seat_client;
pub extern fn wlr_seat_client_next_serial(client: [*c]struct_wlr_seat_client) u32;
pub extern fn wlr_subsurface_create(surface: [*c]Surface, parent: [*c]Surface, version: u32, id: u32, resource_list: [*c]wayland.List(wayland.Resource, "link")) [*c]Subsurface;
pub extern fn wlr_subsurface_from_wlr_surface(surface: [*c]Surface) [*c]Subsurface;
pub extern fn wlr_xdg_positioner_get_geometry(positioner: [*c]struct_wlr_xdg_positioner) Box;

/// struct wlr_seat_keyboard_grab
pub const struct_wlr_seat_keyboard_grab = extern struct {
    /// struct wlr_keyboard_grab_interface
    pub const Interface = extern struct {
        enter: ?fn ([*c]struct_wlr_seat_keyboard_grab, [*c]Surface, [*c]u32, usize, [*c]Keyboard.Modifiers) callconv(.C) void,
        clear_focus: ?fn ([*c]struct_wlr_seat_keyboard_grab) callconv(.C) void,
        key: ?fn ([*c]struct_wlr_seat_keyboard_grab, u32, u32, u32) callconv(.C) void,
        modifiers: ?fn ([*c]struct_wlr_seat_keyboard_grab, [*c]Keyboard.Modifiers) callconv(.C) void,
        cancel: ?fn ([*c]struct_wlr_seat_keyboard_grab) callconv(.C) void,
    };

    interface: [*c]const Interface,
    seat: [*c]Seat,
    data: ?*c_void,
};

/// enum wlr_log_importance
pub const enum_wlr_log_importance = extern enum(c_int) {
    WLR_SILENT = 0,
    WLR_ERROR = 1,
    WLR_INFO = 2,
    WLR_DEBUG = 3,
    WLR_LOG_IMPORTANCE_LAST = 4,
    _,
};

pub const Matrix = struct {
    pub extern fn wlr_matrix_identity(mat: *[9]f32) void;
    pub extern fn wlr_matrix_multiply(mat: *[9]f32, a: *const [9]f32, b: *const [9]f32) void;
    pub extern fn wlr_matrix_project_box(mat: *[9]f32, box: [*c]const Box, transform: wayland.Output.Transform, rotation: f32, projection: *const [9]f32) void;
    pub extern fn wlr_matrix_projection(mat: *[9]f32, width: c_int, height: c_int, transform: wayland.Output.Transform) void;
    pub extern fn wlr_matrix_rotate(mat: *[9]f32, rad: f32) void;
    pub extern fn wlr_matrix_scale(mat: *[9]f32, x: f32, y: f32) void;
    pub extern fn wlr_matrix_transform(mat: *[9]f32, transform: wayland.Output.Transform) void;
    pub extern fn wlr_matrix_translate(mat: *[9]f32, x: f32, y: f32) void;
    pub extern fn wlr_matrix_transpose(mat: *[9]f32, a: *const [9]f32) void;

    data: [3][3]f32,

    pub const Identity = @This(){
        .data = .{
            .{ 1, 0, 0 },
            .{ 0, 1, 0 },
            .{ 0, 0, 1 },
        },
    };

    pub fn col(m: @This(), n: u4) [3]f32 {
        return [3]f32{
            m.data[0][col],
            m.data[1][col],
            m.data[2][col],
        };
    }

    pub fn mul(dst: *@This(), op1: @This(), op2: @This()) void {
        var i: u4 = 0;
        var out: @This() = undefined;
        while (i < 3) : (i += 1) {
            var j: u4 = 0;
            while (j < 3) : (j += 1) {
                var sum: f32 = 0;
                var k: u4 = 0;
                while (k < 3) : (k += 1) {
                    sum += op1.data[i][k] * op2.data[k][j];
                }
                out.data[i][j] = sum;
            }
        }
        dst.* = out;
    }

    pub fn translate(m: *@This(), x: f32, y: f32) void {
        const trans: @This() = .{
            .data = .{
                .{ 1, 0, x },
                .{ 0, 1, y },
                .{ 0, 0, 1 },
            },
        };
        mul(m, m.*, trans);
    }

    pub fn scale(m: *@This(), x: f32, y: f32) void {
        const trans: @This() = .{
            .data = .{
                .{ x, 0, 0 },
                .{ 0, y, 0 },
                .{ 0, 0, 1 },
            },
        };
        mul(m, m.*, trans);
    }

    pub fn rotate(m: *@This(), rad: f32) void {
        const trans: @This() = .{
            .data = .{
                .{ std.math.cos(rad), -std.math.sin(rad), 0 },
                .{ std.math.sin(rad), std.math.cos(rad), 0 },
                .{ 0, 0, 1 },
            },
        };
        mul(m, m.*, trans);
    }

    pub fn linear(m: *@This()) *[9]f32 {
        return @ptrCast(*[9]f32, &m.data);
    }

    pub fn print(m: @This()) void {
        std.debug.print(
            "{d} {d} {d}\n{d} {d} {d}\n{d} {d} {d}\n\n",
            .{
                m.data[0][0], m.data[0][1], m.data[0][2],
                m.data[1][0], m.data[1][1], m.data[1][2],
                m.data[2][0], m.data[2][1], m.data[2][2],
            },
        );
    }
};

/// struct wlr_buffer
pub const Buffer = extern struct {
    pub extern fn wlr_buffer_init(buffer: [*c]Buffer, impl: [*c]const Impl, width: c_int, height: c_int) void;
    pub extern fn wlr_buffer_drop(buffer: [*c]Buffer) void;
    pub extern fn wlr_buffer_lock(buffer: [*c]Buffer) [*c]Buffer;
    pub extern fn wlr_buffer_unlock(buffer: [*c]Buffer) void;
    pub extern fn wlr_buffer_get_dmabuf(buffer: [*c]Buffer, attribs: [*c]struct_wlr_dmabuf_attributes) bool;

    /// struct wlr_buffer_impl
    pub const Impl = extern struct {
        destroy: fn (*Buffer) callconv(.C) void,
        get_dmabuf: ?fn (*Buffer, [*]struct_wlr_dmabuf_attributes) callconv(.C) bool,
    };

    impl: [*c]const Impl,
    width: c_int,
    height: c_int,
    dropped: bool,
    n_locks: usize,
    events: extern struct {
        destroy: wayland.Signal(void),
        release: wayland.Signal(void),
    },
};

/// struct wlr_client_buffer
pub const ClientBuffer = extern struct {
    pub extern fn wlr_client_buffer_apply_damage(buffer: [*c]ClientBuffer, resource: [*c]wayland.Resource, damage: [*c]pixman_region32_t) [*c]ClientBuffer;
    pub extern fn wlr_client_buffer_import(renderer: *Renderer, resource: [*c]wayland.Resource) [*c]ClientBuffer;

    base: Buffer,
    resource: [*c]wayland.Resource,
    resource_released: bool,
    texture: [*c]Texture,
    resource_destroy: wayland.Listener(?*c_void),
    release: wayland.Listener(?*c_void),
};

/// struct wlr_compositor
pub const Compositor = extern struct {
    /// struct wlr_subcompositor
    pub const Subcompositor = extern struct {
        global: ?*wayland.Global,
    };

    pub extern fn wlr_compositor_create(display: ?*wayland.Display, renderer: *Renderer) [*c]Compositor;

    global: ?*wayland.Global,
    renderer: *Renderer,
    subcompositor: Subcompositor,
    display_destroy: wayland.Listener(?*c_void),
    events: extern struct {
        new_surface: wayland.Signal(*Surface),
        destroy: wayland.Signal(*Compositor),
    },
};

/// struct wlr_subsurface
pub const Subsurface = extern struct {
    /// struct wlr_subsurface_state
    pub const State = extern struct {
        x: i32,
        y: i32,
    };

    resource: [*c]wayland.Resource,
    surface: [*c]Surface,
    parent: [*c]Surface,
    current: State,
    pending: State,
    cached: Surface.State,
    has_cache: bool,
    synchronized: bool,
    reordered: bool,
    mapped: bool,
    parent_link: wayland.ListElement(Subsurface, "parent_link"),
    parent_pending_link: wayland.ListElement(Subsurface, "parent_pending_link"),
    surface_destroy: wayland.Listener(?*c_void),
    parent_destroy: wayland.Listener(?*c_void),
    events: extern struct {
        destroy: wayland.Signal(*Subsurface),
        map: wayland.Signal(*Subsurface),
        unmap: wayland.Signal(*Subsurface),
    },
    data: ?*c_void,
};

/// enum wlr_button_state
pub const enum_wlr_button_state = extern enum(c_int) {
    Released,
    Pressed,
    _,
};

/// struct wlr_touch
pub const Touch = extern struct {
    /// struct wlr_touch_impl
    pub const Impl = opaque {};

    pub const Events = struct {
        /// struct wlr_event_touch_down
        pub const Down = extern struct {
            device: *InputDevice,
            time_msec: u32,
            touch_id: i32,
            x: f64,
            y: f64,
        };

        /// struct wlr_event_touch_up
        pub const Up = extern struct {
            device: *InputDevice,
            time_msec: u32,
            touch_id: i32,
        };

        /// struct wlr_event_touch_motion
        pub const Motion = extern struct {
            device: *InputDevice,
            time_msec: u32,
            touch_id: i32,
            x: f64,
            y: f64,
        };

        /// struct wlr_event_touch_cancel
        pub const Cancel = extern struct {
            device: *InputDevice,
            time_msec: u32,
            touch_id: i32,
        };
    };

    impl: ?*const Impl,
    events: extern struct {
        down: wayland.Signal(*Events.Down),
        up: wayland.Signal(*Events.Up),
        motion: wayland.Signal(*Events.Motion),
        cancel: wayland.Signal(*Events.Cancel),
    },
    data: ?*c_void,
};

/// struct wlr_list
pub const List = extern struct {
    pub extern fn wlr_list_init(list: [*c]List) bool;
    pub extern fn wlr_list_finish(list: [*c]List) void;
    pub extern fn wlr_list_for_each(list: [*c]List, callback: ?fn (?*c_void) callconv(.C) void) void;
    pub extern fn wlr_list_push(list: [*c]List, item: ?*c_void) isize;
    pub extern fn wlr_list_insert(list: [*c]List, index: usize, item: ?*c_void) isize;
    pub extern fn wlr_list_del(list: [*c]List, index: usize) void;
    pub extern fn wlr_list_pop(list: [*c]List) ?*c_void;
    pub extern fn wlr_list_peek(list: [*c]List) ?*c_void;
    pub extern fn wlr_list_cat(list: [*c]List, source: [*c]const List) isize;
    pub extern fn wlr_list_qsort(list: [*c]List, compare: ?fn (?*const c_void, ?*const c_void) callconv(.C) c_int) void;
    pub extern fn wlr_list_find(list: [*c]List, compare: ?fn (?*const c_void, ?*const c_void) callconv(.C) c_int, cmp_to: ?*const c_void) isize;

    capacity: usize,
    length: usize,
    items: [*c]?*c_void,
};

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
        keyboard: *Keyboard,
        pointer: *Pointer,
        switch_device: *Switch,
        touch: *Touch,
        tablet: *Tablet,
        tablet_pad: *Tablet.Pad,
    },
    events: extern struct {
        destroy: wayland.Signal(?*c_void),
    },
    data: ?*c_void,
    link: wayland.ListElement(InputDevice, "link"),
};

/// struct wlr_serial_range
pub const struct_wlr_serial_range = extern struct {
    min_incl: u32,
    max_incl: u32,
};

/// struct wlr_serial_ringset
pub const struct_wlr_serial_ringset = extern struct {
    data: [128]struct_wlr_serial_range,
    end: c_int,
    count: c_int,
};

/// struct wlr_data_source
pub const struct_wlr_data_source = extern struct {
    /// struct wlr_data_source_impl
    pub const struct_wlr_data_source_impl = extern struct {
        send: ?fn ([*c]struct_wlr_data_source, [*c]const u8, i32) callconv(.C) void,
        accept: ?fn ([*c]struct_wlr_data_source, u32, [*c]const u8) callconv(.C) void,
        destroy: ?fn ([*c]struct_wlr_data_source) callconv(.C) void,
        dnd_drop: ?fn ([*c]struct_wlr_data_source) callconv(.C) void,
        dnd_finish: ?fn ([*c]struct_wlr_data_source) callconv(.C) void,
        dnd_action: ?fn ([*c]struct_wlr_data_source, wayland.enum_wl_data_device_manager_dnd_action) callconv(.C) void,
    };

    impl: [*c]const struct_wlr_data_source_impl,
    mime_types: wayland.struct_wl_array,
    actions: i32,
    accepted: bool,
    current_dnd_action: wayland.enum_wl_data_device_manager_dnd_action,
    compositor_action: u32,
    events: extern struct {
        destroy: wayland.Signal(?*c_void),
    },
};

/// struct wlr_primary_selection_source
pub const struct_wlr_primary_selection_source = opaque {};

/// struct wlr_drag
pub const struct_wlr_drag = extern struct {
    /// enum wlr_drag_grab_type
    pub const enum_wlr_drag_grab_type = extern enum(c_int) {
        WLR_DRAG_GRAB_KEYBOARD,
        WLR_DRAG_GRAB_KEYBOARD_POINTER,
        WLR_DRAG_GRAB_KEYBOARD_TOUCH,
        _,
    };

    pub const Events = struct {
        /// struct wlr_drag_motion_event
        pub const struct_wlr_drag_motion_event = extern struct {
            drag: [*c]struct_wlr_drag,
            time: u32,
            sx: f64,
            sy: f64,
        };

        /// struct wlr_drag_drop_event
        pub const struct_wlr_drag_drop_event = extern struct {
            drag: [*c]struct_wlr_drag,
            time: u32,
        };
    };

    /// struct wlr_drag_icon
    pub const Icon = extern struct {
        drag: [*c]struct_wlr_drag,
        surface: [*c]Surface,
        mapped: bool,
        events: extern struct {
            map: wayland.Signal(?*c_void),
            unmap: wayland.Signal(?*c_void),
            destroy: wayland.Signal(?*c_void),
        },
        surface_destroy: wayland.Listener(?*c_void),
        data: ?*c_void,
    };

    grab_type: enum_wlr_drag_grab_type,
    keyboard_grab: struct_wlr_seat_keyboard_grab,
    pointer_grab: Seat.struct_wlr_seat_pointer_grab,
    touch_grab: Seat.struct_wlr_seat_touch_grab,
    seat: [*c]Seat,
    seat_client: [*c]Seat.Client,
    focus_client: [*c]Seat.Client,
    icon: [*c]Icon,
    focus: [*c]Surface,
    source: [*c]struct_wlr_data_source,
    started: bool,
    dropped: bool,
    cancelling: bool,
    grab_touch_id: i32,
    touch_id: i32,
    events: extern struct {
        focus: wayland.Signal(?*c_void),
        motion: wayland.Signal(?*c_void),
        drop: wayland.Signal(?*c_void),
        destroy: wayland.Signal(?*c_void),
    },
    point_destroy: wayland.Listener(?*c_void),
    source_destroy: wayland.Listener(?*c_void),
    seat_client_destroy: wayland.Listener(?*c_void),
    icon_destroy: wayland.Listener(?*c_void),
    data: ?*c_void,
};

pub extern const wlr_data_device_pointer_drag_interface: struct_wlr_pointer_grab_interface;
pub extern const wlr_data_device_keyboard_drag_interface: struct_wlr_keyboard_grab_interface;
pub extern const wlr_data_device_touch_drag_interface: struct_wlr_touch_grab_interface;

/// struct wlr_data_device_manager
pub const struct_wlr_data_device_manager = extern struct {
    global: ?*wayland.Global,
    // XXX audit the list type
    data_sources: wayland.List(wayland.Resource, "link"),
    display_destroy: wayland.Listener(?*c_void),
    events: extern struct {
        destroy: wayland.Signal(?*c_void),
    },
    data: ?*c_void,
};

/// struct wlr_data_offer
pub const struct_wlr_data_offer = extern struct {
    /// enum wlr_data_offer_type
    pub const enum_wlr_data_offer_type = extern enum(c_int) {
        WLR_DATA_OFFER_SELECTION,
        WLR_DATA_OFFER_DRAG,
        _,
    };

    resource: [*c]wayland.Resource,
    source: [*c]struct_wlr_data_source,
    type: enum_wlr_data_offer_type,
    link: wayland.ListElement(struct_wlr_data_offer, "link"),
    actions: u32,
    preferred_action: wayland.enum_wl_data_device_manager_dnd_action,
    in_ask: bool,
    source_destroy: wayland.Listener(?*c_void),
};

/// struct wlr_xdg_shell
pub const struct_wlr_xdg_shell = extern struct {
    pub extern fn wlr_xdg_shell_create(display: ?*wayland.Display) [*c]struct_wlr_xdg_shell;

    global: ?*wayland.Global,
    clients: wayland.List(struct_wlr_xdg_client, "link"),
    popup_grabs: wayland.List(struct_wlr_xdg_popup.struct_wlr_xdg_popup_grab, "link"),
    ping_timeout: u32,
    display_destroy: wayland.Listener(?*c_void),
    events: extern struct {
        new_surface: wayland.Signal(*XDGSurface),
        destroy: wayland.Signal(?*c_void),
    },
    data: ?*c_void,
};

/// struct wlr_xdg_client
pub const struct_wlr_xdg_client = extern struct {
    shell: [*c]struct_wlr_xdg_shell,
    resource: [*c]wayland.Resource,
    client: ?*wayland.Client,
    surfaces: wayland.List(XDGSurface, "link"),
    link: wayland.ListElement(struct_wlr_xdg_client, "link"), // wlr_xdg_shell::clients
    ping_serial: u32,
    ping_timer: ?*wayland.EventSource,
};

/// struct wlr_xdg_positioner
pub const struct_wlr_xdg_positioner = extern struct {
    pub extern fn wlr_positioner_invert_x(positioner: [*c]struct_wlr_xdg_positioner) void;
    pub extern fn wlr_positioner_invert_y(positioner: [*c]struct_wlr_xdg_positioner) void;

    resource: [*c]wayland.Resource,
    anchor_rect: Box,
    anchor: wayland.enum_xdg_positioner_anchor,
    gravity: wayland.enum_xdg_positioner_gravity,
    constraint_adjustment: wayland.enum_xdg_positioner_constraint_adjustment,
    size: extern struct {
        width: i32,
        height: i32,
    },
    offset: extern struct {
        x: i32,
        y: i32,
    },
};

/// struct wlr_xdg_popup
pub const struct_wlr_xdg_popup = extern struct {
    pub extern fn wlr_xdg_popup_destroy(surface: [*c]XDGSurface) void;
    pub extern fn wlr_xdg_popup_get_anchor_point(popup: [*c]struct_wlr_xdg_popup, toplevel_sx: [*c]c_int, toplevel_sy: [*c]c_int) void;
    pub extern fn wlr_xdg_popup_get_toplevel_coords(popup: [*c]struct_wlr_xdg_popup, popup_sx: c_int, popup_sy: c_int, toplevel_sx: [*c]c_int, toplevel_sy: [*c]c_int) void;
    pub extern fn wlr_xdg_popup_unconstrain_from_box(popup: [*c]struct_wlr_xdg_popup, toplevel_sx_box: [*c]Box) void;

    /// struct wlr_xdg_popup_grab
    pub const struct_wlr_xdg_popup_grab = extern struct {
        client: ?*wayland.Client,
        pointer_grab: Seat.struct_wlr_seat_pointer_grab,
        keyboard_grab: struct_wlr_seat_keyboard_grab,
        touch_grab: Seat.struct_wlr_seat_touch_grab,
        seat: [*c]Seat,
        popups: wayland.List(struct_wlr_xdg_popup, "grab_link"),
        link: wayland.ListElement(struct_wlr_xdg_popup_grab, "link"), // wlr_xdg_shell::popup_grabs
        seat_destroy: wayland.Listener(?*c_void),
    };

    base: [*c]XDGSurface,
    link: wayland.ListElement(struct_wlr_xdg_popup, "link"),
    resource: [*c]wayland.Resource,
    committed: bool,
    parent: [*c]Surface,
    seat: [*c]Seat,
    geometry: Box,
    positioner: struct_wlr_xdg_positioner,
    grab_link: wayland.ListElement(struct_wlr_xdg_popup, "grab_link"), // wlr_xdg_popup_grab::popups
};

/// struct wlr_device
pub const Device = extern struct {
    fd: c_int,
    dev: dev_t,
    signal: wayland.Signal(?*c_void),
    link: wayland.ListElement(Device, "link"),
};

/// struct wlr_dmabuf_attributes
pub const struct_wlr_dmabuf_attributes = extern struct {
    pub extern fn wlr_dmabuf_attributes_copy(dst: [*c]struct_wlr_dmabuf_attributes, src: [*c]struct_wlr_dmabuf_attributes) bool;
    pub extern fn wlr_dmabuf_attributes_finish(attribs: [*c]struct_wlr_dmabuf_attributes) void;

    /// enum wlr_dmabuf_attributes_flags
    pub const enum_wlr_dmabuf_attributes_flags = extern enum(c_int) {
        WLR_DMABUF_ATTRIBUTES_FLAGS_Y_INVERT = 1,
        WLR_DMABUF_ATTRIBUTES_FLAGS_INTERLACED = 2,
        WLR_DMABUF_ATTRIBUTES_FLAGS_BOTTOM_FIRST = 4,
        _,
    };

    width: i32,
    height: i32,
    format: u32,
    flags: u32,
    modifier: u64,
    n_planes: c_int,
    offset: [4]u32,
    stride: [4]u32,
    fd: [4]c_int,
};

/// struct wlr_drm_format
pub const struct_wlr_drm_format = opaque {}; // /nix/store/137db3flxx6vgsaqj733yjfp175cajdj-wlroots-0.11.0/include/wlr/render/drm_format_set.h:11:11: warning: struct demoted to opaque type - has variable length array

/// struct wlr_drm_format_set
pub const struct_wlr_drm_format_set = extern struct {
    len: usize,
    cap: usize,
    formats: [*c]?*struct_wlr_drm_format,
};

/// struct_wlr_egl_context
pub const struct_wlr_egl_context = extern struct {
    display: egl.EGLDisplay,
    context: egl.EGLContext,
    draw_surface: egl.EGLSurface,
    read_surface: egl.EGLSurface,
};

/// struct wlr_egl
pub const struct_wlr_egl = extern struct {
    pub extern fn wlr_egl_init(egl: [*c]struct_wlr_egl, platform: egl.EGLenum, remote_display: ?*c_void, config_attribs: [*c]const egl.EGLint, visual_id: egl.EGLint) bool;
    pub extern fn wlr_egl_finish(egl: [*c]struct_wlr_egl) void;
    pub extern fn wlr_egl_bind_display(egl: [*c]struct_wlr_egl, local_display: ?*wayland.Display) bool;
    pub extern fn wlr_egl_create_surface(egl: [*c]struct_wlr_egl, window: ?*c_void) egl.EGLSurface;
    pub extern fn wlr_egl_create_image_from_wl_drm(egl: [*c]struct_wlr_egl, data: [*c]wayland.Resource, fmt: [*c]egl.EGLint, width: [*c]c_int, height: [*c]c_int, inverted_y: [*c]bool) egl.EGLImageKHR;
    pub extern fn wlr_egl_create_image_from_dmabuf(egl: [*c]struct_wlr_egl, attributes: [*c]struct_wlr_dmabuf_attributes, external_only: [*c]bool) egl.EGLImageKHR;
    pub extern fn wlr_egl_get_dmabuf_formats(egl: [*c]struct_wlr_egl) [*c]const struct_wlr_drm_format_set;
    pub extern fn wlr_egl_export_image_to_dmabuf(egl: [*c]struct_wlr_egl, image: EGLImageKHR, width: i32, height: i32, flags: u32, attribs: [*c]struct_wlr_dmabuf_attributes) bool;
    pub extern fn wlr_egl_destroy_image(egl: [*c]struct_wlr_egl, image: egl.EGLImageKHR) bool;
    pub extern fn wlr_egl_make_current(egl: [*c]struct_wlr_egl, surface: egl.EGLSurface, buffer_age: [*c]c_int) bool;
    pub extern fn wlr_egl_unset_current(egl: [*c]struct_wlr_egl) bool;
    pub extern fn wlr_egl_is_current(egl: [*c]struct_wlr_egl) bool;
    pub extern fn wlr_egl_save_context(context: [*c]struct_wlr_egl_context) void;
    pub extern fn wlr_egl_restore_context(context: [*c]struct_wlr_egl_context) bool;
    pub extern fn wlr_egl_swap_buffers(egl: [*c]struct_wlr_egl, surface: egl.EGLSurface, damage: [*c]pixman_region32_t) bool;
    pub extern fn wlr_egl_destroy_surface(egl: [*c]struct_wlr_egl, surface: egl.EGLSurface) bool;

    platform: egl.EGLenum,
    display: egl.EGLDisplay,
    config: egl.EGLConfig,
    context: egl.EGLContext,
    exts: extern struct {
        bind_wayland_display_wl: bool,
        buffer_age_ext: bool,
        image_base_khr: bool,
        image_dma_buf_export_mesa: bool,
        image_dmabuf_import_ext: bool,
        image_dmabuf_import_modifiers_ext: bool,
        swap_buffers_with_damage: bool,
    },
    procs: extern struct {
        eglGetPlatformDisplayEXT: egl.PFNEGLGETPLATFORMDISPLAYEXTPROC,
        eglCreatePlatformWindowSurfaceEXT: egl.PFNEGLCREATEPLATFORMWINDOWSURFACEEXTPROC,
        eglCreateImageKHR: egl.PFNEGLCREATEIMAGEKHRPROC,
        eglDestroyImageKHR: egl.PFNEGLDESTROYIMAGEKHRPROC,
        eglQueryWaylandBufferWL: egl.PFNEGLQUERYWAYLANDBUFFERWLPROC,
        eglBindWaylandDisplayWL: egl.PFNEGLBINDWAYLANDDISPLAYWLPROC,
        eglUnbindWaylandDisplayWL: egl.PFNEGLUNBINDWAYLANDDISPLAYWLPROC,
        eglSwapBuffersWithDamage: egl.PFNEGLSWAPBUFFERSWITHDAMAGEEXTPROC,
        eglQueryDmaBufFormatsEXT: egl.PFNEGLQUERYDMABUFFORMATSEXTPROC,
        eglQueryDmaBufModifiersEXT: egl.PFNEGLQUERYDMABUFMODIFIERSEXTPROC,
        eglExportDMABUFImageQueryMESA: egl.PFNEGLEXPORTDMABUFIMAGEQUERYMESAPROC,
        eglExportDMABUFImageMESA: egl.PFNEGLEXPORTDMABUFIMAGEMESAPROC,
        eglDebugMessageControlKHR: egl.PFNEGLDEBUGMESSAGECONTROLKHRPROC,
    },
    wl_display: ?*wayland.Display,
    dmabuf_formats: struct_wlr_drm_format_set,
    external_only_dmabuf_formats: [*c][*c]egl.EGLBoolean,
};

/// enum wlr_edges
pub const enum_wlr_edges = extern enum(c_int) {
    WLR_EDGE_NONE = 0,
    WLR_EDGE_TOP = 1,
    WLR_EDGE_BOTTOM = 2,
    WLR_EDGE_LEFT = 4,
    WLR_EDGE_RIGHT = 8,
    _,
};

/// struct wlr_xcursor
pub const XCursor = extern struct {
    pub extern fn wlr_xcursor_frame(cursor: [*c]XCursor, time: u32) c_int;
    pub extern fn wlr_xcursor_get_resize_name(edges: enum_wlr_edges) [*c]const u8;

    /// struct wlr_xcursor_manager
    pub const Manager = extern struct {
        pub extern fn wlr_xcursor_manager_create(name: ?[*:0]const u8, size: u32) [*c]Manager;
        pub extern fn wlr_xcursor_manager_destroy(manager: [*c]Manager) void;
        pub extern fn wlr_xcursor_manager_get_xcursor(manager: [*c]Manager, name: [*:0]const u8, scale: f32) [*c]XCursor;
        pub extern fn wlr_xcursor_manager_load(manager: [*c]Manager, scale: f32) bool;
        pub extern fn wlr_xcursor_manager_set_cursor_image(manager: [*c]Manager, name: [*:0]const u8, cursor: [*c]Cursor) void;

        /// struct wlr_xcursor_manager_theme
        pub const ManagerTheme = extern struct {
            scale: f32,
            theme: [*c]Theme,
            link: wayland.ListElement(ManagerTheme, "link"),
        };

        name: [*c]u8,
        size: u32,
        scaled_themes: wayland.List(ManagerTheme, "link"),
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
};

/// struct wlr_session
pub const Session = extern struct {
    pub extern fn wlr_session_create(disp: ?*wayland.Display) [*c]Session;
    pub extern fn wlr_session_destroy(session: [*c]Session) void;
    pub extern fn wlr_session_open_file(session: [*c]Session, path: [*:0]const u8) c_int;
    pub extern fn wlr_session_close_file(session: [*c]Session, fd: c_int) void;
    pub extern fn wlr_session_signal_add(session: [*c]Session, fd: c_int, listener: [*c]wayland.Listener(?*c_void)) void;
    pub extern fn wlr_session_change_vt(session: [*c]Session, vt: c_uint) bool;
    pub extern fn wlr_session_find_gpus(session: [*c]Session, ret_len: usize, ret: [*c]c_int) usize;

    /// struct wlr_session_impl
    pub const struct_session_impl = opaque {};

    impl: ?*const struct_session_impl,
    session_signal: wayland.Signal(?*c_void),
    active: bool,
    vtnr: c_uint,
    seat: [256]u8,
    udev: ?*struct_udev,
    mon: ?*struct_udev_monitor,
    udev_event: ?*wayland.EventSource,
    // XXX audit the list type
    devices: wayland.List(wayland.Resource, "link"),
    display_destroy: wayland.Listener(?*c_void),
    events: extern struct {
        destroy: wayland.Signal(?*c_void),
    },
};

/// struct wlr_box
pub const Box = extern struct {
    pub extern fn wlr_box_closest_point(box: [*c]const Box, x: f64, y: f64, dest_x: [*c]f64, dest_y: [*c]f64) void;
    pub extern fn wlr_box_intersection(dest: [*c]Box, box_a: [*c]const Box, box_b: [*c]const Box) bool;
    pub extern fn wlr_box_contains_point(box: [*c]const Box, x: f64, y: f64) bool;
    pub extern fn wlr_box_empty(box: [*c]const Box) bool;
    pub extern fn wlr_box_transform(dest: [*c]Box, box: [*c]const Box, transform: wayland.Output.Transform, width: c_int, height: c_int) void;
    pub extern fn wlr_box_rotated_bounds(dest: [*c]Box, box: [*c]const Box, rotation: f32) void;
    pub extern fn wlr_box_from_pixman_box32(dest: [*c]Box, box: pixman_box32_t) void;

    x: c_int,
    y: c_int,
    width: c_int,
    height: c_int,
};

/// struct wlr_fbox
pub const FBox = extern struct {
    x: f64,
    y: f64,
    width: f64,
    height: f64,
};

/// struct wlr_texture
pub const Texture = extern struct {
    /// struct wlr_texture_impl
    pub const Impl = opaque {};

    impl: ?*const Impl,
    width: u32,
    height: u32,

    pub extern fn wlr_texture_from_pixels(renderer: *Renderer, wl_fmt: enum_wl_shm_format, stride: u32, width: u32, height: u32, data: ?*const c_void) [*c]Texture;
    pub extern fn wlr_texture_from_wl_drm(renderer: *Renderer, data: [*c]wayland.Resource) [*c]Texture;
    pub extern fn wlr_texture_from_dmabuf(renderer: *Renderer, attribs: [*c]struct_wlr_dmabuf_attributes) [*c]Texture;
    pub extern fn wlr_texture_get_size(texture: [*c]Texture, width: [*c]c_int, height: [*c]c_int) void;
    pub extern fn wlr_texture_is_opaque(texture: [*c]Texture) bool;
    pub extern fn wlr_texture_write_pixels(texture: [*c]Texture, stride: u32, width: u32, height: u32, src_x: u32, src_y: u32, dst_x: u32, dst_y: u32, data: ?*const c_void) bool;
    pub extern fn wlr_texture_to_dmabuf(texture: [*c]Texture, attribs: [*c]struct_wlr_dmabuf_attributes) bool;
    pub extern fn wlr_texture_destroy(texture: [*c]Texture) void;
};

pub const WLR_HAS_EGLMESAEXT_H = 1;
pub const WLR_HAS_SYSTEMD = 1;
pub const WLR_HAS_ELOGIND = 0;
pub const WLR_HAS_X11_BACKEND = 1;
pub const WLR_HAS_XWAYLAND = 1;
pub const WLR_HAS_XCB_ERRORS = 1;
pub const WLR_HAS_XCB_ICCCM = 1;
pub const WLR_DMABUF_MAX_PLANES = 4;
pub const WLR_SERIAL_RINGSET_SIZE = 128;
pub const WLR_POINTER_BUTTONS_CAP = 16;
pub const WLR_LED_COUNT = 3;
pub const WLR_MODIFIER_COUNT = 8;
pub const WLR_KEYBOARD_KEYS_CAP = 32;
