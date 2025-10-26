const std = @import("std");
const glfw = @import("zglfw");
const allocator_selector = @import("allocator_selector.zig");
const gl = @import("zgl");
const shader = @import("shader.zig");
const windows = @import("window.zig");
const fps = @import("fps.zig");

pub fn main() !void {
    // Allocator
    const allocator_info = allocator_selector.getAllocator();
    const allocator = allocator_info.allocator;

    defer if (allocator_info.is_debug) {
        switch (allocator_selector.debugDeinit()) {
            .leak => std.debug.print("You leaked memory dum dum\n", .{}),
            .ok => std.debug.print("No memory leaks. For now...\n", .{}),
        }
    };

    // glfw 
    const window = try windows.initGlfw();
    defer windows.deinitGlfw(window);

    // gl
    const vertices = [_]f32{
        -0.5, -0.5, 0.0,
         0.5, -0.5, 0.0,
         0.0,  0.5, 0.0,
    };

    try gl.loadExtensions(void, getProcAddressWrapper);

    const shader_program = try shader.createProgram(allocator);
    defer shader_program.delete();

    const vbo = gl.genBuffer();
    gl.bindBuffer(vbo, .array_buffer);
    gl.bufferData(.array_buffer, f32, &vertices, .static_draw);

    const vao = gl.genVertexArray();
    gl.bindVertexArray(vao);

    gl.vertexAttribPointer(0, 3, .float, false, 3 * @sizeOf(f32), 0);
    gl.enableVertexAttribArray(0);

    var timer = try std.time.Timer.start();

    // Main loop
    while (!window.shouldClose()) {
        fps.frameStart(&timer);
        glfw.pollEvents();
        
        // Rendering
        gl.clearColor(0.2, 0.3, 0.3, 1.0);
        gl.clear(.{.color = true});

        gl.useProgram(shader_program);
        gl.bindVertexArray(vao);
        gl.drawArrays(.triangles, 0, 3);

        window.swapBuffers();

        // FPS stuff
        const fps_info = fps.frameEnd(&timer);
        std.debug.print("{d}\n", .{fps_info.delta});
        std.debug.print("{d}\n", .{fps_info.fps});
    }
}

fn getProcAddressWrapper(comptime _: type, symbolName: [:0]const u8) ?*const anyopaque {
    return glfw.getProcAddress(symbolName);
}
