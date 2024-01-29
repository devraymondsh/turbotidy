const builtin = @import("builtin");
const os = @import("os.zig");
pub const root = @import("root");
const writer = @import("writer.zig");

pub var stack: usize = 0;
pub fn Start(comptime entry: anytype) type {
    if (builtin.os.tag == .linux) {
        if (builtin.cpu.arch == .x86_64) {
            return struct {
                pub fn _start() callconv(.Naked) void {
                    asm volatile (
                        \\ xorl %%ebp, %%ebp
                        \\ movq %%rsp, %[stack]
                        \\ andq $-16, %%rsp
                        \\ callq %[start:P]
                        : [stack] "=m" (stack),
                        : [start] "X" (&entry),
                    );
                }
            };
        }
    }
    @compileError("Unsupported OS/CPU!");
}

pub const _start = Start(start)._start;
pub fn start() callconv(.C) noreturn {
    const args_len: usize = @as(*usize, @ptrFromInt(stack)).*;
    const args_addr = stack +% 8;
    const args: [*][*:0]u8 = @ptrFromInt(args_addr);
    const vars: [*][*:0]u8 = @ptrFromInt(args_addr +% ((args_len +% 1) *% 8));
    const vars_len: usize = blk_1: {
        var len: usize = 0;
        while (@intFromPtr(vars[len]) != 0) len +%= 1;
        break :blk_1 len;
    };
    @call(.auto, root.main, .{ args[0..args_len], vars[0..vars_len] });

    os.exit(0);
    unreachable;
}

pub fn panic(msg: []const u8, _: @TypeOf(@errorReturnTrace()), _: ?usize) noreturn {
    @setCold(true);
    var bufwriter = writer.BufWriter(1024).init(0);
    bufwriter.write_many(3, .{ "TurboTidy paniced: ", msg, "\n" });
    bufwriter.flush();

    os.exit(1);
    unreachable;
}

comptime {
    @export(_start, .{ .name = "_start", .linkage = .Strong });
}
