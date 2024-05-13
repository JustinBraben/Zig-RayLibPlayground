const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const Iterator = @import("../core/iterator.zig");
const Utility = @import("../core/utility.zig");

pub const Registry = struct {
    allocator: Allocator,

    pub fn init(allocator: Allocator) Registry {
        return .{
            .allocator = allocator,
        };
    }

    // pub fn create(registry: *Registry) Entity {

    // }

    pub fn deinit(registry: *Registry) void {
        _ = registry;
    }
};