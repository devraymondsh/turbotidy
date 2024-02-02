const os = @import("../os/os.zig");
const Allocator = @import("../allocators/Allocator.zig");
const ArrayList = @import("../allocators/ArrayList.zig").ArrayList;

const tokens = @import("tokens.zig");
const Token = tokens.Token;

const Tokenizer = @This();

arraylist: ArrayList(Token),
mem: []u8,
pos: usize = 0,

pub fn init(allocator: Allocator, mem: []u8) Allocator.AllocErr!Tokenizer {
    return Tokenizer{ .arraylist = try ArrayList(Token).init(allocator), .mem = mem, .pos = 0 };
}

fn is_quote_alpah(char: u8) bool {
    return char == tokens.Dquote or char == tokens.Quote;
}
fn is_opening_alpha(char: u8) bool {
    return char == tokens.Oparan or char == tokens.Obrace;
}
fn is_closing_alpha(char: u8) bool {
    return char == tokens.Cparan or char == tokens.Cbrace;
}

pub fn tokenize_strlit(self: *Tokenizer, dquote: bool) Allocator.AllocErr!void {
    self.pos += 1;
    const starting_pos = self.pos;
    var prev_char = self.mem[self.pos - 1];
    while (self.pos < self.mem.len) : ({
        prev_char = self.mem[self.pos];
        self.pos += 1;
    }) {
        const char = self.mem[self.pos];

        if ((dquote and char == tokens.Dquote) or (!dquote and char == tokens.Quote)) {
            if (prev_char != tokens.Bslash) {
                try self.arraylist.push(Token{ .string_literal = self.mem[starting_pos..self.pos] });
            }
        }
    }
}

pub fn tokenize(self: *Tokenizer) Allocator.AllocErr!ArrayList(Token) {
    while (self.pos < self.mem.len) : (self.pos += 1) {
        const char = self.mem[self.pos];

        switch (char) {
            tokens.Dquote => try self.tokenize_strlit(true),
            tokens.Quote => try self.tokenize_strlit(false),
            else => {},
        }
    }

    return self.arraylist;
}
