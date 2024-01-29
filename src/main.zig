const builtin = @import("builtin");
const Cli = @import("Cli.zig");
const math = @import("math.zig");
const os = @import("os/os.zig");
const writer = @import("os/writer.zig");

pub usingnamespace @import("os/start.zig");

fn fatal_exit(msg: []const u8) void {
    @setCold(true);
    var bufwriter = writer.BufWriter(1024).init(0);
    bufwriter.write_many(3, .{ "Fatal error: ", msg, "\n" });
    bufwriter.flush();
    os.exit(1);
}

pub fn main(args: [][*:0]u8, env: [][*:0]u8) void {
    const cli = Cli.parse(args, env);
    if (cli) |_| {} else |err| switch (err) {
        error.InvalidCommand => return fatal_exit("Invalid command."),
        error.NotEnoughArgs => return fatal_exit("Not enough arguments."),
    }
}
