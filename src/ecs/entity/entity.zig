const std = @import("std");
const assert = std.debug.assert;

/// default entity traits
pub const EntityTraits = EntityTraitsType(.medium);

pub const EntityTraitsSize = enum { small, medium, large };

pub fn EntityTraitsType(comptime size: EntityTraitsSize) type {
    return switch (size) {
        .small => @compileError("Oops, " ++ @typeName(size) ++ " is not a implemented size for EntityTraitsType yet."),
        .medium => EntityTraitsDefinition(u32, u32, u16),
        .large => @compileError("Oops, " ++ @typeName(size) ++ " is not a implemented size for EntityTraitsType yet."),
    };
}

fn EntityTraitsDefinition(comptime EntityType: type, comptime IndexType: type, comptime VersionType: type) type {

    const sizeOfIndexType = @bitSizeOf(IndexType);
    const sizeOfVersionType = @bitSizeOf(VersionType);
    const entityShift = sizeOfIndexType;

    // assert that the size of the entity type is the sum of the size of the index and version types
    assert(sizeOfIndexType + sizeOfVersionType == @bitSizeOf(EntityType));

    const entityMask = std.math.maxInt(IndexType);
    const versionMask = std.math.maxInt(VersionType);

    return struct {
        const Self = @This();
        entity_type: EntityType,
        index_type: IndexType,
        version_type: VersionType,
        /// Mask to use to get the entity index number out of an identifier
        entity_mask: EntityType = entityMask,
        /// Mask to use to get the version out of an identifier
        version_mask: EntityType = versionMask,
        /// Bit size of entity in entity_type
        entity_shift: EntityType = entityShift,

        pub fn init() Self {
            return .{};
        }
    };
}