const std = @import("std");
const assert = std.debug.assert;
const Utility = @import("../core/utility.zig");

/// Default entity traits for the entity and version types.
pub const DefaultEntityTraits = EntityTraits(u32);

/// EntityTraits provides a set of functions to work with entity identifiers.
/// It is a type that is used to define the entity and version types.
pub fn EntityTraits(comptime EntityType: type) type {
    if (@typeInfo(EntityType) != .Int) {
        @compileError("EntityTraits only supports unsigned integer types");
    }

    if (std.meta.Int(.unsigned, @bitSizeOf(EntityType)) != EntityType) {
        @compileError("EntityTraits only supports unsigned integer types");
    }

    const entity_mask: EntityType = switch (EntityType) {
        u32 => std.math.maxInt(u24),
        u64 => std.math.maxInt(u32),
        else => |DataType| @compileError("Invalid EntityType" ++ DataType ++ " for entity_mask"),
    };

    const version_mask: EntityType = switch (EntityType) {
        u32 => std.math.maxInt(u12),
        u64 => std.math.maxInt(u32),
        else => |DataType| @compileError("Invalid EntityType" ++ DataType ++ " for version_mask"),
    };

    assert(entity_mask != 0 and (entity_mask & (entity_mask + 1)) == 0);
    assert((version_mask & (version_mask + 1)) == 0);

    return struct {
        entity_type: type = EntityType,
        entity_mask: EntityType = entity_mask,
        version_mask: EntityType = version_mask,
        length: EntityType = Utility.PopCount(entity_mask),

        const VersionType: type = switch (EntityType) {
            u32 => u16,
            u64 => u32,
            else => |DataType| @compileError("Invalid EntityType" ++ DataType ++ " for VersionType"),
        };

        const Self = @This();

        pub fn init() Self {
            return Self{
                .entity_type = EntityType,
                .entity_mask = entity_mask,
                .version_mask = version_mask,
                .length = Utility.PopCount(entity_mask),
            };
        }
    };
}

test "EntityTraits" {
    const m = EntityTraits(u32).init();
    const l = EntityTraits(u64).init();

    // try std.testing.expectEqual(u32, m.entity_type);
    // try std.testing.expectEqual(u64, l.entity_type);
    // try std.testing.expectEqual(u32, m.value_type);
    // try std.testing.expectEqual(u64, l.value_type);
    // try std.testing.expectEqual(u16, m.version_type);
    // try std.testing.expectEqual(u32, l.version_type);

    try std.testing.expectEqual(std.math.maxInt(u24), m.entity_mask);
    try std.testing.expectEqual(std.math.maxInt(u32), l.entity_mask);

    try std.testing.expectEqual(std.math.maxInt(u12), m.version_mask);
    try std.testing.expectEqual(std.math.maxInt(u32), l.version_mask);
}