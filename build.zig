const std = @import("std");
const Builder = std.build.Builder;
const Pkg = std.build.Pkg;

const ScanProtocolsStep = @import("deps/zig-wayland/build.zig").ScanProtocolsStep;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();
    const tracy = b.option([]const u8, "tracy", "Enable Tracy integration. Supply path to Tracy source");

    const scanner = ScanProtocolsStep.create(b, "deps/zig-wayland");
    scanner.addSystemProtocol("stable/xdg-shell/xdg-shell.xml");

    const wayland = scanner.getPkg();
    const xkbcommon = Pkg{
        .name = "xkbcommon",
        .path = "deps/zig-xkbcommon/src/xkbcommon.zig",
    };
    const pixman = Pkg{
        .name = "pixman",
        .path = "deps/zig-pixman/pixman.zig",
    };
    const wlroots = Pkg{
        .name = "wlroots",
        .path = "deps/zig-wlroots/src/wlroots.zig",
        .dependencies = &[_]Pkg{ wayland, xkbcommon, pixman },
    };

    const exe = b.addExecutable("wayfarer", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.linkLibC();

    exe.addPackage(wayland);
    exe.linkSystemLibrary("wayland-server");
    exe.step.dependOn(&scanner.step);
    scanner.addCSource(exe);

    exe.addPackage(xkbcommon);
    exe.linkSystemLibrary("xkbcommon");

    exe.addPackage(wlroots);
    exe.linkSystemLibrary("wlroots");
    exe.linkSystemLibrary("pixman-1");

    if (tracy) |tracy_path| {
        const client_cpp = std.fs.path.join(
            b.allocator,
            &[_][]const u8{ tracy_path, "TracyClient.cpp" },
        ) catch unreachable;
        exe.addIncludeDir(tracy_path);
        exe.addCSourceFile(client_cpp, &[_][]const u8{ "-DTRACY_ENABLE=1", "-fno-sanitize=undefined" });
        exe.linkSystemLibraryName("c++");
    }
    exe.addBuildOption(bool, "enable_tracy", tracy != null);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
