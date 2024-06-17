const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

pub fn Storage(comptime ComponentType: type) type {
    return struct {
        const Self = @This();

        allocator: Allocator,
        entity_id_list: std.ArrayList(u32),
        component_list: std.ArrayList(ComponentType),

        pub fn init(allocator: Allocator) Self {
            return Self{
                .allocator = allocator,
                .name = @typeName(ComponentType),
                .entity_id_list = std.ArrayList(u32).init(allocator),
                .component_list = std.ArrayList(ComponentType).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.entity_id_list.deinit();
            self.component_list.deinit();
        }

        /// Adds entity_id to this storage to signify 
        pub fn add(self: *Self, entity: u32, component: ComponentType) void {
            self.entity_id_list.append(entity);
            self.component_list.append(component);
        }
    };
}