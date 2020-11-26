const std = @import("std");

const wl = @import("wayland").server.wl;
const wlroots = @import("wlroots");
const xkb = @import("xkbcommon");

const c = @cImport({
    @cInclude("stdlib.h");
});
const spawn = @import("spawn.zig");
const tracy = @import("tracy.zig");
const libinput = @cImport({
    @cInclude("linux/input.h");
});
var allocator_state = tracy.Allocator.init(std.heap.c_allocator, "C allocator");
const allocator = &allocator_state.allocator;

const stdout = std.io.getStdout().writer();

// TODO(dh): should window movement relative to a stationary cursor be
// considered cursor movement? say we have two seats with a pointer
// each, and one seat moves a window under the other seat's cursor,
// should the window receive cursor motion events?

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
// - https://hikari.acmelabs.space

// TODO: decide the exact semantics of shortcuts. Cf. https://xkbcommon.org/doc/current/group__state.html

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
// FIXME(dh): don't use @panic in functions called from C; send an error to the wayland client
// TODO(dh): ponder https://github.com/swaywm/sway/pull/4452
// TODO(dh): http://www.jlekstrand.net/jason/projects/wayland/transforms/
// TODO(dh): handle device removal
// OPT(dh): wlr_cursor stores the cursor position as f64. Find out
//   why, and if the values are ever not integer. if they're always
//   integer, we can drop our use of @round. there's probably something
//   scaling related.
// FIXME(dh): don't allow multiple active grabs for a single seat
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
    dsp: *wl.Server,
    evloop: *wl.EventLoop,

    backend: *wlroots.Backend,
    renderer: *wlroots.Renderer,
    output_layout: *wlroots.OutputLayout,

    xdg_shell: *wlroots.XdgShell,
    views: wl.list.Head(View, "link"),

    cursor_mgr: *wlroots.XcursorManager,

    outputs: wl.list.Head(Output, "link"),

    // TODO(dh): support multiple seats
    seat: Seat,

    events: struct {
        new_view: wl.Signal(*View),
    } = undefined,

    new_xdg_surface: wl.Listener(*wlroots.XdgSurface),
    new_output: wl.Listener(*wlroots.Output),
    new_input: wl.Listener(*wlroots.InputDevice),

    fn init(server: *Server) !void {
        server.outputs.init();
        server.views.init();
        server.events.new_view.init();
        try server.seat.init(server);
    }

    /// findViewUnderCursor finds the view and surface at position (lx, ly), respecting input regions.
    fn findViewUnderCursor(server: *Server, lx: f64, ly: f64, surface: ?**wlroots.Surface, sx: *f64, sy: *f64) ?*View {
        const tracectx = tracy.trace(@src());
        defer tracectx.end();

        // OPT(dh): test against the previously found view. most of
        // the time, the cursor moves within a view.
        //
        // OPT(dh): cache check against views' transforms by finding
        // the rectangular (non-rotated) area that views occupy
        var iter = server.views.iterator(.forward);
        while (iter.next()) |view| {
            // XXX support rotation and scaling
            const view_sx = lx - view.position.x;
            const view_sy = ly - view.position.y;

            if (view.xdg_toplevel.base.surfaceAt(view_sx, view_sy, sx, sy)) |found| {
                if (surface) |s| {
                    s.* = found;
                }
                return view;
            }
        }
        return null;
    }

    // TODO(dh): move part of this function into Seat. device creation
    // is decidedly the server's responsibility, but actually managing
    // the devices is the responsibility of the seat the device is
    // assigend to.
    fn newInput(listener: *wl.Listener(*wlroots.InputDevice), dev: *wlroots.InputDevice) void {
        const server = @fieldParentPtr(Server, "new_input", listener);

        switch (dev.type) {
            .keyboard => {
                const device = dev.device.keyboard;
                var keyboard = allocator.create(Keyboard) catch @panic("out of memory");
                keyboard.server = server;
                keyboard.device = dev;

                // TODO(dh): a whole bunch of keymap stuff
                const rules: xkb.RuleNames = .{
                    .rules = null,
                    .model = null,
                    .variant = null,
                    .options = null,
                    .layout = null,
                };
                const context = xkb.Context.new(.no_flags).?;
                defer context.unref();
                const keymap = xkb.Keymap.newFromNames(context, &rules, .no_flags).?;
                defer keymap.unref();

                // XXX handle failure
                _ = device.setKeymap(keymap);
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

                server.seat.keyboards.prepend(keyboard);

                if (server.seat.seat.getKeyboard() == null) {
                    // set the first added keyboard as active so we
                    // can give new clients keyboard focus even before
                    // any key has been pressed.
                    server.seat.seat.setKeyboard(dev);
                }
            },

            .pointer => {
                server.seat.cursor.attachInputDevice(dev);
                var pointer = allocator.create(Pointer) catch @panic("out of memory");
                pointer.server = server;
                pointer.device = dev;
                server.seat.pointers.prepend(pointer);
            },

            else => {
                // TODO(dh): handle other devices
            },
        }

        server.seat.updateSeatCapabilities();
    }

    fn newXdgSurface(listener: *wl.Listener(*wlroots.XdgSurface), xdg_surface: *wlroots.XdgSurface) void {
        const server = @fieldParentPtr(Server, "new_xdg_surface", listener);
        switch (xdg_surface.role) {
            .toplevel => {
                var view = allocator.create(View) catch @panic("out of memory");
                view.* = .{
                    .server = server,
                    .xdg_toplevel = xdg_surface.role_data.toplevel,
                };
                view.events.destroy.init();

                view.map.setNotify(View.xdgSurfaceMap);
                view.unmap.setNotify(View.xdgSurfaceUnmap);
                view.destroy.setNotify(View.xdgSurfaceDestroy);
                xdg_surface.events.map.add(&view.map);
                xdg_surface.events.unmap.add(&view.unmap);
                xdg_surface.events.destroy.add(&view.destroy);

                const toplevel = xdg_surface.role_data.toplevel;
                view.request_move.setNotify(View.xdgToplevelRequestMove);
                view.request_resize.setNotify(View.xdgToplevelRequestResize);
                view.request_maximize.setNotify(View.xdgToplevelRequestMaximize);
                toplevel.events.request_move.add(&view.request_move);
                toplevel.events.request_resize.add(&view.request_resize);
                toplevel.events.request_maximize.add(&view.request_maximize);

                view.commit.setNotify(View.commit);
                xdg_surface.surface.events.commit.add(&view.commit);

                server.views.prepend(view);

                server.events.new_view.emit(view);
            },
            else => {
                // TODO(dh): handle other roles
            },
        }
    }
};

const Seat = struct {
    seat: *wlroots.Seat,
    server: *Server,

    pointers: wl.list.Head(Pointer, "link"),
    keyboards: wl.list.Head(Keyboard, "link"),

    cursor: *wlroots.Cursor,
    cursor_mode: struct {
        mode: enum {
            normal,
            move,
            resize,
        },
        grabbed_view: ?*View,
        initiated_by: ?u32,
    },
    keybinding_manager: KeybindingManager,

    cursor_motion: wl.Listener(*wlroots.Pointer.event.Motion),
    cursor_motion_absolute: wl.Listener(*wlroots.Pointer.event.MotionAbsolute),
    cursor_button: wl.Listener(*wlroots.Pointer.event.Button),
    cursor_axis: wl.Listener(*wlroots.Pointer.event.Axis),
    cursor_frame: wl.Listener(*wlroots.Cursor),
    request_cursor: wl.Listener(*wlroots.Seat.event.RequestSetCursor),

    new_view: wl.Listener(*View),
    destroy_view: wl.Listener(*View),

    pub fn init(seat: *Seat, server: *Server) !void {
        seat.cursor_mode = .{
            .mode = .normal,
            .grabbed_view = null,
            .initiated_by = null,
        };
        seat.server = server;
        seat.keyboards.init();
        seat.pointers.init();
        seat.keybinding_manager = .{
            .keybindings_data = undefined,
            .server = server,
            .keybindings = &[0]Keybinding{},
        };

        seat.cursor = try wlroots.Cursor.create();

        seat.new_view.setNotify(Seat.newView);
        seat.server.events.new_view.add(&seat.new_view);

        seat.destroy_view.setNotify(Seat.destroyView);

        // TODO(dh): other cursor events
        seat.cursor_motion.setNotify(Seat.cursorMotion);
        seat.cursor_motion_absolute.setNotify(Seat.cursorMotionAbsolute);
        seat.cursor_button.setNotify(Seat.cursorButton);
        seat.cursor_axis.setNotify(Seat.cursorAxis);
        seat.cursor_frame.setNotify(Seat.cursorFrame);

        seat.cursor.events.motion.add(&seat.cursor_motion);
        seat.cursor.events.motion_absolute.add(&seat.cursor_motion_absolute);
        seat.cursor.events.button.add(&seat.cursor_button);
        seat.cursor.events.axis.add(&seat.cursor_axis);
        seat.cursor.events.frame.add(&seat.cursor_frame);
    }

    pub fn deinit(seat: *Seat) void {
        seat.cursor.destroy();
    }

    fn newView(listener: *wl.Listener(*View), view: *View) void {
        const seat = @fieldParentPtr(Seat, "new_view", listener);
        view.events.destroy.add(&seat.destroy_view);
    }

    fn destroyView(listener: *wl.Listener(*View), view: *View) void {
        const seat = @fieldParentPtr(Seat, "destroy_view", listener);
        if (seat.cursor_mode.grabbed_view == view) {
            std.debug.print("cancelling grab\n", .{});
            seat.cursor_mode = .{
                .mode = .normal,
                .grabbed_view = null,
                .initiated_by = null,
            };
        }
    }

    fn updateSeatCapabilities(seat: *Seat) void {
        const caps = wl.Seat.Capability{
            .pointer = !seat.pointers.empty(),
            .keyboard = !seat.keyboards.empty(),
        };
        seat.seat.setCapabilities(caps);
    }

    fn startInteractiveMove(seat: *Seat, view: *View, initiated_by: u32) void {
        view.link.remove();
        seat.server.views.prepend(view);
        seat.cursor_mode = .{
            .mode = .move,
            .grabbed_view = view,
            .initiated_by = initiated_by,
        };
        view.active_grab = .{
            .move = .{
                .orig_position = view.position,
                .orig_cursor = .{
                    .x = seat.cursor.x,
                    .y = seat.cursor.y,
                },
            },
        };
    }

    fn startInteractiveResize(seat: *Seat, view: *View, initiated_by: u32, edges: wlroots.Edges) void {
        // XXX clear focus
        _ = view.xdg_toplevel.setResizing(true);

        seat.cursor_mode = .{
            .mode = .resize,
            .grabbed_view = view,
            .initiated_by = initiated_by,
        };
        view.active_grab = .{
            .resize = .{
                .orig_position = view.position,
                .orig_geometry = view.getGeometry(),
                .orig_cursor = .{
                    .x = seat.cursor.x,
                    .y = seat.cursor.y,
                },
                .edges = edges,
            },
        };
    }

    fn cursorFrame(listener: *wl.Listener(*wlroots.Cursor), event: *wlroots.Cursor) void {
        const seat = @fieldParentPtr(Seat, "cursor_frame", listener);
        seat.seat.pointerNotifyFrame();
    }

    fn cursorButton(listener: *wl.Listener(*wlroots.Pointer.event.Button), event: *wlroots.Pointer.event.Button) void {
        const seat = @fieldParentPtr(Seat, "cursor_button", listener);

        // XXX handle return value
        // XXX don't notify if we've swallowed the button press
        _ = seat.seat.pointerNotifyButton(event.time_msec, event.button, event.state);

        switch (seat.cursor_mode.mode) {
            .normal => blk: {
                if (event.state != .pressed) {
                    break :blk;
                }
                if (seat.seat.getKeyboard()) |keyboard| {
                    // OPT(dh): this calculation can be cached once per keymap
                    // FIXME(dh): don't be this unsafe. use std.math.cast, and check for xkb.mod_invalid
                    const keymap = keyboard.keymap.?;
                    const wanted = @as(xkb.ModMask, 1) << @intCast(u5, keymap.modGetIndex(modkey));
                    if (wanted == keyboard.modifiers.depressed | keyboard.modifiers.latched) {
                        var sx: f64 = undefined;
                        var sy: f64 = undefined;
                        // OPT(dh): instead of using findViewUnderCursor, get the focussed surface from the seat.
                        if (seat.server.findViewUnderCursor(seat.cursor.x, seat.cursor.y, null, &sx, &sy)) |view| {
                            switch (event.button) {
                                libinput.BTN_LEFT => seat.startInteractiveMove(view, event.button),
                                libinput.BTN_MIDDLE => {
                                    seat.startInteractiveResize(view, event.button, .{
                                        // TODO(dh0: do we need to use geometry coordinates instead?
                                        .left = sx <= view.width() / 2,
                                        .right = sx > view.width() / 2,
                                        .top = sy <= view.height() / 2,
                                        .bottom = sy > view.height() / 2,
                                    });
                                },
                                else => {},
                            }
                        }
                    }
                }
            },
            .move, .resize => {
                if (event.button == seat.cursor_mode.initiated_by.? and event.state == .released) {
                    const view = seat.cursor_mode.grabbed_view.?;
                    _ = view.xdg_toplevel.setResizing(false);
                    seat.cursor_mode = .{
                        .mode = .normal,
                        .grabbed_view = null,
                        .initiated_by = null,
                    };
                }
            },
        }
    }

    fn cursorMotion(listener: *wl.Listener(*wlroots.Pointer.event.Motion), event: *wlroots.Pointer.event.Motion) void {
        const seat = @fieldParentPtr(Seat, "cursor_motion", listener);
        seat.cursor.move(event.device, event.delta_x, event.delta_y);
        seat.processCursorMotion(event.time_msec);
    }

    fn cursorMotionAbsolute(listener: *wl.Listener(*wlroots.Pointer.event.MotionAbsolute), event: *wlroots.Pointer.event.MotionAbsolute) void {
        const seat = @fieldParentPtr(Seat, "cursor_motion_absolute", listener);
        seat.cursor.warpAbsolute(event.device, event.x, event.y);
        seat.processCursorMotion(event.time_msec);
    }

    fn cursorAxis(listener: *wl.Listener(*wlroots.Pointer.event.Axis), event: *wlroots.Pointer.event.Axis) void {
        const seat = @fieldParentPtr(Seat, "cursor_axis", listener);
        if (seat.seat.pointer_state.focused_surface) |surface| {
            seat.pointerNotifyAxis(
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

    fn processCursorMotion(seat: *Seat, time_msec: u32) void {
        const tracectx = tracy.trace(@src());
        defer tracectx.end();

        const cursor_lx = seat.cursor.x;
        const cursor_ly = seat.cursor.y;

        switch (seat.cursor_mode.mode) {
            .normal => {
                // TODO(dh): the event coordinates are in the range [0, 1].
                // for the prototype we just hackily map to the layout. for
                // real applications, we'll have to make use of the layout,
                // support constricting absolute input devices to specific
                // outputs or portions thereof, etc.
                var surface: *wlroots.Surface = undefined;
                var sx: f64 = undefined;
                var sy: f64 = undefined;
                if (seat.server.findViewUnderCursor(cursor_lx, cursor_ly, &surface, &sx, &sy)) |view| {
                    // XXX set focus only if the view changed from last time
                    if (seat.seat.getKeyboard()) |keyboard| {
                        seat.seat.keyboardNotifyEnter(surface, &keyboard.keycodes, keyboard.num_keycodes, &keyboard.modifiers);
                    }

                    // XXX this probably isn't handling subsurfaces correctly
                    if (seat.seat.pointer_state.focused_surface == surface) {
                        seat.seat.pointerNotifyMotion(time_msec, sx, sy);
                    } else {
                        seat.seat.pointerNotifyEnter(surface, sx, sy);
                    }
                } else {
                    // TODO(dh): what if a button was held while the pointer left the surface?
                    seat.seat.pointerNotifyClearFocus();

                    // TODO(dh): is there a fixed set of valid pointer names?
                    seat.server.cursor_mgr.setCursorImage("left_ptr", seat.cursor);
                }
            },

            .move => {
                const view = seat.cursor_mode.grabbed_view.?;
                const delta_lx = cursor_lx - view.active_grab.move.orig_cursor.x;
                const delta_ly = cursor_ly - view.active_grab.move.orig_cursor.y;
                view.position = .{
                    .x = view.active_grab.move.orig_position.x + delta_lx,
                    .y = view.active_grab.move.orig_position.y + delta_ly,
                };
            },

            .resize => {
                const view = seat.cursor_mode.grabbed_view.?;
                const ar = view.active_grab.resize;
                const delta_lx = cursor_lx - ar.orig_cursor.x;
                const delta_ly = cursor_ly - ar.orig_cursor.y;

                var new_size = Vec2{
                    .x = ar.orig_geometry.width,
                    .y = ar.orig_geometry.height,
                };
                if (ar.edges.left) {
                    new_size.x = ar.orig_geometry.width - delta_lx;
                } else if (ar.edges.right) {
                    new_size.x = ar.orig_geometry.width + delta_lx;
                }
                if (ar.edges.top) {
                    new_size.y = ar.orig_geometry.height - delta_ly;
                } else if (ar.edges.bottom) {
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

                _ = view.xdg_toplevel.setSize(
                    @floatToInt(u32, @round(new_size.x)),
                    @floatToInt(u32, @round(new_size.y)),
                );
            },
        }
    }

    fn pointerNotifyAxis(
        seat: *const Seat,
        time_msec: u32,
        orientation: wlroots.AxisOrientation,
        value: f64,
        value_discrete: i32,
        source: wlroots.AxisSource,
    ) void {
        seat.seat.pointerNotifyAxis(time_msec, orientation, value, value_discrete, source);
    }

    fn requestCursor(listener: *wl.Listener(*wlroots.Seat.event.RequestSetCursor), event: *wlroots.Seat.event.RequestSetCursor) void {
        const seat = @fieldParentPtr(Seat, "request_cursor", listener);
        if (seat.seat.pointer_state.focused_client == event.seat_client) {
            seat.cursor.setSurface(event.surface, event.hotspot_x, event.hotspot_y);
        }
    }
};

const Output = struct {
    output: *wlroots.Output,
    server: *Server,
    last_frame: std.os.timespec,

    destroy: wl.Listener(*wlroots.Output),
    frame: wl.Listener(*wlroots.Output),
    present: wl.Listener(*wlroots.Output.event.Present),

    link: wl.list.Link,

    fn newOutputNotify(listener: *wl.Listener(*wlroots.Output), output: *wlroots.Output) void {
        std.debug.print("new output\n", .{});
        const server = @fieldParentPtr(Server, "new_output", listener);

        const modes = &output.modes;
        if (!modes.empty()) {
            const mode = modes.iterator(.reverse).next().?;
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
        server.outputs.prepend(our_output);

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

    fn clockGetTime() !std.os.timespec {
        var now: std.os.timespec = undefined;
        try std.os.clock_gettime(std.os.CLOCK_MONOTONIC, &now);
        return now;
    }

    fn frameNotify(listener: *wl.Listener(*wlroots.Output), output: *wlroots.Output) void {
        const tracectx = tracy.trace(@src());
        defer tracectx.end();

        const our_output = @fieldParentPtr(Output, "frame", listener);
        const server = our_output.server;
        const renderer = server.renderer;

        // XXX don't panic
        const now = clockGetTime() catch |err| @panic(@errorName(err));

        if (!output.attachRender(null)) {
            // TODO(dh): why can this fail?
            return;
        }

        var width: c_int = undefined;
        var height: c_int = undefined;
        our_output.output.effectiveResolution(&width, &height);
        renderer.begin(width, height);

        const color = [_]f32{ 0.3, 0.3, 0.3, 1 };
        renderer.clear(&color);

        var iter = server.views.iterator(.reverse);
        while (iter.next()) |view| {
            if (!view.xdg_toplevel.base.mapped) {
                continue;
            }
            var rdata = RenderData{
                .output = our_output,
                .view = view,
                .now = now,
            };
            view.xdg_toplevel.base.forEachSurface(*RenderData, Output.renderSurface, &rdata);
        }

        our_output.output.renderSoftwareCursors(null);

        renderer.end();
        // TODO(dh): why can this fail?
        _ = our_output.output.commit();
    }

    fn present(listener: *wl.Listener(*wlroots.Output.event.Present), output: *wlroots.Output.event.Present) void {
        tracy.frame(null);
    }

    fn renderSurface(surface: *wlroots.Surface, sx: c_int, sy: c_int, rdata: *RenderData) callconv(.C) void {
        const tracectx = tracy.trace(@src());
        defer tracectx.end();

        const view = rdata.view;
        const output = rdata.output;
        const renderer = output.server.renderer;

        const texture = surface.getTexture() orelse return;

        // buffer -> surface -> layout -> output

        // TODO(dh): support rotated outputs
        // TODO(dh): support buffers that don't match surface coordinates

        var ox: f64 = undefined;
        var oy: f64 = undefined;
        output.server.output_layout.outputCoords(output.output, &ox, &oy);
        var m: [9]f32 = undefined;
        wlroots.matrix.identity(&m);
        wlroots.matrix.translate(
            &m,
            @floatCast(f32, view.position.x + @intToFloat(f64, sx) + ox),
            @floatCast(f32, view.position.y + @intToFloat(f64, sy) + oy),
        );

        wlroots.matrix.scale(
            &m,
            @intToFloat(f32, surface.current.width),
            @intToFloat(f32, surface.current.height),
        );

        // var m = view.transformation_matrix();
        wlroots.matrix.multiply(&m, &output.output.transform_matrix, &m);

        // XXX handle failure
        renderer.renderTextureWithMatrix(texture, &m, 1) catch {};
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
    xdg_toplevel: *wlroots.XdgToplevel,
    // the view's position in layout space
    position: Vec2 = .{},
    rotation: f32 = 0, // in radians

    active_grab: union(enum) {
        none: void,
        move: struct {
            orig_position: Vec2,
            /// The cursor position when the grab was initiated, in layout coordinates
            orig_cursor: Vec2,
        },
        resize: struct {
            orig_position: Vec2,
            orig_cursor: Vec2,
            orig_geometry: Box,
            /// The cursor position when the grab was initiated, in layout coordinates
            edges: wlroots.Edges,
        },
    } = .none,

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

    events: struct {
        destroy: wl.Signal(*View),
    } = undefined,

    map: wl.Listener(*wlroots.XdgSurface) = undefined,
    unmap: wl.Listener(*wlroots.XdgSurface) = undefined,
    destroy: wl.Listener(*wlroots.XdgSurface) = undefined,

    request_move: wl.Listener(*wlroots.XdgToplevel.event.Move) = undefined,
    request_resize: wl.Listener(*wlroots.XdgToplevel.event.Resize) = undefined,
    request_maximize: wl.Listener(*wlroots.XdgSurface) = undefined,
    commit: wl.Listener(*wlroots.Surface) = undefined,

    link: wl.list.Link = undefined,

    /// transformation_matrix maps the view to layout space.
    fn transformation_matrix(view: *const View) [9]f32 {
        // TODO(dh): support buffer transforms

        // OPT(dh): cache this computation, update the matrix when
        // position, size or rotation change
        const x = view.position.x;
        const y = view.position.y;

        // translate
        // rotate
        // scale
        var m: [9]f32 = undefined;
        wlroots.matrix.identity(&m);
        wlroots.matrix.translate(&m, @floatCast(f32, x), @floatCast(f32, y));
        wlroots.matrix.rotate(&m, view.rotation);
        // TODO(dh): rotation should probably be around the center, not the origin
        wlroots.matrix.scale(&m, @intToFloat(f32, view.width()), @intToFloat(f32, view.height()));
        return m;
    }

    fn getGeometry(view: *const View) Box {
        // TODO(dh): de-c-ify all of this
        var box: wlroots.Box = undefined;
        view.xdg_toplevel.base.surface.getExtends(&box);
        if (view.xdg_toplevel.base.geometry.width != 0) {
            // XXX handle return value
            _ = &box.intersection(&view.xdg_toplevel.base.geometry, &box);
        }
        return .{
            .x = @intToFloat(f64, box.x),
            .y = @intToFloat(f64, box.y),
            .width = @intToFloat(f64, box.width),
            .height = @intToFloat(f64, box.height),
        };
    }

    fn width(surface: *const View) f64 {
        return @intToFloat(f64, surface.xdg_toplevel.base.surface.current.width);
    }

    fn height(surface: *const View) f64 {
        return @intToFloat(f64, surface.xdg_toplevel.base.surface.current.height);
    }

    fn xdgSurfaceMap(listener: *wl.Listener(*wlroots.XdgSurface), surface: *wlroots.XdgSurface) void {
        const view = @fieldParentPtr(View, "map", listener);

        // XXX should only the focussed client be active?
        _ = surface.role_data.toplevel.setActivated(true);
    }

    fn xdgSurfaceUnmap(listener: *wl.Listener(*wlroots.XdgSurface), surface: *wlroots.XdgSurface) void {
        // XXX cancel interactive move, resize, …
        const view = @fieldParentPtr(View, "unmap", listener);
        // TODO(dh): if this was the surface with pointer focus, see if there's another window we can focus instead
    }

    fn xdgSurfaceDestroy(listener: *wl.Listener(*wlroots.XdgSurface), surface: *wlroots.XdgSurface) void {
        std.debug.print("destroyed surface\n", .{});
        switch (surface.role) {
            .toplevel => {
                var view = @fieldParentPtr(View, "destroy", listener);
                view.link.remove();
                view.events.destroy.emit(view);
                allocator.destroy(view);
            },
            else => {
                // TODO(dh): handle other roles
            },
        }
    }

    fn xdgToplevelRequestMove(listener: *wl.Listener(*wlroots.XdgToplevel.event.Move), event: *wlroots.XdgToplevel.event.Move) void {
        // TODO(dh): check the serial against recent button presses, to prevent bad clients from invoking this at will
        // TODO(dh): unmaximize the window if it is maximized
        const view = @fieldParentPtr(View, "request_move", listener);
        // XXX use the serial to look up which button was used to initiate this
        view.server.seat.startInteractiveMove(view, libinput.BTN_LEFT);
    }

    fn xdgToplevelRequestResize(listener: *wl.Listener(*wlroots.XdgToplevel.event.Resize), event: *wlroots.XdgToplevel.event.Resize) void {
        // TODO(dh): check the serial against recent button presses, to prevent bad clients from invoking this at will
        // TODO(dh): only allow this request from the focussed client
        const view = @fieldParentPtr(View, "request_resize", listener);
        // XXX use the serial to look up which button was used to initiate this
        view.server.seat.startInteractiveResize(view, libinput.BTN_LEFT, event.edges);
    }

    fn xdgToplevelRequestMaximize(listener: *wl.Listener(*wlroots.XdgSurface), surface: *wlroots.XdgSurface) void {
        const view = @fieldParentPtr(View, "request_maximize", listener);

        if (view.xdg_toplevel.client_pending.maximized) {
            if (view.xdg_toplevel.current.maximized) {
                // TODO(dh): make sure wlroots doesn't swallow this event. see https://github.com/swaywm/wlroots/issues/2330
                _ = surface.role_data.toplevel.setMaximized(true);
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
            _ = view.xdg_toplevel.setMaximized(true);
            _ = view.xdg_toplevel.setSize(@intCast(u32, extents.width), @intCast(u32, extents.height));
        } else {
            if (!view.xdg_toplevel.current.maximized) {
                // TODO(dh): make sure wlroots doesn't swallow this event. see https://github.com/swaywm/wlroots/issues/2330
                _ = view.xdg_toplevel.setMaximized(false);
                return;
            }

            _ = view.xdg_toplevel.setMaximized(false);
            // TODO(dh): what happens if the client changed its geometry in the meantime? our old width and height will no longer be correct.
            _ = view.xdg_toplevel.setSize(@floatToInt(u32, @round(view.state_before_maximize.width)), @floatToInt(u32, @round(view.state_before_maximize.height)));
        }
    }

    fn commit(listener: *wl.Listener(*wlroots.Surface), data: *wlroots.Surface) void {
        const view = @fieldParentPtr(View, "commit", listener);
        if (view.xdg_toplevel.current.resizing) {
            const edges = view.active_grab.resize.edges;
            if (edges.left) {
                const delta_width = view.active_grab.resize.orig_geometry.width - view.getGeometry().width;
                view.position.x = view.active_grab.resize.orig_position.x + delta_width;
            }
            if (edges.top) {
                const delta_height = view.active_grab.resize.orig_geometry.height - view.getGeometry().height;
                view.position.y = view.active_grab.resize.orig_position.y + delta_height;
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

    link: wl.list.Link,
};

const Keyboard = struct {
    server: *Server,
    device: *wlroots.InputDevice,

    modifiers: wl.Listener(*wlroots.Keyboard),
    key: wl.Listener(*wlroots.Keyboard.event.Key),
    keymap: wl.Listener(*wlroots.Keyboard),
    repeat_info: wl.Listener(*wlroots.Keyboard),
    destroy: wl.Listener(*wlroots.Keyboard),

    link: wl.list.Link,

    fn handleModifiers(listener: *wl.Listener(*wlroots.Keyboard), data: *wlroots.Keyboard) void {
        const keyboard = @fieldParentPtr(Keyboard, "modifiers", listener);
        const seat = keyboard.server.seat;
        // TODO(dh): is there any benefit to avoiding repeated calls to this?
        seat.seat.setKeyboard(keyboard.device);
        seat.seat.keyboardNotifyModifiers(&data.modifiers);
    }

    fn handleKey(listener: *wl.Listener(*wlroots.Keyboard.event.Key), key: *wlroots.Keyboard.event.Key) void {
        const keyboard = @fieldParentPtr(Keyboard, "key", listener);
        const wlr_keyboard = keyboard.device.device.keyboard;
        const server = keyboard.server;
        var seat = server.seat;

        // map libinput keycode to xkbcommon
        const keycode = key.keycode + 8;

        var swallowed = false;
        for (wlr_keyboard.xkb_state.?.keyGetSyms(keycode)) |keysym| {
            const sym = @enumToInt(keysym);
            if (sym >= @enumToInt(xkb.Keysym.XF86Switch_VT_1) and sym <= @enumToInt(xkb.Keysym.XF86Switch_VT_12)) {
                const backend = server.backend;
                if (backend.getSession()) |session| {
                    const vt = sym - @enumToInt(xkb.Keysym.XF86Switch_VT_1) + 1;
                    // XXX handle failure
                    _ = session.changeVt(vt);
                }
                swallowed = true;
            }
        }

        if (!swallowed) {
            // XXX what is the layout index?
            const layout_index = wlr_keyboard.xkb_state.?.keyGetLayout(keycode);
            const raw_keysyms = wlr_keyboard.keymap.?.keyGetSymsByLevel(keycode, layout_index, 0);
            for (raw_keysyms) |sym| {
                if (seat.keybinding_manager.keyEvent(keyboard, sym, key.state == .pressed)) {
                    swallowed = true;
                }
            }
        }

        // FIXME(dh): do not send key release events if the key press was swallowed

        if (!swallowed) {
            // TODO(dh): is there any benefit to avoiding repeated calls to this?
            seat.seat.setKeyboard(keyboard.device);
            seat.seat.keyboardNotifyKey(key.time_msec, key.keycode, key.state);
        }
    }
    // TODO(dh): implement all of these
    fn handleKeymap(listener: *wl.Listener(*wlroots.Keyboard), data: *wlroots.Keyboard) void {}
    fn handleRepeatInfo(listener: *wl.Listener(*wlroots.Keyboard), data: *wlroots.Keyboard) void {}
    fn handleDestroy(listener: *wl.Listener(*wlroots.Keyboard), data: *wlroots.Keyboard) void {}
};

const KeybindingManager = struct {
    keybindings_data: [256]Keybinding,
    keybindings: []Keybinding,

    server: *Server,

    fn addKeybinding(self: *KeybindingManager, keybinding: Keybinding) !void {
        if (self.keybindings.len == self.keybindings_data.len) {
            return error.OutOfMemory;
        }
        self.keybindings = self.keybindings_data[0 .. self.keybindings.len + 1];
        self.keybindings[self.keybindings.len - 1] = keybinding;
    }

    fn keyEvent(self: *KeybindingManager, keyboard: *Keyboard, key: xkb.Keysym, pressed: bool) bool {
        if (!pressed) {
            return false;
        }

        const keymap = keyboard.device.device.keyboard.keymap.?;
        const mods = keyboard.device.device.keyboard.modifiers;

        for (self.keybindings) |keybinding| {
            // OPT(dh): this calculation can be cached once per keymap
            var wanted: xkb.ModMask = 0;
            for (keybinding.modifiers) |mod| {
                const modIndex = keymap.modGetIndex(mod);
                if (modIndex == xkb.mod_invalid) {
                    continue;
                }
                wanted |= @as(xkb.ModMask, 1) << (std.math.cast(u5, modIndex) catch {
                    // TODO(dh): log an error?
                    continue;
                });
            }

            if (wanted == mods.depressed | mods.latched and keybinding.keysym == key) {
                keybinding.cb(self.server);
                return true;
            }
        }

        return false;
    }
};

const Keybinding = struct {
    modifiers: []const [*:0]const u8,
    keysym: xkb.Keysym,
    // TODO(dh): keybinds should be able to report failure, with a
    // descriptive error message. then the compositor can present the
    // message to the user.
    cb: fn (*Server) void,
};

const WL_EVENT_READABLE = 0x01;
const WL_EVENT_WRITABLE = 0x02;
const WL_EVENT_HANGUP = 0x04;
const WL_EVENT_ERROR = 0x08;

fn dispatch(fd: c_int, mask: u32, data: *EventSource) callconv(.C) c_int {
    if (mask & WL_EVENT_HANGUP != 0 or mask & WL_EVENT_ERROR != 0) {
        // XXX what should we do here? kill the process? do nothing?
        return 0;
    }
    if (mask & WL_EVENT_READABLE != 0) {
        spawn.wait(@bitCast(std.c.pid_t, fd)) catch {
            unreachable;
        };
        data.hnd.remove();
        allocator.destroy(data);
        return 0;
    }
    unreachable;
}

const EventSource = struct {
    hnd: *wl.EventSource,
};

fn spawnTerminal(server: *Server) void {
    const tracectx = tracy.trace(@src());
    defer tracectx.end();

    const pid = spawn.spawn(allocator, &[_][]const u8{"termite"}) catch |err| {
        std.debug.print("couldn't spawn terminal: {}\n", .{err});
        return;
    };

    var data = allocator.create(EventSource) catch {
        // XXX handle
        return;
    };
    data.hnd = server.dsp.getEventLoop().addFd(
        *EventSource,
        pid,
        WL_EVENT_READABLE,
        dispatch,
        data,
    ) catch {
        // XXX handle error
        return;
    };
    // XXX reap the process
}

const modkey = xkb.names.mod.shift;

pub fn main() !void {
    const tracectx = tracy.trace(@src());
    defer tracectx.end();

    // c.wlr_log_init(c.enum_wlr_log_importance.WLR_DEBUG, null);
    var server: Server = undefined;
    try server.init();

    try server.seat.keybinding_manager.addKeybinding(.{
        .modifiers = &[_][*:0]const u8{modkey},
        .keysym = xkb.Keysym.Return,
        .cb = spawnTerminal,
    });

    server.dsp = try wl.Server.create();
    defer server.dsp.destroy();

    server.evloop = server.dsp.getEventLoop();
    server.backend = try wlroots.Backend.autocreate(server.dsp, null);
    defer server.backend.destroy();

    server.renderer = server.backend.getRenderer() orelse return error.GetRendererFailed;
    try server.renderer.initServer(server.dsp);
    server.new_output.setNotify(Output.newOutputNotify);
    server.backend.events.new_output.add(&server.new_output);

    // TODO(dh): do we need to free anything?
    _ = try wlroots.Compositor.create(server.dsp, server.renderer);
    _ = try wlroots.DataDeviceManager.create(server.dsp);

    server.output_layout = try wlroots.OutputLayout.create();
    defer server.output_layout.destroy();

    server.seat.cursor.attachOutputLayout(server.output_layout);

    // TODO(dh): what do the arguments mean?
    server.cursor_mgr = try wlroots.XcursorManager.create(null, 24);
    defer server.cursor_mgr.destroy();
    try server.cursor_mgr.load(1);

    server.new_input.setNotify(Server.newInput);
    server.backend.events.new_input.add(&server.new_input);

    server.seat.seat = try wlroots.Seat.create(server.dsp, "seat0");
    defer server.seat.seat.destroy();

    server.seat.request_cursor.setNotify(Seat.requestCursor);
    server.seat.seat.events.request_set_cursor.add(&server.seat.request_cursor);

    // note: no destructor; the shell is a static global
    server.xdg_shell = try wlroots.XdgShell.create(server.dsp);
    server.new_xdg_surface.setNotify(Server.newXdgSurface);
    server.xdg_shell.events.new_surface.add(&server.new_xdg_surface);

    var buf: [11]u8 = undefined;
    const socket = try server.dsp.addSocketAuto(&buf);
    // XXX handle error
    _ = c.setenv("WAYLAND_DISPLAY", socket, 1);
    std.debug.print("listening on {}\n", .{socket});

    try server.backend.start();
    server.dsp.run();
    defer server.dsp.destroyClients();
}
