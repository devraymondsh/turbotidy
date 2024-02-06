const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "turbotidy",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const turbotidy_mod = b.addModule("turbotidy", .{
        .root_source_file = std.Build.LazyPath.relative("src/root.zig"),
    });
    const swift_lib = b.dependency("swift_lib", .{
        .target = target,
        .optimize = optimize,
    });
    turbotidy_mod.addImport("swift_lib", swift_lib.module("swift_lib"));
    exe.root_module.addImport("swift_lib", swift_lib.module("swift_lib"));

    b.installArtifact(exe);

    if (optimize != .Debug) {
        exe.root_module.strip = true;
        if (target.result.os.tag != .macos) {
            exe.want_lto = true;
        }
    }

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&b.addRunArtifact(exe).step);

    const test_step = b.step("test", "Runs the tests");
    const tests = b.addTest(.{ .root_source_file = std.Build.LazyPath.relative("tests/lexer/lexer.zig") });
    tests.root_module.addImport("turbotidy", turbotidy_mod);
    tests.root_module.addImport("swift_lib", swift_lib.module("swift_lib"));
    test_step.dependOn(&b.addRunArtifact(tests).step);
}
