const std = @import("std");
const Allocator = std.mem.Allocator;
const ray = @import("../raylib.zig");

pub const Game = struct {
    allocator: Allocator,
    width: c_int = 800,
    height: c_int = 450,

    pub fn init(allocator: Allocator, width: c_int, height: c_int) Game {
        ray.SetConfigFlags(ray.FLAG_MSAA_4X_HINT | ray.FLAG_VSYNC_HINT);
        ray.InitWindow(width, height, "zig raylib example");

        return .{
            .allocator = allocator,
            .width = width,
            .height = height,
        };
    }

    pub fn deinit(self: *Game) void {
        ray.CloseWindow();
        _ = self;
    }
};