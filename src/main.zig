const std = @import("std");
const glfw = @import("zglfw");
const allocator_selector = @import("allocator_selector.zig");
const gl = @import("zgl");

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
    try glfw.init();
    defer glfw.terminate();

    std.debug.print("Initalized glfw\n", .{});

    const window = try glfw.Window.create(600, 600, "zig-gamedev: minimal_glfw_gl", null);
    defer window.destroy();

    glfw.makeContextCurrent(window);
    _ = glfw.setFramebufferSizeCallback(window, framebuffer_size_callback);

    std.debug.print("Created a window\n", .{});

    const vertices = [_]f32{
        -0.5, -0.5, 0.0,
        0.5, -0.5, 0.0,
        0.0,  0.5, 0.0,
    };

    // gl
    try gl.loadExtensions(void, getProcAddressWrapper);

    const vao = gl.genVertexArray();
    gl.bindVertexArray(vao);

    const vbo = gl.genBuffer();
    gl.bindBuffer(vbo, .array_buffer);
    gl.bufferData(.array_buffer, f32, &vertices, .static_draw);

    const vertexShader = gl.createShader(.vertex);
    const vertexShaderSource = try readFile(allocator, "./assets/vertex.vert");
    defer allocator.free(vertexShaderSource);
    gl.shaderSource(vertexShader, 1, &vertexShaderSource);
    gl.compileShader(vertexShader);

    const fragmentShader = gl.createShader(.fragment);
    const fragmentShaderSource = try readFile(allocator, "./assets/fragment.frag");
    defer allocator.free(fragmentShaderSource);
    gl.shaderSource(fragmentShader, 1, &fragmentShaderSource);
    gl.compileShader(fragmentShader);

    const shaderProgram = gl.createProgram();
    gl.attachShader(shaderProgram, vertexShader);
    gl.attachShader(shaderProgram, fragmentShader);
    gl.linkProgram(shaderProgram);

    gl.useProgram(shaderProgram);
    gl.deleteShader(vertexShader);
    gl.deleteShader(fragmentShader);

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

fn readFile(allocator: std.mem.Allocator, file_path: [] const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();
    const file_size = try file.getEndPos();

    var reader = file.reader(&.{});
    const file_content = try reader.interface.readAlloc(allocator, file_size);

    return file_content;
}

fn getProcAddressWrapper(comptime _: type, symbolName: [:0]const u8) ?*const anyopaque {
    return glfw.getProcAddress(symbolName);
}

fn framebuffer_size_callback(window: *glfw.Window, width: c_int, height: c_int) callconv(.c) void
{
    _ = window;
    gl.viewport(0, 0, @intCast(width), @intCast(height));
}

fn initGlfw() void {
    
}
