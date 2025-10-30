const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "_4d_something",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
        .use_lld = true,
        .use_llvm = true,
    });

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const zglfw = b.dependency("zglfw", .{ .target = target, .optimize = optimize });
    var zglfw_module = zglfw.module("root");
    zglfw_module.sanitize_c = .full;
    exe.root_module.addImport("zglfw", zglfw_module);
    if (target.result.os.tag != .emscripten) exe.linkLibrary(zglfw.artifact("glfw"));

    const zgl = b.dependency("zgl", .{ .target = target, .optimize = optimize });
    exe.root_module.addImport("zgl", zgl.module("zgl"));

    const zm = b.dependency("zm", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("zm", zm.module("zm"));

    b.installArtifact(exe);
}
