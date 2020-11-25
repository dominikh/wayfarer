const std = @import("std");

const CloneArgs = extern struct {
    flags: u64 = 0,
    pidfd: u64 = 0,
    child_tid: u64 = 0,
    parent_tid: u64 = 0,
    exit_signal: u64 = 0,
    stack: u64 = 0,
    stack_size: u64 = 0,
    tls: u64 = 0,
    set_tid: u64 = 0,
    set_tid_size: u64 = 0,
    cgroup: u64 = 0,
};

pub const Clone3Error = error{
    PermissionDenied,
    PidAlreadyExists,
    ResourceLimitReached,
    SystemResources,
} || std.os.UnexpectedError;

pub fn clone3(args: *const CloneArgs) Clone3Error!usize {
    const ret = std.os.linux.syscall2(.clone3, @ptrToInt(args), @sizeOf(CloneArgs));
    if (ret == 0) {
        return 0;
    }
    switch (std.os.linux.getErrno(ret)) {
        0 => return ret,
        std.c.EAGAIN => return error.ResourceLimitReached,
        std.c.EFAULT => unreachable,
        std.c.EBUSY => unreachable,
        std.c.EEXIST => return error.PidAlreadyExists,
        std.c.EINVAL => unreachable,
        std.c.ENOMEM => return error.SystemResources,
        std.c.ENOSPC => return error.ResourceLimitReached,
        std.c.EOPNOTSUPP => unreachable,
        std.c.EPERM => return error.PermissionDenied,
        std.c.EUSERS => return error.ResourceLimitReached,
        else => |err| return std.os.unexpectedErrno(err),
    }
}

/// spawn spawns a new process and returns its pidfd. No signal will
/// be delivered when the child terminates, and calls to waitid have
/// to use the __WCLONE flag.
pub fn spawn(allocator: *std.mem.Allocator, argv: []const []const u8) !std.c.pid_t {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    const CLONE_PIDFD = 0x00001000;
    var fd: std.c.pid_t = undefined;
    const args: CloneArgs = .{
        .flags = std.c.CLONE_CLEAR_SIGHAND | CLONE_PIDFD,
        .pidfd = @ptrToInt(&fd),
        .exit_signal = 17, // 17
    };
    var env = try std.process.getEnvMap(&arena.allocator);
    const ret = clone3(&args) catch |err| switch (err) {
        Clone3Error.ResourceLimitReached => return err,
        Clone3Error.PidAlreadyExists => unreachable,
        Clone3Error.SystemResources => return err,
        Clone3Error.PermissionDenied => return err,
        Clone3Error.Unexpected => return err,
    };
    if (ret == 0) {
        spawnChild(&arena.allocator, argv, &env);
        std.os.exit(1);
    } else {
        return fd;
    }
}

fn spawnChild(allocator: *std.mem.Allocator, argv: []const []const u8, env: *std.BufMap) void {
    const devnull = std.os.open("/dev/null", std.os.O_RDWR, 0) catch return;
    std.os.dup2(devnull, 0) catch return;
    std.os.dup2(devnull, 1) catch return;
    std.os.dup2(devnull, 2) catch return;
    std.os.execvpe(allocator, argv, env) catch {};
}

pub fn wait(fd: std.c.pid_t) !void {
    const P_PIDFD = 3;
    // we don't care about the info, but passing NULL is only supported by Linux and discouraged
    var info: std.c.siginfo_t = undefined;
    while (true) {
        const ret = std.os.linux.syscall5(.waitid, P_PIDFD, @intCast(usize, fd), @ptrToInt(&info), std.c.WEXITED, 0);
        switch (std.os.linux.getErrno(ret)) {
            0 => return,
            std.c.ECHILD => unreachable,
            std.c.EINVAL => unreachable,
            std.c.EINTR => continue,
            else => |err| return std.os.unexpectedErrno(err),
        }
    }
}
