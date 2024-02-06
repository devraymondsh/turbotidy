const std = @import("std");
const swift_lib = @import("swift_lib");

const turbotidy = @import("turbotidy");
const Lexer = turbotidy.js.Lexer;
const Token = turbotidy.js.tokens.Token;

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

pub fn only_string(allocator: swift_lib.heap.Allocator) !void {
    for (strings, 0..) |string, idx| {
        const tokens: swift_lib.heap.ArrayList(Token) = try Lexer.analyze(
            allocator,
            try allocator.dupe(u8, string),
        );

        try std.testing.expect(std.mem.eql(
            u8,
            @tagName(tokens.mem[0]),
            "strlit",
        ));
        try std.testing.expect(std.mem.eql(
            u8,
            tokens.mem[0].strlit,
            strings[idx][1 .. strings[idx].len - 1],
        ));
    }
}
