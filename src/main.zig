const builtin = @import("builtin");
const Cli = @import("Cli.zig");
const Files = @import("Files.zig");
const Lexer = @import("js/Lexer.zig");
const swift_lib = @import("swift_lib");

pub usingnamespace swift_lib.start;

fn fatal_exit(msg: []const u8) void {
    @setCold(true);
    var bufprinter = swift_lib.os.BufPrinter(1024).init();
    bufprinter.print_many(3, .{ "TurboTidy exited with a fatal error: ", msg, "\n" });
    bufprinter.flush();
    swift_lib.os.exit(1);
}

pub fn main(args: [][*:0]u8, env: [][*:0]u8) void {
    const cli = Cli.parse(args, env) catch |e| switch (e) {
        error.InvalidCommand => return fatal_exit("Invalid command."),
        error.NotEnoughArgs => return fatal_exit("Not enough arguments."),
    };

    var page = swift_lib.heap.PageAllocator.init(2) catch {
        return fatal_exit("Failed to allocate any memory");
    };
    defer page.deinit();
    var arena = swift_lib.heap.ArenaAllocator.init(page.mem);
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
