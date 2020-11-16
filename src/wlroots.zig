const wayland = @import("wayland.zig");

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
pub const XCursor = @import("wlroots/XCursor.zig").XCursor;
pub const Touch = @import("wlroots/Touch.zig").Touch;
pub const XDGPopup = @import("wlroots/XDGPopup.zig").XDGPopup;
pub const XDGShell = @import("wlroots/XDGShell.zig").XDGShell;
pub const Session = @import("wlroots/Session.zig").Session;
pub const Compositor = @import("wlroots/Compositor.zig").Compositor;
pub const Subcompositor = @import("wlroots/Subcompositor.zig").Subcompositor;
pub const Subsurface = @import("wlroots/Subsurface.zig").Subsurface;
pub const InputDevice = @import("wlroots/InputDevice.zig").InputDevice;
pub const Matrix = @import("wlroots/Matrix.zig").Matrix;
pub const Drag = @import("wlroots/Drag.zig").Drag;
pub const EGL = @import("wlroots/EGL.zig").EGL;
pub const Texture = @import("wlroots/Texture.zig").Texture;
pub const Buffer = @import("wlroots/Buffer.zig").Buffer;
pub const ClientBuffer = @import("wlroots/ClientBuffer.zig").ClientBuffer;
pub const List = @import("wlroots/List.zig").List;
pub const XDGPositioner = @import("wlroots/XDGPositioner.zig").XDGPositioner;

pub extern fn wlr_data_device_manager_create(display: *wayland.Display) ?*DataDeviceManager;
pub extern fn wlr_drag_create(seat_client: [*c]struct_wlr_seat_client, source: [*c]DataSource, icon_surface: [*c]Surface) [*c]Drag;
pub extern fn wlr_log_get_verbosity() enum_wlr_log_importance;
pub extern fn wlr_log_init(verbosity: enum_wlr_log_importance, callback: wlr_log_func_t) void;
pub extern fn wlr_resource_get_buffer_size(resource: [*c]wayland.Resource, renderer: *Renderer, width: [*c]c_int, height: [*c]c_int) bool;
pub extern fn wlr_resource_is_buffer(resource: [*c]wayland.Resource) bool;

/// enum wlr_log_importance
pub const enum_wlr_log_importance = extern enum(c_int) {
    WLR_SILENT = 0,
    WLR_ERROR = 1,
    WLR_INFO = 2,
    WLR_DEBUG = 3,
    WLR_LOG_IMPORTANCE_LAST = 4,
    _,
};

/// enum wlr_button_state
pub const enum_wlr_button_state = extern enum(c_int) {
    Released,
    Pressed,
    _,
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
pub const DataSource = extern struct {
    /// struct wlr_data_source_impl
    pub const Impl = extern struct {
        send: ?fn ([*c]DataSource, [*c]const u8, i32) callconv(.C) void,
        accept: ?fn ([*c]DataSource, u32, [*c]const u8) callconv(.C) void,
        destroy: ?fn ([*c]DataSource) callconv(.C) void,
        dnd_drop: ?fn ([*c]DataSource) callconv(.C) void,
        dnd_finish: ?fn ([*c]DataSource) callconv(.C) void,
        dnd_action: ?fn ([*c]DataSource, wayland.enum_wl_data_device_manager_dnd_action) callconv(.C) void,
    };

    pub extern fn wlr_data_source_accept(source: *DataSource, serial: u32, mime_type: [*:0]const u8) void;
    pub extern fn wlr_data_source_destroy(source: *DataSource) void;
    pub extern fn wlr_data_source_dnd_action(source: *DataSource, action: wayland.enum_wl_data_device_manager_dnd_action) void;
    pub extern fn wlr_data_source_dnd_drop(source: *DataSource) void;
    pub extern fn wlr_data_source_dnd_finish(source: *DataSource) void;
    pub extern fn wlr_data_source_init(source: *DataSource, impl: [*c]const Impl) void;
    pub extern fn wlr_data_source_send(source: *DataSource, mime_type: [*:0]const u8, fd: i32) void;

    impl: [*c]const Impl,
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

pub extern const wlr_data_device_pointer_drag_interface: struct_wlr_pointer_grab_interface;
pub extern const wlr_data_device_keyboard_drag_interface: struct_wlr_keyboard_grab_interface;
pub extern const wlr_data_device_touch_drag_interface: struct_wlr_touch_grab_interface;

/// struct wlr_data_device_manager
pub const DataDeviceManager = extern struct {
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
pub const DataOffer = extern struct {
    /// enum wlr_data_offer_type
    pub const enum_wlr_data_offer_type = extern enum(c_int) {
        WLR_DATA_OFFER_SELECTION,
        WLR_DATA_OFFER_DRAG,
        _,
    };

    resource: [*c]wayland.Resource,
    source: [*c]DataSource,
    type: enum_wlr_data_offer_type,
    link: wayland.ListElement(DataOffer, "link"),
    actions: u32,
    preferred_action: wayland.enum_wl_data_device_manager_dnd_action,
    in_ask: bool,
    source_destroy: wayland.Listener(?*c_void),
};

/// struct wlr_xdg_client
pub const XDGClient = extern struct {
    shell: [*c]XDGShell,
    resource: [*c]wayland.Resource,
    client: ?*wayland.Client,
    surfaces: wayland.List(XDGSurface, "link"),
    link: wayland.ListElement(XDGClient, "link"), // wlr_xdg_shell::clients
    ping_serial: u32,
    ping_timer: ?*wayland.EventSource,
};

/// struct wlr_device
pub const Device = extern struct {
    fd: c_int,
    dev: dev_t,
    signal: wayland.Signal(?*c_void),
    link: wayland.ListElement(Device, "link"),
};

/// struct wlr_dmabuf_attributes
pub const DmabufAttributes = extern struct {
    pub extern fn wlr_dmabuf_attributes_copy(dst: [*c]DmabufAttributes, src: [*c]DmabufAttributes) bool;
    pub extern fn wlr_dmabuf_attributes_finish(attribs: [*c]DmabufAttributes) void;

    /// enum wlr_dmabuf_attributes_flags
    pub const Flags = extern enum(c_int) {
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
    pub extern fn wlr_drm_format_set_add(set: [*c]struct_wlr_drm_format_set, format: u32, modifier: u64) bool;
    pub extern fn wlr_drm_format_set_finish(set: [*c]struct_wlr_drm_format_set) void;
    pub extern fn wlr_drm_format_set_get(set: [*c]const struct_wlr_drm_format_set, format: u32) ?*const struct_wlr_drm_format;
    pub extern fn wlr_drm_format_set_has(set: [*c]const struct_wlr_drm_format_set, format: u32, modifier: u64) bool;

    len: usize,
    cap: usize,
    formats: [*c]?*struct_wlr_drm_format,
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
