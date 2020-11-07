const std = @import("std");

// A 2D transformation matrix in row-major order.
pub const Matrix = [3][3]f32;
pub const Identity = Matrix{
    .{ 1, 0, 0 },
    .{ 0, 1, 0 },
    .{ 0, 0, 1 },
};

pub fn col(m: Matrix, n: u4) [3]f32 {
    return [3]f32{
        m[0][col],
        m[1][col],
        m[2][col],
    };
}

pub fn mul(dst: *Matrix, op1: Matrix, op2: Matrix) void {
    var i: u4 = 0;
    var out: Matrix = undefined;
    while (i < 3) : (i += 1) {
        var j: u4 = 0;
        while (j < 3) : (j += 1) {
            var sum: f32 = 0;
            var k: u4 = 0;
            while (k < 3) : (k += 1) {
                sum += op1[i][k] * op2[k][j];
            }
            out[i][j] = sum;
        }
    }
    dst.* = out;
}

pub fn translate(m: *Matrix, x: f32, y: f32) void {
    const trans: Matrix = .{
        .{ 1, 0, x },
        .{ 0, 1, y },
        .{ 0, 0, 1 },
    };
    mul(m, m.*, trans);
}

pub fn scale(m: *Matrix, x: f32, y: f32) void {
    const trans: Matrix = .{
        .{ x, 0, 0 },
        .{ 0, y, 0 },
        .{ 0, 0, 1 },
    };
    mul(m, m.*, trans);
}

pub fn rotate(m: *Matrix, rad: f32) void {
    const trans: Matrix = .{
        .{ std.math.cos(rad), -std.math.sin(rad), 0 },
        .{ std.math.sin(rad), std.math.cos(rad), 0 },
        .{ 0, 0, 1 },
    };
    mul(m, m.*, trans);
}

pub fn linear(m: *Matrix) *[9]f32 {
    return @ptrCast(*[9]f32, m);
}

pub fn print(m: Matrix) void {
    std.debug.print(
        "{d} {d} {d}\n{d} {d} {d}\n{d} {d} {d}\n\n",
        .{
            m[0][0], m[0][1], m[0][2],
            m[1][0], m[1][1], m[1][2],
            m[2][0], m[2][1], m[2][2],
        },
    );
}
