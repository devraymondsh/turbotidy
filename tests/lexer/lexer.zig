const turbotidy = @import("turbotidy");
const only_string = @import("only-string.zig").only_string;
const only_number = @import("only-number.zig").only_number;

const PageAllocator = turbotidy.allocators.PageAllocator;
const ArenaAllocator = turbotidy.allocators.ArenaAllocator;

test "lexer" {
    var page = try PageAllocator.init(10);
    defer page.deinit();
    var arena = ArenaAllocator.init(page.mem);
    const allocator = arena.allocator();

    try only_string(allocator);
    try only_number(allocator);
}
