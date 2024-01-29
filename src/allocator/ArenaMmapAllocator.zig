const builtin = @import("builtin");
const os = @import("../os/os.zig");
const Allocator = @import("Allocator.zig");
const math = @import("../math.zig");

cursor: usize,
mem: []align(os.page_size) u8,

const ArenaMmapAllcoator = @This();

fn unlikely() void {
    @setCold(true);
}

pub fn init(total_size: usize) !ArenaMmapAllcoator {
    return ArenaMmapAllcoator{
        .mem = try os.mmap(
            null,
            math.alignForward(usize, total_size, os.page_size),
            os.PROT.NONE,
            os.MAP.ANONYMOUS | os.MAP.PRIVATE,
            0,
            0,
        ),
        .cursor = 0,
    };
}

pub fn alloc(ctx: *anyopaque, size: usize) ?[]u8 {
    var self: *ArenaMmapAllcoator = @alignCast(@ptrCast(ctx));
    const starting_pos = self.cursor;
    var ending_pos: usize = starting_pos + 16;
    if (size > 16) {
        ending_pos += math.alignForward(usize, size - 16, 8);
    }

    self.cursor = ending_pos;

    if (self.cursor > self.mem.len) {
        unlikely();
        return null;
    }

    return self.mem[starting_pos .. starting_pos + size];
}

fn free(_: *anyopaque, _: []u8) void {
    @panic("You shouldn't call free on a arena allocator!");
}
fn resize(_: *anyopaque, _: []u8, _: usize) bool {
    return false;
}

pub fn allocator(self: *ArenaMmapAllcoator) Allocator {
    return Allocator{
        .ptr = self,
        .alloc = alloc,
        .resize = resize,
        .free = free,
    };
}

pub fn deinit(self: *ArenaMmapAllcoator) void {
    os.unmap(self.mem);
}
