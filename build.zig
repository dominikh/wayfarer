const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const tracy = b.option([]const u8, "tracy", "Enable Tracy integration. Supply path to Tracy source");

    const exe = b.addExecutable("wayfarer", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.addIncludeDir("src/include/");
    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("wayland-server");
    exe.linkSystemLibrary("wlroots");
    exe.linkSystemLibrary("xcb");
    exe.linkSystemLibrary("xkbcommon");
    if (tracy) |tracy_path| {
        const client_cpp = std.fs.path.join(
            b.allocator,
            &[_][]const u8{ tracy_path, "TracyClient.cpp" },
        ) catch unreachable;
        exe.addIncludeDir(tracy_path);
        exe.addCSourceFile(client_cpp, &[_][]const u8{ "-DTRACY_ENABLE=1", "-fno-sanitize=undefined" });
        exe.linkSystemLibraryName("c++");
        exe.linkLibC();
    }
    exe.addBuildOption(bool, "enable_tracy", tracy != null);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
