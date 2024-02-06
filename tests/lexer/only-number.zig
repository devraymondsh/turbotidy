const std = @import("std");
const swift_lib = @import("swift_lib");

const turbotidy = @import("turbotidy");
const Lexer = turbotidy.js.Lexer;
const Token = turbotidy.js.tokens.Token;

const strings =
    [_][]const u8{
    \\0123456789
    ,
    \\5453
};

pub fn only_number(allocator: swift_lib.heap.Allocator) !void {
    for (strings, 0..) |string, idx| {
        const tokens: swift_lib.heap.ArrayList(Token) = try Lexer.analyze(
            allocator,
            try allocator.dupe(u8, string),
        );

        try std.testing.expect(std.mem.eql(
            u8,
            @tagName(tokens.mem[0]),
            "numlit",
        ));
        try std.testing.expect(std.mem.eql(
            u8,
            tokens.mem[0].numlit,
            strings[idx],
        ));
    }
}
