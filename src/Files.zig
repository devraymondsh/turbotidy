const os = @import("os/os.zig");
const swift_lib = @import("swift_lib");

const Files = @This();

maps: []os.Mmapf,

const FilesInitError = swift_lib.heap.Allocator.AllocErr || os.Mmapf.MmapfInitError;

pub fn init(allocator: swift_lib.heap.Allocator, args: [][*:0]u8) FilesInitError!Files {
    var maps = try allocator.alloc(os.Mmapf, args.len);

    // Keeping track of how much files are pushed in order to free them in case of failure.
    var pushed: usize = 0;
    for (args, 0..) |arg, idx| {
        maps[idx] = os.Mmapf.init(.ReadOnly, arg) catch |e| {
            var bufprinter = os.BufPrinter(200).init();
            bufprinter.print_many(3, .{ "Failed to read: ", swift_lib.mem.span(arg), "\n" });
            bufprinter.flush();

            return e;
        };
        pushed += 1;
    }

    // Freeing the pushed files on error.
    errdefer for (0..pushed) |idx| maps[idx].deinit();

    return Files{ .maps = maps };
}

pub fn deinit(self: *Files) void {
    for (0..self.maps.len) |idx| self.maps[idx].deinit();
}
