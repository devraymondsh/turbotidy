const builtin = @import("builtin");
const os = @import("../os.zig");

pub const SyscallType = enum(usize) {
    read = 0,
    write = 1,
    open = 2,
    close = 3,
    stat = 4,
    fstat = 5,
    lstat = 6,
    poll = 7,
    lseek = 8,
    mmap = 9,
    mprotect = 10,
    munmap = 11,
    brk = 12,
    // ...
    exit_group = 231,
};

const SyscallErr = enum(u16) {
    /// No error occurred.
    /// Same code used for `NSROK`.
    SUCCESS = 0,
    /// Operation not permitted
    PERM = 1,
    /// No such file or directory
    NOENT = 2,
    /// No such process
    SRCH = 3,
    /// Interrupted system call
    INTR = 4,
    /// I/O error
    IO = 5,
    /// No such device or address
    NXIO = 6,
    /// Arg list too long
    @"2BIG" = 7,
    /// Exec format error
    NOEXEC = 8,
    /// Bad file number
    BADF = 9,
    /// No child processes
    CHILD = 10,
    /// Try again
    /// Also means: WOULDBLOCK: operation would block
    AGAIN = 11,
    /// Out of memory
    NOMEM = 12,
    /// Permission denied
    ACCES = 13,
    /// Bad address
    FAULT = 14,
    /// Block device required
    NOTBLK = 15,
    /// Device or resource busy
    BUSY = 16,
    /// File exists
    EXIST = 17,
};

pub fn get_syserr(r: usize) SyscallErr {
    @setRuntimeSafety(false);
    const signed_r = @as(isize, @bitCast(r));
    const int = if (signed_r > -4096 and signed_r < 0) -signed_r else 0;
    return @as(SyscallErr, @enumFromInt(int));
}

fn syscall(syscall_type: SyscallType, args: anytype) usize {
    @setRuntimeSafety(false);
    return switch (args.len) {
        1 => asm volatile ("syscall"
            : [ret] "={rax}" (-> usize),
            : [syscall_type] "{rax}" (syscall_type),
              [a0] "{rdi}" (args[0]),
            : "rcx", "r11", "memory"
        ),
        2 => asm volatile ("syscall"
            : [ret] "={rax}" (-> usize),
            : [syscall_type] "{rax}" (syscall_type),
              [a0] "{rdi}" (args[0]),
              [a1] "{rsi}" (args[1]),
            : "rcx", "r11", "memory"
        ),
        3 => asm volatile ("syscall"
            : [ret] "={rax}" (-> usize),
            : [syscall_type] "{rax}" (syscall_type),
              [a0] "{rdi}" (args[0]),
              [a1] "{rsi}" (args[1]),
              [a2] "{rdx}" (args[2]),
            : "rcx", "r11", "memory"
        ),
        4 => asm volatile ("syscall"
            : [ret] "={rax}" (-> usize),
            : [syscall_type] "{rax}" (syscall_type),
              [a0] "{rdi}" (args[0]),
              [a1] "{rsi}" (args[1]),
              [a2] "{rdx}" (args[2]),
              [a3] "{r10}" (args[3]),
            : "rcx", "r11", "memory"
        ),
        5 => asm volatile ("syscall"
            : [ret] "={rax}" (-> usize),
            : [syscall_type] "{rax}" (syscall_type),
              [a0] "{rdi}" (args[0]),
              [a1] "{rsi}" (args[1]),
              [a2] "{rdx}" (args[2]),
              [a3] "{r10}" (args[3]),
              [a4] "{r8}" (args[4]),
            : "rcx", "r11", "memory"
        ),
        6 => asm volatile ("syscall"
            : [ret] "={rax}" (-> usize),
            : [syscall_type] "{rax}" (syscall_type),
              [a0] "{rdi}" (args[0]),
              [a1] "{rsi}" (args[1]),
              [a2] "{rdx}" (args[2]),
              [a3] "{r10}" (args[3]),
              [a4] "{r8}" (args[4]),
              [a5] "{r9}" (args[5]),
            : "rcx", "r11", "memory"
        ),
        else => @compileError("Invalid number of arguments to syscall!"),
    };
}

pub fn exit(status: u8) void {
    _ = syscall(.exit_group, .{
        @as(usize, @bitCast(@as(isize, status))),
    });
}

pub fn open(path: []const u8, flags: i32, mode: u16) i32 {
    _ = mode; // autofix
    _ = flags; // autofix
    _ = path; // autofix
}

pub fn write(buf: []const u8, fd: i32) void {
    _ = syscall(.write, .{
        @as(usize, @bitCast(@as(isize, fd))),
        @intFromPtr(buf.ptr),
        buf.len,
    });
}

pub fn mmap(
    ptr: ?[*]align(os.page_size) u8,
    length: usize,
    prot: u32,
    flags: u32,
    fd: i32,
    offset: u64,
) ![]align(os.page_size) u8 {
    @setRuntimeSafety(false);
    const res = syscall(.mmap, .{
        @intFromPtr(ptr),
        length,
        prot,
        flags,
        @as(usize, @bitCast(@as(isize, fd))),
        @as(u64, @bitCast(offset)),
    });

    if (get_syserr(res) == .SUCCESS) {
        return @as([*]align(os.page_size) u8, @ptrFromInt(res))[0..length];
    }
    return error.FailedToAllocateMmap;
}

pub fn unmap(memory: []align(os.page_size) const u8) void {
    @setRuntimeSafety(false);
    _ = syscall(.munmap, .{ @intFromPtr(memory.ptr), memory.len });
}
