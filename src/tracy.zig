pub const std = @import("std");

pub const enable = if (std.builtin.is_test) false else @import("build_options").enable_tracy;

extern fn ___tracy_emit_zone_begin_callstack(
    srcloc: *const ___tracy_source_location_data,
    depth: c_int,
    active: c_int,
) ___tracy_c_zone_context;

extern fn ___tracy_emit_zone_begin(
    srcloc: *const ___tracy_source_location_data,
    active: c_int,
) ___tracy_c_zone_context;

extern fn ___tracy_emit_zone_end(ctx: ___tracy_c_zone_context) void;
extern fn ___tracy_emit_frame_mark(?[*:0]const u8) void;
extern fn ___tracy_emit_frame_mark_start(?[*:0]const u8) void;
extern fn ___tracy_emit_frame_mark_end(?[*:0]const u8) void;
extern fn ___tracy_emit_memory_alloc_callstack(ptr: *const c_void, size: usize, depth: c_int, secure: c_int) void;
extern fn ___tracy_emit_memory_free_callstack(ptr: *const c_void, depth: c_int, secure: c_int) void;
extern fn ___tracy_emit_memory_alloc(ptr: *const c_void, size: usize, secure: c_int) void;
extern fn ___tracy_emit_memory_free(ptr: *const c_void, secure: c_int) void;
extern fn ___tracy_emit_memory_alloc_named(ptr: *const c_void, size: usize, secure: c_int, name: [*:0]const u8) void;
extern fn ___tracy_emit_memory_free_named(ptr: *const c_void, secure: c_int, name: [*:0]const u8) void;

pub fn frame(name: ?[*:0]const u8) void {
    if (!enable) return;
    ___tracy_emit_frame_mark(name);
}

pub fn frameStart(name: ?[*:0]const u8) void {
    if (!enable) return;
    ___tracy_emit_frame_mark_start(name);
}

pub fn frameEnd(name: ?[*:0]const u8) void {
    if (!enable) return;
    ___tracy_emit_frame_mark_end(name);
}

// TODO(dh): stack capture doesn't seem to be working at the moment, so disable it.
const stack_depth = 0;

inline fn _alloc(ptr: []u8, size: usize, name: ?[*:0]const u8) void {
    if (!enable) return;
    if (stack_depth > 0) {
        if (name) |n| {
            ___tracy_emit_memory_alloc_callstack_named(ptr.ptr, size, stack_depth, 0, n);
        } else {
            ___tracy_emit_memory_alloc_callstack(ptr.ptr, size, stack_depth, 0);
        }
    } else {
        if (name) |n| {
            ___tracy_emit_memory_alloc_named(ptr.ptr, size, 0, n);
        } else {
            ___tracy_emit_memory_alloc(ptr.ptr, size, 0);
        }
    }
}

inline fn _free(ptr: []u8, name: ?[*:0]const u8) void {
    if (!enable) return;
    if (stack_depth > 0) {
        if (name) |n| {
            ___tracy_emit_memory_free_callstack_named(ptr.ptr, stack_depth, 0, n);
        } else {
            ___tracy_emit_memory_free_callstack(ptr.ptr, stack_depth, 0);
        }
    } else {
        if (name) |n| {
            ___tracy_emit_memory_free_named(ptr.ptr, 0, n);
        } else {
            ___tracy_emit_memory_free(ptr.ptr, 0);
        }
    }
}

pub const ___tracy_source_location_data = extern struct {
    name: ?[*:0]const u8,
    function: [*:0]const u8,
    file: [*:0]const u8,
    line: u32,
    color: u32,
};

pub const ___tracy_c_zone_context = extern struct {
    id: u32,
    active: c_int,

    pub fn end(self: ___tracy_c_zone_context) void {
        ___tracy_emit_zone_end(self);
    }
};

pub const Ctx = if (enable) ___tracy_c_zone_context else struct {
    pub fn end(self: Ctx) void {}
};

pub inline fn trace(comptime src: std.builtin.SourceLocation) Ctx {
    return traceName(src, null);
}

pub inline fn traceName(comptime src: std.builtin.SourceLocation, comptime name: ?[*:0]const u8) Ctx {
    if (!enable) return .{};

    const loc: ___tracy_source_location_data = .{
        .name = name,
        .function = src.fn_name.ptr,
        .file = src.file.ptr,
        .line = src.line,
        .color = 0,
    };
    if (stack_depth > 0) {
        return ___tracy_emit_zone_begin_callstack(&loc, stack_depth, 1);
    } else {
        return ___tracy_emit_zone_begin(&loc, 1);
    }
}

pub const Allocator = struct {
    allocator: std.mem.Allocator,
    orig: *std.mem.Allocator,
    // TODO(dh): Tracy's C API doesn't currently expose named memory pools, so we can't make use of this yetc
    name: ?[*:0]const u8,

    pub fn init(orig: *std.mem.Allocator, name: ?[*:0]const u8) Allocator {
        return .{
            .allocator = .{
                .allocFn = allocFn,
                .resizeFn = resizeFn,
            },
            .orig = orig,
            .name = name,
        };
    }

    fn allocFn(ptr: *std.mem.Allocator, arg1: usize, arg2: u29, arg3: u29, arg4: usize) std.mem.Allocator.Error![]u8 {
        const alloc = @fieldParentPtr(Allocator, "allocator", ptr);
        const ret = try alloc.orig.allocFn(alloc.orig, arg1, arg2, arg3, arg4);
        _alloc(ret, ret.len, alloc.name);
        return ret;
    }

    fn resizeFn(ptr: *std.mem.Allocator, arg1: []u8, arg2: u29, new_size: usize, arg4: u29, arg5: usize) std.mem.Allocator.Error!u64 {
        const alloc = @fieldParentPtr(Allocator, "allocator", ptr);
        const ret = try alloc.orig.resizeFn(alloc.orig, arg1, arg2, new_size, arg4, arg5);
        _free(arg1, alloc.name);
        if (new_size != 0) {
            _alloc(arg1, ret, alloc.name);
        }
        return ret;
    }
};
