const builtin = @import("builtin");
const Cli = @import("Cli.zig");
const os = @import("os/os.zig");
const Files = @import("Files.zig");
const writer = @import("os/writer.zig");
const ArenaMmapAlloactor = @import("allocator/ArenaMmapAllocator.zig");

pub usingnamespace @import("os/start.zig");

fn fatal_exit(msg: []const u8) void {
    @setCold(true);
    var bufwriter = writer.BufWriter(1024).init(0);
    bufwriter.write_many(3, .{ "Fatal error: ", msg, "\n" });
    bufwriter.flush();
    os.exit(1);
}

pub fn main(args: [][*:0]u8, env: [][*:0]u8) void {
    const cli = Cli.parse(args, env) catch |err| switch (err) {
        error.InvalidCommand => return fatal_exit("Invalid command."),
        error.NotEnoughArgs => return fatal_exit("Not enough arguments."),
    };

    var arena = ArenaMmapAlloactor.init(1 * 1024 * 1024) catch {
        return fatal_exit("Failed to allocate any memory!");
    };
    const allocator = arena.allocator();

    var files = Files.init();
    files.from_args(allocator, cli.files);
}
