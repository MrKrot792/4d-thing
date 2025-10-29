const std = @import("std");
const builtin = @import("builtin");

pub const vec4: type = [4]f32;
pub const uvec3: type = [3]u32;

pub const modelInfo = struct {
    vertices: []f32,
    indices: []u32,
};

pub const model = struct {
    vertices: std.ArrayList(vec4),
    indices: std.ArrayList(uvec3),

    /// Ignoring faces for now
    ///
    /// **!WARNING!** If the line is larger than 1024 bytes, this **WILL** break!
    pub fn initFromFile(path: []const u8, allocator: std.mem.Allocator) !model {
        // Opening the file
        const file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
        defer file.close();

        // Some buffering stuff
        var file_buffer: [1024]u8 = undefined;
        var file_reader = file.reader(&file_buffer);
        var reader = &file_reader.interface;

        var result: model = .{ .vertices = .empty, .indices = .empty };

        // Reading lines till the end of the file
        outer: while (true) {
            if (reader.takeSentinel('\n')) |text| {
                // Processing the line here
                if(text.len == 0) continue; // Skipping empty lines
                if(text[0] == '#') continue; // Skipping comments

                // If the line is a vertex
                if(text[0] == 'v') {
                    // `tokenizeScalar` will probably work here, if 
                    // it doesn't, i'll just use `splitScalar`.
                    var tokens = std.mem.tokenizeScalar(u8, text, ' ');
                    _ = tokens.next();

                    var num_buffer: [3]f32 = undefined;
                    for (0..3) |i| {
                        const next = tokens.next();
                        if (next == null) break;

                        // In this case, `next` is always a float
                        num_buffer[i] = try std.fmt.parseFloat(f32, next.?);
                    }

                    try result.vertices.append(allocator, vec4{num_buffer[0], num_buffer[1], num_buffer[2], 1});
                }

                // If the line is a face (triangle)
                if(text[0] == 'f') {
                    var tokens = std.mem.tokenizeScalar(u8, text, ' ');
                    _ = tokens.next();

                    var num_buffer: [3]u32 = undefined;
                    for (0..3) |i| {
                        const next = tokens.next();
                        if (next == null) break;

                        // In this case, `next` is always a num
                        num_buffer[i] = try std.fmt.parseUnsigned(u32, next.?, 10) - 1; // -1 because blender thought it was really funny to
                                                                                        // export indices shifted
                    }

                    try result.indices.append(allocator, num_buffer);
                }

            } else |err| switch (err) {
                // Oops! End of the file
                std.Io.Reader.Error.EndOfStream => {
                    break :outer;
                },
                else => {
                    @branchHint(.cold); // Cause really unlikely
                    return err;
                },
            }
        }

        return result;
    }

    pub fn deinit(this: *model, allocator: std.mem.Allocator) void {
        if (builtin.mode == .Debug) {
            std.debug.print("Vertices: \n", .{});
            for (this.vertices.items) |value| {
                std.debug.print("- {any}\n", .{value});
            }

            std.debug.print("Indices: \n", .{});
            for (this.indices.items) |value| {
                std.debug.print("- {any}\n", .{value});
            }
        }

        this.vertices.deinit(allocator);
        this.indices.deinit(allocator);
    }

    pub fn packIntoModelInfo(this: *model) modelInfo {
        return .{ 
            .vertices = @ptrCast(this.vertices.items), 
            .indices = @ptrCast(this.indices.items) 
        };
    }
};
