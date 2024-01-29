const builtin = @import("builtin");
const Cli = @import("Cli.zig");
const os = @import("os/os.zig");
const Files = @import("Files.zig");
const writer = @import("os/writer.zig");
const Allocator = @import("allocator/Allocator.zig");
const MmapAllocator = @import("allocator/MmapAllocator.zig");

pub usingnamespace @import("os/start.zig");

fn fatal_exit(msg: []const u8) void {
    @setCold(true);
    var bufwriter = writer.BufWriter(1024).init(0);
    bufwriter.write_many(3, .{ "Fatal error: ", msg, "\n" });
    bufwriter.flush();
    os.exit(1);
}

pub fn main(args: [][*:0]u8, env: [][*:0]u8) void {
    var cli: Cli = undefined;
    if (Cli.parse(args, env)) |c| {
        cli = c;
    } else |err| switch (err) {
        error.InvalidCommand => return fatal_exit("Invalid command."),
        error.NotEnoughArgs => return fatal_exit("Not enough arguments."),
    }

    var mmap_allocator: MmapAllocator = undefined;
    if (MmapAllocator.init(1 * 1024 * 1024)) |m| {
        mmap_allocator = m;
    } else |_| {
        return fatal_exit("Failed to allocate any memory!");
    }
    const allocator = mmap_allocator.allocator();

    var files = Files.init();
    files.from_args(allocator, cli.files);
}
