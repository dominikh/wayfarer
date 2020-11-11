const std = @import("std");
const matrix = @import("matrix.zig");
const trace = @import("tracy.zig").trace;
const allocator = std.heap.c_allocator;

const stdout = std.io.getStdout().writer();

// The "seat" is a Wayland abstraction that provides one keyboard, one
// pointer device and one touch device. This is independent of the
// actual number of devices connected to a system. Multiple keyboards,
// for example, all count as "the keyboard of a seat". Things like
// differing keyboard layouts would have to be handled by dynamically
// changing the active layout.
//
// Alternatively, multiple seats can be created, with devices assigned
// to specific seats. Each seat gets its own input focus.

// Coordinate systems
//
// Output space:
//
// Extends from (0, 0) to (1,1). Top left corner is (0, 0), bottom
// right is (1, 1). Covers a single physical output.
// output.transform_matrix maps from layout space to output space,
// taking into consideration the display's resolution, orientation,
// and scale factor.
//
// An output renders a portion of layout space, equivalent to its
// effective size after scaling and rotation. For example, a 1920x1080
// monitor, rotated 90 degrees and being scaled by a factor of 2x will
// display a 540x960 portion of layout space.
//
// Layout space:
//
// Measured in pixels, extends to infinity in both directions. A
// window's size and location is specified in layout space.
//
// Surface space:
//
// A window's coordinate system, measured in pixels. (0, 0) is the
// upper left corner of the window, (width, height) is the bottom right corner.
// In the common case, surface space equals layout space plus a
// transform applied, to move the origin. Windows can, however, also
// be rotated and scaled (or otherwise manipulated in fancy compositors.)
//
// Buffer space:
//
// Measured in pixels, this space is used for the actual pixel data to
// be rendered in a window. Normally, buffer space and surface space
// are identical. A buffer can, however, also be a different size from
// the surface, expecting the compositor to scale the buffer for the
// client. The buffer can _also_ have its own transformation applied,
// usually to _avoid_ scaling by the compositor. For example a 800x600
// window, knowing that the compositor uses an output scale of 2x, may
// render into a 1600x1200 buffer instead.

// TODO(dh): force server side decorations
//
// TODO(dh): figure out and formalize handedness of our coordinate system
//
// TODO(dh): don't use std.debug.print for user output
// TODO(dh): support multiple cursors
// TODO(dh): run wayland-scanner in build.zig
// TODO(dh): the use of fieldParentPtr is error-prone, because we
//   might accidentally use the wrong field. can we do better?
// FIXME(dh): don't use @panic in functions called from C; send an error to the wayland client
// TODO(dh): ponder https://github.com/swaywm/sway/pull/4452
// TODO(dh): http://www.jlekstrand.net/jason/projects/wayland/transforms/
// TODO(dh): handle device removal
// OPT(dh): wlr_cursor stores the cursor position as f64. Find out
//   why, and if the values are ever not integer. if they're always
//   integer, we can drop our use of @round. there's probably something
//   scaling related.

const c = @cImport({
    @cDefine("WLR_USE_UNSTABLE", {});
    @cInclude("wayland-server-core.h");
    @cInclude("linux/input-event-codes.h");

    @cInclude("wlr/backend.h");
    // @cInclude("wlr/backend/drm.h");
    // @cInclude("wlr/backend/headless.h");
    // @cInclude("wlr/backend/interface.h");
    // @cInclude("wlr/backend/libinput.h");
    @cInclude("wlr/backend/multi.h");
    // @cInclude("wlr/backend/noop.h");
    // @cInclude("wlr/backend/session.h");
    // @cInclude("wlr/backend/wayland.h");
    // @cInclude("wlr/backend/x11.h");
    // @cInclude("wlr/backend/session/interface.h");

    @cInclude("wlr/xcursor.h");
    // @cInclude("wlr/config.h");
    // @cInclude("wlr/version.h");
    // @cInclude("wlr/xwayland.h");

    // @cInclude("wlr/interfaces/wlr_input_device.h");
    // @cInclude("wlr/interfaces/wlr_keyboard.h");
    // @cInclude("wlr/interfaces/wlr_output.h");
    // @cInclude("wlr/interfaces/wlr_pointer.h");
    // @cInclude("wlr/interfaces/wlr_switch.h");
    // @cInclude("wlr/interfaces/wlr_tablet_pad.h");
    // @cInclude("wlr/interfaces/wlr_tablet_tool.h");
    // @cInclude("wlr/interfaces/wlr_touch.h");

    // @cInclude("wlr/render/dmabuf.h");
    // @cInclude("wlr/render/drm_format_set.h");
    // @cInclude("wlr/render/egl.h");
    // @cInclude("wlr/render/gles2.h");
    // @cInclude("wlr/render/interface.h");
    @cInclude("wlr/render/wlr_renderer.h");
    // @cInclude("wlr/render/wlr_texture.h");

    // @cInclude("wlr/util/edges.h");
    @cInclude("wlr/util/log.h");
    // @cInclude("wlr/util/region.h");

    @cInclude("wlr/types/wlr_box.h");
    // @cInclude("wlr/types/wlr_buffer.h");
    @cInclude("wlr/types/wlr_compositor.h");
    @cInclude("wlr/types/wlr_cursor.h");
    // @cInclude("wlr/types/wlr_data_control_v1.h");
    @cInclude("wlr/types/wlr_data_device.h");
    // @cInclude("wlr/types/wlr_export_dmabuf_v1.h");
    // @cInclude("wlr/types/wlr_foreign_toplevel_management_v1.h");
    // @cInclude("wlr/types/wlr_fullscreen_shell_v1.h");
    // @cInclude("wlr/types/wlr_gamma_control_v1.h");
    // @cInclude("wlr/types/wlr_gtk_primary_selection.h");
    // @cInclude("wlr/types/wlr_idle.h");
    // @cInclude("wlr/types/wlr_idle_inhibit_v1.h");
    // @cInclude("wlr/types/wlr_input_device.h");
    // @cInclude("wlr/types/wlr_input_inhibitor.h");
    // @cInclude("wlr/types/wlr_input_method_v2.h");
    // @cInclude("wlr/types/wlr_keyboard_group.h");
    // @cInclude("wlr/types/wlr_keyboard.h");
    // @cInclude("wlr/types/wlr_keyboard_shortcuts_inhibit_v1.h");
    // @cInclude("wlr/types/wlr_layer_shell_v1.h");
    // @cInclude("wlr/types/wlr_linux_dmabuf_v1.h");
    // @cInclude("wlr/types/wlr_list.h");
    @cInclude("wlr/types/wlr_matrix.h");
    // @cInclude("wlr/types/wlr_output_damage.h");
    @cInclude("wlr/types/wlr_output.h");
    @cInclude("wlr/types/wlr_output_layout.h");
    // @cInclude("wlr/types/wlr_output_management_v1.h");
    // @cInclude("wlr/types/wlr_output_power_management_v1.h");
    // @cInclude("wlr/types/wlr_pointer_constraints_v1.h");
    // @cInclude("wlr/types/wlr_pointer_gestures_v1.h");
    // @cInclude("wlr/types/wlr_pointer.h");
    // @cInclude("wlr/types/wlr_presentation_time.h");
    // @cInclude("wlr/types/wlr_primary_selection.h");
    // @cInclude("wlr/types/wlr_primary_selection_v1.h");
    // @cInclude("wlr/types/wlr_region.h");
    // @cInclude("wlr/types/wlr_relative_pointer_v1.h");
    // @cInclude("wlr/types/wlr_screencopy_v1.h");
    @cInclude("wlr/types/wlr_seat.h");
    // @cInclude("wlr/types/wlr_server_decoration.h");
    // @cInclude("wlr/types/wlr_surface.h");
    // @cInclude("wlr/types/wlr_switch.h");
    // @cInclude("wlr/types/wlr_tablet_pad.h");
    // @cInclude("wlr/types/wlr_tablet_tool.h");
    // @cInclude("wlr/types/wlr_tablet_v2.h");
    // @cInclude("wlr/types/wlr_text_input_v3.h");
    // @cInclude("wlr/types/wlr_touch.h");
    // @cInclude("wlr/types/wlr_viewporter.h");
    // @cInclude("wlr/types/wlr_virtual_keyboard_v1.h");
    // @cInclude("wlr/types/wlr_virtual_pointer_v1.h");
    @cInclude("wlr/types/wlr_xcursor_manager.h");
    // @cInclude("wlr/types/wlr_xdg_decoration_v1.h");
    // @cInclude("wlr/types/wlr_xdg_output_v1.h");
    @cInclude("wlr/types/wlr_xdg_shell.h");
    // @cInclude("wlr/types/wlr_xdg_shell_v6.h");
});

fn ListIterator(comptime T: type, comptime forward: bool) type {
    return struct {
        head: *T,
        cur: *T,

        fn hasMore(iter: *@This()) bool {
            if (forward) {
                return iter.cur.next != iter.head;
            } else {
                return iter.cur.prev != iter.head;
            }
        }
        fn next(iter: *@This()) ?*T.elem {
            if (!iter.hasMore()) {
                return null;
            }

            if (forward) {
                iter.cur = iter.cur.next;
                return iter.cur.container();
            } else {
                iter.cur = iter.cur.prev;
                return iter.cur.container();
            }
        }
    };
}

fn List(comptime T: type, comptime element_link_field: []const u8) type {
    return struct {
        prev: *@This() = undefined,
        next: *@This() = undefined,

        const elem = T;

        fn init(self: *@This()) void {
            self.prev = self;
            self.next = self;
        }

        fn isEmpty(self: *const @This()) bool {
            return self.next == self;
        }

        fn iterate(self: *@This()) ListIterator(@This(), true) {
            return .{
                .head = self,
                .cur = self,
            };
        }

        fn iterate_reverse(self: *@This()) ListIterator(@This(), false) {
            return .{
                .head = self,
                .cur = self,
            };
        }

        fn insert(list: *@This(), elm: *@This()) void {
            elm.prev = list;
            elm.next = list.next;
            list.next = elm;
            elm.next.prev = elm;
        }

        fn remove(elm: *@This()) void {
            elm.prev.next = elm.next;
            elm.next.prev = elm.prev;
            elm.next = elm;
            elm.prev = elm;
        }

        fn container(elm: *@This()) *T {
            // look up the actual type of the link field, because we
            // have to stay compatible with C structs that use
            // wl_list, not our safe version
            const dst_type: type = TypeOfField(T, element_link_field);

            // 'elm' is field 'field' in 'T'
            return @fieldParentPtr(T, element_link_field, @ptrCast(*dst_type, elm));
        }
    };
}

fn TypeOfField(comptime T: type, comptime field: []const u8) type {
    return std.meta.fieldInfo(T, field).field_type;
}

fn Listener(comptime T: type) type {
    return struct {
        link: List(@This(), "link") = .{},
        notify: fn (*Listener(T), T) callconv(.C) void = undefined,
    };
}

fn wl_signal_add(signal: *c.struct_wl_signal, listener: anytype) void {
    // XXX verify that listener is a *Listener(T)
    c.wl_signal_add(signal, @ptrCast(*c.struct_wl_listener, listener));
}

const Position = struct {
    x: f64 = 0,
    y: f64 = 0,
};

const Server = struct {
    const CursorMode = enum {
        Normal,
        Move,
    };

    dsp: *c.struct_wl_display,
    evloop: *c.struct_wl_event_loop,

    backend: *c.struct_wlr_backend,
    renderer: *c.struct_wlr_renderer,
    output_layout: *c.struct_wlr_output_layout,

    xdg_shell: *c.struct_wlr_xdg_shell,
    new_xdg_surface: Listener(*c.struct_wlr_xdg_surface),
    views: List(View, "link"),

    cursor: *c.struct_wlr_cursor,
    cursor_mgr: *c.wlr_xcursor_manager,
    cursor_mode: CursorMode,
    grabbed_view: ?*View,
    grab_offset: Position = .{},

    outputs: List(Output, "link"),

    // TODO(dh): support multiple seats
    seat: Seat,
    pointers: List(Pointer, "link"),
    keyboards: List(Keyboard, "link"),

    new_output: Listener(*c.struct_wlr_output),
    new_input: Listener(*c.struct_wlr_input_device),
    cursor_motion: Listener(*c.struct_wlr_event_pointer_motion),
    cursor_motion_absolute: Listener(*c.struct_wlr_event_pointer_motion_absolute),
    cursor_button: Listener(*c.struct_wlr_event_pointer_button),
    cursor_frame: Listener(*c_void),

    fn init(server: *Server) void {
        server.cursor_mode = .Normal;
        server.outputs.init();
        server.views.init();
        server.keyboards.init();
        server.pointers.init();
    }

    fn update_seat_capabilities(server: *const Server) void {
        var caps: c_int = 0;
        if (!server.pointers.isEmpty()) {
            caps |= c.WL_SEAT_CAPABILITY_POINTER;
        }
        if (!server.keyboards.isEmpty()) {
            caps |= c.WL_SEAT_CAPABILITY_KEYBOARD;
        }
        server.seat.setCapabilities(@intCast(u32, caps));
    }

    fn cursorFrame(listener: *Listener(*c_void), event: *c_void) callconv(.C) void {
        const server = @fieldParentPtr(Server, "cursor_frame", listener);
        server.seat.pointerNotifyFrame();
    }

    fn cursorButton(listener: *Listener(*c.struct_wlr_event_pointer_button), event: *c.struct_wlr_event_pointer_button) callconv(.C) void {
        const server = @fieldParentPtr(Server, "cursor_button", listener);

        switch (server.cursor_mode) {
            .Normal => {
                // XXX handle return value
                _ = server.seat.pointerNotifyButton(event.time_msec, event.button, event.state);
            },

            .Move => {
                if (event.button == c.BTN_LEFT) {
                    switch (event.state) {
                        .WLR_BUTTON_RELEASED => {
                            server.cursor_mode = .Normal;
                        },
                        .WLR_BUTTON_PRESSED => {
                            // XXX throw an error, because this should be impossible
                        },
                        else => {
                            // Oh, if only C enums were exhaustive
                        },
                    }
                }
            },
        }
    }

    fn cursorMotion(listener: *Listener(*c.struct_wlr_event_pointer_motion), event: *c.struct_wlr_event_pointer_motion) callconv(.C) void {
        // XXX support relative cursor motion
        std.debug.print("cursor motion\n", .{});
    }

    //TypeOfField(@This(), "cursor_motion_absolute")
    fn cursorMotionAbsolute(listener: *Listener(*c.struct_wlr_event_pointer_motion_absolute), event: *c.struct_wlr_event_pointer_motion_absolute) callconv(.C) void {
        const server = @fieldParentPtr(Server, "cursor_motion_absolute", listener);
        c.wlr_cursor_warp_absolute(server.cursor, event.device, event.x, event.y);
        server.processCursorMotion(event.time_msec);
    }

    fn processCursorMotion(server: *Server, time_msec: u32) void {
        const lx = server.cursor.x;
        const ly = server.cursor.y;

        switch (server.cursor_mode) {
            .Normal => {
                // TODO(dh): the event coordinates are in the range [0, 1].
                // for the prototype we just hackily map to the layout. for
                // real applications, we'll have to make use of the layout,
                // support constricting absolute input devices to specific
                // outputs or portions thereof, etc.
                var surface: ?*c.struct_wlr_surface = undefined;
                var sx: f64 = undefined;
                var sy: f64 = undefined;
                if (server.findViewUnderCursor(lx, ly, &surface, &sx, &sy)) |view| {
                    // XXX set focus only if the view changed from last time
                    if (view.server.seat.getKeyboard()) |keyboard| {
                        server.seat.keyboardNotifyEnter(surface.?, &keyboard.*.keycodes, keyboard.*.num_keycodes, &keyboard.*.modifiers);
                    }

                    // XXX this probably isn't handling subsurfaces correctly
                    if (server.seat.seat.pointer_state.focused_surface == surface.?) {
                        server.seat.pointerNotifyMotion(time_msec, sx, sy);
                    } else {
                        server.seat.pointerNotifyEnter(surface.?, sx, sy);
                    }
                } else {
                    // TODO(dh): what if a button was held while the pointer left the surface?
                    server.seat.pointerNotifyClearFocus();

                    // TODO(dh): is there a fixed set of valid pointer names?
                    c.wlr_xcursor_manager_set_cursor_image(server.cursor_mgr, "left_ptr", server.cursor);
                }
            },

            .Move => {
                server.grabbed_view.?.position = .{
                    .x = lx - server.grab_offset.x,
                    .y = ly - server.grab_offset.y,
                };
            },
        }
    }

    fn findViewUnderCursor(server: *Server, lx: f64, ly: f64, surface: *?*c.struct_wlr_surface, sx: *f64, sy: *f64) ?*View {
        // OPT(dh): test against the previously found view. most of
        // the time, the cursor moves within a view.
        //
        // OPT(dh): cache check against views' transforms by finding
        // the rectangular (non-rotated) area that views occupy
        var iter = server.views.iterate();
        while (iter.hasMore()) {
            const view = iter.next().?;

            // XXX support rotation and scaling
            const view_sx = lx - view.position.x;
            const view_sy = ly - view.position.y;

            surface.* = c.wlr_xdg_surface_surface_at(view.xdg_surface, view_sx, view_sy, sx, sy);
            if (surface.* != null) {
                return view;
            }
        }
        return null;
    }

    fn newInput(listener: *Listener(*c.wlr_input_device), device: *c.wlr_input_device) callconv(.C) void {
        const server = @fieldParentPtr(Server, "new_input", listener);

        switch (device.type) {
            .WLR_INPUT_DEVICE_KEYBOARD => {
                var keyboard = allocator.create(Keyboard) catch @panic("out of memory");
                keyboard.server = server;
                keyboard.device = device;

                // TODO(dh): a whole bunch of keymap stuff
                const rules: c.xkb_rule_names = undefined;
                const context = c.xkb_context_new(.XKB_CONTEXT_NO_FLAGS);
                const keymap = c.xkb_map_new_from_names(context, &rules, .XKB_KEYMAP_COMPILE_NO_FLAGS);

                _ = c.wlr_keyboard_set_keymap(device.unnamed_0.keyboard, keymap);
                c.xkb_keymap_unref(keymap);
                c.xkb_context_unref(context);
                c.wlr_keyboard_set_repeat_info(device.unnamed_0.keyboard, 25, 600);

                keyboard.modifiers.notify = Keyboard.handleModifiers;
                keyboard.key.notify = Keyboard.handleKey;
                keyboard.keymap.notify = Keyboard.handleKeymap;
                keyboard.repeat_info.notify = Keyboard.handleRepeatInfo;
                keyboard.destroy.notify = Keyboard.handleDestroy;
                wl_signal_add(&device.unnamed_0.keyboard.*.events.modifiers, &keyboard.modifiers);
                wl_signal_add(&device.unnamed_0.keyboard.*.events.key, &keyboard.key);
                wl_signal_add(&device.unnamed_0.keyboard.*.events.keymap, &keyboard.keymap);
                wl_signal_add(&device.unnamed_0.keyboard.*.events.repeat_info, &keyboard.repeat_info);
                wl_signal_add(&device.unnamed_0.keyboard.*.events.destroy, &keyboard.destroy);

                server.keyboards.insert(&keyboard.link);

                if (server.seat.getKeyboard() == null) {
                    // set the first added keyboard as active so we
                    // can give new clients keyboard focus even before
                    // any key has been pressed.
                    server.seat.setKeyboard(device);
                }
            },

            .WLR_INPUT_DEVICE_POINTER => {
                c.wlr_cursor_attach_input_device(server.cursor, device);
                var pointer = allocator.create(Pointer) catch @panic("out of memory");
                pointer.server = server;
                pointer.device = device;
                server.pointers.insert(&pointer.link);
            },

            else => {
                // TODO(dh): handle other devices
            },
        }

        server.update_seat_capabilities();
    }

    fn newXdgSurface(listener: *Listener(*c.struct_wlr_xdg_surface), xdg_surface: *c.struct_wlr_xdg_surface) callconv(.C) void {
        const server = @fieldParentPtr(Server, "new_xdg_surface", listener);
        switch (xdg_surface.role) {
            .WLR_XDG_SURFACE_ROLE_TOPLEVEL => {
                var view = allocator.create(View) catch @panic("out of memory");
                view.* = .{
                    .server = server,
                    .xdg_surface = xdg_surface,
                };

                view.map.notify = View.xdgSurfaceMap;
                view.unmap.notify = View.xdgSurfaceUnmap;
                view.destroy.notify = View.xdgSurfaceDestroy;
                wl_signal_add(&xdg_surface.events.map, &view.map);
                wl_signal_add(&xdg_surface.events.unmap, &view.unmap);
                wl_signal_add(&xdg_surface.events.destroy, &view.destroy);

                const toplevel = xdg_surface.unnamed_0.toplevel;
                view.request_move.notify = View.xdgToplevelRequestMove;
                view.request_resize.notify = View.xdgToplevelRequestResize;
                wl_signal_add(&toplevel.*.events.request_move, &view.request_move);
                wl_signal_add(&toplevel.*.events.request_resize, &view.request_resize);

                server.views.insert(&view.link);
            },
            else => {
                // TODO(dh): handle other roles
            },
        }
    }
};

const Seat = struct {
    seat: *c.wlr_seat,

    request_cursor: Listener(*c.struct_wlr_seat_pointer_request_set_cursor_event),

    fn setCapabilities(seat: *const Seat, caps: u32) void {
        c.wlr_seat_set_capabilities(seat.seat, caps);
    }

    fn setKeyboard(seat: *const Seat, kbd: *c.wlr_input_device) void {
        c.wlr_seat_set_keyboard(seat.seat, kbd);
    }

    fn getKeyboard(seat: *const Seat) ?*c.struct_wlr_keyboard {
        return c.wlr_seat_get_keyboard(seat.seat);
    }

    fn keyboardNotifyEnter(seat: *const Seat, surface: *c.struct_wlr_surface, keycodes: [*]u32, num_keycodes: usize, modifiers: *c.struct_wlr_keyboard_modifiers) void {
        c.wlr_seat_keyboard_notify_enter(seat.seat, surface, keycodes, num_keycodes, modifiers);
    }

    fn keyboardNotifyModifiers(seat: *const Seat, mods: *c.struct_wlr_keyboard_modifiers) void {
        c.wlr_seat_keyboard_notify_modifiers(seat.seat, mods);
    }

    fn keyboardNotifyKey(seat: *const Seat, time_msec: u32, keycode: u32, state: c.enum_wlr_key_state) void {
        c.wlr_seat_keyboard_notify_key(seat.seat, time_msec, keycode, @intCast(u32, @enumToInt(state)));
    }

    fn pointerNotifyEnter(seat: *const Seat, surface: *c.struct_wlr_surface, sx: f64, sy: f64) void {
        c.wlr_seat_pointer_notify_enter(seat.seat, surface, sx, sy);
    }

    fn pointerNotifyClearFocus(seat: *const Seat) void {
        c.wlr_seat_pointer_notify_clear_focus(seat.seat);
    }

    fn pointerNotifyButton(seat: *const Seat, time_msec: u32, button: u32, state: c.enum_wlr_button_state) u32 {
        return c.wlr_seat_pointer_notify_button(seat.seat, time_msec, button, state);
    }

    fn pointerNotifyMotion(seat: *const Seat, time_msec: u32, sx: f64, sy: f64) void {
        c.wlr_seat_pointer_notify_motion(seat.seat, time_msec, sx, sy);
    }

    fn pointerNotifyFrame(seat: *const Seat) void {
        c.wlr_seat_pointer_notify_frame(seat.seat);
    }

    fn requestCursor(listener: *Listener(*c.struct_wlr_seat_pointer_request_set_cursor_event), event: *c.struct_wlr_seat_pointer_request_set_cursor_event) callconv(.C) void {
        const seat = @fieldParentPtr(Seat, "request_cursor", listener);
        const server = @fieldParentPtr(Server, "seat", seat);
        if (seat.seat.pointer_state.focused_client == event.seat_client) {
            c.wlr_cursor_set_surface(server.cursor, event.surface, event.hotspot_x, event.hotspot_y);
        }
    }
};

const Output = struct {
    output: *c.struct_wlr_output,
    server: *Server,
    last_frame: std.os.timespec,

    destroy: Listener(*c.struct_wlr_output),
    frame: Listener(*c.struct_wlr_output),

    link: List(@This(), "link"),

    fn transform_matrix(output: *Output) matrix.Matrix {
        return @bitCast(matrix.Matrix, output.output.transform_matrix);
    }

    fn newOutputNotify(listener: *Listener(*c.struct_wlr_output), output: *c.struct_wlr_output) callconv(.C) void {
        std.debug.print("new output\n", .{});
        const server = @fieldParentPtr(Server, "new_output", listener);

        const modes = @ptrCast(*List(c.wlr_output_mode, "link"), &output.modes);
        if (!modes.isEmpty()) {
            const mode: *c.wlr_output_mode = modes.prev.container();
            c.wlr_output_set_mode(output, mode);
            c.wlr_output_enable(output, true);
            if (!c.wlr_output_commit(output)) {
                return;
            }
        }

        var our_output = allocator.create(Output) catch @panic("out of memory");
        our_output.output = output;
        our_output.server = server;
        std.os.clock_gettime(std.os.CLOCK_MONOTONIC, &our_output.last_frame) catch |err| @panic(@errorName(err));
        server.outputs.insert(&our_output.link);

        our_output.destroy.notify = Output.destroyNotify;
        our_output.frame.notify = Output.frameNotify;
        wl_signal_add(&output.events.destroy, &our_output.destroy);
        wl_signal_add(&output.events.frame, &our_output.frame);

        c.wlr_output_layout_add_auto(server.output_layout, output);
    }

    fn destroyNotify(listener: *Listener(*c.struct_wlr_output), data: *c.struct_wlr_output) callconv(.C) void {
        const our_output = @fieldParentPtr(Output, "destroy", listener);

        our_output.link.remove();
        // XXX listRemove
        // our_output.destroy.remove();
        // our_output.frame.remove();

        // XXX deallocate our output?
    }

    fn frameNotify(listener: *Listener(*c.struct_wlr_output), output: *c.struct_wlr_output) callconv(.C) void {
        const tracy = trace(@src());
        defer tracy.end();

        const our_output = @fieldParentPtr(Output, "frame", listener);
        const server = our_output.server;
        const renderer = server.renderer;

        var now: std.os.timespec = undefined;
        // XXX don't panic
        std.os.clock_gettime(std.os.CLOCK_MONOTONIC, &now) catch |err| @panic(@errorName(err));

        if (!c.wlr_output_attach_render(output, null)) {
            // TODO(dh): why can this fail?
            return;
        }

        var width: c_int = undefined;
        var height: c_int = undefined;
        c.wlr_output_effective_resolution(our_output.output, &width, &height);
        c.wlr_renderer_begin(renderer, width, height);

        const color = [_]f32{ 0.3, 0.3, 0.3, 1 };
        c.wlr_renderer_clear(renderer, color[0..4]);

        var iter = server.views.iterate_reverse();
        while (iter.hasMore()) {
            const view = iter.next().?;
            if (!view.mapped) {
                continue;
            }
            const texture = c.wlr_surface_get_texture(view.xdg_surface.surface) orelse continue;

            // buffer -> surface -> layout -> output

            // TODO(dh): support rotated outputs
            // TODO(dh): support outputs not positioned at (0, 0) in layout space
            // TODO(dh): support buffers that don't match surface coordinates

            var m = view.transformation_matrix();
            matrix.mul(&m, @bitCast(matrix.Matrix, output.transform_matrix), m);

            // XXX handle failure
            _ = c.wlr_render_texture_with_matrix(renderer, texture, matrix.linear(&m), 1);
            // XXX make sure the two timespec structs are actually ABI compatible
            c.wlr_surface_send_frame_done(view.xdg_surface.surface, @ptrCast(*c.struct_timespec, &now));
        }

        c.wlr_output_render_software_cursors(our_output.output, null);

        c.wlr_renderer_end(renderer);
        if (!c.wlr_output_commit(our_output.output)) {
            // TODO(dh): why can this fail?
            return;
        }
    }
};

fn deg2rad(deg: f32) f32 {
    return (deg * std.math.pi) / 180.0;
}

const View = struct {
    server: *Server,
    xdg_surface: *c.struct_wlr_xdg_surface,
    // the view's position in layout space
    position: Position = .{},
    rotation: f32 = 0, // in radians
    mapped: bool = false,

    map: Listener(*c.struct_wlr_xdg_surface) = .{},
    unmap: Listener(*c.struct_wlr_xdg_surface) = .{},
    destroy: Listener(*c.struct_wlr_xdg_surface) = .{},
    request_move: Listener(*c.struct_wlr_xdg_toplevel_move_event) = .{},
    request_resize: Listener(*c.struct_wlr_xdg_toplevel_resize_event) = .{},

    link: List(@This(), "link") = .{},

    // transformation_matrix maps the view to layout space.
    fn transformation_matrix(view: *const View) matrix.Matrix {
        // TODO(dh): support buffer transforms

        // OPT(dh): cache this computation, update the matrix when
        // position, size or rotation change
        const x = view.position.x;
        const y = view.position.y;

        // translate
        // rotate
        // scale
        var m = matrix.Identity;
        matrix.translate(&m, @floatCast(f32, x), @floatCast(f32, y));
        // TODO(dh): rotation should probably be around the center, not the origin
        matrix.rotate(&m, view.rotation);
        matrix.scale(&m, @intToFloat(f32, view.width()), @intToFloat(f32, view.height()));
        return m;
    }

    fn getGeometry(view: *const View) c.wlr_box {
        // TODO(dh): de-c-ify all of this
        var box: c.wlr_box = undefined;
        c.wlr_surface_get_extends(view.xdg_surface.surface, &box);
        if (view.xdg_surface.geometry.width == 0) {
            return box;
        }
        // XXX handle return value
        _ = c.wlr_box_intersection(&box, &view.xdg_surface.geometry, &box);
        return box;
    }

    fn width(surface: *const View) i32 {
        return surface.xdg_surface.surface.*.current.width;
    }

    fn height(surface: *const View) i32 {
        return surface.xdg_surface.surface.*.current.height;
    }

    // TODO(dh): implement all of these
    fn xdgSurfaceMap(listener: *Listener(*c.struct_wlr_xdg_surface), surface: *c.struct_wlr_xdg_surface) callconv(.C) void {
        std.debug.print("mapping {}\n", .{surface});
        const view = @fieldParentPtr(View, "map", listener);
        view.mapped = true;

        _ = c.wlr_xdg_toplevel_set_activated(surface, true);
    }

    fn xdgSurfaceUnmap(listener: *Listener(*c.struct_wlr_xdg_surface), surface: *c.struct_wlr_xdg_surface) callconv(.C) void {
        const view = @fieldParentPtr(View, "map", listener);
        view.mapped = false;
    }

    fn xdgSurfaceDestroy(listener: *Listener(*c.struct_wlr_xdg_surface), surface: *c.struct_wlr_xdg_surface) callconv(.C) void {
        var view = @fieldParentPtr(View, "destroy", listener);
        view.link.remove();
        allocator.destroy(view);
    }
    fn xdgToplevelRequestMove(listener: *Listener(*c.struct_wlr_xdg_toplevel_move_event), event: *c.struct_wlr_xdg_toplevel_move_event) callconv(.C) void {
        // TODO(dh): check the serial against recent button presses, to prevent bad clients from invoking this at will
        // TODO(dh): only allow this request from the focussed client
        const view = @fieldParentPtr(View, "request_move", listener);
        const server = view.server;

        server.cursor_mode = .Move;
        server.grabbed_view = view;
        server.grab_offset = .{
            .x = server.cursor.x - view.position.x,
            .y = server.cursor.y - view.position.y,
        };
    }

    fn xdgToplevelRequestResize(listener: *Listener(*c.struct_wlr_xdg_toplevel_resize_event), surface: *c.struct_wlr_xdg_toplevel_resize_event) callconv(.C) void {}
};

const Pointer = struct {
    server: *Server,
    device: *c.wlr_input_device,

    link: List(@This(), "link"),
};

const Keyboard = struct {
    server: *Server,
    device: *c.wlr_input_device,

    modifiers: Listener(*c_void),
    key: Listener(*c.wlr_event_keyboard_key),
    keymap: Listener(*c_void),
    repeat_info: Listener(*c_void),
    destroy: Listener(*c_void),

    link: List(@This(), "link"),

    // TODO(dh): implement all of these
    fn handleModifiers(listener: *Listener(*c_void), data: *c_void) callconv(.C) void {
        const keyboard = @fieldParentPtr(Keyboard, "modifiers", listener);
        const seat = keyboard.server.seat;
        // TODO(dh): is there any benefit to avoiding repeated calls to this?
        seat.setKeyboard(keyboard.device);
        seat.keyboardNotifyModifiers(&keyboard.device.unnamed_0.keyboard.*.modifiers);
    }
    fn handleKey(listener: *Listener(*c.wlr_event_keyboard_key), key: *c.wlr_event_keyboard_key) callconv(.C) void {
        const keyboard = @fieldParentPtr(Keyboard, "key", listener);
        const server = keyboard.server;
        const seat = server.seat;

        // TODO(dh): is there any benefit to avoiding repeated calls to this?
        seat.setKeyboard(keyboard.device);
        seat.keyboardNotifyKey(key.time_msec, key.keycode, key.state);
    }
    fn handleKeymap(listener: *Listener(*c_void), data: *c_void) callconv(.C) void {}
    fn handleRepeatInfo(listener: *Listener(*c_void), data: *c_void) callconv(.C) void {}
    fn handleDestroy(listener: *Listener(*c_void), data: *c_void) callconv(.C) void {}
};

pub fn main() !void {
    // c.wlr_log_init(c.enum_wlr_log_importance.WLR_DEBUG, null);
    var server: Server = undefined;
    server.init();

    server.dsp = c.wl_display_create() orelse return error.Failure;
    defer c.wl_display_destroy(server.dsp);

    server.evloop = c.wl_display_get_event_loop(server.dsp) orelse return error.Failure;
    server.backend = c.wlr_backend_autocreate(server.dsp, null) orelse return error.Failure;
    defer c.wlr_backend_destroy(server.backend);

    server.renderer = c.wlr_backend_get_renderer(server.backend);
    // XXX
    _ = c.wlr_renderer_init_wl_display(server.renderer, server.dsp);
    server.new_output.notify = Output.newOutputNotify;
    wl_signal_add(&server.backend.events.new_output, &server.new_output);

    // TODO(dh): do we need to free anything?
    _ = c.wlr_compositor_create(server.dsp, server.renderer);
    _ = c.wlr_data_device_manager_create(server.dsp);

    server.output_layout = c.wlr_output_layout_create() orelse return error.Failure;
    defer c.wlr_output_layout_destroy(server.output_layout);

    server.cursor = c.wlr_cursor_create() orelse return error.Failure;
    defer c.wlr_cursor_destroy(server.cursor);

    c.wlr_cursor_attach_output_layout(server.cursor, server.output_layout);

    // TODO(dh): what do the arguments mean?
    server.cursor_mgr = c.wlr_xcursor_manager_create(null, 24) orelse return error.Failure;
    defer c.wlr_xcursor_manager_destroy(server.cursor_mgr);
    if (!c.wlr_xcursor_manager_load(server.cursor_mgr, 1)) {
        std.debug.print("failed to load cursor theme", .{});
        return error.Failure;
    }

    // TODO(dh): other cursor events
    server.cursor_motion.notify = Server.cursorMotion;
    server.cursor_motion_absolute.notify = Server.cursorMotionAbsolute;
    server.cursor_button.notify = Server.cursorButton;
    server.cursor_frame.notify = Server.cursorFrame;
    wl_signal_add(&server.cursor.events.motion, &server.cursor_motion);
    wl_signal_add(&server.cursor.events.motion_absolute, &server.cursor_motion_absolute);
    wl_signal_add(&server.cursor.events.button, &server.cursor_button);
    wl_signal_add(&server.cursor.events.frame, &server.cursor_frame);

    server.new_input.notify = Server.newInput;
    wl_signal_add(&server.backend.events.new_input, &server.new_input);

    server.seat.seat = c.wlr_seat_create(server.dsp, "seat0") orelse return error.Failure;
    defer c.wlr_seat_destroy(server.seat.seat);

    server.seat.request_cursor.notify = Seat.requestCursor;
    wl_signal_add(&server.seat.seat.events.request_set_cursor, &server.seat.request_cursor);

    // note: no destructor; the shell is a static global
    server.xdg_shell = c.wlr_xdg_shell_create(server.dsp) orelse return error.Failure;
    server.new_xdg_surface.notify = Server.newXdgSurface;
    wl_signal_add(&server.xdg_shell.events.new_surface, &server.new_xdg_surface);

    const socket: [*:0]const u8 = c.wl_display_add_socket_auto(server.dsp) orelse return error.Failure;
    std.debug.print("listening on {}\n", .{socket});

    if (!c.wlr_backend_start(server.backend)) {
        return error.Failure;
    }
    c.wl_display_run(server.dsp);
    defer c.wl_display_destroy_clients(server.dsp);
}
