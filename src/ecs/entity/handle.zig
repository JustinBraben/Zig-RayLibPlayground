const std = @import("std");
const Allocator = std.mem.Allocator;
const Iterator = @import("../core/iterator.zig");

pub fn Handles(comptime HandleType: type, comptime IndexType: type, comptime VersionType: type) type {
    std.debug.assert(@typeInfo(HandleType) == .Int and std.meta.Int(.unsigned, @bitSizeOf(HandleType)) == HandleType);
    std.debug.assert(@typeInfo(IndexType) == .Int and std.meta.Int(.unsigned, @bitSizeOf(IndexType)) == IndexType);
    std.debug.assert(@typeInfo(VersionType) == .Int and std.meta.Int(.unsigned, @bitSizeOf(VersionType)) == VersionType);

    return struct {
        allocator: Allocator,
        handles: []HandleType,

        const Self = @This();

        pub fn init(allocator: Allocator) Self {
            return initWithCapacity(allocator, 32);
        }

        pub fn initWithCapacity(allocator: Allocator, capacity: usize) Self {
            return Self {
                .allocator = allocator,
                .handles = allocator.alloc(HandleType, capacity) catch unreachable,
            };
        }

        pub fn deinit(self: Self) void {
            self.allocator.free(self.handles);
        }
    };
}