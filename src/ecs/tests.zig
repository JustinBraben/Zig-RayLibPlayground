// include all files with tests
comptime {
    // core
    _ = @import("core/iterator.zig");
    _ = @import("core/utility.zig");
    _ = @import("entity/entity.zig");
    _ = @import("entity/registry.zig");
}