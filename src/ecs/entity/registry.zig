const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;
const utils = @import("utils.zig");
const Storage = @import("component_storage.zig").Storage;

pub const Registry = struct {
    const Self = @This();

    allocator: Allocator,
    available_entities: std.ArrayList(u32),
    type_set: std.StringHashMap(void),
    components: std.AutoHashMap(u32, usize),

    pub fn init(allocator: Allocator) Self {
        return Self{
            .allocator = allocator,
            .available_entities = std.ArrayList(u32).init(allocator),
            .type_set = std.StringHashMap(void).init(allocator),
            .components = std.AutoHashMap(u32, usize).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        var iter = self.components.valueIterator();
        while(iter.next()) |ptr| {
            var storage = @as(*Storage(u1), @ptrFromInt(ptr.*));
            storage.deinit();
        }

        self.components.deinit();
        self.available_entities.deinit();
        self.type_set.deinit();
    }

    pub fn assure(self: *Registry, comptime T: type) *Storage(T) {
        if (@typeInfo(@TypeOf(T)) == .Pointer) {
            @compileError("assure must receive a value, not a pointer. Received: " ++ @typeName(T));
        }

        // Found type in components hashmap, we have already initialized a pointer for it
        // Use that pointer
        const type_id = comptime utils.typeId(T);
        if (self.components.getEntry(type_id)) |kv| {
            std.debug.print("Found : {} type in components, we have already initialized a pointer for it\n", .{kv});
            return @as(*Storage(T), @ptrFromInt(kv.value_ptr.*));
        }

        // No component storage found for T, must create a pointer for it and add to components hashmap
        const comp_set = Storage(T).initPtr(self.allocator);
        comp_set.registry = self;
        const comp_set_ptr = @intFromPtr(comp_set);
        _ = self.components.put(type_id, comp_set_ptr) catch unreachable;
        return comp_set;

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

        var storage = self.assure(@TypeOf(datatype_args));
        storage.add(entity_id, datatype_args);
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

    try testing.expectEqual(2, reg.type_set.count());
    try testing.expectEqual(2, reg.components.count());
}