const std = @import("std");
const testing = std.testing;
const Fnv1a_32 = std.hash.Fnv1a_32; 

/// comptime string hashing for the type names
pub fn typeId(comptime T: type) u32 {
    return hashStringFnv(u32, @typeName(T));
}

/// Fowler–Noll–Vo string hash. ReturnType should be u32/u64
pub fn hashStringFnv(comptime ReturnType: type, comptime str: []const u8) ReturnType {
    std.debug.assert(ReturnType == u32 or ReturnType == u64);

    return Fnv1a_32.hash(str);
}

pub fn isComptimeIntOrFloat(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .ComptimeInt, .ComptimeFloat => true,
        else => false,
    };
}

test "Fnv1a_32" {
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

    const pos_type_id = comptime typeId(Position);
    const cardsuit_type_id = comptime typeId(CardSuit);
    try testing.expectEqual(0x6e4eb8da, pos_type_id);
    try testing.expectEqual(0x5f6fd78e, cardsuit_type_id);
}