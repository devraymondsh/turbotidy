const os = @import("os/os.zig");
const mem = @import("mem.zig");
const math = @import("math.zig");

const Cli = @This();

pub const Command = enum {
    Format,
    Lint,
};
pub const CliParseErr = error{
    NotEnoughArgs,
    InvalidCommand,
};

command: Command,

pub fn parse(args: [][*:0]u8, _: [][*:0]u8) CliParseErr!Cli {
    if (args.len < 3) return error.NotEnoughArgs;
    if (mem.eql(u8, mem.span(args[1]), "format")) {
        return Cli{ .command = Command.Format };
    } else if (mem.eql(u8, mem.span(args[1]), "link")) {
        return Cli{ .command = Command.Lint };
    } else {
        return error.InvalidCommand;
    }
}
