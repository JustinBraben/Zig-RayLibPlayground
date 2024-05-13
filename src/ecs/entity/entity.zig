const std = @import("std");
const assert = std.debug.assert;
const Utility = @import("../core/utility.zig");

/// default EntityTraitsDefinition with reasonable sizes suitable for most situations
pub const DefaultEntityTraits = EntityTraitsType(u32);

pub fn EntityTraitsType(comptime UIntDataType: type) type {
    // const ValidUintDataType = Utility.GetValidEntityTraitsType(UIntDataType);
    return switch (UIntDataType) {
        // u16 => EntityTraitsDefinition(u16, u16, u8), 
        u32 => EntityTraitsDefinition(u32, u32, u16),
        u64 => EntityTraitsDefinition(u64, u64, u32),
        else => |DataType| @compileError("Invalid UIntDataType" ++ DataType ++ " for EntityTraitsType"),
    };
}

fn EntityTraitsDefinition(comptime EntityType: type, comptime ValueType: type, comptime VersionType: type) type {
    assert(@typeInfo(EntityType) == .Int and std.meta.Int(.unsigned, @bitSizeOf(EntityType)) == EntityType);
    assert(@typeInfo(ValueType) == .Int and std.meta.Int(.unsigned, @bitSizeOf(ValueType)) == ValueType);
    assert(@typeInfo(VersionType) == .Int and std.meta.Int(.unsigned, @bitSizeOf(VersionType)) == VersionType);

    const sizeOfValueType = @bitSizeOf(ValueType);
    // const sizeOfVersionType = @bitSizeOf(VersionType);
    const entityShift = sizeOfValueType;

    const entityMaskType = if(EntityType == u64) u64 else u32;
    const versionMaskType = if(VersionType == u32) u32 else u16;

    const entityMask = if (EntityType == u64) std.math.maxInt(u32) else std.math.maxInt(u24);
    const versionMask = if (VersionType == u32) std.math.maxInt(u32) else std.math.maxInt(u12);

    // assert entity mask is not 0
    // assert entity mask and entity mask + 1 have no common set bits
    // Success means entity mask is a power of 2
    const entityMaskPowerOfTwo: bool = (entityMask != 0 and (entityMask & (entityMask + 1)) == 0);
    assert(entityMaskPowerOfTwo);

    // assert version mask and version mask + 1 have no common set bits
    // Success means version mask is a power of 2
    const versionMaskPowerOfTwo: bool = ((versionMask & (versionMask + 1)) == 0);
    assert(versionMaskPowerOfTwo);

    return struct {
        entity_type: type = EntityType,
        value_type: type = ValueType,
        version_type: type = VersionType,
        /// Mask to use to get the entity index number out of an identifier
        entity_mask: entityMaskType = entityMask,
        /// Mask to use to get the version out of an identifier
        version_mask: versionMaskType = versionMask,
        /// Bit size of entity in entity_type
        entity_shift: EntityType = entityShift,

        pub fn init() @This() {
            return @This(){};
        }
    };
}

test "entity traits" {
    // const sm = EntityTraitsType(u16).init();
    const m = EntityTraitsType(u32).init();
    const l = EntityTraitsType(u64).init();

    // try std.testing.expectEqual(std.math.maxInt(sm.value_type), sm.entity_mask);
    try std.testing.expectEqual(std.math.maxInt(u24), m.entity_mask);
    try std.testing.expectEqual(std.math.maxInt(u32), l.entity_mask);

    
    try std.testing.expectEqual(std.math.maxInt(u8), m.entity_type);
    try std.testing.expectEqual(u32, m.value_type);
    try std.testing.expectEqual(u64, l.value_type);
}