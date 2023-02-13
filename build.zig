const std = @import("std");

pub fn addAssetsOption(b: *std.build.Builder, exe:anytype) !void {
    var options = b.addOptions();

    var files = std.ArrayList([]const u8).init(b.allocator);
    defer files.deinit();

    var buf: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const path = try std.fs.cwd().realpath("src/assets", buf[0..]);

    var dir = try std.fs.openIterableDirAbsolute(path, .{});
    var it = dir.iterate();
    while (try it.next()) |file| {
        if (file.kind != .File) {
            continue;
        }
        try files.append(b.dupe(file.name));
    }
    options.addOption([]const []const u8, "files", files.items);

    var pkg = std.build.Pkg{
        .name = "assets",
        .source = options.getSource(),
    };
    exe.addPackage(pkg);

}

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("embeddir", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    addAssetsOption(b, exe) catch |err| {
        std.log.err("Problem adding assets: {!}", .{err});
    };

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
