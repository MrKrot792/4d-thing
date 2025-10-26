var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
const builtin = @import("builtin");
const std = @import("std");

pub const AllocatorInformation = struct {
    allocator: std.mem.Allocator,
    is_debug: bool,
};

pub fn getAllocator() AllocatorInformation {
    const allocator, const is_debug = gpa: {
        break :gpa switch (builtin.mode) {
            .Debug, .ReleaseSafe => .{ debug_allocator.allocator(), true },
            .ReleaseFast, .ReleaseSmall => .{ std.heap.smp_allocator, false },
        };
    };

    return .{
        .allocator = allocator,
        .is_debug = is_debug,
    };
}

pub fn debugDeinit() std.heap.Check {
    return debug_allocator.deinit();
}
