const std = @import("std");
const turbotidy = @import("turbotidy");

const Lexer = turbotidy.js.Lexer;
const Token = turbotidy.js.tokens.Token;
const ArrayList = turbotidy.allocators.ArrayList.ArrayList;

const strings =
    [_][]const u8{
    \\0123456789
    ,
    \\5453
};

pub fn only_number(allocator: turbotidy.allocators.Allocator) !void {
    for (strings, 0..) |string, idx| {
        const tokens: ArrayList(Token) = try Lexer.analyze(
            allocator,
            try allocator.dupe(u8, string),
        );

        try std.testing.expect(std.mem.eql(
            u8,
            @tagName(tokens.mem[0]),
            "numeric_literal",
        ));
        try std.testing.expect(std.mem.eql(
            u8,
            tokens.mem[0].numeric_literal,
            strings[idx],
        ));
    }
}
