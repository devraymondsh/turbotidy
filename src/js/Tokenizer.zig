const os = @import("../os/os.zig");
const Allocator = @import("../allocators/Allocator.zig");
const ArrayList = @import("../allocators/ArrayList.zig").ArrayList;

const tokens = @import("tokens.zig");
const Token = tokens.Token;

const Tokenizer = @This();

allocator: Allocator,
mem: []u8,
pos: usize = 0,

pub fn init(allocator: Allocator, mem: []u8) Tokenizer {
    return Tokenizer{ .allocator = allocator, .mem = mem, .pos = 0 };
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

pub fn tokenize(self: *Tokenizer) Allocator.AllocErr!ArrayList(Token) {
    var tokens_slice = try ArrayList(Token).init(self.allocator);

    var is_in_state = false;
    var state_pos: usize = 0;
    while (self.pos < self.mem.len) : (self.pos += 1) {
        const char = self.mem[self.pos];

        if (char == tokens.Space) {
            continue;
        }

        if (is_quote_alpah(char)) {
            if (is_in_state) {
                try tokens_slice.push(Token{ .string_literal = self.mem[state_pos..self.pos] });
                is_in_state = false;
            } else {
                is_in_state = true;
                state_pos = self.pos + 1;
            }
        } else {
            //
        }
    }

    return tokens_slice;
}
