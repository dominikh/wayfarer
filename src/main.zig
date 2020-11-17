const std = @import("std");
const wl = @import("wayland.zig");
const wlroots = @import("wlroots.zig");
const xkb = @import("xkb.zig");
const tracy = @import("tracy.zig");
const libinput = @cImport({
    @cInclude("linux/input.h");
});
var allocator_state = tracy.Allocator.init(std.heap.c_allocator, "C allocator");
const allocator = &allocator_state.allocator;

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

// Resources
// - https://ppaalanen.blogspot.com/2013/11/sub-surfaces-now.html

// Coordinate systems
//
// Absolute pointer space:
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
// Window geometry space:
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
// XXX is it me, or does wlroots not let us change surface state
//   atomically? e.g. setting the size and setting activated both
//   schedule configure events

// TODO(dh): input handling: support swipe, pinch, touch and tablet

// xdg_wm_base
//   requests
//   - [-] destroy
//   - [-] create_positioner
//   - [-] get_xdg_surface
//   - [ ] pong
//   events
//   - [ ] ping
//
// xdg_positioner
//   requests
//   - [-] destroy
//   - [ ] set_size
//   - [ ] set_anchor_rect
//   - [ ] set_anchor
//   - [ ] set_gravity
//   - [ ] set_constraint_adjustment
//   - [ ] set_offset
//   - [ ] set_reactive
//   - [ ] set_parent_size
//   - [ ] set_parent_configure
//
// xdg_surface
//   requests
//   - [-] destroy
//   - [ ] get_toplevel
//   - [ ] get_popup
//   - [ ] set_window_geometry
//   - [ ] ack_configure
//   - [ ] configure
//
// xdg_toplevel
//   requests
//   - [-] destroy
//   - [ ] set_parent
//   - [-] set_title
//   - [-] set_app_id
//   - [ ] show_window_menu
//   - [X] move
//   - [X] resize
//   - [X] set_max_size
//   - [X] set_min_size
//   - [X] set_maximized
//   - [X] unset_maximized
//   - [ ] set_fullscreen
//   - [ ] unset_fullscreen
//   - [ ] set_minimized
//   events
//   - [X] configure
//   - [ ] close
//
// xdg_popup
//   requests
//   - [-] destroy
//   - [ ] grab
//   - [ ] reposition
//   events
//   - [ ] configure
//   - [ ] popup_done
//   - [ ] repositioned

// const c = @cImport({
//     @cDefine("WLR_USE_UNSTABLE", {});
//     @cInclude("wayland-server-core.h");
//     @cInclude("linux/input-event-codes.h");

//     @cInclude("wlr/backend.h");
//     // @cInclude("wlr/backend/drm.h");
//     // @cInclude("wlr/backend/headless.h");
//     // @cInclude("wlr/backend/interface.h");
//     // @cInclude("wlr/backend/libinput.h");
//     @cInclude("wlr/backend/multi.h");
//     // @cInclude("wlr/backend/noop.h");
//     // @cInclude("wlr/backend/session.h");
//     // @cInclude("wlr/backend/wayland.h");
//     // @cInclude("wlr/backend/x11.h");
//     // @cInclude("wlr/backend/session/interface.h");

//     @cInclude("wlr/xcursor.h");
//     // @cInclude("wlr/config.h");
//     // @cInclude("wlr/version.h");
//     // @cInclude("wlr/xwayland.h");

//     // @cInclude("wlr/interfaces/wlr_input_device.h");
//     // @cInclude("wlr/interfaces/wlr_keyboard.h");
//     // @cInclude("wlr/interfaces/wlr_output.h");
//     // @cInclude("wlr/interfaces/wlr_pointer.h");
//     // @cInclude("wlr/interfaces/wlr_switch.h");
//     // @cInclude("wlr/interfaces/wlr_tablet_pad.h");
//     // @cInclude("wlr/interfaces/wlr_tablet_tool.h");
//     // @cInclude("wlr/interfaces/wlr_touch.h");

//     // @cInclude("wlr/render/dmabuf.h");
//     // @cInclude("wlr/render/drm_format_set.h");
//     // @cInclude("wlr/render/egl.h");
//     // @cInclude("wlr/render/gles2.h");
//     // @cInclude("wlr/render/interface.h");
//     @cInclude("wlr/render/wlr_renderer.h");
//     // @cInclude("wlr/render/wlr_texture.h");

//     // @cInclude("wlr/util/edges.h");
//     @cInclude("wlr/util/log.h");
//     // @cInclude("wlr/util/region.h");

//     @cInclude("wlr/types/wlr_box.h");
//     // @cInclude("wlr/types/wlr_buffer.h");
//     @cInclude("wlr/types/wlr_compositor.h");
//     @cInclude("wlr/types/wlr_cursor.h");
//     // @cInclude("wlr/types/wlr_data_control_v1.h");
//     @cInclude("wlr/types/wlr_data_device.h");
//     // @cInclude("wlr/types/wlr_export_dmabuf_v1.h");
//     // @cInclude("wlr/types/wlr_foreign_toplevel_management_v1.h");
//     // @cInclude("wlr/types/wlr_fullscreen_shell_v1.h");
//     // @cInclude("wlr/types/wlr_gamma_control_v1.h");
//     // @cInclude("wlr/types/wlr_gtk_primary_selection.h");
//     // @cInclude("wlr/types/wlr_idle.h");
//     // @cInclude("wlr/types/wlr_idle_inhibit_v1.h");
//     // @cInclude("wlr/types/wlr_input_device.h");
//     // @cInclude("wlr/types/wlr_input_inhibitor.h");
//     // @cInclude("wlr/types/wlr_input_method_v2.h");
//     // @cInclude("wlr/types/wlr_keyboard_group.h");
//     // @cInclude("wlr/types/wlr_keyboard.h");
//     // @cInclude("wlr/types/wlr_keyboard_shortcuts_inhibit_v1.h");
//     // @cInclude("wlr/types/wlr_layer_shell_v1.h");
//     // @cInclude("wlr/types/wlr_linux_dmabuf_v1.h");
//     // @cInclude("wlr/types/wlr_list.h");
//     @cInclude("wlr/types/wlr_matrix.h");
//     // @cInclude("wlr/types/wlr_output_damage.h");
//     @cInclude("wlr/types/wlr_output.h");
//     @cInclude("wlr/types/wlr_output_layout.h");
//     // @cInclude("wlr/types/wlr_output_management_v1.h");
//     // @cInclude("wlr/types/wlr_output_power_management_v1.h");
//     // @cInclude("wlr/types/wlr_pointer_constraints_v1.h");
//     // @cInclude("wlr/types/wlr_pointer_gestures_v1.h");
//     // @cInclude("wlr/types/wlr_pointer.h");
//     // @cInclude("wlr/types/wlr_presentation_time.h");
//     // @cInclude("wlr/types/wlr_primary_selection.h");
//     // @cInclude("wlr/types/wlr_primary_selection_v1.h");
//     // @cInclude("wlr/types/wlr_region.h");
//     // @cInclude("wlr/types/wlr_relative_pointer_v1.h");
//     // @cInclude("wlr/types/wlr_screencopy_v1.h");
//     @cInclude("wlr/types/wlr_seat.h");
//     // @cInclude("wlr/types/wlr_server_decoration.h");
//     // @cInclude("wlr/types/wlr_surface.h");
//     // @cInclude("wlr/types/wlr_switch.h");
//     // @cInclude("wlr/types/wlr_tablet_pad.h");
//     // @cInclude("wlr/types/wlr_tablet_tool.h");
//     // @cInclude("wlr/types/wlr_tablet_v2.h");
//     // @cInclude("wlr/types/wlr_text_input_v3.h");
//     // @cInclude("wlr/types/wlr_touch.h");
//     // @cInclude("wlr/types/wlr_viewporter.h");
//     // @cInclude("wlr/types/wlr_virtual_keyboard_v1.h");
//     // @cInclude("wlr/types/wlr_virtual_pointer_v1.h");
//     @cInclude("wlr/types/wlr_xcursor_manager.h");
//     // @cInclude("wlr/types/wlr_xdg_decoration_v1.h");
//     // @cInclude("wlr/types/wlr_xdg_output_v1.h");
//     @cInclude("wlr/types/wlr_xdg_shell.h");
//     // @cInclude("wlr/types/wlr_xdg_shell_v6.h");
// });

const Vec2 = struct {
    x: f64 = 0,
    y: f64 = 0,
};

const Box = struct {
    x: f64 = 0,
    y: f64 = 0,
    width: f64 = 0,
    height: f64 = 0,
};

const Server = struct {
    const CursorModeTag = enum {
        Normal,
        Move,
        Resize,
    };

    const CursorMode = union(CursorModeTag) {
        Normal: void,
        Move: struct {
            grabbed_view: *View,
            orig_position: Vec2,
            /// The cursor position when the grab was initiated, in layout coordinates
            orig_cursor: Vec2,
        },
        Resize: *View,
    };

    dsp: *wl.Display,
    evloop: *wl.EventLoop,

    backend: *wlroots.Backend,
    renderer: *wlroots.Renderer,
    output_layout: *wlroots.Output.Layout,

    xdg_shell: *wlroots.XDGShell,
    views: wl.List(View, "link"),

    cursor: *wlroots.Cursor,
    cursor_mgr: *wlroots.XCursor.Manager,
    cursor_mode: CursorMode = .{ .Normal = .{} },

    outputs: wl.List(Output, "link"),

    // TODO(dh): support multiple seats
    seat: Seat,
    pointers: wl.List(Pointer, "link"),
    keyboards: wl.List(Keyboard, "link"),

    new_xdg_surface: wl.Listener(*wlroots.XDGSurface),
    new_output: wl.Listener(*wlroots.Output),
    new_input: wl.Listener(*wlroots.InputDevice),
    cursor_motion: wl.Listener(*wlroots.Pointer.Events.Motion),
    cursor_motion_absolute: wl.Listener(*wlroots.Pointer.Events.MotionAbsolute),
    cursor_button: wl.Listener(*wlroots.Pointer.Events.Button),
    cursor_axis: wl.Listener(*wlroots.Pointer.Events.Axis),
    cursor_frame: wl.Listener(*wlroots.Cursor),

    fn init(server: *Server) void {
        server.cursor_mode = .Normal;
        server.outputs.init();
        server.views.init();
        server.keyboards.init();
        server.pointers.init();
    }

    fn updateSeatCapabilities(server: *const Server) void {
        var caps: c_int = 0;
        if (!server.pointers.isEmpty()) {
            caps |= @enumToInt(wl.struct_wl_seat.enum_wl_seat_capability.WL_SEAT_CAPABILITY_POINTER);
        }
        if (!server.keyboards.isEmpty()) {
            caps |= @enumToInt(wl.struct_wl_seat.enum_wl_seat_capability.WL_SEAT_CAPABILITY_KEYBOARD);
        }
        server.seat.seat.setCapabilities(@intCast(u32, caps));
    }

    fn cursorFrame(listener: *wl.Listener(*wlroots.Cursor), event: *wlroots.Cursor) void {
        const server = @fieldParentPtr(Server, "cursor_frame", listener);
        server.seat.seat.pointerNotifyFrame();
    }

    fn cursorButton(listener: *wl.Listener(*wlroots.Pointer.Events.Button), event: *wlroots.Pointer.Events.Button) void {
        const server = @fieldParentPtr(Server, "cursor_button", listener);

        // XXX handle return value
        _ = server.seat.seat.pointerNotifyButton(event.time_msec, event.button, event.state);

        switch (server.cursor_mode) {
            .Normal => {},
            .Move, .Resize => {
                if (event.button == libinput.BTN_LEFT) {
                    switch (event.state) {
                        .Released => {
                            switch (server.cursor_mode) {
                                .Move => |value| {
                                    _ = value.grabbed_view.xdg_toplevel.SetResizing(false);
                                },
                                .Resize => |view| {
                                    _ = view.xdg_toplevel.SetResizing(false);
                                },
                                else => {},
                            }

                            server.cursor_mode = .Normal;
                        },
                        .Pressed => {
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

    fn cursorMotion(listener: *wl.Listener(*wlroots.Pointer.Events.Motion), event: *wlroots.Pointer.Events.Motion) void {
        // XXX support relative cursor motion
        std.debug.print("cursor motion\n", .{});
    }

    fn cursorMotionAbsolute(listener: *wl.Listener(*wlroots.Pointer.Events.MotionAbsolute), event: *wlroots.Pointer.Events.MotionAbsolute) void {
        const server = @fieldParentPtr(Server, "cursor_motion_absolute", listener);
        server.cursor.warpAbsolute(event.device, event.x, event.y);
        server.processCursorMotion(event.time_msec);
    }

    fn cursorAxis(listener: *wl.Listener(*wlroots.Pointer.Events.Axis), event: *wlroots.Pointer.Events.Axis) void {
        const server = @fieldParentPtr(Server, "cursor_axis", listener);
        if (server.seat.seat.pointer_state.focused_surface) |surface| {
            server.seat.pointerNotifyAxis(
                event.time_msec,
                event.orientation,
                event.delta,
                event.delta_discrete,
                event.source,
            );
        } else {
            // TODO(dh): let the compositor handle axis events
        }
    }

    fn processCursorMotion(server: *Server, time_msec: u32) void {
        const cursor_lx = server.cursor.x;
        const cursor_ly = server.cursor.y;

        switch (server.cursor_mode) {
            .Normal => {
                // TODO(dh): the event coordinates are in the range [0, 1].
                // for the prototype we just hackily map to the layout. for
                // real applications, we'll have to make use of the layout,
                // support constricting absolute input devices to specific
                // outputs or portions thereof, etc.
                var surface: *wlroots.Surface = undefined;
                var sx: f64 = undefined;
                var sy: f64 = undefined;
                if (server.findViewUnderCursor(cursor_lx, cursor_ly, &surface, &sx, &sy)) |view| {
                    // XXX set focus only if the view changed from last time
                    if (view.server.seat.seat.getKeyboard()) |keyboard| {
                        server.seat.seat.keyboardNotifyEnter(surface, keyboard.keycodes[0..keyboard.num_keycodes], &keyboard.modifiers);
                    }

                    // XXX this probably isn't handling subsurfaces correctly
                    if (server.seat.seat.pointer_state.focused_surface == surface) {
                        server.seat.seat.pointerNotifyMotion(time_msec, sx, sy);
                    } else {
                        server.seat.seat.pointerNotifyEnter(surface, sx, sy);
                    }
                } else {
                    // TODO(dh): what if a button was held while the pointer left the surface?
                    server.seat.seat.pointerNotifyClearFocus();

                    // TODO(dh): is there a fixed set of valid pointer names?
                    server.cursor_mgr.setCursorImage("left_ptr", server.cursor);
                }
            },

            .Move => |value| {
                const delta_lx = cursor_lx - value.orig_cursor.x;
                const delta_ly = cursor_ly - value.orig_cursor.y;
                value.grabbed_view.position = .{
                    .x = value.orig_position.x + delta_lx,
                    .y = value.orig_position.y + delta_ly,
                };
            },

            .Resize => |view| {
                const ar = view.active_resize;
                const delta_lx = cursor_lx - ar.orig_cursor.x;
                const delta_ly = cursor_ly - ar.orig_cursor.y;

                var new_size = Vec2{
                    .x = ar.orig_geometry.width,
                    .y = ar.orig_geometry.height,
                };
                if (ar.edges & @intCast(u32, @enumToInt(wlroots.enum_wlr_edges.WLR_EDGE_LEFT)) != 0) {
                    new_size.x = ar.orig_geometry.width - delta_lx;
                } else if (ar.edges & @intCast(u32, @enumToInt(wlroots.enum_wlr_edges.WLR_EDGE_RIGHT)) != 0) {
                    new_size.x = ar.orig_geometry.width + delta_lx;
                }
                if (ar.edges & @intCast(u32, @enumToInt(wlroots.enum_wlr_edges.WLR_EDGE_TOP)) != 0) {
                    new_size.y = ar.orig_geometry.height - delta_ly;
                } else if (ar.edges & @intCast(u32, @enumToInt(wlroots.enum_wlr_edges.WLR_EDGE_BOTTOM)) != 0) {
                    new_size.y = ar.orig_geometry.height + delta_ly;
                }

                const state = view.xdg_toplevel.current;
                const min_width = @intToFloat(f64, state.min_width);
                const min_height = @intToFloat(f64, state.min_height);
                if (new_size.x < min_width) {
                    new_size.x = min_width;
                }
                if (new_size.y < min_height) {
                    new_size.y = min_height;
                }

                _ = view.xdg_toplevel.SetSize(
                    @floatToInt(u32, @round(new_size.x)),
                    @floatToInt(u32, @round(new_size.y)),
                );
            },
        }
    }

    /// findViewUnderCursor finds the view and surface at position (lx, ly), respecting input regions.
    fn findViewUnderCursor(server: *Server, lx: f64, ly: f64, surface: **wlroots.Surface, sx: *f64, sy: *f64) ?*View {
        // OPT(dh): test against the previously found view. most of
        // the time, the cursor moves within a view.
        //
        // OPT(dh): cache check against views' transforms by finding
        // the rectangular (non-rotated) area that views occupy
        var iter = server.views.iterate();
        while (iter.next()) |view| {
            // XXX support rotation and scaling
            const view_sx = lx - view.position.x;
            const view_sy = ly - view.position.y;

            if (view.xdg_toplevel.base.surfaceAt(view_sx, view_sy, sx, sy)) |found| {
                surface.* = found;
                return view;
            }
        }
        return null;
    }

    fn newInput(listener: *wl.Listener(*wlroots.InputDevice), dev: *wlroots.InputDevice) void {
        const server = @fieldParentPtr(Server, "new_input", listener);

        switch (dev.device()) {
            .keyboard => |device| {
                var keyboard = allocator.create(Keyboard) catch @panic("out of memory");
                keyboard.server = server;
                keyboard.device = dev;

                // TODO(dh): a whole bunch of keymap stuff
                const rules: xkb.struct_xkb_rule_names = undefined;
                const context = xkb.xkb_context_new(.XKB_CONTEXT_NO_FLAGS);
                const keymap = xkb.xkb_map_new_from_names(context, &rules, .XKB_KEYMAP_COMPILE_NO_FLAGS);

                _ = device.setKeymap(keymap);
                xkb.xkb_keymap_unref(keymap);
                xkb.xkb_context_unref(context);
                device.setRepeatInfo(25, 600);

                keyboard.modifiers.setNotify(Keyboard.handleModifiers);
                keyboard.key.setNotify(Keyboard.handleKey);
                keyboard.keymap.setNotify(Keyboard.handleKeymap);
                keyboard.repeat_info.setNotify(Keyboard.handleRepeatInfo);
                keyboard.destroy.setNotify(Keyboard.handleDestroy);
                device.events.modifiers.add(&keyboard.modifiers);
                device.events.key.add(&keyboard.key);
                device.events.keymap.add(&keyboard.keymap);
                device.events.repeat_info.add(&keyboard.repeat_info);
                device.events.destroy.add(&keyboard.destroy);

                server.keyboards.insert(&keyboard.link);

                if (server.seat.seat.getKeyboard() == null) {
                    // set the first added keyboard as active so we
                    // can give new clients keyboard focus even before
                    // any key has been pressed.
                    server.seat.seat.setKeyboard(dev);
                }
            },

            .pointer => {
                server.cursor.attachInputDevice(dev);
                var pointer = allocator.create(Pointer) catch @panic("out of memory");
                pointer.server = server;
                pointer.device = dev;
                server.pointers.insert(&pointer.link);
            },

            else => {
                // TODO(dh): handle other devices
            },
        }

        server.updateSeatCapabilities();
    }

    fn newXdgSurface(listener: *wl.Listener(*wlroots.XDGSurface), xdg_surface: *wlroots.XDGSurface) void {
        const server = @fieldParentPtr(Server, "new_xdg_surface", listener);
        switch (xdg_surface.role) {
            .WLR_XDG_SURFACE_ROLE_TOPLEVEL => {
                var view = allocator.create(View) catch @panic("out of memory");
                view.* = .{
                    .server = server,
                    .xdg_toplevel = xdg_surface.unnamed_0.toplevel,
                };

                view.map.setNotify(View.xdgSurfaceMap);
                view.unmap.setNotify(View.xdgSurfaceUnmap);
                view.destroy.setNotify(View.xdgSurfaceDestroy);
                xdg_surface.events.map.add(&view.map);
                xdg_surface.events.unmap.add(&view.unmap);
                xdg_surface.events.destroy.add(&view.destroy);

                const toplevel = xdg_surface.unnamed_0.toplevel;
                view.request_move.setNotify(View.xdgToplevelRequestMove);
                view.request_resize.setNotify(View.xdgToplevelRequestResize);
                view.request_maximize.setNotify(View.xdgToplevelRequestMaximize);
                toplevel.events.request_move.add(&view.request_move);
                toplevel.events.request_resize.add(&view.request_resize);
                toplevel.events.request_maximize.add(&view.request_maximize);

                view.commit.setNotify(View.commit);
                xdg_surface.surface.events.commit.add(&view.commit);

                server.views.insert(&view.link);
            },
            else => {
                // TODO(dh): handle other roles
            },
        }
    }
};

const Seat = struct {
    seat: *wlroots.Seat,

    request_cursor: wl.Listener(*wlroots.Seat.Events.RequestSetCursor),

    fn pointerNotifyAxis(
        seat: *const Seat,
        time_msec: u32,
        orientation: wlroots.Pointer.enum_wlr_axis_orientation,
        value: f64,
        value_discrete: i32,
        source: wlroots.Pointer.enum_wlr_axis_source,
    ) void {
        seat.seat.pointerNotifyAxis(time_msec, orientation, value, value_discrete, source);
    }

    fn requestCursor(listener: *wl.Listener(*wlroots.Seat.Events.RequestSetCursor), event: *wlroots.Seat.Events.RequestSetCursor) void {
        const seat = @fieldParentPtr(Seat, "request_cursor", listener);
        const server = @fieldParentPtr(Server, "seat", seat);
        if (seat.seat.pointer_state.focused_client == event.seat_client) {
            server.cursor.setSurface(event.surface, event.hotspot_x, event.hotspot_y);
        }
    }
};

const Output = struct {
    output: *wlroots.Output,
    server: *Server,
    last_frame: std.os.timespec,

    destroy: wl.Listener(*wlroots.Output),
    frame: wl.Listener(*wlroots.Output),
    present: wl.Listener(?*c_void),

    link: wl.List(@This(), "link"),

    fn transform_matrix(output: *Output) wlroots.Matrix {
        return .{
            .data = @bitCast([3][3]f32, output.output.transform_matrix),
        };
    }

    fn newOutputNotify(listener: *wl.Listener(*wlroots.Output), output: *wlroots.Output) void {
        std.debug.print("new output\n", .{});
        const server = @fieldParentPtr(Server, "new_output", listener);

        const modes = @ptrCast(*wl.List(wlroots.Output.Mode, "link"), &output.modes);
        if (!modes.isEmpty()) {
            const mode: *wlroots.Output.Mode = modes.prev.container();
            output.setMode(mode);
            output.enable(true);
            if (!output.commit()) {
                return;
            }
        }

        var our_output: *Output = allocator.create(Output) catch @panic("out of memory");
        our_output.output = output;
        our_output.server = server;
        std.os.clock_gettime(std.os.CLOCK_MONOTONIC, &our_output.last_frame) catch |err| @panic(@errorName(err));
        server.outputs.insert(&our_output.link);

        our_output.destroy.setNotify(Output.destroyNotify);
        our_output.frame.setNotify(Output.frameNotify);
        our_output.present.setNotify(Output.present);
        output.events.destroy.add(&our_output.destroy);
        output.events.frame.add(&our_output.frame);
        output.events.present.add(&our_output.present);

        server.output_layout.addAuto(output);
    }

    fn destroyNotify(listener: *wl.Listener(*wlroots.Output), data: *wlroots.Output) void {
        const our_output = @fieldParentPtr(Output, "destroy", listener);

        our_output.link.remove();
        // XXX listRemove
        // our_output.destroy.remove();
        // our_output.frame.remove();

        // XXX deallocate our output?
    }

    fn frameNotify(listener: *wl.Listener(*wlroots.Output), output: *wlroots.Output) void {
        const tracectx = tracy.trace(@src());
        defer tracectx.end();

        const our_output = @fieldParentPtr(Output, "frame", listener);
        const server = our_output.server;
        const renderer = server.renderer;

        var now: std.os.timespec = undefined;
        // XXX don't panic
        std.os.clock_gettime(std.os.CLOCK_MONOTONIC, &now) catch |err| @panic(@errorName(err));

        if (!output.attachRender(null)) {
            // TODO(dh): why can this fail?
            return;
        }

        var width: c_int = undefined;
        var height: c_int = undefined;
        our_output.output.effectiveResolution(&width, &height);
        renderer.begin(width, height);

        const color = [_]f32{ 0.3, 0.3, 0.3, 1 };
        renderer.clear(color);

        var iter = server.views.iterate_reverse();
        while (iter.next()) |view| {
            if (!view.xdg_toplevel.base.mapped) {
                continue;
            }
            var rdata = RenderData{
                .output = our_output,
                .view = view,
                .now = now,
            };
            // TODO(dh): provide a safe wrapper for wlr_xdg_surface_for_each_surface
            view.xdg_toplevel.base.forEachSurface(Output.renderSurface, &rdata);
        }

        our_output.output.renderSoftwareCursors(null);

        renderer.end();
        // TODO(dh): why can this fail?
        _ = our_output.output.commit();
    }

    fn present(listener: *wl.Listener(?*c_void), output: ?*c_void) void {
        tracy.frame(null);
    }

    fn renderSurface(surface: *wlroots.Surface, sx: c_int, sy: c_int, data: ?*c_void) callconv(.C) void {
        const tracectx = tracy.trace(@src());
        defer tracectx.end();

        const rdata = @ptrCast(*RenderData, @alignCast(@alignOf(*RenderData), data.?));
        const view = rdata.view;
        const output = rdata.output;
        const renderer = output.server.renderer;

        const texture = surface.getTexture() orelse return;

        // buffer -> surface -> layout -> output

        // TODO(dh): support rotated outputs
        // TODO(dh): support outputs not positioned at (0, 0) in layout space
        // TODO(dh): support buffers that don't match surface coordinates

        var m: wlroots.Matrix = wlroots.Matrix.Identity;
        m.translate(@floatCast(f32, view.position.x + @intToFloat(f64, sx)), @floatCast(f32, view.position.y + @intToFloat(f64, sy)));
        m.scale(@intToFloat(f32, surface.current.width), @intToFloat(f32, surface.current.height));

        // var m = view.transformation_matrix();
        m.mul(output.transform_matrix(), m);

        // XXX handle failure
        renderer.renderTextureWithMatrix(texture, m, 1) catch {};
        // XXX make sure the two timespec structs are actually ABI compatible

        surface.sendFrameDone(&rdata.now);
    }
};

const RenderData = struct {
    output: *Output,
    view: *View,
    now: std.os.timespec,
};

fn deg2rad(deg: f32) f32 {
    return (deg * std.math.pi) / 180.0;
}

const View = struct {
    server: *Server,
    xdg_toplevel: *wlroots.XDGToplevel,
    // the view's position in layout space
    position: Vec2 = .{},
    rotation: f32 = 0, // in radians

    active_resize: struct {
        orig_position: Vec2,
        orig_geometry: Box,
        /// The cursor position when the grab was initiated, in layout coordinates
        orig_cursor: Vec2,
        edges: u32,
    } = undefined,

    state_before_maximize: struct {
        valid: bool,
        position: Vec2,
        width: f64,
        height: f64,
    } = .{
        .valid = false,
        .position = undefined,
        .width = undefined,
        .height = undefined,
    },

    map: wl.Listener(*wlroots.XDGSurface) = .{},
    unmap: wl.Listener(*wlroots.XDGSurface) = .{},
    destroy: wl.Listener(*wlroots.XDGSurface) = .{},

    request_move: wl.Listener(*wlroots.XDGToplevel.Events.Move) = .{},
    request_resize: wl.Listener(*wlroots.XDGToplevel.Events.Resize) = .{},
    request_maximize: wl.Listener(*wlroots.XDGSurface) = .{},
    commit: wl.Listener(?*c_void) = .{},

    link: wl.List(@This(), "link") = .{},

    /// transformation_matrix maps the view to layout space.
    fn transformation_matrix(view: *const View) Matrix {
        // TODO(dh): support buffer transforms

        // OPT(dh): cache this computation, update the matrix when
        // position, size or rotation change
        const x = view.position.x;
        const y = view.position.y;

        // translate
        // rotate
        // scale
        var m: Matrix = Matrix.Identity;
        m.translate(@floatCast(f32, x), @floatCast(f32, y));
        // TODO(dh): rotation should probably be around the center, not the origin
        m.rotate(view.rotation);
        m.scale(@intToFloat(f32, view.width()), @intToFloat(f32, view.height()));
        return m;
    }

    fn getGeometry(view: *const View) Box {
        // TODO(dh): de-c-ify all of this
        var box: wlroots.Box = undefined;
        view.xdg_toplevel.base.surface.getExtends(&box);
        if (view.xdg_toplevel.base.geometry.width != 0) {
            // XXX handle return value
            _ = &box.wlr_box_intersection(&view.xdg_toplevel.base.geometry, &box);
        }
        return .{
            .x = @intToFloat(f64, box.x),
            .y = @intToFloat(f64, box.y),
            .width = @intToFloat(f64, box.width),
            .height = @intToFloat(f64, box.height),
        };
    }

    fn width(surface: *const View) i32 {
        return surface.xdg_toplevel.base.surface.current.width;
    }

    fn height(surface: *const View) i32 {
        return surface.xdg_toplevel.base.surface.current.height;
    }

    // TODO(dh): implement all of these
    fn xdgSurfaceMap(listener: *wl.Listener(*wlroots.XDGSurface), surface: *wlroots.XDGSurface) void {
        const view = @fieldParentPtr(View, "map", listener);

        // XXX should only the focussed client be active?
        _ = surface.unnamed_0.toplevel.SetActivated(true);
    }

    fn xdgSurfaceUnmap(listener: *wl.Listener(*wlroots.XDGSurface), surface: *wlroots.XDGSurface) void {
        // XXX cancel interactive move, resize, …
        const view = @fieldParentPtr(View, "unmap", listener);
        // TODO(dh): if this was the surface with pointer focus, see if there's another window we can focus instead
    }

    fn xdgSurfaceDestroy(listener: *wl.Listener(*wlroots.XDGSurface), surface: *wlroots.XDGSurface) void {
        switch (surface.role) {
            .WLR_XDG_SURFACE_ROLE_TOPLEVEL => {
                var view = @fieldParentPtr(View, "destroy", listener);
                view.link.remove();
                allocator.destroy(view);
            },
            else => {
                // TODO(dh): handle other roles
            },
        }
    }

    fn xdgToplevelRequestMove(listener: *wl.Listener(*wlroots.XDGToplevel.Events.Move), event: *wlroots.XDGToplevel.Events.Move) void {
        // TODO(dh): check the serial against recent button presses, to prevent bad clients from invoking this at will
        // TODO(dh): unmaximize the window if it is maximized
        const view = @fieldParentPtr(View, "request_move", listener);
        const server = view.server;

        // bring the view to the front
        view.link.remove();
        server.views.insert(&view.link);

        server.cursor_mode = .{
            .Move = .{
                .grabbed_view = view,
                .orig_position = view.position,
                .orig_cursor = .{
                    .x = server.cursor.x,
                    .y = server.cursor.y,
                },
            },
        };
    }

    fn xdgToplevelRequestResize(listener: *wl.Listener(*wlroots.XDGToplevel.Events.Resize), event: *wlroots.XDGToplevel.Events.Resize) void {
        // TODO(dh): check the serial against recent button presses, to prevent bad clients from invoking this at will
        // TODO(dh): only allow this request from the focussed client
        const view = @fieldParentPtr(View, "request_resize", listener);
        const server = view.server;

        // XXX clear focus
        _ = view.xdg_toplevel.SetResizing(true);

        server.cursor_mode = .{
            .Resize = view,
        };
        view.active_resize = .{
            .orig_position = view.position,
            .orig_geometry = view.getGeometry(),
            .orig_cursor = .{
                .x = server.cursor.x,
                .y = server.cursor.y,
            },
            .edges = event.edges,
        };
    }

    fn xdgToplevelRequestMaximize(listener: *wl.Listener(*wlroots.XDGSurface), surface: *wlroots.XDGSurface) void {
        const view = @fieldParentPtr(View, "request_maximize", listener);

        if (view.xdg_toplevel.client_pending.maximized) {
            if (view.xdg_toplevel.current.maximized) {
                // TODO(dh): make sure wlroots doesn't swallow this event. see https://github.com/swaywm/wlroots/issues/2330
                _ = surface.unnamed_0.toplevel.SetMaximized(true);
                return;
            }

            const output = view.server.output_layout.outputAt(view.position.x, view.position.y);
            if (output == null) {
                return;
            }
            const geom = view.getGeometry();
            view.state_before_maximize = .{
                .valid = true,
                .position = view.position,
                .width = geom.width,
                .height = geom.height,
            };

            const extents = view.server.output_layout.getBox(output).*;
            _ = view.xdg_toplevel.SetMaximized(true);
            _ = view.xdg_toplevel.SetSize(@intCast(u32, extents.width), @intCast(u32, extents.height));
        } else {
            if (!view.xdg_toplevel.current.maximized) {
                // TODO(dh): make sure wlroots doesn't swallow this event. see https://github.com/swaywm/wlroots/issues/2330
                _ = view.xdg_toplevel.SetMaximized(false);
                return;
            }

            _ = view.xdg_toplevel.SetMaximized(false);
            // TODO(dh): what happens if the client changed its geometry in the meantime? our old width and height will no longer be correct.
            _ = view.xdg_toplevel.SetSize(@floatToInt(u32, @round(view.state_before_maximize.width)), @floatToInt(u32, @round(view.state_before_maximize.height)));
        }
    }

    fn commit(listener: *wl.Listener(?*c_void), data: ?*c_void) void {
        const view = @fieldParentPtr(View, "commit", listener);
        if (view.xdg_toplevel.current.resizing) {
            const edges = view.active_resize.edges;
            if (edges & @intCast(u32, @enumToInt(wlroots.enum_wlr_edges.WLR_EDGE_LEFT)) != 0) {
                const delta_width = view.active_resize.orig_geometry.width - view.getGeometry().width;
                view.position.x = view.active_resize.orig_position.x + delta_width;
            }
            if (edges & @intCast(u32, @enumToInt(wlroots.enum_wlr_edges.WLR_EDGE_TOP)) != 0) {
                const delta_height = view.active_resize.orig_geometry.height - view.getGeometry().height;
                view.position.y = view.active_resize.orig_position.y + delta_height;
            }
        }
        if (view.xdg_toplevel.current.maximized) {
            // OPT(dh): this is causing unnecessary memory writes on each commit
            view.position = .{ .x = 0, .y = 0 };
        } else if (view.state_before_maximize.valid) {
            view.position = view.state_before_maximize.position;
            view.state_before_maximize.valid = false;
        }
    }
};

const Pointer = struct {
    server: *Server,
    device: *wlroots.InputDevice,

    link: wl.List(@This(), "link"),
};

const Keyboard = struct {
    server: *Server,
    device: *wlroots.InputDevice,

    modifiers: wl.Listener(*wlroots.Keyboard),
    key: wl.Listener(*wlroots.Keyboard.Events.Key),
    keymap: wl.Listener(*wlroots.Keyboard),
    repeat_info: wl.Listener(*wlroots.Keyboard),
    destroy: wl.Listener(*wlroots.Keyboard),

    link: wl.List(@This(), "link"),

    // TODO(dh): implement all of these
    fn handleModifiers(listener: *wl.Listener(*wlroots.Keyboard), data: *wlroots.Keyboard) void {
        const keyboard = @fieldParentPtr(Keyboard, "modifiers", listener);
        const seat = keyboard.server.seat;
        // TODO(dh): is there any benefit to avoiding repeated calls to this?
        seat.seat.setKeyboard(keyboard.device);
        seat.seat.keyboardNotifyModifiers(&data.modifiers);
    }

    fn handleKey(listener: *wl.Listener(*wlroots.Keyboard.Events.Key), key: *wlroots.Keyboard.Events.Key) void {
        const keyboard = @fieldParentPtr(Keyboard, "key", listener);
        const server = keyboard.server;
        const seat = server.seat;

        // TODO(dh): is there any benefit to avoiding repeated calls to this?
        seat.seat.setKeyboard(keyboard.device);
        seat.seat.keyboardNotifyKey(key.time_msec, key.keycode, key.state);
    }
    fn handleKeymap(listener: *wl.Listener(*wlroots.Keyboard), data: *wlroots.Keyboard) void {}
    fn handleRepeatInfo(listener: *wl.Listener(*wlroots.Keyboard), data: *wlroots.Keyboard) void {}
    fn handleDestroy(listener: *wl.Listener(*wlroots.Keyboard), data: *wlroots.Keyboard) void {}
};

pub fn main() !void {
    // c.wlr_log_init(c.enum_wlr_log_importance.WLR_DEBUG, null);
    var server: Server = undefined;
    server.init();

    server.dsp = try wl.Display.create();
    defer server.dsp.destroy();

    server.evloop = server.dsp.getEventLoop();
    server.backend = try wlroots.Backend.autocreate(server.dsp, null);
    defer server.backend.deinit();

    server.renderer = server.backend.getRenderer();
    try server.renderer.initDisplay(server.dsp);
    server.new_output.setNotify(Output.newOutputNotify);
    server.backend.events.new_output.add(&server.new_output);

    // TODO(dh): do we need to free anything?
    _ = try wlroots.Compositor.init(server.dsp, server.renderer);
    _ = try wlroots.DataDeviceManager.init(server.dsp);

    server.output_layout = try wlroots.Output.Layout.init();
    defer server.output_layout.deinit();

    server.cursor = try wlroots.Cursor.init();
    defer server.cursor.deinit();

    server.cursor.attachOutputLayout(server.output_layout);

    // TODO(dh): what do the arguments mean?
    server.cursor_mgr = try wlroots.XCursor.Manager.init(null, 24);
    defer server.cursor_mgr.deinit();
    try server.cursor_mgr.load(1);

    // TODO(dh): other cursor events
    server.cursor_motion.setNotify(Server.cursorMotion);
    server.cursor_motion_absolute.setNotify(Server.cursorMotionAbsolute);
    server.cursor_button.setNotify(Server.cursorButton);
    server.cursor_axis.setNotify(Server.cursorAxis);
    server.cursor_frame.setNotify(Server.cursorFrame);
    server.cursor.events.motion.add(&server.cursor_motion);
    server.cursor.events.motion_absolute.add(&server.cursor_motion_absolute);
    server.cursor.events.button.add(&server.cursor_button);
    server.cursor.events.axis.add(&server.cursor_axis);
    server.cursor.events.frame.add(&server.cursor_frame);

    server.new_input.setNotify(Server.newInput);
    server.backend.events.new_input.add(&server.new_input);

    server.seat.seat = try wlroots.Seat.init(server.dsp, "seat0");
    defer server.seat.seat.deinit();

    server.seat.request_cursor.setNotify(Seat.requestCursor);
    server.seat.seat.events.request_set_cursor.add(&server.seat.request_cursor);

    // note: no destructor; the shell is a static global
    server.xdg_shell = try wlroots.XDGShell.init(server.dsp);
    server.new_xdg_surface.setNotify(Server.newXdgSurface);
    server.xdg_shell.events.new_surface.add(&server.new_xdg_surface);

    const socket: [*:0]const u8 = wl.Display.wl_display_add_socket_auto(server.dsp) orelse return error.Failure;
    std.debug.print("listening on {}\n", .{socket});

    try server.backend.start();
    server.dsp.wl_display_run();
    defer server.dsp.wl_display_destroy_clients();
}
