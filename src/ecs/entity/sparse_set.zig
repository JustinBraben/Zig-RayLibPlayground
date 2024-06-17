const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;
const Allocator = std.mem.Allocator;
const utils = @import("utils.zig");
const registry = @import("registry.zig");

pub fn SparseSet(comptime SparseType: type) type {
    return struct {
        const Self = @This();

        sparse: std.ArrayList(?[]SparseType),
        dense: std.ArrayList(SparseType),
        entity_mask: SparseType,
        allocator: ?Allocator,

        pub fn init(allocator: Allocator) Self {
            return Self{
                .sparse = std.ArrayList(?[]SparseType).init(allocator),
                .dense = std.ArrayList(SparseType).init(allocator),
                // TODO: set entity_mask properly
                .entity_mask = 2,
                .allocator = null,
            };
        }

        pub fn initPtr(allocator: Allocator) *Self {
            var set = allocator.create(Self) catch unreachable;
            set.sparse = std.ArrayList(?[]SparseType).initCapacity(allocator, 16) catch unreachable;
            set.dense = std.ArrayList(SparseType).initCapacity(allocator, 16) catch unreachable;
            // TODO: set entity_mask properly
            set.entity_mask = 2;
            set.allocator = allocator;
            return set;
        }

        pub fn deinit(self: *Self) void {
            for (self.sparse.items) |array| {
                if (array) |arr| {
                    self.sparse.allocator.free(arr);
                }
            }

            self.dense.deinit();
            self.sparse.deinit();

            if (self.allocator) |allocator| {
                allocator.destroy(self);
            }
        }
    };
}

test "init/deinit" {
    var set_1 = SparseSet(u32).init(testing.allocator);
    defer set_1.deinit();

    var set_2 = SparseSet(u32).initPtr(testing.allocator);
    defer set_2.deinit();
}