const Allocator = @import("Allocator.zig");

pub fn ArrayList(comptime T: type) type {
    return struct {
        const ArrayListInner = @This();

        allocator: Allocator,
        mem: []T,
        pos: usize = 0,

        pub fn init(allocator: Allocator) Allocator.AllocErr!ArrayListInner {
            return ArrayListInner{ .allocator = allocator, .mem = try allocator.alloc(T, 10), .pos = 0 };
        }

        pub fn push(self: *ArrayListInner, entity: T) Allocator.AllocErr!void {
            if (self.pos >= self.mem.len) {
                self.mem = try self.allocator.resize_or_alloc(T, self.mem, self.mem.len * 2);
            }

            self.mem[self.pos] = entity;
            self.pos += 1;
        }

        pub fn get(self: *ArrayListInner, idx: usize) ?T {
            if (idx > self.pos) return null;

            return self.mem[idx];
        }

        pub fn get_all(self: *ArrayListInner) []T {
            return self.mem[0..self.pos];
        }
    };
}
