const std = @import("std");
const turbotidy = @import("turbotidy");

const strings =
    [_][]const u8{
    \\"hi there"
    ,
    \\"hi \"there\""
    ,
    \\"hi \\\"there\""
    ,
    \\'hi there'
    ,
    \\'hi \'there\''
    ,
    \\'hi \\\'there\''
};

test "only-string" {
    var page = try turbotidy.allocators.PageAllocator.init(10);
    defer page.deinit();
    var arena = turbotidy.allocators.ArenaAllocator.init(page.mem);
    const allocator = arena.allocator();

    for (strings, 0..) |string, idx| {
        const str = try allocator.dupe(u8, string);

        const tokens: turbotidy.allocators.ArrayList.ArrayList(turbotidy.js.tokens.Token) = try turbotidy.js.Lexer.analyze(
            allocator,
            str,
        );

        try std.testing.expect(std.mem.eql(
            u8,
            @tagName(tokens.mem[0]),
            "string_literal",
        ));
        try std.testing.expect(std.mem.eql(
            u8,
            tokens.mem[0].string_literal,
            strings[idx][1 .. strings[idx].len - 1],
        ));
    }
}
