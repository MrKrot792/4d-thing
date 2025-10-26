const std = @import("std");

const Fps = @This();
const Timer = std.time.Timer;
var frames_count: u32 = 0;
var frames:       u32 = 0;
var elapsed:      f32 = 0;

pub const FpsInfo = struct {
    fps: u32,
    fps_average: f32,
    delta: f32
};

/// It is not neccesary to call this function every frame, although it is recommended.
pub fn frameStart(timer: *Timer) void {
    timer.reset(); // Yeah cuz why not
}

/// Make sure that this is called at the very end of your loop!
pub fn frameEnd(timer: *Timer) FpsInfo {
    const ns_per_frame = @as(f32, @floatFromInt(timer.lap()));
    const d = ns_per_frame / 1.0e9;

    elapsed += d;
    frames_count += 1;

    if (elapsed >= 1.0) {
        elapsed = 0;
        frames = frames_count;
        frames_count = 0;
    }

    return .{
        .delta = d,
        .fps = frames,
        .fps_average = 1.0 / d,
    };
}
