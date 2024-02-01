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

pub const Token = union(enum) {
    @"const",
    @"var",
    function,
    identifier: []const u8,
    let,
    numeric_literal: []const u8,
    string_literal: []const u8,
};
