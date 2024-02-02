const os = @import("../os/os.zig");
const mem = @import("../mem.zig");
const Tokenizer = @import("Tokenizer.zig");
const Allocator = @import("../allocators/Allocator.zig");
const ArrayList = @import("../allocators/ArrayList.zig").ArrayList;

const tokens = @import("tokens.zig");
const Token = tokens.Token;

const Lexer = @This();

pub fn print_tokens(tokens_slice: []const Token) void {
    var bufprinter = os.BufPrinter(100).init();
    bufprinter.print("Printing tokens:\n");
    for (tokens_slice) |token| {
        switch (token) {
            .identifier => bufprinter.println_many(3, .{
                mem.span(@tagName(token)),
                ": ",
                token.identifier,
            }),
            .numeric_literal => bufprinter.println_many(3, .{
                mem.span(@tagName(token)),
                ": ",
                token.numeric_literal,
            }),
            .string_literal => bufprinter.println_many(3, .{
                mem.span(@tagName(token)),
                ": ",
                token.string_literal,
            }),
            else => bufprinter.println(mem.span(@tagName(token))),
        }
        bufprinter.flush();
    }
}

pub fn analyze(allocator: Allocator, file: []u8) Allocator.AllocErr!ArrayList(Token) {
    var tokenizer = try Tokenizer.init(allocator, file);

    return tokenizer.tokenize();
}
