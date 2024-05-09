const std = @import("std");
const testing = std.testing;
const expect = testing.expect;
const Child = std.meta.Child;

const Utility = @This();

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
