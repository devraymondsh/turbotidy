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
files: [][*:0]u8,

pub fn parse(args: [][*:0]u8, _: [][*:0]u8) CliParseErr!Cli {
    if (args.len < 3) return error.NotEnoughArgs;

    const files = args[2..args.len];
    if (mem.eql(u8, mem.span(args[1]), "format")) {
        return Cli{ .command = Command.Format, .files = files };
    } else if (mem.eql(u8, mem.span(args[1]), "link")) {
        return Cli{ .command = Command.Lint, .files = files };
    } else {
        return error.InvalidCommand;
    }
}
