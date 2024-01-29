const builtin = @import("builtin");
const os = @import("../os/os.zig");
const math = @import("../math.zig");
const Allocator = @import("Allocator.zig");
const ArenaMmapAllocator = @import("ArenaMmapAllocator.zig");

const FreelistNode = packed struct {
    len: usize,
    next: ?*FreelistNode,
};
var empty_freelist = FreelistNode{ .len = 0, .next = null };

freelist: *FreelistNode,
arena: ArenaMmapAllocator,

const MmapAllcoator = @This();

pub fn init(total_size: usize) !MmapAllcoator {
    return MmapAllcoator{
        .arena = try ArenaMmapAllocator.init(total_size),
        .freelist = &empty_freelist,
    };
}

fn alloc(ctx: *anyopaque, size: usize) ?[]u8 {
    var self: *MmapAllcoator = @alignCast(@ptrCast(ctx));
    if (self.freelist.len != 0) {
        if (self.freelist.len >= size) {
            var freelist_slice: []u8 = undefined;
            freelist_slice.len = self.freelist.len;
            freelist_slice.ptr = @alignCast(@ptrCast(self.freelist));

            if (self.freelist.len - size != 0) {
                @memset(freelist_slice[size..self.freelist.len], 0);
            }

            if (self.freelist.next) |_| {
                self.freelist = self.freelist.next.?;
            } else {
                self.freelist = &empty_freelist;
            }

            return freelist_slice[0..size];
        }
    }

    return ArenaMmapAllocator.alloc(@alignCast(@ptrCast(&self.arena)), size);
}

fn free(ctx: *anyopaque, buf: []u8) void {
    var self: *MmapAllcoator = @alignCast(@ptrCast(ctx));
    const freelist = @as(*FreelistNode, @alignCast(@ptrCast(buf.ptr)));

    if (buf.len > 16) {
        freelist.len = @intCast(math.alignForward(usize, buf.len, 8));
    } else {
        freelist.len = 16;
    }

    if (self.freelist.len != 0) {
        freelist.next = self.freelist;
    } else {
        freelist.next = null;
    }

    self.freelist = freelist;
}

fn resize(_: *anyopaque, _: []u8, _: usize) bool {
    return false;
}

pub fn allocator(self: *MmapAllcoator) Allocator {
    return Allocator{
        .ptr = self,
        .alloc = alloc,
        .resize = resize,
        .free = free,
    };
}

pub fn deinit(self: *MmapAllcoator) void {
    self.arena.deinit();
}
