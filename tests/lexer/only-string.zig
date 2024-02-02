const std = @import("std");
const turbotidy = @import("turbotidy");

const Lexer = turbotidy.js.Lexer;
const Token = turbotidy.js.tokens.Token;
const ArrayList = turbotidy.allocators.ArrayList.ArrayList;

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

pub fn only_string(allocator: turbotidy.allocators.Allocator) !void {
    for (strings, 0..) |string, idx| {
        const tokens: ArrayList(Token) = try Lexer.analyze(
            allocator,
            try allocator.dupe(u8, string),
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
