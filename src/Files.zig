const Allocator = @import("allocator/Allocator.zig");

const Files = @This();

descripters: []i32,

pub fn init() Files {
    return Files{
        .descripters = undefined,
    };
}

pub fn from_args(self: *Files, allocator: Allocator, args: [][*:0]u8) void {
    _ = allocator; // autofix
    _ = self; // autofix
    _ = args; // autofix
}
