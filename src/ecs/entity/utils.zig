const std = @import("std");
const testing = std.testing;
const builtin = std.builtin;
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

pub fn isU32orU64(comptime T: type) bool {
    if (T == u32) {
        return true;
    }
    if (T == u64) {
        return true;
    }

    return false;
}

pub fn popCount(value: anytype) @TypeOf(value) {
    const ReturnType = @TypeOf(value);
    return if (value > 0) @as(ReturnType, (@as(ReturnType, (value & 1)) + popCount(@as(ReturnType, value >> 1)))) else @as(ReturnType, 0);
}

test "popCount" {
    const num1: u32 = 1000;
    const num2: u16 = 0b1001011;

    const num1_pop = popCount(num1);
    const num2_pop = popCount(num2);

    try testing.expectEqual(6, num1_pop);
    try testing.expectEqual(4, num2_pop);
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