const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const Iterator = @import("../core/iterator.zig");
const Utility = @import("../core/utility.zig");
const Entity = @import("entity.zig");

pub const Registry = struct {
    allocator: Allocator,
    entt_traits: Entity.EntityTraits(u32),

    pub fn init(allocator: Allocator) Registry {
        return .{
            .allocator = allocator,
            .entt_traits = Entity.EntityTraits(u32).init(),
        };
    }

    // pub fn create(registry: *Registry) Entity {

    // }

    pub fn deinit(registry: *Registry) void {
        _ = registry;
    }
};

test "Registry" {
    var registry = Registry.init(std.testing.allocator);
    defer registry.deinit();
}