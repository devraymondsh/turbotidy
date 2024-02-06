const std = @import("std");
const swift_lib = @import("swift_lib");

const turbotidy = @import("turbotidy");
const Lexer = turbotidy.js.Lexer;
const Token = turbotidy.js.tokens.Token;

const strings =
    [_][]const u8{
    \\var myVariable = "data";
    ,
};

pub fn var_decl(allocator: swift_lib.heap.Allocator) !void {
    const tokens: swift_lib.heap.ArrayList(Token) = try Lexer.analyze(
        allocator,
        try allocator.dupe(u8, strings[0]),
    );

    std.debug.print("{any}\n", .{tokens.mem});

    try std.testing.expect(std.mem.eql(
        u8,
        @tagName(tokens.mem[0]),
        "var",
    ));
    try std.testing.expect(std.mem.eql(
        u8,
        @tagName(tokens.mem[1]),
        "ident",
    ));
    try std.testing.expect(std.mem.eql(
        u8,
        @tagName(tokens.mem[2]),
        "eqlsign",
    ));
    try std.testing.expect(std.mem.eql(
        u8,
        @tagName(tokens.mem[3]),
        "strlit",
    ));
    try std.testing.expect(std.mem.eql(
        u8,
        @tagName(tokens.mem[4]),
        "semicolon",
    ));
}
