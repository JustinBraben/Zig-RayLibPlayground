// include all files with tests
comptime {
    // core
    _ = @import("entity/registry.zig");
    _ = @import("entity/component_storage.zig");
    _ = @import("entity/utils.zig");
}