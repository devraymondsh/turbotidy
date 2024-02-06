const swift_lib = @import("swift_lib");

const tokens = @import("tokens.zig");
const Token = tokens.Token;

const Tokenizer = @This();

arraylist: swift_lib.heap.ArrayList(Token),
mem: []u8,
pos: usize = 0,

pub fn init(allocator: swift_lib.heap.Allocator, mem: []u8) swift_lib.heap.Allocator.AllocErr!Tokenizer {
    return Tokenizer{ .arraylist = try swift_lib.heap.ArrayList(Token).init(allocator), .mem = mem, .pos = 0 };
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

fn eql(a: []const u8, b: []const u8) bool {
    for (a, b) |a_elem, b_elem| {
        if (a_elem != b_elem) return false;
    }
    return true;
}

pub fn tokenize_strlit(self: *Tokenizer, dquote: bool) swift_lib.heap.Allocator.AllocErr!void {
    self.pos += 1;
    const starting_pos = self.pos;
    var prev_char = self.mem[self.pos - 1];

    while (self.pos < self.mem.len) : ({
        prev_char = self.mem[self.pos];
        self.pos += 1;
    }) {
        const char = self.mem[self.pos];

        if ((dquote and char == tokens.Dquote) or (!dquote and char == tokens.Quote)) {
            // Handling character escape
            if (prev_char != tokens.Bslash) {
                try self.arraylist.push(Token{ .strlit = self.mem[starting_pos..self.pos] });
            }
        }
    }
}

pub fn tokenize_numlit(self: *Tokenizer) swift_lib.heap.Allocator.AllocErr!void {
    const starting_pos = self.pos;
    self.pos += 1;

    while (self.pos < self.mem.len and
        self.mem[self.pos] >= 48 and self.mem[self.pos] <= 57) : ({
        self.pos += 1;
    }) {}

    return self.arraylist.push(Token{ .numlit = self.mem[starting_pos..self.pos] });
}

pub fn tokenize_identifier(self: *Tokenizer) swift_lib.heap.Allocator.AllocErr!void {
    const starting_pos = self.pos;
    while (self.pos < self.mem.len and
        self.mem[self.pos] != tokens.Space) : ({
        self.pos += 1;
    }) {}
    return self.arraylist.push(Token{ .ident = self.mem[starting_pos..self.pos] });
}

pub fn tokenize_keyword(self: *Tokenizer, comptime kind: Token) swift_lib.heap.Allocator.AllocErr!void {
    const keyword = @tagName(kind);
    const keyword_len = keyword.len;
    if (self.pos + keyword_len < self.mem.len and
        eql(self.mem[self.pos .. self.pos + keyword_len], keyword))
    {
        if (self.mem[self.pos + keyword_len] == tokens.Space) {
            try self.arraylist.push(kind);

            self.pos += keyword_len;
        } else {
            try self.tokenize_identifier();
        }
    }
}

pub fn tokenize_singlechar(self: *Tokenizer, comptime kind: Token) swift_lib.heap.Allocator.AllocErr!void {
    try self.arraylist.push(kind);
    self.pos += 1;
}

pub fn tokenize(self: *Tokenizer) swift_lib.heap.Allocator.AllocErr!swift_lib.heap.ArrayList(Token) {
    while (self.pos < self.mem.len) {
        const char = self.mem[self.pos];

        switch (char) {
            tokens.Dquote => try self.tokenize_strlit(true),
            tokens.Quote => try self.tokenize_strlit(false),
            48...57 => try self.tokenize_numlit(),
            'v' => try self.tokenize_keyword(.@"var"),
            'l' => try self.tokenize_keyword(.let),
            'c' => try self.tokenize_keyword(.@"const"),
            'f' => try self.tokenize_keyword(.function),
            '=' => try self.tokenize_singlechar(.eqlsign),
            ';' => try self.tokenize_singlechar(.semicolon),
            tokens.Space | '\t' | '\n' => {},
            else => try self.tokenize_identifier(),
        }
    }

    return self.arraylist;
}
