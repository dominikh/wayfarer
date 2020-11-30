const std = @import("std");

const wl = @import("wayland").server.wl;
const wlr = @import("wlroots");
const xkb = @import("xkbcommon");

const c = @cImport({
    @cInclude("stdlib.h");
});
const spawn = @import("spawn.zig");
const tracy = @import("tracy.zig");
const libinput = @cImport({
    @cInclude("linux/input.h");
});
var gpa_state = tracy.Allocator.init(std.heap.c_allocator, "C allocator");
const gpa = &gpa_state.allocator;

const stdout = std.io.getStdout().writer();

// TODO(dh): upstream to zig-wlroots
extern fn wlr_subsurface_from_wlr_surface(surface: *wlr.Surface) ?*wlr.Subsurface;
extern fn wlr_surface_is_subsurface(surface: *wlr.Surface) bool;

// TODO(dh): handle implicit grabs correctly.

// We looked into using seat grabs to implement interactive move and
// resize, but it's not quite the right abstraction. What these grabs
// do is redirect calls to wlr_seat_*_notify_* through a grab, which can
// manipulate or drop the calls. This isn't useful for something like
// interactive move, because we need global mouse events, not ones
// local to a surface.

// We experimented with replacing most uses of @fieldParentPtr with
// using 'data' fields in wlroots types. This worked well for
// wlr.Surface and wlr.XdgSurface. XdgSurface points back to its
// Surface, and all events in XdgSurface and Surface point back to the
// respective surface.
//
// This stopped working with
// wlr.Keyboard and wlr.InputDevice. Keyboard wouldn't point back to
// its InputDevice, so we had to store to two different data fields.
// Furthermore, the events in Keyboard don't carry a reference to the
// Keyboard, so we'd have to use @fieldParentPtr for those events,
// anyway.
//
// Considering these inconsistencies, and the fact that
// @fieldParentPtr is free at runtime, while reading data fields is
// not, we'll stick with that.

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
// - https://developer.gnome.org/notification-spec/
// - https://github.com/emersion/wleird
// - https://raphlinus.github.io/ui/graphics/2020/09/13/compositor-is-evil.html
// - https://emersion.fr/blog/2019/xdc2019-wrap-up/#libliftoff

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
// OPT(dh): occlusion culling

fn defaultNotify(comptime notify: anytype) @typeInfo(@typeInfo(@TypeOf(notify)).Fn.args[0].arg_type.?).Pointer.child {
    const Listener = @typeInfo(@typeInfo(@TypeOf(notify)).Fn.args[0].arg_type.?).Pointer.child;
    return .{
        .link = .{ .next = null, .prev = null },
        .notify = Listener.getNotifyFn(notify),
    };
}

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

    backend: *wlr.Backend,
    renderer: *wlr.Renderer,
    output_layout: *wlr.OutputLayout,

    xdg_shell: *wlr.XdgShell,
    views: wl.list.Head(View, "link"),

    cursor_mgr: *wlr.XcursorManager,
    output_manager: *wlr.OutputManagerV1,

    outputs: wl.list.Head(Output, "link"),

    // TODO(dh): support multiple seats
    seat: Seat,

    events: struct {
        new_view: wl.Signal(*View),
    },

    new_xdg_surface: wl.Listener(*wlr.XdgSurface) = defaultNotify(Server.handleNewXdgSurface),
    // TODO(dh): move newOutputNotify into Server?
    new_output: wl.Listener(*wlr.Output) = defaultNotify(Output.handleNewOutput),
    new_input: wl.Listener(*wlr.InputDevice) = defaultNotify(Server.handleNewInput),
    output_manager_apply: wl.Listener(*wlr.OutputConfigurationV1) = defaultNotify(Server.handleOutputManagerApply),
    output_manager_test: wl.Listener(*wlr.OutputConfigurationV1) = defaultNotify(Server.handleOutputManagerTest),
    output_manager_destroy: wl.Listener(*wlr.OutputManagerV1) = defaultNotify(Server.handleOutputManagerDestroy),

    fn init(server: *Server, dsp: *wl.Server) !void {
        const backend = try wlr.Backend.autocreate(dsp, null);
        errdefer backend.destroy();
        const output_layout = try wlr.OutputLayout.create();
        errdefer output_layout.destroy();
        // TODO(dh): what do the arguments mean?
        const cursor_mgr = try wlr.XcursorManager.create(null, 24);
        errdefer cursor_mgr.destroy();
        const output_manager = try wlr.OutputManagerV1.create(dsp);
        const xdg_shell = try wlr.XdgShell.create(dsp);

        _ = try wlr.XdgOutputManagerV1.create(dsp, output_layout);

        server.* = .{
            .dsp = dsp,
            .evloop = dsp.getEventLoop(),
            .backend = backend,
            .renderer = backend.getRenderer() orelse return error.GetRendererFailed,
            .output_layout = output_layout,
            .cursor_mgr = cursor_mgr,
            .output_manager = output_manager,
            .xdg_shell = xdg_shell,

            .views = undefined,
            .outputs = undefined,
            .seat = undefined,
            .events = undefined,
        };

        server.outputs.init();
        server.views.init();
        server.events.new_view.init();

        // Note: the compositor has to be created before the seat, or
        // weston programs will crash, trying to create a surface when
        // it sees the seat, resulting in a segfault because it has no
        // valid proxy for the compositor yet.
        _ = try wlr.Compositor.create(server.dsp, server.renderer);
        const wlr_seat = try wlr.Seat.create(dsp, "seat0");
        errdefer wlr_seat.destroy();

        try server.seat.init(wlr_seat, server);
        errdefer server.seat.deinit();

        try server.renderer.initServer(dsp);
        // TODO(dh): do we need to free anything?
        _ = try wlr.DataDeviceManager.create(server.dsp);

        server.backend.events.new_output.add(&server.new_output);
        server.backend.events.new_input.add(&server.new_input);
        server.seat.seat.events.request_set_cursor.add(&server.seat.request_cursor);
        server.seat.seat.events.request_start_drag.add(&server.seat.request_start_drag);
        server.seat.seat.events.start_drag.add(&server.seat.start_drag);
        server.xdg_shell.events.new_surface.add(&server.new_xdg_surface);
        server.output_manager.events.apply.add(&server.output_manager_apply);
        server.output_manager.events.@"test".add(&server.output_manager_test);
        server.output_manager.events.destroy.add(&server.output_manager_destroy);
    }

    fn deinit(server: *Server) void {
        // FIXME(dh): deinit inputs and outputs and anything else we've allocated (or will wlroots call all our destroy handlers for us?)
        // FIXME(dh): stop the event loop
        server.new_output.link.remove();
        server.new_input.link.remove();
        server.seat.request_cursor.link.remove();
        server.seat.request_start_drag.link.remove();
        server.seat.start_drag.link.remove();
        server.new_xdg_surface.link.remove();
        server.output_manager_apply.link.remove();
        server.output_manager_test.link.remove();
        server.output_manager_destroy.link.remove();

        server.backend.destroy();
        server.output_layout.destroy();
        server.cursor_mgr.destroy();
        server.seat.seat.destroy();
        server.seat.deinit();
    }

    fn handleOutputManagerApply(listener: *wl.Listener(*wlr.OutputConfigurationV1), config: *wlr.OutputConfigurationV1) void {
        const server = @fieldParentPtr(Server, "output_manager_apply", listener);
        defer config.destroy();
        if (server.handleOutputManagerApply2(config)) {
            config.sendSucceeded();
        } else |_| {
            // XXX restore the previous configuration. right now, we
            // can be left in a seriously messed up state, e.g. one
            // with all outputs disabled.
            config.sendFailed();
        }
    }

    fn handleOutputManagerApply2(server: *Server, config: *wlr.OutputConfigurationV1) !void {
        // First disable all disabled outputs. We don't disable and
        // enable outputs in a single pass because we don't have
        // atomic modesetting yet, and enabling outputs might fail if
        // we've run out of CRTCs.
        var iter = config.heads.iterator(.forward);
        while (iter.next()) |head| {
            if (!head.state.enabled) {
                head.state.output.enable(false);
                try head.state.output.commit();
            }
        }

        iter = config.heads.iterator(.forward);
        while (iter.next()) |head| {
            if (!head.state.enabled) {
                continue;
            }
            const output = head.state.output;
            output.enable(true);
            if (head.state.mode) |mode| {
                output.setMode(mode);
            } else {
                const cmode = head.state.custom_mode;
                output.setCustomMode(cmode.width, cmode.height, cmode.refresh);
            }
            output.setTransform(head.state.transform);
            output.setScale(@floatCast(f32, head.state.scale));
            try output.commit();
            server.output_layout.add(output, head.state.x, head.state.y);
        }
    }

    fn handleOutputManagerTest(listener: *wl.Listener(*wlr.OutputConfigurationV1), config: *wlr.OutputConfigurationV1) void {
        // TODO(dh): add support for test, see wlr_output_test
        defer config.destroy();
        config.sendSucceeded();
    }

    fn handleOutputManagerDestroy(listener: *wl.Listener(*wlr.OutputManagerV1), data: *wlr.OutputManagerV1) void {
        std.debug.print("destroy\n", .{});
    }

    fn updateOutputConfiguration(server: *Server) !void {
        const output_configuration = try wlr.OutputConfigurationV1.create();
        errdefer output_configuration.destroy();

        var iter = server.outputs.iterator(.forward);
        while (iter.next()) |item| {
            // XXX does output_configuration.destroy destroy already added heads?
            // TODO set output position, transform, scale
            _ = try wlr.OutputConfigurationV1.Head.create(output_configuration, item.output);
        }
        server.output_manager.setConfiguration(output_configuration);
    }

    fn raiseView(server: *Server, view: *View) !void {
        const tracectx = tracy.trace(@src());
        defer tracectx.end();

        var arena = std.heap.ArenaAllocator.init(gpa);
        defer arena.deinit();

        try server.raiseView2(&arena, view, true, null);
    }

    fn raiseView2(server: *Server, arena: *std.heap.ArenaAllocator, view: *View, raiseParent: bool, ignoreChild: ?*View) error{OutOfMemory}!void {
        const tracectx = tracy.trace(@src());
        defer tracectx.end();

        // recursively raise our parents
        if (raiseParent) {
            if (view.xdg_toplevel.parent) |parent| {
                try server.raiseView2(arena, @intToPtr(*View, parent.data), true, view);
            }
        }

        // place ourselves above our parents
        view.link.remove();
        server.views.prepend(view);

        // raise our children above us, maintaining their relative order
        var toRaise = std.ArrayList(*View).init(&arena.allocator);
        var iter = server.views.iterator(.reverse);
        while (iter.next()) |item| {
            if (item.xdg_toplevel.parent == view.xdg_toplevel.base) {
                const child_view = @intToPtr(*View, item.xdg_toplevel.base.data);
                if (child_view == ignoreChild) {
                    // skip this child. it is the one that started the
                    // chain of raiseView calls, and will raise itself
                    // above its siblings. we don't want to pay the
                    // cost of raising it twice.
                } else {
                    try toRaise.append(child_view);
                }
            }
        }
        for (toRaise.items) |item| {
            // FIXME(dh): consider FIXME in setParent; this might contain loops
            try server.raiseView2(arena, item, false, null);
        }

        // we're done. all windows that are part of the same family
        // have the correct relative order to each other, and the
        // entire family is on top of all other windows.
    }

    /// findViewUnderCursor finds the view and surface at position (lx, ly), respecting input regions.
    fn findViewUnderCursor(server: *Server, lx: f64, ly: f64, surface: ?**wlr.Surface, sx: *f64, sy: *f64) ?*View {
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
    fn handleNewInput(listener: *wl.Listener(*wlr.InputDevice), dev: *wlr.InputDevice) void {
        const server = @fieldParentPtr(Server, "new_input", listener);

        switch (dev.type) {
            .keyboard => {
                var keyboard = gpa.create(Keyboard) catch @panic("out of memory");
                keyboard.init(server, dev);

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
                const device = dev.device.keyboard;
                _ = device.setKeymap(keymap);
                device.setRepeatInfo(25, 600);

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
                var pointer = gpa.create(Pointer) catch @panic("out of memory");
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

    fn handleNewXdgSurface(listener: *wl.Listener(*wlr.XdgSurface), xdg_surface: *wlr.XdgSurface) void {
        const server = @fieldParentPtr(Server, "new_xdg_surface", listener);
        switch (xdg_surface.role) {
            .toplevel => {
                var view = gpa.create(View) catch @panic("out of memory");
                view.init(server, xdg_surface.role_data.toplevel);
                server.views.prepend(view);
                xdg_surface.data = @ptrToInt(view);
                server.events.new_view.emit(view);
            },
            .popup => {
                // XXX do we have to do anything?
            },
            else => {
                unreachable;
            },
        }
    }
};

// TODO(dh): review this function in the future; it feels more complex than should be necessary
fn subsurfaceCoordsRelativeToRootSurface(surface: *wlr.Surface, sx: *c_int, sy: *c_int) void {
    var x: c_int = 0;
    var y: c_int = 0;
    var ptr: ?*wlr.Surface = surface;
    while (ptr != null and wlr_surface_is_subsurface(ptr.?)) {
        if (wlr_subsurface_from_wlr_surface(ptr.?)) |subsurface| {
            x += subsurface.current.x;
            x += subsurface.current.y;
            ptr = subsurface.parent;
        } else {
            // the subsurface for this surface has already been deleted
            // TODO(dh): do we need to bubble this up as an error?
            sx.* = 0;
            sy.* = 0;
        }
    } else {
        sx.* = x;
        sy.* = y;
    }
}

const Seat = struct {
    seat: *wlr.Seat,
    server: *Server,

    pointers: wl.list.Head(Pointer, "link"),
    keyboards: wl.list.Head(Keyboard, "link"),

    // FIXME(dh): implement keyboard grabs
    focused_view: ?*View = null,
    cursor: *wlr.Cursor,
    cursor_mode: struct {
        mode: enum {
            normal,
            implicit_grab,
            move,
            resize,
        },
        grabbed_view: ?*View,
        initiated_by: ?u32,
    },
    keybinding_manager: KeybindingManager,

    cursor_motion: wl.Listener(*wlr.Pointer.event.Motion) = defaultNotify(Seat.handleCursorMotion),
    cursor_motion_absolute: wl.Listener(*wlr.Pointer.event.MotionAbsolute) = defaultNotify(Seat.handleCursorMotionAbsolute),
    cursor_button: wl.Listener(*wlr.Pointer.event.Button) = defaultNotify(Seat.handleCursorButton),
    cursor_axis: wl.Listener(*wlr.Pointer.event.Axis) = defaultNotify(Seat.handleCursorAxis),
    cursor_frame: wl.Listener(*wlr.Cursor) = defaultNotify(Seat.handleCursorFrame),
    request_cursor: wl.Listener(*wlr.Seat.event.RequestSetCursor) = defaultNotify(Seat.handleRequestCursor),
    request_start_drag: wl.Listener(*wlr.Seat.event.RequestStartDrag) = defaultNotify(Seat.handleRequestStartDrag),
    start_drag: wl.Listener(*wlr.Drag) = defaultNotify(Seat.handleStartDrag),

    new_view: wl.Listener(*View) = defaultNotify(Seat.handleNewView),
    destroy_view: wl.Listener(*View) = defaultNotify(Seat.handleDestroyView),

    pub fn init(seat: *Seat, wlr_seat: *wlr.Seat, server: *Server) !void {
        const cursor = try wlr.Cursor.create();
        errdefer cursor.destroy();

        seat.* = .{
            .seat = wlr_seat,
            .server = server,
            .pointers = undefined,
            .keyboards = undefined,
            .cursor = cursor,
            .cursor_mode = .{
                .mode = .normal,
                .grabbed_view = null,
                .initiated_by = null,
            },
            .keybinding_manager = .{
                .keybindings_data = undefined,
                .server = server,
                .keybindings = &[0]Keybinding{},
            },
        };

        seat.keyboards.init();
        seat.pointers.init();

        seat.server.events.new_view.add(&seat.new_view);
        seat.cursor.events.motion.add(&seat.cursor_motion);
        seat.cursor.events.motion_absolute.add(&seat.cursor_motion_absolute);
        seat.cursor.events.button.add(&seat.cursor_button);
        seat.cursor.events.axis.add(&seat.cursor_axis);
        seat.cursor.events.frame.add(&seat.cursor_frame);
    }

    pub fn deinit(seat: *Seat) void {
        seat.cursor.destroy();
    }

    fn handleNewView(listener: *wl.Listener(*View), view: *View) void {
        const seat = @fieldParentPtr(Seat, "new_view", listener);
        view.events.destroy.add(&seat.destroy_view);
    }

    fn handleDestroyView(listener: *wl.Listener(*View), view: *View) void {
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

    fn startInteractiveMove(seat: *Seat, view: *View, initiated_by: u32) !void {
        try seat.server.raiseView(view);
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

    fn startInteractiveResize(seat: *Seat, view: *View, initiated_by: u32, edges: wlr.Edges) void {
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

    fn handleCursorFrame(listener: *wl.Listener(*wlr.Cursor), event: *wlr.Cursor) void {
        const seat = @fieldParentPtr(Seat, "cursor_frame", listener);
        seat.seat.pointerNotifyFrame();
    }

    fn handleCursorButton(listener: *wl.Listener(*wlr.Pointer.event.Button), event: *wlr.Pointer.event.Button) void {
        // XXX we can't rely on cursor motion to update the active
        // view. we have to do it for clicks, too. and probably when
        // windows get unmapped.
        const seat = @fieldParentPtr(Seat, "cursor_button", listener);

        switch (seat.cursor_mode.mode) {
            .normal => blk: {
                if (event.state != .pressed) {
                    // this can happen when running nested
                    // compositors: press a button outside this
                    // compositor, move pointer into this compositor,
                    // release button.
                    break :blk;
                }
                if (seat.focused_view != null) {
                    seat.cursor_mode.mode = .implicit_grab;
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
                                libinput.BTN_LEFT => {
                                    seat.startInteractiveMove(view, event.button) catch {
                                        // TODO(dh): present error to user
                                    };
                                    return;
                                },
                                libinput.BTN_MIDDLE => {
                                    seat.startInteractiveResize(view, event.button, .{
                                        // TODO(dh0: do we need to use geometry coordinates instead?
                                        .left = sx <= view.width() / 2,
                                        .right = sx > view.width() / 2,
                                        .top = sy <= view.height() / 2,
                                        .bottom = sy > view.height() / 2,
                                    });
                                    return;
                                },
                                else => {},
                            }
                        }
                    }
                }
            },

            .implicit_grab => {
                switch (event.state) {
                    .pressed => {},
                    .released => {
                        if (seat.seat.pointer_state.button_count == 1) {
                            // we're releasing the last pressed button
                            seat.cursor_mode.mode = .normal;
                        }
                    },
                    else => unreachable,
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
                    return;
                }
            },
        }

        _ = seat.seat.pointerNotifyButton(event.time_msec, event.button, event.state);
    }

    fn handleCursorMotion(listener: *wl.Listener(*wlr.Pointer.event.Motion), event: *wlr.Pointer.event.Motion) void {
        const seat = @fieldParentPtr(Seat, "cursor_motion", listener);
        seat.cursor.move(event.device, event.delta_x, event.delta_y);
        seat.processCursorMotion(event.time_msec);
    }

    fn handleCursorMotionAbsolute(listener: *wl.Listener(*wlr.Pointer.event.MotionAbsolute), event: *wlr.Pointer.event.MotionAbsolute) void {
        const seat = @fieldParentPtr(Seat, "cursor_motion_absolute", listener);
        seat.cursor.warpAbsolute(event.device, event.x, event.y);
        seat.processCursorMotion(event.time_msec);
    }

    fn handleCursorAxis(listener: *wl.Listener(*wlr.Pointer.event.Axis), event: *wlr.Pointer.event.Axis) void {
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
                var surface: *wlr.Surface = undefined;
                var sx: f64 = undefined;
                var sy: f64 = undefined;
                if (seat.server.findViewUnderCursor(cursor_lx, cursor_ly, &surface, &sx, &sy)) |view| {
                    // XXX set focus only if the view changed from last time
                    if (seat.seat.getKeyboard()) |keyboard| {
                        seat.seat.keyboardNotifyEnter(surface, &keyboard.keycodes, keyboard.num_keycodes, &keyboard.modifiers);
                    }

                    // In a previous version of this code, we checked seat.pointer_state.focused_surface == surface,
                    // to avoid extra calls to pointerNotifyEnter. This didn't work with an active drag-and-drop
                    // however, because pointerNotifyEnter no longer updated focused_surface, and we never called
                    // pointerNotifyMotion.
                    seat.seat.pointerNotifyEnter(surface, sx, sy);
                    // TODO(dh): is it fine to call both pointerNotifyEnter and pointerNotifyMotion? Does this cause duplicate events?
                    seat.seat.pointerNotifyMotion(time_msec, sx, sy);
                    seat.focused_view = view;
                } else {
                    // TODO(dh): what if a button was held while the pointer left the surface?
                    seat.seat.pointerNotifyClearFocus();
                    seat.focused_view = null;

                    // TODO(dh): is there a fixed set of valid pointer names?
                    seat.server.cursor_mgr.setCursorImage("left_ptr", seat.cursor);
                }
            },

            .implicit_grab => {
                // XXX why exactly can focussed_surface be null while focussed_view is not null?
                if (seat.seat.pointer_state.focused_surface) |surface| {
                    var ox: c_int = undefined;
                    var oy: c_int = undefined;
                    subsurfaceCoordsRelativeToRootSurface(surface, &ox, &oy);
                    const sx = cursor_lx - seat.focused_view.?.position.x - @intToFloat(f64, ox);
                    const sy = cursor_ly - seat.focused_view.?.position.y - @intToFloat(f64, oy);
                    seat.seat.pointerNotifyMotion(time_msec, sx, sy);
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
        orientation: wlr.AxisOrientation,
        value: f64,
        value_discrete: i32,
        source: wlr.AxisSource,
    ) void {
        seat.seat.pointerNotifyAxis(time_msec, orientation, value, value_discrete, source);
    }

    fn handleRequestCursor(listener: *wl.Listener(*wlr.Seat.event.RequestSetCursor), event: *wlr.Seat.event.RequestSetCursor) void {
        const seat = @fieldParentPtr(Seat, "request_cursor", listener);
        if (seat.seat.pointer_state.focused_client == event.seat_client) {
            seat.cursor.setSurface(event.surface, event.hotspot_x, event.hotspot_y);
        }
    }

    fn handleRequestStartDrag(listener: *wl.Listener(*wlr.Seat.event.RequestStartDrag), event: *wlr.Seat.event.RequestStartDrag) void {
        // TODO(dh): validate serial
        const seat = @fieldParentPtr(Seat, "request_start_drag", listener);
        seat.seat.startPointerDrag(event.drag, event.serial);
    }

    fn handleStartDrag(listener: *wl.Listener(*wlr.Drag), drag: *wlr.Drag) void {
        // TODO(dh): support drag icons
    }
};

const Output = struct {
    output: *wlr.Output,
    server: *Server,
    // XXX we're not actually using last_frame for anything, nor updating it when we render frames
    last_frame: std.os.timespec,

    destroy: wl.Listener(*wlr.Output) = defaultNotify(Output.handleDestroy),
    frame: wl.Listener(*wlr.Output) = defaultNotify(Output.handleFrame),
    present: wl.Listener(*wlr.Output.event.Present) = defaultNotify(Output.handlePresent),
    mode: wl.Listener(*wlr.Output) = defaultNotify(Output.handleMode),
    scale: wl.Listener(*wlr.Output) = defaultNotify(Output.handleScale),
    transform: wl.Listener(*wlr.Output) = defaultNotify(Output.handleTransform),

    link: wl.list.Link,

    fn init(output: *Output, wlr_output: *wlr.Output, server: *Server) void {
        output.* = .{
            .output = wlr_output,
            .server = server,
            .last_frame = undefined,
            .link = .{ .prev = null, .next = null },
        };

        wlr_output.events.destroy.add(&output.destroy);
        wlr_output.events.frame.add(&output.frame);
        wlr_output.events.present.add(&output.present);
        wlr_output.events.mode.add(&output.mode);
        wlr_output.events.scale.add(&output.scale);
        wlr_output.events.transform.add(&output.transform);
    }

    fn handleNewOutput(listener: *wl.Listener(*wlr.Output), output: *wlr.Output) void {
        std.debug.print("new output\n", .{});
        const server = @fieldParentPtr(Server, "new_output", listener);

        const modes = &output.modes;
        if (!modes.empty()) {
            const mode = modes.iterator(.reverse).next().?;
            output.setMode(mode);
            output.enable(true);
            output.commit() catch return;
        }

        var our_output: *Output = gpa.create(Output) catch @panic("out of memory");
        our_output.init(output, server);
        std.os.clock_gettime(std.os.CLOCK_MONOTONIC, &our_output.last_frame) catch |err| @panic(@errorName(err));
        server.outputs.append(our_output);

        server.output_layout.addAuto(output);

        // XXX handle error
        server.updateOutputConfiguration() catch {};
    }

    fn handleMode(listener: *wl.Listener(*wlr.Output), data: *wlr.Output) void {
        // XXX handle error
        const our_output = @fieldParentPtr(Output, "mode", listener);
        our_output.server.updateOutputConfiguration() catch {};
    }

    fn handleScale(listener: *wl.Listener(*wlr.Output), data: *wlr.Output) void {
        // XXX handle error
        const our_output = @fieldParentPtr(Output, "scale", listener);
        our_output.server.updateOutputConfiguration() catch {};
    }

    fn handleTransform(listener: *wl.Listener(*wlr.Output), data: *wlr.Output) void {
        // XXX handle error
        const our_output = @fieldParentPtr(Output, "transform", listener);
        our_output.server.updateOutputConfiguration() catch {};
    }

    fn handleDestroy(listener: *wl.Listener(*wlr.Output), data: *wlr.Output) void {
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

    fn handleFrame(listener: *wl.Listener(*wlr.Output), output: *wlr.Output) void {
        const tracectx = tracy.trace(@src());
        defer tracectx.end();

        const our_output = @fieldParentPtr(Output, "frame", listener);
        const server = our_output.server;
        const renderer = server.renderer;

        // XXX don't panic
        const now = clockGetTime() catch |err| @panic(@errorName(err));

        // TODO(dh): why can this fail?
        output.attachRender(null) catch return;

        // Contrary to what tinywl suggests, we do _not_ want the
        // "effective resolution" here. We want the actual resolution
        // of the output.
        renderer.begin(output.width, output.height);

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
        our_output.output.commit() catch return;
    }

    fn handlePresent(listener: *wl.Listener(*wlr.Output.event.Present), output: *wlr.Output.event.Present) void {
        tracy.frame(null);
    }

    fn renderSurface(surface: *wlr.Surface, sx: c_int, sy: c_int, rdata: *RenderData) callconv(.C) void {
        const tracectx = tracy.trace(@src());
        defer tracectx.end();

        const view = rdata.view;
        const output = rdata.output.output;
        const renderer = view.server.renderer;

        const texture = surface.getTexture() orelse return;

        // buffer -> surface -> layout -> output

        // TODO(dh): support rotated outputs
        // TODO(dh): support buffers that don't match surface coordinates

        var ox: f64 = undefined;
        var oy: f64 = undefined;
        view.server.output_layout.outputCoords(output, &ox, &oy);
        ox = ox + view.position.x + @intToFloat(f64, sx);
        oy = oy + view.position.y + @intToFloat(f64, sy);

        // TODO(dh): make sure this handles fractional scaling correctly
        const box: wlr.Box = .{
            .x = @floatToInt(c_int, @round(ox * output.scale)),
            .y = @floatToInt(c_int, @round(oy * output.scale)),
            .width = @floatToInt(c_int, @intToFloat(f32, surface.current.width) * output.scale),
            .height = @floatToInt(c_int, @intToFloat(f32, surface.current.height) * output.scale),
        };

        var m: [9]f32 = undefined;
        const transform = wlr.Output.transformInvert(surface.current.transform);
        wlr.matrix.projectBox(&m, &box, transform, 0, &output.transform_matrix);

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
    xdg_toplevel: *wlr.XdgToplevel,
    // the view's position in layout space

    // XXX we should probably make this properly double-buffered
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
            edges: wlr.Edges,
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

    children: wl.list.Head(View, "child_link") = undefined,
    child_link: wl.list.Link = .{ .prev = null, .next = null },

    map: wl.Listener(*wlr.XdgSurface) = defaultNotify(View.handleXdgSurfaceMap),
    unmap: wl.Listener(*wlr.XdgSurface) = defaultNotify(View.handleXdgSurfaceUnmap),
    destroy: wl.Listener(*wlr.XdgSurface) = defaultNotify(View.handleXdgSurfaceDestroy),
    request_move: wl.Listener(*wlr.XdgToplevel.event.Move) = defaultNotify(View.handleXdgToplevelRequestMove),
    request_resize: wl.Listener(*wlr.XdgToplevel.event.Resize) = defaultNotify(View.handleXdgToplevelRequestResize),
    request_maximize: wl.Listener(*wlr.XdgSurface) = defaultNotify(View.handleXdgToplevelRequestMaximize),
    commit: wl.Listener(*wlr.Surface) = defaultNotify(View.handleCommit),
    set_parent: wl.Listener(*wlr.XdgSurface) = defaultNotify(View.handleXdgToplevelSetParent),

    link: wl.list.Link = undefined,

    fn init(view: *View, server: *Server, toplevel: *wlr.XdgToplevel) void {
        view.* = .{
            .server = server,
            .xdg_toplevel = toplevel,
        };
        view.events.destroy.init();
        view.children.init();

        toplevel.base.events.map.add(&view.map);
        toplevel.base.events.unmap.add(&view.unmap);
        toplevel.base.events.destroy.add(&view.destroy);
        toplevel.base.surface.events.commit.add(&view.commit);
        toplevel.events.request_move.add(&view.request_move);
        toplevel.events.request_resize.add(&view.request_resize);
        toplevel.events.request_maximize.add(&view.request_maximize);
        toplevel.events.set_parent.add(&view.set_parent);
    }

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
        wlr.matrix.identity(&m);
        wlr.matrix.translate(&m, @floatCast(f32, x), @floatCast(f32, y));
        wlr.matrix.rotate(&m, view.rotation);
        // TODO(dh): rotation should probably be around the center, not the origin
        wlr.matrix.scale(&m, @intToFloat(f32, view.width()), @intToFloat(f32, view.height()));
        return m;
    }

    fn getGeometry(view: *const View) Box {
        // TODO(dh): de-c-ify all of this
        var box: wlr.Box = undefined;
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

    fn handleXdgSurfaceMap(listener: *wl.Listener(*wlr.XdgSurface), surface: *wlr.XdgSurface) void {
        const view = @fieldParentPtr(View, "map", listener);

        // XXX should only the focussed client be active?
        _ = surface.role_data.toplevel.setActivated(true);
    }

    fn handleXdgSurfaceUnmap(listener: *wl.Listener(*wlr.XdgSurface), surface: *wlr.XdgSurface) void {
        // XXX cancel interactive move, resize, …
        const view = @fieldParentPtr(View, "unmap", listener);
        // TODO(dh): if this was the surface with pointer focus, see if there's another window we can focus instead
    }

    fn handleXdgSurfaceDestroy(listener: *wl.Listener(*wlr.XdgSurface), surface: *wlr.XdgSurface) void {
        std.debug.print("destroyed surface\n", .{});
        switch (surface.role) {
            .toplevel => {
                var view = @fieldParentPtr(View, "destroy", listener);
                view.link.remove();
                view.events.destroy.emit(view);
                gpa.destroy(view);
            },
            else => {
                // TODO(dh): handle other roles
            },
        }
    }

    fn handleXdgToplevelRequestMove(listener: *wl.Listener(*wlr.XdgToplevel.event.Move), event: *wlr.XdgToplevel.event.Move) void {
        // TODO(dh): check the serial against recent button presses, to prevent bad clients from invoking this at will
        // TODO(dh): unmaximize the window if it is maximized
        const view = @fieldParentPtr(View, "request_move", listener);
        // XXX use the serial to look up which button was used to initiate this
        view.server.seat.startInteractiveMove(view, libinput.BTN_LEFT) catch {
            // TODO(dh): inform user about failure
        };
    }

    fn handleXdgToplevelRequestResize(listener: *wl.Listener(*wlr.XdgToplevel.event.Resize), event: *wlr.XdgToplevel.event.Resize) void {
        // TODO(dh): check the serial against recent button presses, to prevent bad clients from invoking this at will
        // TODO(dh): only allow this request from the focussed client
        const view = @fieldParentPtr(View, "request_resize", listener);
        // XXX use the serial to look up which button was used to initiate this
        view.server.seat.startInteractiveResize(view, libinput.BTN_LEFT, event.edges);
    }

    fn handleXdgToplevelRequestMaximize(listener: *wl.Listener(*wlr.XdgSurface), surface: *wlr.XdgSurface) void {
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

            const extents = view.server.output_layout.getBox(output).?;
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

    fn handleXdgToplevelSetParent(listener: *wl.Listener(*wlr.XdgSurface), surface: *wlr.XdgSurface) void {
        // FIXME(dh): can a misbehaving client create a cycle like a -> b -> a?
        // FIXME(dh): does wlroots call this when the current parent gets unmapped?
        const view = @fieldParentPtr(View, "set_parent", listener);
        if (view.child_link.prev != null) {
            view.child_link.remove();
        }
        if (surface.role_data.toplevel.parent) |parent| {
            const parent_view = @intToPtr(*View, parent.data);
            parent_view.children.append(view);
        }

        // TODO(dh): should we raise the window above its parent?
    }

    fn handleCommit(listener: *wl.Listener(*wlr.Surface), data: *wlr.Surface) void {
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
    device: *wlr.InputDevice,

    link: wl.list.Link = .{ .prev = null, .next = null },
};

const Keyboard = struct {
    server: *Server,
    device: *wlr.InputDevice,

    modifiers: wl.Listener(*wlr.Keyboard) = defaultNotify(Keyboard.handleModifiers),
    key: wl.Listener(*wlr.Keyboard.event.Key) = defaultNotify(Keyboard.handleKey),
    keymap: wl.Listener(*wlr.Keyboard) = defaultNotify(Keyboard.handleKeymap),
    repeat_info: wl.Listener(*wlr.Keyboard) = defaultNotify(Keyboard.handleRepeatInfo),
    destroy: wl.Listener(*wlr.Keyboard) = defaultNotify(Keyboard.handleDestroy),

    link: wl.list.Link = .{ .prev = null, .next = null },

    fn init(keyboard: *Keyboard, server: *Server, dev: *wlr.InputDevice) void {
        keyboard.* = .{
            .server = server,
            .device = dev,
        };

        const device = dev.device.keyboard;
        device.events.modifiers.add(&keyboard.modifiers);
        device.events.key.add(&keyboard.key);
        device.events.keymap.add(&keyboard.keymap);
        device.events.repeat_info.add(&keyboard.repeat_info);
        device.events.destroy.add(&keyboard.destroy);
    }

    fn handleModifiers(listener: *wl.Listener(*wlr.Keyboard), data: *wlr.Keyboard) void {
        const keyboard = @fieldParentPtr(Keyboard, "modifiers", listener);
        const seat = keyboard.server.seat;
        // TODO(dh): is there any benefit to avoiding repeated calls to this?
        seat.seat.setKeyboard(keyboard.device);
        seat.seat.keyboardNotifyModifiers(&data.modifiers);
    }

    fn handleKey(listener: *wl.Listener(*wlr.Keyboard.event.Key), key: *wlr.Keyboard.event.Key) void {
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
                    session.changeVt(vt) catch {};
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
    fn handleKeymap(listener: *wl.Listener(*wlr.Keyboard), data: *wlr.Keyboard) void {}
    fn handleRepeatInfo(listener: *wl.Listener(*wlr.Keyboard), data: *wlr.Keyboard) void {}
    fn handleDestroy(listener: *wl.Listener(*wlr.Keyboard), data: *wlr.Keyboard) void {}
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
        gpa.destroy(data);
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

    const pid = spawn.spawn(gpa, &[_][]const u8{"termite"}) catch |err| {
        std.debug.print("couldn't spawn terminal: {}\n", .{err});
        return;
    };

    var data = gpa.create(EventSource) catch {
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

    const dsp = try wl.Server.create();
    defer dsp.destroy();

    var server: Server = undefined;
    try server.init(dsp);
    // c.wlr_log_init(c.enum_wlr_log_importance.WLR_DEBUG, null);
    defer server.deinit();

    try server.seat.keybinding_manager.addKeybinding(.{
        .modifiers = &[_][*:0]const u8{modkey},
        .keysym = xkb.Keysym.Return,
        .cb = spawnTerminal,
    });

    server.seat.cursor.attachOutputLayout(server.output_layout);

    try server.cursor_mgr.load(1);

    var buf: [11]u8 = undefined;
    const socket = try server.dsp.addSocketAuto(&buf);
    // XXX handle error
    _ = c.setenv("WAYLAND_DISPLAY", socket, 1);
    std.debug.print("listening on {}\n", .{socket});

    try server.backend.start();
    server.dsp.run();
    defer server.dsp.destroyClients();
}
