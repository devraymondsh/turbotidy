const builtin = @import("builtin");
const Cli = @import("Cli.zig");
const os = @import("os/os.zig");
const Files = @import("Files.zig");
const printer = @import("os/printer.zig");
const mem = @import("mem.zig");
const Allocator = @import("allocators/Allocator.zig");
const ArenaAllocator = @import("allocators/ArenaAllocator.zig");
const PageAllocator = @import("allocators/PageAllocator.zig");
const Lexer = @import("js/Lexer.zig");

pub usingnamespace @import("os/start.zig");

fn fatal_exit(msg: []const u8) void {
    @setCold(true);
    var bufprinter = printer.BufPrinter(1024).init();
    bufprinter.print_many(3, .{ "TurboTidy exited with a fatal error: ", msg, "\n" });
    bufprinter.flush();
    os.exit(1);
}

pub fn main(args: [][*:0]u8, env: [][*:0]u8) void {
    const cli = Cli.parse(args, env) catch |e| switch (e) {
        error.InvalidCommand => return fatal_exit("Invalid command."),
        error.NotEnoughArgs => return fatal_exit("Not enough arguments."),
    };

    var page = PageAllocator.init(2) catch {
        return fatal_exit("Failed to allocate any memory");
    };
    defer page.deinit();
    var arena = ArenaAllocator.init(page.mem);
    const allocator = arena.allocator();

    var files = Files.init(allocator, cli.files) catch |e| switch (e) {
        error.OutOfMemory => return fatal_exit("Failed to allocate memory."),
        else => return fatal_exit("Unable to open the file."),
    };
    defer files.deinit();

    for (files.maps) |map| {
        const tokens_slice = Lexer.analyze(allocator, map.mem) catch {
            return fatal_exit("Unable allocate memory.");
        };
        Lexer.print_tokens(tokens_slice.mem);
    }
}
