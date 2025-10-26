const std = @import("std");

pub const vec4: type = @Vector(4, f32);

pub const model = struct {
    vertices: std.ArrayList(vec4),

    /// Ignoring faces for now
    pub fn initFromFile(path: []const u8) !model {
        const file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
        defer file.close();

        var file_buffer: [1024]u8 = undefined;
        var file_reader = file.reader(&file_buffer);
        var reader = &file_reader.interface;

        // Reading lines till the end of the file
        outer: while (true) {
            if (reader.takeSentinel('\n')) |text| {
                std.debug.print("{s}\n", .{text});
            } else |err| switch (err) {
                // Oops! End of the file
                std.Io.Reader.Error.EndOfStream => {
                    std.debug.print("End of the line\n", .{});
                    break :outer;
                },
                else => {
                    return err;
                },
            }
        }

        return model{ .vertices = .empty };
    }

    pub fn deinit(this: *const model) void {
        _ = this;
        // do nothing lol
    }
};
