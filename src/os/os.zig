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

pub fn exit(status: u8) void {
    if (builtin.os.tag == .linux) {
        if (builtin.cpu.arch == .x86_64)
            return x86_syscall.exit(status);
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
