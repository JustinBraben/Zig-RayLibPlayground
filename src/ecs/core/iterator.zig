const std = @import("std");

const Iterator = @This();

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

        ptr: DataType,
        end: DataType,
        stride: usize,

        pub fn next(self: *Self) ?DataType {
            switch(comptime Mode) {
                .forward => {
                    if (self.ptr < self.end) {
                        defer self.ptr += self.stride;
                        return self.ptr;
                    }
                },
                .reverse => {
                    if (self.ptr > self.end) {
                        defer self.ptr -= self.stride;
                        return self.ptr;
                    }
                },
            }
            return null;
        }
    };
}