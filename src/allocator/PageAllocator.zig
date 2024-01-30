const builtin = @import("builtin");
const os = @import("../os/os.zig");
const Allocator = @import("Allocator.zig");
const math = @import("../math.zig");

mem: []align(os.page_size) u8,

const PageAllocator = @This();

fn unlikely() void {
    @setCold(true);
}

pub fn init(n: usize) !PageAllocator {
    @setRuntimeSafety(false);
    if (builtin.os.tag == .linux) {
        const mmapsys_res = os.linux.syscall(.mmap, .{
            @as(usize, 0),
            n * os.page_size,
            os.linux.PROT.READ | os.linux.PROT.WRITE,
            os.linux.MAP.ANONYMOUS | os.linux.MAP.PRIVATE,
            0,
            @as(u64, 0),
        });

        if (os.linux.get_errno(mmapsys_res) == .SUCCESS) {
            return PageAllocator{
                .mem = @as(
                    [*]align(os.page_size) u8,
                    @ptrFromInt(mmapsys_res),
                )[0..mmapsys_res],
            };
        }

        return error.FailedToAllocatePage;
    } else @compileError("Unsupported OS/CPU!");
}

pub fn deinit(self: *PageAllocator) void {
    @setRuntimeSafety(false);
    if (builtin.os.tag == .linux) {
        _ = os.linux.syscall(.munmap, .{ @intFromPtr(self.mem.ptr), self.mem.len });
    }
}
