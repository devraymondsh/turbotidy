/// A wrapper around syscalls that uses the right module for the OS and CPU kind
const builtin = @import("builtin");
const x86_syscall = @import("linux/x86-syscall.zig");

pub const page_size = switch (builtin.cpu.arch) {
    .wasm32, .wasm64 => 64 * 1024,
    .aarch64 => switch (builtin.os.tag) {
        .macos, .ios, .watchos, .tvos => 16 * 1024,
        else => 4 * 1024,
    },
    .sparc64 => 8 * 1024,
    else => 4 * 1024,
};

pub const OpenFlags = struct {
    pub const RDONLY = 0o0;
    pub const WRONLY = 0o1;
    pub const RDWR = 0o2;
};
pub const PROT = struct {
    /// page can not be accessed
    pub const NONE = 0x0;
    /// page can be read
    pub const READ = 0x1;
    /// page can be written
    pub const WRITE = 0x2;
    /// page can be executed
    pub const EXEC = 0x4;
    /// page may be used for atomic ops
    pub const SEM = 0x8;
    /// mprotect flag: extend change to start of growsdown vma
    pub const GROWSDOWN = 0x01000000;
    /// mprotect flag: extend change to end of growsup vma
    pub const GROWSUP = 0x02000000;
};
pub const MAP = struct {
    /// Share changes
    pub const SHARED = 0x01;
    /// Changes are private
    pub const PRIVATE = 0x02;
    /// share + validate extension flags
    pub const SHARED_VALIDATE = 0x03;
    /// Mask for type of mapping
    pub const TYPE = 0x0f;
    /// Interpret addr exactly
    pub const FIXED = 0x10;
    /// don't use a file
    pub const ANONYMOUS = 0x20;
    // MAP_ 0x0100 - 0x4000 flags are per architecture
    /// populate (prefault) pagetables
    pub const POPULATE = 0x8000;
    /// do not block on IO
    pub const NONBLOCK = 0x10000;
    /// give out an address that is best suited for process/thread stacks
    pub const STACK = 0x20000;
    /// create a huge page mapping
    pub const HUGETLB = 0x40000;
    /// perform synchronous page faults for the mapping
    pub const SYNC = 0x80000;
    /// MAP_FIXED which doesn't unmap underlying mapping
    pub const FIXED_NOREPLACE = 0x100000;
    /// For anonymous mmap, memory could be uninitialized
    pub const UNINITIALIZED = 0x4000000;
};

pub const default_read_mode = switch (builtin.os.tag) {
    .windows => 0,
    .wasi => 0,
    else => 0o666,
};

pub fn exit(status: u8) void {
    if (builtin.os.tag == .linux) {
        if (builtin.cpu.arch == .x86_64)
            return x86_syscall.exit(status);
    }
    @compileError("Unsupported OS/CPU!");
}

const std = @import("std");

pub fn open(path: []const u8, flags: i32, mode: u16) i32 {
    if (builtin.os.tag == .linux) {
        if (builtin.cpu.arch == .x86_64)
            return x86_syscall.open(path, flags, mode);
    }
    @compileError("Unsupported OS/CPU!");
}

pub fn write(buf: []const u8, fd: i32) void {
    if (builtin.os.tag == .linux) {
        if (builtin.cpu.arch == .x86_64)
            return x86_syscall.write(buf, fd);
    }
    @compileError("Unsupported OS/CPU!");
}

pub fn mmap(
    ptr: ?[*]align(page_size) u8,
    length: usize,
    prot: u32,
    flags: u32,
    fd: i32,
    offset: u64,
) ![]align(page_size) u8 {
    if (builtin.os.tag == .linux) {
        if (builtin.cpu.arch == .x86_64)
            return x86_syscall.mmap(ptr, length, prot, flags, fd, offset);
    }
    @compileError("Unsupported OS/CPU!");
}

pub fn unmap(memory: []align(page_size) const u8) void {
    if (builtin.os.tag == .linux) {
        if (builtin.cpu.arch == .x86_64)
            return x86_syscall.mmap(memory);
    }
    @compileError("Unsupported OS/CPU!");
}
