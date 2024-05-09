const std = @import("std");
const testing = std.testing;
const expect = testing.expect;
const Utility = @import("utility.zig");

const Iterator = @This();

pub fn iterator(
    comptime mode: IteratorMode,
    items: anytype,
) BaseIterator(Utility.DeepChild(@TypeOf(items)), mode) {
    const T = Utility.DeepChild(@TypeOf(items));

    if (comptime !Utility.isSlice(@TypeOf(items))) {
        return iterator(mode, @as([]const T, items));
    }

    const P = [*c]const T;

    const ptr: P = if (comptime mode == .forward)
        @as(P, @ptrCast(items.ptr)) else (@as(P, @ptrCast(items.ptr)) + items.len) - 1;

    const end: P = if (comptime mode == .forward)
        @as(P, @ptrCast(items.ptr)) + items.len else @as(P, @ptrCast(items.ptr)) - 1;

    return .{
        .ptr = ptr,
        .end = end,
        .stride = 1,
    };
}

pub const IteratorMode = enum { forward, reverse };

pub fn BaseIterator(comptime T: type, mode: IteratorMode) type {
    return IteratorInterface(T, mode);
}

////////////////////////////////////////////////////////////////////////////////
//                        Backends and Implementation                         //
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Iterator Interface Implementation:                                         //
////////////////////////////////////////////////////////////////////////////////

fn IteratorInterface(
    comptime DataType: type,
    mode: IteratorMode,
    // comptime filters: anytype, // tuple or function
    // comptime transforms: anytype, // tuple or function
) type {
    return struct {
        const Self = @This();
        const Mode = mode;

        ptr: [*c]const DataType,
        end: [*c]const DataType,
        stride: usize,

        pub fn next(self: *Self) ?DataType {
            switch(comptime Mode) {
                .forward => {
                    if (self.ptr < self.end) {
                        defer self.ptr += self.stride;
                        return self.ptr.*;
                    }
                },
                .reverse => {
                    if (self.ptr > self.end) {
                        defer self.ptr -= self.stride;
                        return self.ptr.*;
                    }
                },
            }
            return null;
        }
    };
}

test "Iterator" {
    var itr = iterator(.forward, "hello");
    try std.testing.expectEqual(itr.next().?, 'h');
}