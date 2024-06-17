const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;
const Allocator = std.mem.Allocator;
const utils = @import("utils.zig");

const Registry = @import("registry.zig").Registry;

/// Stores an ArrayList of components. The max amount that can be stored is based on the type below
pub fn Storage(comptime CompT: type) type {
    return ComponentStorage(CompT, u32);
}

pub fn ComponentStorage(comptime Component: type, comptime Entity: type) type {
    assert(!utils.isComptimeIntOrFloat(Component));

    // empty (zero-sized) structs will not have an array created
    const is_empty_struct = @sizeOf(Component) == 0;

    const ComponentOrDummy = if (is_empty_struct) struct { dummy: u1 } else Component;

    return struct {
        const Self = @This();

        // TODO: Make this a sparseSet, using Arraylist for now
        set: std.ArrayList(Entity),
        instances: std.ArrayList(ComponentOrDummy),
        allocator: ?Allocator,

        safeDeinit: *const fn (*Self) void,

        registry: *Registry = undefined,

        pub fn init(allocator: Allocator) Self {
            var store = Self{
                .set = std.ArrayList(Entity).init(allocator),
                .instances = undefined,
                .allocator = null,
                .safeDeinit = struct {
                    fn deinit(self: *Self) void {
                        if (!is_empty_struct) {
                            self.instances.deinit();
                        }
                    }
                }.deinit,
            };

            if (!is_empty_struct) {
                store.instances = std.ArrayList(ComponentOrDummy).init(allocator);
            }

            return store;
        }

        pub fn initPtr(allocator: Allocator) *Self {
            var store = allocator.create(Self) catch unreachable;
            store.set = std.ArrayList(Entity).init(allocator);
            if (!is_empty_struct) {
                store.instances = std.ArrayList(ComponentOrDummy).init(allocator);
            }
            store.allocator = allocator;
            
            // since we are stored as a pointer, we need to catpure this
            // having the inner directly in the deinit() will crash 
            store.safeDeinit = struct {
                fn deinit(self:*Self) void {
                    if (!is_empty_struct) {
                        self.instances.deinit();
                    }
                }
            }.deinit;

            return store;
        }

        pub fn deinit(self: *Self) void {
            self.safeDeinit(self);
            self.set.deinit();

            if (self.allocator) |allocator| {
                allocator.destroy(self);
            }
        }

        pub fn add(self: *Self, entity: Entity, value: Component) void {
            if (!is_empty_struct) {
                _ = self.instances.append(value) catch unreachable;
            }
            self.set.append(entity) catch unreachable;
        }
    };
}

test "Storage" {
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

    var pos_storage = Storage(Position).init(testing.allocator);
    var cs_storage = Storage(CardSuit).init(testing.allocator);
    defer pos_storage.deinit();
    defer cs_storage.deinit();

    pos_storage.add(0, Position{.x = 1, .y = 2});
    pos_storage.add(1, Position{.x = 3, .y = 4});
    pos_storage.add(2, Position{.x = 5, .y = 6});
    pos_storage.add(3, Position{.x = 7, .y = 8});
    try testing.expectEqual(4, pos_storage.set.items.len);
}