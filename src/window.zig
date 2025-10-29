const std = @import("std");
const glfw = @import("zglfw");
const gl = @import("zgl");

pub fn initGlfw() !*glfw.Window {
    try glfw.init();
    std.debug.print("Initalized glfw\n", .{});

    const window = try glfw.Window.create(600, 600, "zig-gamedev: minimal_glfw_gl", null);

    glfw.makeContextCurrent(window);
    _ = glfw.setFramebufferSizeCallback(window, framebuffer_size_callback);

    std.debug.print("Created a window\n", .{});

    glfw.swapInterval(0); // Turning v-sync off

    return window;
}

pub fn deinitGlfw(window: *glfw.Window) void {
    glfw.terminate();
    window.destroy();
}

fn framebuffer_size_callback(window: *glfw.Window, width: c_int, height: c_int) callconv(.c) void {
    _ = window;
    gl.viewport(0, 0, @intCast(width), @intCast(height));
}

pub fn getAspect(window: *glfw.Window) f32 {
    const size = window.getSize();

    return @as(f32, @floatFromInt(size[0])) / @as(f32, @floatFromInt(size[1]));
}
