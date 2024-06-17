const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

pub const Registry = struct {
    const Self = @This();

    allocator: Allocator,
    available_entities: std.ArrayList(u32),
    type_set: std.StringHashMap(void),

    pub fn init(allocator: Allocator) Self {
        return Self{
            .allocator = allocator,
            .available_entities = std.ArrayList(u32).init(allocator),
            .type_set = std.StringHashMap(void).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.available_entities.deinit();
        self.type_set.deinit();
    }

    pub fn create(self: *Self) u32 {
        const new_entity_id = @as(u32, @intCast(self.available_entities.items.len));

        defer self.available_entities.append(new_entity_id) catch unreachable;
        return new_entity_id;
    }

    pub fn emplace(self: *Self, entity_id: u32, datatype_args: anytype) void {
        std.debug.print("Attempting to add to entity {}\n", .{entity_id});
        std.debug.print("There are this many available entities {}\n", .{self.available_entities.items.len});
        std.debug.print("Attempting to use datatype_args {}\n", .{datatype_args});

        const datatype_args_str = @typeName(@TypeOf(datatype_args));

        if (self.type_set.get(datatype_args_str) == null) {
            std.debug.print("{s} not found in type_store, adding...\n", .{datatype_args_str});

            self.type_set.put(datatype_args_str, {}) catch unreachable;
        }
    }
};

test "Basic" {
    var reg = Registry.init(testing.allocator);
    defer reg.deinit();

    const e_1 = reg.create();
    const e_2 = reg.create();
    const e_3 = reg.create();

    try testing.expectEqual(0, e_1);
    try testing.expectEqual(1, e_2);
    try testing.expectEqual(2, e_3);

    const Position = struct {
        x: f32,
        y: f32,
    };

    const CardSuit = enum {
        Hearts,
        Diamonds,
        Spades,
        Clubs,
    };

    reg.emplace(e_1, Position{.x = 10.5, .y = 20.2});
    reg.emplace(e_1, CardSuit.Hearts);
}