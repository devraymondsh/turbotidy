pub const Newln = '\n';
pub const Space = ' ';
pub const Quote = '\'';
pub const Dquote = '"';
pub const Obrace = '{';
pub const Cbrace = '}';
pub const Oparan = '(';
pub const Cparan = ')';
pub const Obrack = '[';
pub const Cbrack = ']';
pub const Slash = '/';
pub const Bslash = '\\';
pub const SemiCol = ';';

pub const Token = union(enum) {
    @"const",
    @"var",
    function,
    ident: []const u8,
    let,
    semicolon,
    eqlsign,
    numlit: []const u8,
    strlit: []const u8,
};
