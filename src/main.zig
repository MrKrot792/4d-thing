const std = @import("std");
const glfw = @import("zglfw");
const allocator_selector = @import("allocator_selector.zig");
const gl = @import("zgl");
const shader = @import("shader.zig");
const windows = @import("window.zig");
const fps = @import("fps.zig");
const model = @import("model.zig");
const zm = @import("zm");

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

    // I don't have GLAD
    try gl.loadExtensions(void, getProcAddressWrapper);

    const shader_program = try shader.createProgram(allocator);
    defer shader_program.delete();

    const vao = gl.genVertexArray();
    gl.bindVertexArray(vao);

    // Model of a cube
    var m = try model.model.initFromFile("./assets/cube.obj", allocator);
    defer m.deinit(allocator);

    try m.makeIt4D(allocator); // We make it 4D!

    const modelInfo = m.packIntoModelInfo();

    // Sending it to the GPU
    const vbo = gl.genBuffer();
    gl.bindBuffer(vbo, .array_buffer);
    gl.bufferData(.array_buffer, f32, modelInfo.vertices, .static_draw);

    const ebo = gl.genBuffer();
    gl.bindBuffer(ebo, .element_array_buffer);
    gl.bufferData(.element_array_buffer, u32, modelInfo.indices, .static_draw);

    // How our data should be structured
    gl.vertexAttribPointer(0, 4, .float, false, 4 * @sizeOf(f32), 0); // X Y Z W
    gl.enableVertexAttribArray(0);

    var timer = try std.time.Timer.start();
    var fps_info = fps.frameEnd(&timer);

    var model_m: zm.Mat4f = .identity();

    gl.enable(.cull_face);
    gl.cullFace(.back);

    // Main loop
    while (!window.shouldClose()) {
        fps.frameStart(&timer);
        glfw.pollEvents();

        // Rendering
        gl.clearColor(0.2, 0.3, 0.3, 1.0);
        gl.clear(.{ .color = true });

        var view: zm.Mat4f = .identity();
        // Moving the cube a bit further
        view = view.multiply(.translation(0, 0, -4));

        // Rotating the cube over time
        model_m = model_m.multiply(.rotation(zm.Vec3{1, 0, 0}, std.math.degreesToRadians(45) * fps_info.delta));
        model_m = model_m.multiply(.rotation(zm.Vec3{0, 1, 0}, std.math.degreesToRadians(90) * fps_info.delta));
        model_m = model_m.multiply(.rotation(zm.Vec3{0, 0, 1}, std.math.degreesToRadians(15) * fps_info.delta));
        const projection: zm.Mat4f = .perspective(std.math.degreesToRadians(90), windows.getAspect(window), 0.1, 1000);

        gl.useProgram(shader_program);

        const model_location = gl.getUniformLocation(shader_program, "model");
        const view_location = gl.getUniformLocation(shader_program, "view");
        const projection_location = gl.getUniformLocation(shader_program, "projection");

        gl.uniformMatrix4fv(model_location.?, true, &[_][4][4]f32{vecToArray(model_m.data)});
        gl.uniformMatrix4fv(view_location.?, true, &[_][4][4]f32{vecToArray(view.data)});
        gl.uniformMatrix4fv(projection_location.?, true, &[_][4][4]f32{vecToArray(projection.data)});

        gl.polygonMode(.front_and_back, .line);
        gl.useProgram(shader_program);
        gl.bindVertexArray(vao);
        gl.drawElements(.triangles, modelInfo.indices.len, .unsigned_int, 0);

        window.swapBuffers();

        // FPS stuff
        fps_info = fps.frameEnd(&timer);
        std.debug.print("{d}\n", .{fps_info.delta});
        std.debug.print("{d}\n", .{fps_info.fps});
    }

    std.debug.print("vertices: {any}\n", .{modelInfo.vertices});
    std.debug.print("indices: {any}\n", .{modelInfo.indices});
}

fn getProcAddressWrapper(comptime _: type, symbolName: [:0]const u8) ?*const anyopaque {
    return glfw.getProcAddress(symbolName);
}

fn vecToArray(vec: @Vector(16, f32)) [4][4]f32 {
    const result: [4][4]f32 = [4][4]f32{
        [4]f32{vec[0], vec[1], vec[2], vec[3]},
        [4]f32{vec[4], vec[5], vec[6], vec[7]},
        [4]f32{vec[8], vec[9], vec[10], vec[11]},
        [4]f32{vec[12], vec[13], vec[14], vec[15]},
    };

    return result;
}
