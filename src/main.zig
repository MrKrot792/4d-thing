const std = @import("std");
const glfw = @import("zglfw");
const allocator_selector = @import("allocator_selector.zig");
const gl = @import("zgl");
const shader = @import("shader.zig");
const windows = @import("window.zig");

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

    const shaderProgram = try shader.createProgram(allocator);
    defer shaderProgram.delete();

    const vbo = gl.genBuffer();
    gl.bindBuffer(vbo, .array_buffer);
    gl.bufferData(.array_buffer, f32, &vertices, .static_draw);

    const vao = gl.genVertexArray();
    gl.bindVertexArray(vao);

    gl.vertexAttribPointer(0, 3, .float, false, 3 * @sizeOf(f32), 0);
    gl.enableVertexAttribArray(0);

    // Main loop
    while (!window.shouldClose()) {
        glfw.pollEvents();
        
        // Rendering
        std.debug.print("Rendering...\n", .{});

        gl.clearColor(0.2, 0.3, 0.3, 1.0);
        gl.clear(.{.color = true});

        gl.useProgram(shaderProgram);
        gl.bindVertexArray(vao);
        gl.drawArrays(.triangles, 0, 3);

        window.swapBuffers();
    }
}

fn getProcAddressWrapper(comptime _: type, symbolName: [:0]const u8) ?*const anyopaque {
    return glfw.getProcAddress(symbolName);
}
