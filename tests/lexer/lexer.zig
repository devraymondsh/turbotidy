const swift_lib = @import("swift_lib");

const only_string = @import("only-string.zig").only_string;
const only_number = @import("only-number.zig").only_number;
const var_decl = @import("var-decl.zig").var_decl;

test "lexer" {
    var page = try swift_lib.heap.PageAllocator.init(200);
    defer page.deinit();
    var arena = swift_lib.heap.ArenaAllocator.init(page.mem);
    const allocator = arena.allocator();

    try only_string(allocator);
    try only_number(allocator);
    try var_decl(allocator);
}
