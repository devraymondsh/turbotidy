const Tokenizer = @import("Tokenizer.zig");
const swift_lib = @import("swift_lib");

const Allocator = swift_lib.heap.Allocator;
const ArrayList = swift_lib.heap.ArrayList;

const tokens = @import("tokens.zig");
const Token = tokens.Token;

const Lexer = @This();

pub fn print_tokens(tokens_slice: []const Token) void {
    var bufprinter = swift_lib.os.BufPrinter(100).init();
    bufprinter.print("Printing tokens:\n");
    for (tokens_slice) |token| {
        switch (token) {
            .ident => bufprinter.println_many(3, .{
                swift_lib.mem.span(@tagName(token)),
                ": ",
                token.ident,
            }),
            .numlit => bufprinter.println_many(3, .{
                swift_lib.mem.span(@tagName(token)),
                ": ",
                token.numlit,
            }),
            .strlit => bufprinter.println_many(3, .{
                swift_lib.mem.span(@tagName(token)),
                ": ",
                token.strlit,
            }),
            else => bufprinter.println(swift_lib.mem.span(@tagName(token))),
        }
        bufprinter.flush();
    }
}

pub fn analyze(allocator: Allocator, file: []u8) Allocator.AllocErr!ArrayList(Token) {
    var tokenizer = try Tokenizer.init(allocator, file);

    return tokenizer.tokenize();
}
