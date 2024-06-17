const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;
const utils = @import("utils.zig");

pub fn EntityTraits(comptime EntityType: type) type {
    assert(utils.isU32orU64(EntityType));
    const value_type = EntityType;
    const entity_type = if (EntityType == u32) u32 else u64;
    const version_type = if (EntityType == u32) u16 else u32;
    const EntityMask: entity_type = if (entity_type == u64) std.math.maxInt(u32) else std.math.maxInt(u20);
    const VersionMask: entity_type = if (entity_type == u64) std.math.maxInt(u32) else std.math.maxInt(u12);

    return struct {
        const Self = @This();

        entity_mask: entity_type,
        version_mask: entity_type,
        length: entity_type,

        pub fn init() Self {
            return Self{
                .entity_mask = EntityMask,
                .version_mask = VersionMask,
                .length = @as(entity_type, utils.popCount(EntityMask)),
            };
        }

        /// Converts an entity to its underlying type. 
        /// The given `value` will be coerced to type `entity_type` and returned.
        pub fn to_integral(self: *Self, value: value_type) entity_type {
            _ = self;
            return @as(entity_type, value);
        }

        /// Returns the entity part once converted to the underlying type.
        pub fn to_entity(self: *Self, value: value_type) entity_type {
            return (self.to_integral(value) & self.entity_mask);
        }

        // TODO: FIXME
        /// Returns the version part once converted to the underlying type.
        pub fn to_version(self: *Self, value: value_type) version_type {
            if (self.version_mask == 0) {
                return @as(version_type, 0);
            }
            // return @intCast(@as(version_type, self.to_integral(value) >> @intCast(@as(version_type, self.length))) & self.version_mask);
            return (@as(version_type, value) >> @intCast(@as(version_type, self.length))) & self.version_mask;
        }

        /// Returns the successor of a given identifier.
        pub fn next(self: *Self, value: value_type) value_type {
            const vers = self.to_version(value) + 1;
            const versEqlVersionMask = vers == self.version_mask;
            // If vers equals version_mask, add 1, else add nothing
            const valToAdd: value_type = if (versEqlVersionMask) 1 else 0;
            return self.construct(self.to_integral(value), @as(version_type, (vers + valToAdd)));
        }

        /// Constructs an identifier from its parts.
        pub fn construct(self: *Self, entity: entity_type, version: version_type) value_type {
            if (self.version_mask == 0) {
                return entity & self.entity_mask;
            }
            std.debug.print("self.length type is {}\n", .{@TypeOf(self.length)});
            return (entity & self.entity_mask) | (self.to_integral(version & self.version_mask) << @intCast(@as(entity_type, self.length)));
        }
    };
}

test "Entity 32 Traits" {
    var entity_32 = EntityTraits(u32).init();
    // var entity_64 = EntityTraits(u64).init();

    try testing.expectEqual(std.math.maxInt(u20), entity_32.entity_mask);
    try testing.expectEqual(std.math.maxInt(u12), entity_32.version_mask);
    try testing.expectEqual(20, entity_32.length);

    // try testing.expectEqual(std.math.maxInt(u32), entity_64.entity_mask);
    // try testing.expectEqual(std.math.maxInt(u32), entity_64.version_mask);
    // try testing.expectEqual(32, entity_64.length);

    const entt = entity_32.construct(4, 1);
    const other = entity_32.construct(3, 0);

    try testing.expectEqual(entity_32.to_integral(entt), entity_32.to_integral(entt));

    try testing.expectEqual(4, entity_32.to_entity(entt));
    // try testing.expectEqual(1, entity_32.to_version(entt));

    try testing.expectEqual(3, entity_32.to_entity(other));
    // try testing.expectEqual(0, entity_32.to_version(other));
}