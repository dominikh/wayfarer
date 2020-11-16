pub const pixman_bool_t = c_int;
pub const pixman_fixed_32_32_t = i64;
pub const pixman_fixed_48_16_t = pixman_fixed_32_32_t;
pub const pixman_fixed_1_31_t = u32;
pub const pixman_fixed_1_16_t = u32;
pub const pixman_fixed_16_16_t = i32;
pub const pixman_fixed_t = pixman_fixed_16_16_t;
pub const struct_pixman_color = extern struct {
    red: u16,
    green: u16,
    blue: u16,
    alpha: u16,
};
pub const pixman_color_t = struct_pixman_color;
pub const struct_pixman_point_fixed = extern struct {
    x: pixman_fixed_t,
    y: pixman_fixed_t,
};
pub const pixman_point_fixed_t = struct_pixman_point_fixed;
pub const struct_pixman_line_fixed = extern struct {
    p1: pixman_point_fixed_t,
    p2: pixman_point_fixed_t,
};
pub const pixman_line_fixed_t = struct_pixman_line_fixed;
pub const struct_pixman_vector = extern struct {
    vector: [3]pixman_fixed_t,
};
pub const pixman_vector_t = struct_pixman_vector;
pub const struct_pixman_transform = extern struct {
    matrix: [3][3]pixman_fixed_t,
};
pub const pixman_transform_t = struct_pixman_transform;
pub const struct_pixman_box16 = extern struct {
    x1: i16,
    y1: i16,
    x2: i16,
    y2: i16,
};
pub const union_pixman_image = opaque {};
pub const pixman_image_t = union_pixman_image;
pub extern fn pixman_transform_init_identity(matrix: [*c]struct_pixman_transform) void;
pub extern fn pixman_transform_point_3d(transform: [*c]const struct_pixman_transform, vector: [*c]struct_pixman_vector) pixman_bool_t;
pub extern fn pixman_transform_point(transform: [*c]const struct_pixman_transform, vector: [*c]struct_pixman_vector) pixman_bool_t;
pub extern fn pixman_transform_multiply(dst: [*c]struct_pixman_transform, l: [*c]const struct_pixman_transform, r: [*c]const struct_pixman_transform) pixman_bool_t;
pub extern fn pixman_transform_init_scale(t: [*c]struct_pixman_transform, sx: pixman_fixed_t, sy: pixman_fixed_t) void;
pub extern fn pixman_transform_scale(forward: [*c]struct_pixman_transform, reverse: [*c]struct_pixman_transform, sx: pixman_fixed_t, sy: pixman_fixed_t) pixman_bool_t;
pub extern fn pixman_transform_init_rotate(t: [*c]struct_pixman_transform, cos: pixman_fixed_t, sin: pixman_fixed_t) void;
pub extern fn pixman_transform_rotate(forward: [*c]struct_pixman_transform, reverse: [*c]struct_pixman_transform, c: pixman_fixed_t, s: pixman_fixed_t) pixman_bool_t;
pub extern fn pixman_transform_init_translate(t: [*c]struct_pixman_transform, tx: pixman_fixed_t, ty: pixman_fixed_t) void;
pub extern fn pixman_transform_translate(forward: [*c]struct_pixman_transform, reverse: [*c]struct_pixman_transform, tx: pixman_fixed_t, ty: pixman_fixed_t) pixman_bool_t;
pub extern fn pixman_transform_bounds(matrix: [*c]const struct_pixman_transform, b: [*c]struct_pixman_box16) pixman_bool_t;
pub extern fn pixman_transform_invert(dst: [*c]struct_pixman_transform, src: [*c]const struct_pixman_transform) pixman_bool_t;
pub extern fn pixman_transform_is_identity(t: [*c]const struct_pixman_transform) pixman_bool_t;
pub extern fn pixman_transform_is_scale(t: [*c]const struct_pixman_transform) pixman_bool_t;
pub extern fn pixman_transform_is_int_translate(t: [*c]const struct_pixman_transform) pixman_bool_t;
pub extern fn pixman_transform_is_inverse(a: [*c]const struct_pixman_transform, b: [*c]const struct_pixman_transform) pixman_bool_t;
pub const struct_pixman_f_transform = extern struct {
    m: [3][3]f64,
};
pub const pixman_f_transform_t = struct_pixman_f_transform;
pub const struct_pixman_f_vector = extern struct {
    v: [3]f64,
};
pub const pixman_f_vector_t = struct_pixman_f_vector;
pub extern fn pixman_transform_from_pixman_f_transform(t: [*c]struct_pixman_transform, ft: [*c]const struct_pixman_f_transform) pixman_bool_t;
pub extern fn pixman_f_transform_from_pixman_transform(ft: [*c]struct_pixman_f_transform, t: [*c]const struct_pixman_transform) void;
pub extern fn pixman_f_transform_invert(dst: [*c]struct_pixman_f_transform, src: [*c]const struct_pixman_f_transform) pixman_bool_t;
pub extern fn pixman_f_transform_point(t: [*c]const struct_pixman_f_transform, v: [*c]struct_pixman_f_vector) pixman_bool_t;
pub extern fn pixman_f_transform_point_3d(t: [*c]const struct_pixman_f_transform, v: [*c]struct_pixman_f_vector) void;
pub extern fn pixman_f_transform_multiply(dst: [*c]struct_pixman_f_transform, l: [*c]const struct_pixman_f_transform, r: [*c]const struct_pixman_f_transform) void;
pub extern fn pixman_f_transform_init_scale(t: [*c]struct_pixman_f_transform, sx: f64, sy: f64) void;
pub extern fn pixman_f_transform_scale(forward: [*c]struct_pixman_f_transform, reverse: [*c]struct_pixman_f_transform, sx: f64, sy: f64) pixman_bool_t;
pub extern fn pixman_f_transform_init_rotate(t: [*c]struct_pixman_f_transform, cos: f64, sin: f64) void;
pub extern fn pixman_f_transform_rotate(forward: [*c]struct_pixman_f_transform, reverse: [*c]struct_pixman_f_transform, c: f64, s: f64) pixman_bool_t;
pub extern fn pixman_f_transform_init_translate(t: [*c]struct_pixman_f_transform, tx: f64, ty: f64) void;
pub extern fn pixman_f_transform_translate(forward: [*c]struct_pixman_f_transform, reverse: [*c]struct_pixman_f_transform, tx: f64, ty: f64) pixman_bool_t;
pub extern fn pixman_f_transform_bounds(t: [*c]const struct_pixman_f_transform, b: [*c]struct_pixman_box16) pixman_bool_t;
pub extern fn pixman_f_transform_init_identity(t: [*c]struct_pixman_f_transform) void;
pub const pixman_repeat_t = extern enum(c_int) {
    PIXMAN_REPEAT_NONE,
    PIXMAN_REPEAT_NORMAL,
    PIXMAN_REPEAT_PAD,
    PIXMAN_REPEAT_REFLECT,
    _,
};
pub const pixman_filter_t = extern enum(c_int) {
    PIXMAN_FILTER_FAST,
    PIXMAN_FILTER_GOOD,
    PIXMAN_FILTER_BEST,
    PIXMAN_FILTER_NEAREST,
    PIXMAN_FILTER_BILINEAR,
    PIXMAN_FILTER_CONVOLUTION,
    PIXMAN_FILTER_SEPARABLE_CONVOLUTION,
    _,
};
pub const pixman_op_t = extern enum(c_int) {
    PIXMAN_OP_CLEAR = 0,
    PIXMAN_OP_SRC = 1,
    PIXMAN_OP_DST = 2,
    PIXMAN_OP_OVER = 3,
    PIXMAN_OP_OVER_REVERSE = 4,
    PIXMAN_OP_IN = 5,
    PIXMAN_OP_IN_REVERSE = 6,
    PIXMAN_OP_OUT = 7,
    PIXMAN_OP_OUT_REVERSE = 8,
    PIXMAN_OP_ATOP = 9,
    PIXMAN_OP_ATOP_REVERSE = 10,
    PIXMAN_OP_XOR = 11,
    PIXMAN_OP_ADD = 12,
    PIXMAN_OP_SATURATE = 13,
    PIXMAN_OP_DISJOINT_CLEAR = 16,
    PIXMAN_OP_DISJOINT_SRC = 17,
    PIXMAN_OP_DISJOINT_DST = 18,
    PIXMAN_OP_DISJOINT_OVER = 19,
    PIXMAN_OP_DISJOINT_OVER_REVERSE = 20,
    PIXMAN_OP_DISJOINT_IN = 21,
    PIXMAN_OP_DISJOINT_IN_REVERSE = 22,
    PIXMAN_OP_DISJOINT_OUT = 23,
    PIXMAN_OP_DISJOINT_OUT_REVERSE = 24,
    PIXMAN_OP_DISJOINT_ATOP = 25,
    PIXMAN_OP_DISJOINT_ATOP_REVERSE = 26,
    PIXMAN_OP_DISJOINT_XOR = 27,
    PIXMAN_OP_CONJOINT_CLEAR = 32,
    PIXMAN_OP_CONJOINT_SRC = 33,
    PIXMAN_OP_CONJOINT_DST = 34,
    PIXMAN_OP_CONJOINT_OVER = 35,
    PIXMAN_OP_CONJOINT_OVER_REVERSE = 36,
    PIXMAN_OP_CONJOINT_IN = 37,
    PIXMAN_OP_CONJOINT_IN_REVERSE = 38,
    PIXMAN_OP_CONJOINT_OUT = 39,
    PIXMAN_OP_CONJOINT_OUT_REVERSE = 40,
    PIXMAN_OP_CONJOINT_ATOP = 41,
    PIXMAN_OP_CONJOINT_ATOP_REVERSE = 42,
    PIXMAN_OP_CONJOINT_XOR = 43,
    PIXMAN_OP_MULTIPLY = 48,
    PIXMAN_OP_SCREEN = 49,
    PIXMAN_OP_OVERLAY = 50,
    PIXMAN_OP_DARKEN = 51,
    PIXMAN_OP_LIGHTEN = 52,
    PIXMAN_OP_COLOR_DODGE = 53,
    PIXMAN_OP_COLOR_BURN = 54,
    PIXMAN_OP_HARD_LIGHT = 55,
    PIXMAN_OP_SOFT_LIGHT = 56,
    PIXMAN_OP_DIFFERENCE = 57,
    PIXMAN_OP_EXCLUSION = 58,
    PIXMAN_OP_HSL_HUE = 59,
    PIXMAN_OP_HSL_SATURATION = 60,
    PIXMAN_OP_HSL_COLOR = 61,
    PIXMAN_OP_HSL_LUMINOSITY = 62,
    _,
};
pub const struct_pixman_region16_data = extern struct {
    size: c_long,
    numRects: c_long,
};
pub const pixman_region16_data_t = struct_pixman_region16_data;
pub const pixman_box16_t = struct_pixman_box16;
pub const struct_pixman_rectangle16 = extern struct {
    x: i16,
    y: i16,
    width: u16,
    height: u16,
};
pub const pixman_rectangle16_t = struct_pixman_rectangle16;
pub const struct_pixman_region16 = extern struct {
    extents: pixman_box16_t,
    data: [*c]pixman_region16_data_t,
};
pub const pixman_region16_t = struct_pixman_region16;
pub const pixman_region_overlap_t = extern enum(c_int) {
    PIXMAN_REGION_OUT,
    PIXMAN_REGION_IN,
    PIXMAN_REGION_PART,
    _,
};
pub extern fn pixman_region_set_static_pointers(empty_box: [*c]pixman_box16_t, empty_data: [*c]pixman_region16_data_t, broken_data: [*c]pixman_region16_data_t) void;
pub extern fn pixman_region_init(region: [*c]pixman_region16_t) void;
pub extern fn pixman_region_init_rect(region: [*c]pixman_region16_t, x: c_int, y: c_int, width: c_uint, height: c_uint) void;
pub extern fn pixman_region_init_rects(region: [*c]pixman_region16_t, boxes: [*c]const pixman_box16_t, count: c_int) pixman_bool_t;
pub extern fn pixman_region_init_with_extents(region: [*c]pixman_region16_t, extents: [*c]pixman_box16_t) void;
pub extern fn pixman_region_init_from_image(region: [*c]pixman_region16_t, image: ?*pixman_image_t) void;
pub extern fn pixman_region_fini(region: [*c]pixman_region16_t) void;
pub extern fn pixman_region_translate(region: [*c]pixman_region16_t, x: c_int, y: c_int) void;
pub extern fn pixman_region_copy(dest: [*c]pixman_region16_t, source: [*c]pixman_region16_t) pixman_bool_t;
pub extern fn pixman_region_intersect(new_reg: [*c]pixman_region16_t, reg1: [*c]pixman_region16_t, reg2: [*c]pixman_region16_t) pixman_bool_t;
pub extern fn pixman_region_union(new_reg: [*c]pixman_region16_t, reg1: [*c]pixman_region16_t, reg2: [*c]pixman_region16_t) pixman_bool_t;
pub extern fn pixman_region_union_rect(dest: [*c]pixman_region16_t, source: [*c]pixman_region16_t, x: c_int, y: c_int, width: c_uint, height: c_uint) pixman_bool_t;
pub extern fn pixman_region_intersect_rect(dest: [*c]pixman_region16_t, source: [*c]pixman_region16_t, x: c_int, y: c_int, width: c_uint, height: c_uint) pixman_bool_t;
pub extern fn pixman_region_subtract(reg_d: [*c]pixman_region16_t, reg_m: [*c]pixman_region16_t, reg_s: [*c]pixman_region16_t) pixman_bool_t;
pub extern fn pixman_region_inverse(new_reg: [*c]pixman_region16_t, reg1: [*c]pixman_region16_t, inv_rect: [*c]pixman_box16_t) pixman_bool_t;
pub extern fn pixman_region_contains_point(region: [*c]pixman_region16_t, x: c_int, y: c_int, box: [*c]pixman_box16_t) pixman_bool_t;
pub extern fn pixman_region_contains_rectangle(region: [*c]pixman_region16_t, prect: [*c]pixman_box16_t) pixman_region_overlap_t;
pub extern fn pixman_region_not_empty(region: [*c]pixman_region16_t) pixman_bool_t;
pub extern fn pixman_region_extents(region: [*c]pixman_region16_t) [*c]pixman_box16_t;
pub extern fn pixman_region_n_rects(region: [*c]pixman_region16_t) c_int;
pub extern fn pixman_region_rectangles(region: [*c]pixman_region16_t, n_rects: [*c]c_int) [*c]pixman_box16_t;
pub extern fn pixman_region_equal(region1: [*c]pixman_region16_t, region2: [*c]pixman_region16_t) pixman_bool_t;
pub extern fn pixman_region_selfcheck(region: [*c]pixman_region16_t) pixman_bool_t;
pub extern fn pixman_region_reset(region: [*c]pixman_region16_t, box: [*c]pixman_box16_t) void;
pub extern fn pixman_region_clear(region: [*c]pixman_region16_t) void;
pub const struct_pixman_region32_data = extern struct {
    size: c_long,
    numRects: c_long,
};
pub const pixman_region32_data_t = struct_pixman_region32_data;
pub const struct_pixman_box32 = extern struct {
    x1: i32,
    y1: i32,
    x2: i32,
    y2: i32,
};
pub const pixman_box32_t = struct_pixman_box32;
pub const struct_pixman_rectangle32 = extern struct {
    x: i32,
    y: i32,
    width: u32,
    height: u32,
};
pub const pixman_rectangle32_t = struct_pixman_rectangle32;
pub const struct_pixman_region32 = extern struct {
    extents: pixman_box32_t,
    data: [*c]pixman_region32_data_t,
};
pub const pixman_region32_t = struct_pixman_region32;
pub extern fn pixman_region32_init(region: [*c]pixman_region32_t) void;
pub extern fn pixman_region32_init_rect(region: [*c]pixman_region32_t, x: c_int, y: c_int, width: c_uint, height: c_uint) void;
pub extern fn pixman_region32_init_rects(region: [*c]pixman_region32_t, boxes: [*c]const pixman_box32_t, count: c_int) pixman_bool_t;
pub extern fn pixman_region32_init_with_extents(region: [*c]pixman_region32_t, extents: [*c]pixman_box32_t) void;
pub extern fn pixman_region32_init_from_image(region: [*c]pixman_region32_t, image: ?*pixman_image_t) void;
pub extern fn pixman_region32_fini(region: [*c]pixman_region32_t) void;
pub extern fn pixman_region32_translate(region: [*c]pixman_region32_t, x: c_int, y: c_int) void;
pub extern fn pixman_region32_copy(dest: [*c]pixman_region32_t, source: [*c]pixman_region32_t) pixman_bool_t;
pub extern fn pixman_region32_intersect(new_reg: [*c]pixman_region32_t, reg1: [*c]pixman_region32_t, reg2: [*c]pixman_region32_t) pixman_bool_t;
pub extern fn pixman_region32_union(new_reg: [*c]pixman_region32_t, reg1: [*c]pixman_region32_t, reg2: [*c]pixman_region32_t) pixman_bool_t;
pub extern fn pixman_region32_intersect_rect(dest: [*c]pixman_region32_t, source: [*c]pixman_region32_t, x: c_int, y: c_int, width: c_uint, height: c_uint) pixman_bool_t;
pub extern fn pixman_region32_union_rect(dest: [*c]pixman_region32_t, source: [*c]pixman_region32_t, x: c_int, y: c_int, width: c_uint, height: c_uint) pixman_bool_t;
pub extern fn pixman_region32_subtract(reg_d: [*c]pixman_region32_t, reg_m: [*c]pixman_region32_t, reg_s: [*c]pixman_region32_t) pixman_bool_t;
pub extern fn pixman_region32_inverse(new_reg: [*c]pixman_region32_t, reg1: [*c]pixman_region32_t, inv_rect: [*c]pixman_box32_t) pixman_bool_t;
pub extern fn pixman_region32_contains_point(region: [*c]pixman_region32_t, x: c_int, y: c_int, box: [*c]pixman_box32_t) pixman_bool_t;
pub extern fn pixman_region32_contains_rectangle(region: [*c]pixman_region32_t, prect: [*c]pixman_box32_t) pixman_region_overlap_t;
pub extern fn pixman_region32_not_empty(region: [*c]pixman_region32_t) pixman_bool_t;
pub extern fn pixman_region32_extents(region: [*c]pixman_region32_t) [*c]pixman_box32_t;
pub extern fn pixman_region32_n_rects(region: [*c]pixman_region32_t) c_int;
pub extern fn pixman_region32_rectangles(region: [*c]pixman_region32_t, n_rects: [*c]c_int) [*c]pixman_box32_t;
pub extern fn pixman_region32_equal(region1: [*c]pixman_region32_t, region2: [*c]pixman_region32_t) pixman_bool_t;
pub extern fn pixman_region32_selfcheck(region: [*c]pixman_region32_t) pixman_bool_t;
pub extern fn pixman_region32_reset(region: [*c]pixman_region32_t, box: [*c]pixman_box32_t) void;
pub extern fn pixman_region32_clear(region: [*c]pixman_region32_t) void;
pub extern fn pixman_blt(src_bits: [*c]u32, dst_bits: [*c]u32, src_stride: c_int, dst_stride: c_int, src_bpp: c_int, dst_bpp: c_int, src_x: c_int, src_y: c_int, dest_x: c_int, dest_y: c_int, width: c_int, height: c_int) pixman_bool_t;
pub extern fn pixman_fill(bits: [*c]u32, stride: c_int, bpp: c_int, x: c_int, y: c_int, width: c_int, height: c_int, _xor: u32) pixman_bool_t;
pub extern fn pixman_version() c_int;
pub extern fn pixman_version_string() [*c]const u8;
pub const struct_pixman_indexed = extern struct {
    color: pixman_bool_t,
    rgba: [256]u32,
    ent: [32768]pixman_index_type,
};
pub const pixman_indexed_t = struct_pixman_indexed;
pub const struct_pixman_gradient_stop = extern struct {
    x: pixman_fixed_t,
    color: pixman_color_t,
};
pub const pixman_gradient_stop_t = struct_pixman_gradient_stop;
pub const pixman_read_memory_func_t = ?fn (?*const c_void, c_int) callconv(.C) u32;
pub const pixman_write_memory_func_t = ?fn (?*c_void, u32, c_int) callconv(.C) void;
pub const pixman_image_destroy_func_t = ?fn (?*pixman_image_t, ?*c_void) callconv(.C) void;
pub const pixman_index_type = u8;
pub const pixman_format_code_t = extern enum(c_int) {
    PIXMAN_rgba_float = 281756740,
    PIXMAN_rgb_float = 214631492,
    PIXMAN_a8r8g8b8 = 537036936,
    PIXMAN_x8r8g8b8 = 537004168,
    PIXMAN_a8b8g8r8 = 537102472,
    PIXMAN_x8b8g8r8 = 537069704,
    PIXMAN_b8g8r8a8 = 537430152,
    PIXMAN_b8g8r8x8 = 537397384,
    PIXMAN_r8g8b8a8 = 537495688,
    PIXMAN_r8g8b8x8 = 537462920,
    PIXMAN_x14r6g6b6 = 537003622,
    PIXMAN_x2r10g10b10 = 537004714,
    PIXMAN_a2r10g10b10 = 537012906,
    PIXMAN_x2b10g10r10 = 537070250,
    PIXMAN_a2b10g10r10 = 537078442,
    PIXMAN_a8r8g8b8_sRGB = 537561224,
    PIXMAN_r8g8b8 = 402786440,
    PIXMAN_b8g8r8 = 402851976,
    PIXMAN_r5g6b5 = 268567909,
    PIXMAN_b5g6r5 = 268633445,
    PIXMAN_a1r5g5b5 = 268571989,
    PIXMAN_x1r5g5b5 = 268567893,
    PIXMAN_a1b5g5r5 = 268637525,
    PIXMAN_x1b5g5r5 = 268633429,
    PIXMAN_a4r4g4b4 = 268584004,
    PIXMAN_x4r4g4b4 = 268567620,
    PIXMAN_a4b4g4r4 = 268649540,
    PIXMAN_x4b4g4r4 = 268633156,
    PIXMAN_a8 = 134316032,
    PIXMAN_r3g3b2 = 134349618,
    PIXMAN_b2g3r3 = 134415154,
    PIXMAN_a2r2g2b2 = 134357538,
    PIXMAN_a2b2g2r2 = 134423074,
    PIXMAN_c8 = 134479872,
    PIXMAN_g8 = 134545408,
    PIXMAN_x4a4 = 134299648,
    PIXMAN_x4c4 = 134479872,
    PIXMAN_x4g4 = 134545408,
    PIXMAN_a4 = 67190784,
    PIXMAN_r1g2b1 = 67240225,
    PIXMAN_b1g2r1 = 67305761,
    PIXMAN_a1r1g1b1 = 67244305,
    PIXMAN_a1b1g1r1 = 67309841,
    PIXMAN_c4 = 67371008,
    PIXMAN_g4 = 67436544,
    PIXMAN_a1 = 16846848,
    PIXMAN_g1 = 17104896,
    PIXMAN_yuy2 = 268828672,
    PIXMAN_yv12 = 201785344,
    _,
};
pub extern fn pixman_format_supported_destination(format: pixman_format_code_t) pixman_bool_t;
pub extern fn pixman_format_supported_source(format: pixman_format_code_t) pixman_bool_t;
pub extern fn pixman_image_create_solid_fill(color: [*c]const pixman_color_t) ?*pixman_image_t;
pub extern fn pixman_image_create_linear_gradient(p1: [*c]const pixman_point_fixed_t, p2: [*c]const pixman_point_fixed_t, stops: [*c]const pixman_gradient_stop_t, n_stops: c_int) ?*pixman_image_t;
pub extern fn pixman_image_create_radial_gradient(inner: [*c]const pixman_point_fixed_t, outer: [*c]const pixman_point_fixed_t, inner_radius: pixman_fixed_t, outer_radius: pixman_fixed_t, stops: [*c]const pixman_gradient_stop_t, n_stops: c_int) ?*pixman_image_t;
pub extern fn pixman_image_create_conical_gradient(center: [*c]const pixman_point_fixed_t, angle: pixman_fixed_t, stops: [*c]const pixman_gradient_stop_t, n_stops: c_int) ?*pixman_image_t;
pub extern fn pixman_image_create_bits(format: pixman_format_code_t, width: c_int, height: c_int, bits: [*c]u32, rowstride_bytes: c_int) ?*pixman_image_t;
pub extern fn pixman_image_create_bits_no_clear(format: pixman_format_code_t, width: c_int, height: c_int, bits: [*c]u32, rowstride_bytes: c_int) ?*pixman_image_t;
pub extern fn pixman_image_ref(image: ?*pixman_image_t) ?*pixman_image_t;
pub extern fn pixman_image_unref(image: ?*pixman_image_t) pixman_bool_t;
pub extern fn pixman_image_set_destroy_function(image: ?*pixman_image_t, function: pixman_image_destroy_func_t, data: ?*c_void) void;
pub extern fn pixman_image_get_destroy_data(image: ?*pixman_image_t) ?*c_void;
pub extern fn pixman_image_set_clip_region(image: ?*pixman_image_t, region: [*c]pixman_region16_t) pixman_bool_t;
pub extern fn pixman_image_set_clip_region32(image: ?*pixman_image_t, region: [*c]pixman_region32_t) pixman_bool_t;
pub extern fn pixman_image_set_has_client_clip(image: ?*pixman_image_t, clien_clip: pixman_bool_t) void;
pub extern fn pixman_image_set_transform(image: ?*pixman_image_t, transform: [*c]const pixman_transform_t) pixman_bool_t;
pub extern fn pixman_image_set_repeat(image: ?*pixman_image_t, repeat: pixman_repeat_t) void;
pub extern fn pixman_image_set_filter(image: ?*pixman_image_t, filter: pixman_filter_t, filter_params: [*c]const pixman_fixed_t, n_filter_params: c_int) pixman_bool_t;
pub extern fn pixman_image_set_source_clipping(image: ?*pixman_image_t, source_clipping: pixman_bool_t) void;
pub extern fn pixman_image_set_alpha_map(image: ?*pixman_image_t, alpha_map: ?*pixman_image_t, x: i16, y: i16) void;
pub extern fn pixman_image_set_component_alpha(image: ?*pixman_image_t, component_alpha: pixman_bool_t) void;
pub extern fn pixman_image_get_component_alpha(image: ?*pixman_image_t) pixman_bool_t;
pub extern fn pixman_image_set_accessors(image: ?*pixman_image_t, read_func: pixman_read_memory_func_t, write_func: pixman_write_memory_func_t) void;
pub extern fn pixman_image_set_indexed(image: ?*pixman_image_t, indexed: [*c]const pixman_indexed_t) void;
pub extern fn pixman_image_get_data(image: ?*pixman_image_t) [*c]u32;
pub extern fn pixman_image_get_width(image: ?*pixman_image_t) c_int;
pub extern fn pixman_image_get_height(image: ?*pixman_image_t) c_int;
pub extern fn pixman_image_get_stride(image: ?*pixman_image_t) c_int;
pub extern fn pixman_image_get_depth(image: ?*pixman_image_t) c_int;
pub extern fn pixman_image_get_format(image: ?*pixman_image_t) pixman_format_code_t;
pub const pixman_kernel_t = extern enum(c_int) {
    PIXMAN_KERNEL_IMPULSE,
    PIXMAN_KERNEL_BOX,
    PIXMAN_KERNEL_LINEAR,
    PIXMAN_KERNEL_CUBIC,
    PIXMAN_KERNEL_GAUSSIAN,
    PIXMAN_KERNEL_LANCZOS2,
    PIXMAN_KERNEL_LANCZOS3,
    PIXMAN_KERNEL_LANCZOS3_STRETCHED,
    _,
};
pub extern fn pixman_filter_create_separable_convolution(n_values: [*c]c_int, scale_x: pixman_fixed_t, scale_y: pixman_fixed_t, reconstruct_x: pixman_kernel_t, reconstruct_y: pixman_kernel_t, sample_x: pixman_kernel_t, sample_y: pixman_kernel_t, subsample_bits_x: c_int, subsample_bits_y: c_int) [*c]pixman_fixed_t;
pub extern fn pixman_image_fill_rectangles(op: pixman_op_t, image: ?*pixman_image_t, color: [*c]const pixman_color_t, n_rects: c_int, rects: [*c]const pixman_rectangle16_t) pixman_bool_t;
pub extern fn pixman_image_fill_boxes(op: pixman_op_t, dest: ?*pixman_image_t, color: [*c]const pixman_color_t, n_boxes: c_int, boxes: [*c]const pixman_box32_t) pixman_bool_t;
pub extern fn pixman_compute_composite_region(region: [*c]pixman_region16_t, src_image: ?*pixman_image_t, mask_image: ?*pixman_image_t, dest_image: ?*pixman_image_t, src_x: i16, src_y: i16, mask_x: i16, mask_y: i16, dest_x: i16, dest_y: i16, width: u16, height: u16) pixman_bool_t;
pub extern fn pixman_image_composite(op: pixman_op_t, src: ?*pixman_image_t, mask: ?*pixman_image_t, dest: ?*pixman_image_t, src_x: i16, src_y: i16, mask_x: i16, mask_y: i16, dest_x: i16, dest_y: i16, width: u16, height: u16) void;
pub extern fn pixman_image_composite32(op: pixman_op_t, src: ?*pixman_image_t, mask: ?*pixman_image_t, dest: ?*pixman_image_t, src_x: i32, src_y: i32, mask_x: i32, mask_y: i32, dest_x: i32, dest_y: i32, width: i32, height: i32) void;
pub extern fn pixman_disable_out_of_bounds_workaround() void;
pub const struct_pixman_glyph_cache_t = opaque {};
pub const pixman_glyph_cache_t = struct_pixman_glyph_cache_t;
pub const pixman_glyph_t = extern struct {
    x: c_int,
    y: c_int,
    glyph: ?*const c_void,
};
pub extern fn pixman_glyph_cache_create() ?*pixman_glyph_cache_t;
pub extern fn pixman_glyph_cache_destroy(cache: ?*pixman_glyph_cache_t) void;
pub extern fn pixman_glyph_cache_freeze(cache: ?*pixman_glyph_cache_t) void;
pub extern fn pixman_glyph_cache_thaw(cache: ?*pixman_glyph_cache_t) void;
pub extern fn pixman_glyph_cache_lookup(cache: ?*pixman_glyph_cache_t, font_key: ?*c_void, glyph_key: ?*c_void) ?*const c_void;
pub extern fn pixman_glyph_cache_insert(cache: ?*pixman_glyph_cache_t, font_key: ?*c_void, glyph_key: ?*c_void, origin_x: c_int, origin_y: c_int, glyph_image: ?*pixman_image_t) ?*const c_void;
pub extern fn pixman_glyph_cache_remove(cache: ?*pixman_glyph_cache_t, font_key: ?*c_void, glyph_key: ?*c_void) void;
pub extern fn pixman_glyph_get_extents(cache: ?*pixman_glyph_cache_t, n_glyphs: c_int, glyphs: [*c]pixman_glyph_t, extents: [*c]pixman_box32_t) void;
pub extern fn pixman_glyph_get_mask_format(cache: ?*pixman_glyph_cache_t, n_glyphs: c_int, glyphs: [*c]const pixman_glyph_t) pixman_format_code_t;
pub extern fn pixman_composite_glyphs(op: pixman_op_t, src: ?*pixman_image_t, dest: ?*pixman_image_t, mask_format: pixman_format_code_t, src_x: i32, src_y: i32, mask_x: i32, mask_y: i32, dest_x: i32, dest_y: i32, width: i32, height: i32, cache: ?*pixman_glyph_cache_t, n_glyphs: c_int, glyphs: [*c]const pixman_glyph_t) void;
pub extern fn pixman_composite_glyphs_no_mask(op: pixman_op_t, src: ?*pixman_image_t, dest: ?*pixman_image_t, src_x: i32, src_y: i32, dest_x: i32, dest_y: i32, cache: ?*pixman_glyph_cache_t, n_glyphs: c_int, glyphs: [*c]const pixman_glyph_t) void;
pub const struct_pixman_edge = extern struct {
    x: pixman_fixed_t,
    e: pixman_fixed_t,
    stepx: pixman_fixed_t,
    signdx: pixman_fixed_t,
    dy: pixman_fixed_t,
    dx: pixman_fixed_t,
    stepx_small: pixman_fixed_t,
    stepx_big: pixman_fixed_t,
    dx_small: pixman_fixed_t,
    dx_big: pixman_fixed_t,
};
pub const pixman_edge_t = struct_pixman_edge;
pub const struct_pixman_trapezoid = extern struct {
    top: pixman_fixed_t,
    bottom: pixman_fixed_t,
    left: pixman_line_fixed_t,
    right: pixman_line_fixed_t,
};
pub const pixman_trapezoid_t = struct_pixman_trapezoid;
pub const struct_pixman_trap = extern struct {
    top: pixman_span_fix_t,
    bot: pixman_span_fix_t,
};
pub const pixman_trap_t = struct_pixman_trap;
pub const struct_pixman_span_fix = extern struct {
    l: pixman_fixed_t,
    r: pixman_fixed_t,
    y: pixman_fixed_t,
};
pub const pixman_span_fix_t = struct_pixman_span_fix;
pub const struct_pixman_triangle = extern struct {
    p1: pixman_point_fixed_t,
    p2: pixman_point_fixed_t,
    p3: pixman_point_fixed_t,
};
pub const pixman_triangle_t = struct_pixman_triangle;
pub extern fn pixman_sample_ceil_y(y: pixman_fixed_t, bpp: c_int) pixman_fixed_t;
pub extern fn pixman_sample_floor_y(y: pixman_fixed_t, bpp: c_int) pixman_fixed_t;
pub extern fn pixman_edge_step(e: [*c]pixman_edge_t, n: c_int) void;
pub extern fn pixman_edge_init(e: [*c]pixman_edge_t, bpp: c_int, y_start: pixman_fixed_t, x_top: pixman_fixed_t, y_top: pixman_fixed_t, x_bot: pixman_fixed_t, y_bot: pixman_fixed_t) void;
pub extern fn pixman_line_fixed_edge_init(e: [*c]pixman_edge_t, bpp: c_int, y: pixman_fixed_t, line: [*c]const pixman_line_fixed_t, x_off: c_int, y_off: c_int) void;
pub extern fn pixman_rasterize_edges(image: ?*pixman_image_t, l: [*c]pixman_edge_t, r: [*c]pixman_edge_t, t: pixman_fixed_t, b: pixman_fixed_t) void;
pub extern fn pixman_add_traps(image: ?*pixman_image_t, x_off: i16, y_off: i16, ntrap: c_int, traps: [*c]const pixman_trap_t) void;
pub extern fn pixman_add_trapezoids(image: ?*pixman_image_t, x_off: i16, y_off: c_int, ntraps: c_int, traps: [*c]const pixman_trapezoid_t) void;
pub extern fn pixman_rasterize_trapezoid(image: ?*pixman_image_t, trap: [*c]const pixman_trapezoid_t, x_off: c_int, y_off: c_int) void;
pub extern fn pixman_composite_trapezoids(op: pixman_op_t, src: ?*pixman_image_t, dst: ?*pixman_image_t, mask_format: pixman_format_code_t, x_src: c_int, y_src: c_int, x_dst: c_int, y_dst: c_int, n_traps: c_int, traps: [*c]const pixman_trapezoid_t) void;
pub extern fn pixman_composite_triangles(op: pixman_op_t, src: ?*pixman_image_t, dst: ?*pixman_image_t, mask_format: pixman_format_code_t, x_src: c_int, y_src: c_int, x_dst: c_int, y_dst: c_int, n_tris: c_int, tris: [*c]const pixman_triangle_t) void;
pub extern fn pixman_add_triangles(image: ?*pixman_image_t, x_off: i32, y_off: i32, n_tris: c_int, tris: [*c]const pixman_triangle_t) void;

pub const PIXMAN_VERSION_MAJOR = 0;
pub const PIXMAN_VERSION_MINOR = 38;
pub const PIXMAN_VERSION_MICRO = 4;
pub const PIXMAN_VERSION_STRING = "0.38.4";
pub inline fn PIXMAN_VERSION_ENCODE(major_1: anytype, minor_2: anytype, micro: anytype) @TypeOf(((major_1 * 10000) + (minor_2 * 100)) + (micro * 1)) {
    return ((major_1 * 10000) + (minor_2 * 100)) + (micro * 1);
}
pub const PIXMAN_VERSION = PIXMAN_VERSION_ENCODE(PIXMAN_VERSION_MAJOR, PIXMAN_VERSION_MINOR, PIXMAN_VERSION_MICRO);
pub const pixman_fixed_e = (@import("std").meta.cast(pixman_fixed_t, 1));
pub const pixman_fixed_1 = pixman_int_to_fixed(1);
pub const pixman_fixed_1_minus_e = pixman_fixed_1 - pixman_fixed_e;
pub const pixman_fixed_minus_1 = pixman_int_to_fixed(-1);
pub inline fn pixman_fixed_to_int(f: anytype) @TypeOf((@import("std").meta.cast(c_int, f >> 16))) {
    return (@import("std").meta.cast(c_int, f >> 16));
}
pub inline fn pixman_int_to_fixed(i: anytype) @TypeOf((@import("std").meta.cast(pixman_fixed_t, i << 16))) {
    return (@import("std").meta.cast(pixman_fixed_t, i << 16));
}
pub inline fn pixman_fixed_to_double(f: anytype) @TypeOf((@import("std").meta.cast(f64, f / (@import("std").meta.cast(f64, pixman_fixed_1))))) {
    return (@import("std").meta.cast(f64, f / (@import("std").meta.cast(f64, pixman_fixed_1))));
}
pub inline fn pixman_double_to_fixed(d: anytype) @TypeOf((@import("std").meta.cast(pixman_fixed_t, d * 65536.0))) {
    return (@import("std").meta.cast(pixman_fixed_t, d * 65536.0));
}
pub inline fn pixman_fixed_frac(f: anytype) @TypeOf(f & pixman_fixed_1_minus_e) {
    return f & pixman_fixed_1_minus_e;
}
pub inline fn pixman_fixed_floor(f: anytype) @TypeOf(f & ~pixman_fixed_1_minus_e) {
    return f & ~pixman_fixed_1_minus_e;
}
pub inline fn pixman_fixed_ceil(f: anytype) @TypeOf(pixman_fixed_floor(f + pixman_fixed_1_minus_e)) {
    return pixman_fixed_floor(f + pixman_fixed_1_minus_e);
}
pub inline fn pixman_fixed_fraction(f: anytype) @TypeOf(f & pixman_fixed_1_minus_e) {
    return f & pixman_fixed_1_minus_e;
}
pub inline fn pixman_fixed_mod_2(f: anytype) @TypeOf(f & (pixman_fixed1 | pixman_fixed_1_minus_e)) {
    return f & (pixman_fixed1 | pixman_fixed_1_minus_e);
}
pub const pixman_max_fixed_48_16 = (@import("std").meta.cast(pixman_fixed_48_16_t, 0x7fffffff));
pub const pixman_min_fixed_48_16 = -(@import("std").meta.cast(pixman_fixed_48_16_t, 1 << 31));
pub const PIXMAN_MAX_INDEXED = 256;
pub inline fn PIXMAN_FORMAT(bpp: anytype, type_1: anytype, a: anytype, r: anytype, g: anytype, b: anytype) @TypeOf((((((bpp << 24) | (type_1 << 16)) | (a << 12)) | (r << 8)) | (g << 4)) | b) {
    return (((((bpp << 24) | (type_1 << 16)) | (a << 12)) | (r << 8)) | (g << 4)) | b;
}
pub inline fn PIXMAN_FORMAT_BYTE(bpp: anytype, type_1: anytype, a: anytype, r: anytype, g: anytype, b: anytype) @TypeOf((((((((bpp >> 3) << 24) | (3 << 22)) | (type_1 << 16)) | ((a >> 3) << 12)) | ((r >> 3) << 8)) | ((g >> 3) << 4)) | (b >> 3)) {
    return (((((((bpp >> 3) << 24) | (3 << 22)) | (type_1 << 16)) | ((a >> 3) << 12)) | ((r >> 3) << 8)) | ((g >> 3) << 4)) | (b >> 3);
}
pub inline fn PIXMAN_FORMAT_RESHIFT(val: anytype, ofs: anytype, num: anytype) @TypeOf(((val >> ofs) & ((1 << num) - 1)) << ((val >> 22) & 3)) {
    return ((val >> ofs) & ((1 << num) - 1)) << ((val >> 22) & 3);
}
pub inline fn PIXMAN_FORMAT_BPP(f: anytype) @TypeOf(PIXMAN_FORMAT_RESHIFT(f, 24, 8)) {
    return PIXMAN_FORMAT_RESHIFT(f, 24, 8);
}
pub inline fn PIXMAN_FORMAT_SHIFT(f: anytype) @TypeOf((@import("std").meta.cast(u32, (f >> 22) & 3))) {
    return (@import("std").meta.cast(u32, (f >> 22) & 3));
}
pub inline fn PIXMAN_FORMAT_TYPE(f: anytype) @TypeOf((f >> 16) & 0x3f) {
    return (f >> 16) & 0x3f;
}
pub inline fn PIXMAN_FORMAT_A(f: anytype) @TypeOf(PIXMAN_FORMAT_RESHIFT(f, 12, 4)) {
    return PIXMAN_FORMAT_RESHIFT(f, 12, 4);
}
pub inline fn PIXMAN_FORMAT_R(f: anytype) @TypeOf(PIXMAN_FORMAT_RESHIFT(f, 8, 4)) {
    return PIXMAN_FORMAT_RESHIFT(f, 8, 4);
}
pub inline fn PIXMAN_FORMAT_G(f: anytype) @TypeOf(PIXMAN_FORMAT_RESHIFT(f, 4, 4)) {
    return PIXMAN_FORMAT_RESHIFT(f, 4, 4);
}
pub inline fn PIXMAN_FORMAT_B(f: anytype) @TypeOf(PIXMAN_FORMAT_RESHIFT(f, 0, 4)) {
    return PIXMAN_FORMAT_RESHIFT(f, 0, 4);
}
pub inline fn PIXMAN_FORMAT_RGB(f: anytype) @TypeOf(f & 0xfff) {
    return f & 0xfff;
}
pub inline fn PIXMAN_FORMAT_VIS(f: anytype) @TypeOf(f & 0xffff) {
    return f & 0xffff;
}
pub inline fn PIXMAN_FORMAT_DEPTH(f: anytype) @TypeOf(((PIXMAN_FORMAT_A(f) + PIXMAN_FORMAT_R(f)) + PIXMAN_FORMAT_G(f)) + PIXMAN_FORMAT_B(f)) {
    return ((PIXMAN_FORMAT_A(f) + PIXMAN_FORMAT_R(f)) + PIXMAN_FORMAT_G(f)) + PIXMAN_FORMAT_B(f);
}
pub const PIXMAN_TYPE_OTHER = 0;
pub const PIXMAN_TYPE_A = 1;
pub const PIXMAN_TYPE_ARGB = 2;
pub const PIXMAN_TYPE_ABGR = 3;
pub const PIXMAN_TYPE_COLOR = 4;
pub const PIXMAN_TYPE_GRAY = 5;
pub const PIXMAN_TYPE_YUY2 = 6;
pub const PIXMAN_TYPE_YV12 = 7;
pub const PIXMAN_TYPE_BGRA = 8;
pub const PIXMAN_TYPE_RGBA = 9;
pub const PIXMAN_TYPE_ARGB_SRGB = 10;
pub const PIXMAN_TYPE_RGBA_FLOAT = 11;
pub inline fn PIXMAN_FORMAT_COLOR(f: anytype) @TypeOf(((((PIXMAN_FORMAT_TYPE(f) == PIXMAN_TYPE_ARGB) or (PIXMAN_FORMAT_TYPE(f) == PIXMAN_TYPE_ABGR)) or (PIXMAN_FORMAT_TYPE(f) == PIXMAN_TYPE_BGRA)) or (PIXMAN_FORMAT_TYPE(f) == PIXMAN_TYPE_RGBA)) or (PIXMAN_FORMAT_TYPE(f) == PIXMAN_TYPE_RGBA_FLOAT)) {
    return ((((PIXMAN_FORMAT_TYPE(f) == PIXMAN_TYPE_ARGB) or (PIXMAN_FORMAT_TYPE(f) == PIXMAN_TYPE_ABGR)) or (PIXMAN_FORMAT_TYPE(f) == PIXMAN_TYPE_BGRA)) or (PIXMAN_FORMAT_TYPE(f) == PIXMAN_TYPE_RGBA)) or (PIXMAN_FORMAT_TYPE(f) == PIXMAN_TYPE_RGBA_FLOAT);
}
pub inline fn pixman_trapezoid_valid(t: anytype) @TypeOf((((t.*.left.p1.y) != (t.*.left.p2.y)) and ((t.*.right.p1.y) != (t.*.right.p2.y))) and ((t.*.bottom) > (t.*.top))) {
    return (((t.*.left.p1.y) != (t.*.left.p2.y)) and ((t.*.right.p1.y) != (t.*.right.p2.y))) and ((t.*.bottom) > (t.*.top));
}
