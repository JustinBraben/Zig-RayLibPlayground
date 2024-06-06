const std = @import("std");
const ray = @import("raylib.zig");
const ecs = @import("ecs/ecs.zig");
const Game = @import("game/game.zig").Game;
const Utility = @import("ecs/core/utility.zig");
const Entity = @import("ecs/entity/entity.zig");

const Ball = struct {
    position: ray.Vector2,
    velocity: ray.Vector2,
    radius: f32,
    color: ray.Color,
};

pub fn main() !void {
    try ray_ball();
    try hints();
}

pub fn ray_ball() !void {
    const width = 800;
    const height = 450;

    ray.SetConfigFlags(ray.FLAG_MSAA_4X_HINT | ray.FLAG_VSYNC_HINT);
    ray.InitWindow(width, height, "zig raylib example");
    defer ray.CloseWindow();

    var gpa_impl = std.heap.GeneralPurposeAllocator(.{ .stack_trace_frames = 8 }){};
    const gpa = gpa_impl.allocator();

    const clear_color = ray.BLACK;
    // const colors = [_]ray.Color{ ray.GRAY, ray.RED, ray.GOLD, ray.LIME, ray.BLUE, ray.VIOLET, ray.BROWN };
    // const colors_len: i32 = @intCast(colors.len);
    // var current_color: i32 = 2;

    var ball_list: std.MultiArrayList(Ball) = .{};
    defer ball_list.deinit(gpa);

    var count: usize = 0;
    while(count < 5) : (count += 1) {
        const position = ray.Vector2{ .x = (@as(f32, @floatFromInt(ray.GetRandomValue(0, width)))), .y = (@as(f32, @floatFromInt(ray.GetRandomValue(0, height)))) };
        var velocity = ray.Vector2{ .x = @as(f32, @floatFromInt(ray.GetRandomValue(-1, 1))), .y = @as(f32, @floatFromInt(ray.GetRandomValue(-1, 1))) };
        velocity.x = velocity.x / 2.0;
        velocity.y = velocity.y / 2.0;
        const ball = Ball{
            .position = position,
            .velocity = velocity,
            .radius = @as(f32, @floatFromInt(ray.GetRandomValue(10, 40))),
            .color = ray.BLUE,
        };
        try ball_list.append(gpa, ball);
    }

    std.debug.print("{}\n", .{ball_list.slice().get(0)});

    while (!ray.WindowShouldClose()) {
        // input
        if (ray.IsMouseButtonPressed(ray.MOUSE_LEFT_BUTTON)) {
            std.debug.print("LMB Pressed\n", .{});
        }

        // draw
        {
            ray.BeginDrawing();
            defer ray.EndDrawing();

            ray.ClearBackground(clear_color);

            // for (ball_list.items(.position)) |position| {
            //     ray.DrawCircleV(position, 10, ray.BLUE);
            // }

            const size = ball_list.len;
            var index: usize = 0;
            while (index < size) : (index += 1) {
                var ball = ball_list.get(index);
                const vel = ball.velocity;
                var position = ball.position;
                position.x += vel.x;
                position.y += vel.y;
                ball_list.set(index, .{
                    .position = position,
                    .velocity = vel,
                    .radius = ball.radius,
                    .color = ball.color,
                });
                ball = ball_list.get(index);
                ray.DrawCircleV(ball.position, ball.radius, ball.color);
            }

            ray.DrawFPS(width - 100, 10);
        }
    }
}

pub fn ray_main() !void {
    const width = 800;
    const height = 450;

    ray.SetConfigFlags(ray.FLAG_MSAA_4X_HINT | ray.FLAG_VSYNC_HINT);
    ray.InitWindow(width, height, "zig raylib example");
    defer ray.CloseWindow();

    var gpa_impl = std.heap.GeneralPurposeAllocator(.{ .stack_trace_frames = 8 }){};
    const gpa = gpa_impl.allocator();

    const colors = [_]ray.Color{ ray.GRAY, ray.RED, ray.GOLD, ray.LIME, ray.BLUE, ray.VIOLET, ray.BROWN };
    const colors_len: i32 = @intCast(colors.len);
    var current_color: i32 = 2;
    var hint = true;

    while (!ray.WindowShouldClose()) {
        // input
        var delta: i2 = 0;
        if (ray.IsKeyPressed(ray.KEY_UP)) delta += 1;
        if (ray.IsKeyPressed(ray.KEY_DOWN)) delta -= 1;
        if (delta != 0) {
            current_color = @mod(current_color + delta, colors_len);
            hint = false;
        }

        // draw
        {
            ray.BeginDrawing();
            defer ray.EndDrawing();

            ray.ClearBackground(colors[@intCast(current_color)]);
            if (hint) ray.DrawText("press up or down arrow to change background color", 120, 140, 20, ray.BLUE);
            ray.DrawText("Congrats! You created your first window!", 190, 200, 20, ray.BLACK);

            // now lets use an allocator to create some dynamic text
            // pay attention to the Z in `allocPrintZ` that is a convention
            // for functions that return zero terminated strings
            const seconds: u32 = @intFromFloat(ray.GetTime());
            const dynamic = try std.fmt.allocPrintZ(gpa, "running since {d} seconds", .{seconds});
            defer gpa.free(dynamic);
            ray.DrawText(dynamic, 300, 250, 20, ray.WHITE);

            ray.DrawFPS(width - 100, 10);
        }
    }
}

fn hints() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("\n⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯\n", .{});
    try stdout.print("Here are some hints:\n", .{});
    try stdout.print("Run `zig build --help` to see all the options\n", .{});
    try stdout.print("Run `zig build -Doptimize=ReleaseSmall` for a small release build\n", .{});
    try stdout.print("Run `zig build -Doptimize=ReleaseSmall -Dstrip=true` for a smaller release build, that strips symbols\n", .{});
    try stdout.print("Run `zig build -Draylib-optimize=ReleaseFast` for a debug build of your application, that uses a fast release of raylib (if you are only debugging your code)\n", .{});

    try bw.flush(); // don't forget to flush!
}
