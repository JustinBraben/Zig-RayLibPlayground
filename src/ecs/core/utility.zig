const std = @import("std");
const testing = std.testing;
const expect = testing.expect;
const Child = std.meta.Child;

const Utility = @This();

pub fn GetValidEntityTraitsType(UIntData: anytype) type {
    switch (@TypeOf(UIntData)) {
        u16, u32, u64 => |DataType| DataType,
        else => |DataType| @compileError("Unsupported Type " ++ @typeName(DataType) ++ " for EntityTraitsType"),
    }
}

pub fn PrintValidEntityTraitsType(UIntData: anytype) void {
    switch (@TypeOf(UIntData)) {
        u16, u32, u64 => |DataType| std.debug.print("{s} is allowed\n", .{@typeName(DataType)}),
        else => |DataType| @compileError("Unsupported Type " ++ @typeName(DataType) ++ " for EntityTraitsType"),
    }
}

pub fn GetEntityTrait(comptime T: type) type {
    return switch (@typeInfo(T)) {
        .Int, => T,
        .Struct, .Enum => T,
        else => |DataType| @compileError("Unsupported Type " ++ @typeName(DataType) ++ " for this operation"),
    };
}

test "GetEntityTrait" {
    const i: u32 = 1;
    const iType = GetEntityTrait(@TypeOf(i));
    try expect(iType == u32);
}

pub fn PrintAllowedEntityTraits(comptime T: type) void {
    switch (@typeInfo(T)) {
        .Int, =>|DataType| std.debug.print("{s} is allowed, it has {} bits\n", .{@typeName(DataType), DataType.bits}),
        .Struct => std.debug.print("Struct is allowed\n", .{}),
        .Enum => std.debug.print("Enum is allowed\n", .{}),
        else => |DataType| @compileError("Unsupported Type " ++ @typeName(DataType) ++ " for this operation"),
    }
}

pub fn debugPrintType(DataType: anytype) void {
    std.debug.print("DataType is : {}\n", .{@TypeOf(DataType)});
}

pub fn isSlice(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .Pointer => |ptr| ptr.size == .Slice,
        else => false,
    };
}

test "isSlice" {
    const slice: []const u8 = "hello";
    try expect(isSlice(@TypeOf(slice)));
}

pub fn DeepChild(comptime T: type) type {
    // TODO: consider comptime support, should be Immutable only..

    const C = Child(T);

    return switch (@typeInfo(C)) {
        .Int, .Float => C,
        .Array => |a| a.child,
        else => @compileError("Unsupported Type"),
    };
} 

test "DeepChild" {
    const a = [_]i32{1, 2, 3, 4};
    const dc = DeepChild(@TypeOf(a));
    try expect(dc == i32);
}
