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

    ///  wlr_keyboard_led
    pub const LED = extern enum(c_int) {
        WLR_LED_NUM_LOCK = 1,
        WLR_LED_CAPS_LOCK = 2,
        WLR_LED_SCROLL_LOCK = 4,
        _,
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
    pub const Impl = opaque {};

    /// struct wlr_keyboard_modifiers
    pub const Modifiers = extern struct {
        depressed: xkb_mod_mask_t,
        latched: xkb_mod_mask_t,
        locked: xkb_mod_mask_t,
        group: xkb_mod_mask_t,
    };

    pub extern fn wlr_keyboard_set_keymap(kb: [*c]Keyboard, keymap: ?*struct_xkb_keymap) bool;
    pub extern fn wlr_keyboard_keymaps_match(km1: ?*struct_xkb_keymap, km2: ?*struct_xkb_keymap) bool;
    pub extern fn wlr_keyboard_set_repeat_info(kb: [*c]Keyboard, rate: i32, delay: i32) void;
    pub extern fn wlr_keyboard_led_update(keyboard: [*c]Keyboard, leds: u32) void;
    pub extern fn wlr_keyboard_get_modifiers(keyboard: [*c]Keyboard) u32;

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
};
