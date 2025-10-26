const std = @import("std");
const gl = @import("zgl");

/// Creates and returns a program
pub fn createProgram(allocator: std.mem.Allocator) !gl.Program {
    // Vertex shader section
    const vertexShader = gl.createShader(.vertex);
    const vertexShaderSource = try readFile(allocator, "./assets/vertex.vert");
    defer allocator.free(vertexShaderSource);
    gl.shaderSource(vertexShader, 1, &vertexShaderSource);
    gl.compileShader(vertexShader);

    // Fragment shader section
    const fragmentShader = gl.createShader(.fragment);
    const fragmentShaderSource = try readFile(allocator, "./assets/fragment.frag");
    defer allocator.free(fragmentShaderSource);
    gl.shaderSource(fragmentShader, 1, &fragmentShaderSource);
    gl.compileShader(fragmentShader);

    const shaderProgram = gl.createProgram();
    gl.attachShader(shaderProgram, vertexShader);
    gl.attachShader(shaderProgram, fragmentShader);
    gl.linkProgram(shaderProgram);

    gl.deleteShader(vertexShader);
    gl.deleteShader(fragmentShader);

    return shaderProgram;
}

/// Caller is responsible for freeing the memory
fn readFile(allocator: std.mem.Allocator, file_path: [] const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();
    const file_size = try file.getEndPos();

    var reader = file.reader(&.{});
    const file_content = try reader.interface.readAlloc(allocator, file_size);

    return file_content;
}
