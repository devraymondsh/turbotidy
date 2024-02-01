const math = @import("../math.zig");
const Allocator = @import("Allocator.zig");

mem: []u8,
pos: usize = 0,

const ArenaAllocator = @This();

pub fn unlikely() void {
    @setCold(true);
}

pub fn init(mem: []u8) ArenaAllocator {
    return ArenaAllocator{ .mem = mem, .pos = 0 };
}

pub fn alloc(ctx: *anyopaque, len: usize) ?[*]align(8) u8 {
    const self: *ArenaAllocator = @alignCast(@ptrCast(ctx));
    const new_pos = self.pos + len;

    if (new_pos > self.mem.len) {
        unlikely();
        return null;
    }

    const ret: [*]align(8) u8 = @alignCast(@ptrCast(&self.mem[self.pos]));
    self.pos = new_pos;

    return ret;
}

fn free(_: *anyopaque, _: [*]align(8) u8, _: usize) void {
    return;
}
fn resize(ctx: *anyopaque, buf: [*]align(8) u8, len: usize, new_len: usize) bool {
    const self: *ArenaAllocator = @alignCast(@ptrCast(ctx));
    if (@intFromPtr(self.mem[self.pos..].ptr) == (@intFromPtr(buf) + len)) {
        const new_pos = self.pos + (new_len - len);

        if (new_pos <= self.mem.len) {
            self.pos = new_pos;
            return true;
        } else {
            unlikely();
        }
    }

    return false;
}

pub fn allocator(self: *ArenaAllocator) Allocator {
    @setCold(true);
    return Allocator{ .ptr = self, .vtable = &.{
        .alloc = alloc,
        .resize = resize,
        .free = free,
    } };
}

pub fn reset(self: *ArenaAllocator) void {
    self.pos = 0;
}
