const std = @import("std");
const ray = @import("raylib.zig");
const ecs = @import("ecs/ecs.zig");
const Game = @import("game/game.zig").Game;
const Utility = @import("ecs/core/utility.zig");
const Entity = @import("ecs/entity/entity.zig");

pub const Suite = enum {
    Spades,
    Hearts,
    Diamonds,
    Clubs,
};

pub const Person = struct {
    age: u8,
    canJump: bool,
};

pub fn main() !void {
    // try ray_main();

    // var gpa_impl = std.heap.GeneralPurposeAllocator(.{ .stack_trace_frames = 8 }){};
    // const gpa = gpa_impl.allocator();
    // var game: Game = undefined;
    // game = Game.init(gpa, 850, 450);
    // defer game.deinit();

    const card_1: Suite = .Spades;
    Utility.debugPrintType(card_1);

    const person_1 = Person{ .age = 30, .canJump = true };
    Utility.debugPrintType(person_1);

    // const m = Entity.EntityTraitsType(.medium).init();
    // std.debug.print("traits value_type is {}\n", .{@TypeOf(m.value_type)});
    const u_num2: u32 = 12;
    const u_num3: u64 = 14;
    Utility.PrintValidEntityTraitsType(u_num2);
    Utility.PrintValidEntityTraitsType(u_num3);

    const e_t = Entity.EntityTraits(u32).init();
    std.debug.print("e_t is {}\n", .{e_t});
    const e_tt = Entity.EntityTraits(u64).init();
    std.debug.print("e_tt is {}\n", .{e_tt});

    // try hints();
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
