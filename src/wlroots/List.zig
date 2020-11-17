const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");

/// struct wlr_list
pub const List = extern struct {
    // TODO
    pub extern fn wlr_list_init(list: *List) bool;
    pub extern fn wlr_list_finish(list: *List) void;
    pub extern fn wlr_list_for_each(list: *List, callback: ?fn (?*c_void) callconv(.C) void) void;
    pub extern fn wlr_list_push(list: *List, item: ?*c_void) isize;
    pub extern fn wlr_list_insert(list: *List, index: usize, item: ?*c_void) isize;
    pub extern fn wlr_list_del(list: *List, index: usize) void;
    pub extern fn wlr_list_pop(list: *List) ?*c_void;
    pub extern fn wlr_list_peek(list: *List) ?*c_void;
    pub extern fn wlr_list_cat(list: *List, source: *const List) isize;
    pub extern fn wlr_list_qsort(list: *List, compare: ?fn (?*const c_void, ?*const c_void) callconv(.C) c_int) void;
    pub extern fn wlr_list_find(list: *List, compare: ?fn (?*const c_void, ?*const c_void) callconv(.C) c_int, cmp_to: ?*const c_void) isize;

    capacity: usize,
    length: usize,
    items: [*c]?*c_void,
};
