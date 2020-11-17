pub const Matrix = struct {
    // TODO
    pub extern fn wlr_matrix_identity(mat: *[9]f32) void;
    pub extern fn wlr_matrix_multiply(mat: *[9]f32, a: *const [9]f32, b: *const [9]f32) void;
    pub extern fn wlr_matrix_project_box(mat: *[9]f32, box: [*c]const Box, transform: wayland.Output.Transform, rotation: f32, projection: *const [9]f32) void;
    pub extern fn wlr_matrix_projection(mat: *[9]f32, width: c_int, height: c_int, transform: wayland.Output.Transform) void;
    pub extern fn wlr_matrix_rotate(mat: *[9]f32, rad: f32) void;
    pub extern fn wlr_matrix_scale(mat: *[9]f32, x: f32, y: f32) void;
    pub extern fn wlr_matrix_transform(mat: *[9]f32, transform: wayland.Output.Transform) void;
    pub extern fn wlr_matrix_translate(mat: *[9]f32, x: f32, y: f32) void;
    pub extern fn wlr_matrix_transpose(mat: *[9]f32, a: *const [9]f32) void;

    data: [3][3]f32,

    pub const Identity = @This(){
        .data = .{
            .{ 1, 0, 0 },
            .{ 0, 1, 0 },
            .{ 0, 0, 1 },
        },
    };

    pub fn col(m: @This(), n: u4) [3]f32 {
        return [3]f32{
            m.data[0][col],
            m.data[1][col],
            m.data[2][col],
        };
    }

    pub fn mul(dst: *@This(), op1: @This(), op2: @This()) void {
        var i: u4 = 0;
        var out: @This() = undefined;
        while (i < 3) : (i += 1) {
            var j: u4 = 0;
            while (j < 3) : (j += 1) {
                var sum: f32 = 0;
                var k: u4 = 0;
                while (k < 3) : (k += 1) {
                    sum += op1.data[i][k] * op2.data[k][j];
                }
                out.data[i][j] = sum;
            }
        }
        dst.* = out;
    }

    pub fn translate(m: *@This(), x: f32, y: f32) void {
        const trans: @This() = .{
            .data = .{
                .{ 1, 0, x },
                .{ 0, 1, y },
                .{ 0, 0, 1 },
            },
        };
        mul(m, m.*, trans);
    }

    pub fn scale(m: *@This(), x: f32, y: f32) void {
        const trans: @This() = .{
            .data = .{
                .{ x, 0, 0 },
                .{ 0, y, 0 },
                .{ 0, 0, 1 },
            },
        };
        mul(m, m.*, trans);
    }

    pub fn rotate(m: *@This(), rad: f32) void {
        const trans: @This() = .{
            .data = .{
                .{ std.math.cos(rad), -std.math.sin(rad), 0 },
                .{ std.math.sin(rad), std.math.cos(rad), 0 },
                .{ 0, 0, 1 },
            },
        };
        mul(m, m.*, trans);
    }

    pub fn linear(m: *const @This()) *const [9]f32 {
        return @ptrCast(*const [9]f32, &m.data);
    }

    pub fn print(m: @This()) void {
        std.debug.print(
            "{d} {d} {d}\n{d} {d} {d}\n{d} {d} {d}\n\n",
            .{
                m.data[0][0], m.data[0][1], m.data[0][2],
                m.data[1][0], m.data[1][1], m.data[1][2],
                m.data[2][0], m.data[2][1], m.data[2][2],
            },
        );
    }
};
