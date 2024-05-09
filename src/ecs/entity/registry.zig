const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

// allow overriding EntityTraits by setting in root via: EntityTraits = EntityTraitsType(.medium);
const root = @import("root");
pub const entity_traits = if (@hasDecl(root, "EntityTraits")) root.EntityTraits.init() else @import("entity.zig").EntityTraits.init();
pub const Entity = entity_traits.entity_type;


const Registry = @This();

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