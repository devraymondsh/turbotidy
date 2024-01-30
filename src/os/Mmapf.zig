const builtin = @import("builtin");
const os = @import("os.zig");

const MmapMemProt = enum {
    ReadOnly,
    ReadAndWrite,
    WriteOnly,
};

const Mmapf = @This();

fn unlikely() void {
    @setCold(true);
}

mem: []align(os.page_size) u8,

pub const MmapfInitError = error{
    EmptyFile,
    FailedToOpenTheFile,
    FailedToReadTheMetadata,
    FailedToMapTheFileToMemory,
};

/// Maps a file to memory
pub fn init(comptime kind: MmapMemProt, path: [*:0]const u8) MmapfInitError!Mmapf {
    @setRuntimeSafety(false);
    if (builtin.os.tag == .linux) {
        const opensys_res = os.linux.syscall(.open, .{
            @intFromPtr(path),
            switch (kind) {
                .ReadOnly => os.linux.O.RDONLY,
                .WriteOnly => os.linux.O.WRONLY,
                .ReadAndWrite => os.linux.O.RDWR,
            },
            0,
        });
        if (os.linux.get_errno(opensys_res) != .SUCCESS) {
            return error.FailedToOpenTheFile;
        }

        var fstatbuf: os.linux.stat = undefined;
        const fstatsys_res = os.linux.syscall(.fstat, .{
            opensys_res, @intFromPtr(&fstatbuf),
        });
        if (os.linux.get_errno(fstatsys_res) != .SUCCESS) {
            return error.FailedToReadTheMetadata;
        }

        if (fstatbuf.size == 0) {
            unlikely();
            return error.EmptyFile;
        }

        var nullobj: ?void = null;
        const mmapsys_res = os.linux.syscall(.mmap, .{
            @intFromPtr(&nullobj),
            fstatbuf.size,
            switch (kind) {
                .ReadOnly => os.linux.PROT.READ,
                .WriteOnly => os.linux.PROT.WRITE,
                .ReadAndWrite => os.linux.PROT.READ | os.linux.PROT.WRITE,
            },
            os.linux.MAP.PRIVATE,
            opensys_res,
            @as(u64, 0),
        });

        if (os.linux.get_errno(mmapsys_res) == .SUCCESS) {
            var ptr: [*]align(os.page_size) u8 = @ptrFromInt(mmapsys_res);
            return Mmapf{ .mem = ptr[0..@intCast(fstatbuf.size)] };
        }

        return error.FailedToMapTheFileToMemory;
    }
    @compileError("Unsupported OS/CPU!");
}

/// Unmaps a memory-mapped file
pub fn deinit(self: *Mmapf) void {
    @setRuntimeSafety(false);
    if (builtin.os.tag == .linux) {
        os.linux.syscall(.munmap, .{ @intFromPtr(self.mem.ptr), self.mem.len });
    }
}
