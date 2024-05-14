const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const Iterator = @import("../core/iterator.zig");
const Utility = @import("../core/utility.zig");

pub const entity_traits = @import("entity.zig").DefaultEntityTraits.init();
pub const Entity = entity_traits.entity_type;

pub const Registry = struct {
    allocator: Allocator,
    entities: std.ArrayList(Entity),
    // entities: StorageForType(Entity.EntityTraits(u32)) ,
    // entt_traits: Entity.EntityTraits(u32),

    pub fn init(allocator: Allocator) Registry {
        return .{
            .allocator = allocator,
            .entities = std.ArrayList(Entity).init(allocator),
        };
    }

    pub fn create(registry: *Registry) Entity {
        if (registry.entities.items.len == 0) {
            defer registry.entities.append(@as(Entity, 1)) catch unreachable;
            return @as(Entity, 0);
        }
        defer registry.entities.append(registry.entities.getLast() + 1) catch unreachable;
        return registry.entities.getLast();
    }

    pub fn deinit(registry: *Registry) void {
        registry.entities.deinit();
    }
};

test "Registry" {
    var registry = Registry.init(std.testing.allocator);
    const e_1 = registry.create();
    try testing.expectEqual(0, e_1);
    defer registry.deinit();
}