const std = @import("std");
const testing = std.testing;
const expect = testing.expect;
const Utility = @import("utility.zig");

const Iterator = @This();

pub const IteratorMode = enum { forward, reverse };

pub fn BaseIterator(comptime T: type, mode: IteratorMode) type {
    return IteratorInterface(T, mode);
}

pub fn iterator(
    comptime mode: IteratorMode,
    items: anytype,
) BaseIterator(Utility.DeepChild(@TypeOf(items)), mode) {
    const T = Utility.DeepChild(@TypeOf(items));

    if (comptime !Utility.isSlice(@TypeOf(items))) {
        return iterator(mode, @as([]const T, items));
    }

    const P = [*]const T;

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

        /// strided - set iterator stride (default 1)
        pub fn strided(
            self: Self,
            stride_size: usize,
        ) Self {
            return .{
                .ptr = self.ptr,
                .end = self.end,
                .stride = stride_size,
            };
        }

        /// window - return a slice and advance by stride
        pub fn window(
            self: *Self,
            window_size: usize,
        ) ?[]const DataType {
            switch (comptime Mode) {
                .forward => {
                    if (self.ptr + window_size <= self.end) {
                        defer _ = self.next();
                        return self.ptr[0..window_size];
                    }
                },
                .reverse => {
                    if ((self.ptr + 1) - window_size > self.end) {
                        defer _ = self.next();
                        return ((self.ptr + 1) - window_size)[0..window_size];
                    }
                },
            }
            return null;
        }
    };
}

test "iterator basic" {
    {
        var itr = iterator(.forward, "hello");
        try std.testing.expectEqual(itr.next().?, 'h');
    }
    {
        const arr = [_]u8{1, 2, 3, 4, 5};
        var itr = iterator(.reverse, &arr);
        try std.testing.expectEqual(itr.next().?, 5);
        try std.testing.expectEqual(itr.next().?, 4);
        try std.testing.expectEqual(itr.next().?, 3);
        try std.testing.expectEqual(itr.next().?, 2);
        try std.testing.expectEqual(itr.next().?, 1);
    }
    {
        var arr = [_]i32{1, 2, 3, 4, 5};
        var itr = iterator(.reverse, &arr);
        try std.testing.expectEqual(itr.next().?, 5);
        try std.testing.expectEqual(itr.next().?, 4);
        try std.testing.expectEqual(itr.next().?, 3);
        try std.testing.expectEqual(itr.next().?, 2);
        try std.testing.expectEqual(itr.next().?, 1);
    }
}

test "iterator stride" {
    {
        var arr = [_]i32{2, 4, 6, 8, 10, 12, 14};
        var itr = iterator(.reverse, &arr);
        itr = itr.strided(2);
        try std.testing.expectEqual(itr.next().?, 14);
        try std.testing.expectEqual(itr.next().?, 10);
        try std.testing.expectEqual(itr.next().?, 6);
    }
}