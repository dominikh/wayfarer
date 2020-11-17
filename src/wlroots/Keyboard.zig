const wayland = @import("../wayland.zig");
const wlroots = @import("../wlroots.zig");
usingnamespace @import("../xkb.zig");

/// struct wlr_keyboard
pub const Keyboard = extern struct {
    pub const Events = struct {
        /// struct wlr_event_keyboard_key
        pub const Key = extern struct {
            time_msec: u32,
            keycode: u32,
            update_state: bool,
            state: enum_wlr_key_state,
        };
    };

    /// enum wlr_key_state
    pub const enum_wlr_key_state = extern enum(c_int) {
        Released,
        Pressed,
        _,
    };

    /// struct wlr_keyboard_group
    pub const Group = opaque {
        // XXX fill this in
    };

    /// enum wlr_keyboard_led
    pub const LED = struct {
        pub const NumLock: c_int = 1;
        pub const CapsLock: c_int = 2;
        pub const ScrollLock: c_int = 4;
    };

    /// enum wlr_keyboard_modifier
    pub const Modifier = struct {
        pub const Shift: c_int = 1;
        pub const Caps: c_int = 2;
        pub const Ctrl: c_int = 4;
        pub const Alt: c_int = 8;
        pub const Mod2: c_int = 16;
        pub const Mod3: c_int = 32;
        pub const Logo: c_int = 64;
        pub const Mod5: c_int = 128;
    };

    /// struct wlr_keyboard_impl
    pub const Impl = extern struct {
        destroy: ?fn (*Keyboard) callconv(.C) void,
        led_update: ?fn (*Keyboard, u32) callconv(.C) void,
    };

    /// struct wlr_keyboard_modifiers
    pub const Modifiers = extern struct {
        depressed: xkb_mod_mask_t,
        latched: xkb_mod_mask_t,
        locked: xkb_mod_mask_t,
        group: xkb_mod_mask_t,
    };

    extern fn wlr_keyboard_set_keymap(kb: *Keyboard, keymap: ?*struct_xkb_keymap) bool;
    extern fn wlr_keyboard_keymaps_match(km1: ?*struct_xkb_keymap, km2: ?*struct_xkb_keymap) bool;
    extern fn wlr_keyboard_set_repeat_info(kb: *Keyboard, rate: i32, delay: i32) void;
    extern fn wlr_keyboard_led_update(keyboard: *Keyboard, leds: u32) void;
    extern fn wlr_keyboard_get_modifiers(keyboard: *Keyboard) u32;
    extern fn wlr_keyboard_init(keyboard: *Keyboard, impl: *const Impl) void;
    extern fn wlr_keyboard_destroy(keyboard: *Keyboard) void;
    extern fn wlr_keyboard_notify_key(keyboard: *Keyboard, event: *Keyboard.Events.Key) void;
    extern fn wlr_keyboard_notify_modifiers(keyboard: *Keyboard, mods_depressed: u32, mods_latched: u32, mods_locked: u32, group: u32) void;

    impl: ?*const Impl,
    group: ?*Group,
    keymap_string: [*c]u8,
    keymap_size: usize,
    keymap: ?*struct_xkb_keymap,
    xkb_state: ?*struct_xkb_state,
    led_indexes: [3]xkb_led_index_t,
    mod_indexes: [8]xkb_mod_index_t,
    keycodes: [32]u32,
    num_keycodes: usize,
    modifiers: Modifiers,
    repeat_info: extern struct {
        rate: i32,
        delay: i32,
    },
    events: extern struct {
        key: wayland.Signal(*Events.Key),
        modifiers: wayland.Signal(*Keyboard),
        keymap: wayland.Signal(*Keyboard),
        repeat_info: wayland.Signal(*Keyboard),
        destroy: wayland.Signal(*Keyboard),
    },
    data: ?*c_void,

    pub const setKeymap = wlr_keyboard_set_keymap;
    pub const keymapsMatch = wlr_keyboard_keymaps_match;
    pub const setRepeatInfo = wlr_keyboard_set_repeat_info;
    pub const ledUpdate = wlr_keyboard_led_update;
    pub const getModifiers = wlr_keyboard_get_modifiers;

    pub const init = wlr_keyboard_init;
    pub const deinit = wlr_keyboard_destroy;
    pub const notify_key = wlr_keyboard_notify_key;
    pub const notify_modifiers = wlr_keyboard_notify_modifiers;
};
