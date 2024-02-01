const std = @import("std");
const turbotidy = @import("turbotidy");

const string align(8) =
    \\"hi there"
;

test "only-string" {
    var page = try turbotidy.allocators.PageAllocator.init(2);
    defer page.deinit();
    var arena = turbotidy.allocators.ArenaAllocator.init(page.mem);
    const allocator = arena.allocator();

    const str = try allocator.dupe(u8, string);

    const tokens = try turbotidy.js.Lexer.analyze(allocator, str);

    turbotidy.js.Lexer.print_tokens(tokens);
}
