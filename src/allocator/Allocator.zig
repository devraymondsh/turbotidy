const Allocator = @This();

pub const AllocErr = error{OutOfMemory};
pub const ResizeErr = error{FailedToResize};

pub const Alloc = *const fn (ctx: *anyopaque, size: usize) ?[]u8;
pub const Resize = *const fn (ctx: *anyopaque, buf: []u8, new_size: usize) bool;
pub const Free = *const fn (ctx: *anyopaque, buf: []u8) void;

ptr: *anyopaque,
alloc: Alloc,
resize: Resize,
free: Free,

pub fn any_to_byte(comptime T: type, src: []T) []u8 {
    comptime {
        if (@bitSizeOf(T) % 8 != 0) {
            @compileError("Type's bit size is not devisable by 8");
        }
    }

    var ret: []u8 = undefined;
    ret.ptr = @alignCast(@ptrCast(src.ptr));
    ret.len = src.len * @sizeOf(T);

    return ret;
}
pub fn byte_to_any(comptime T: type, src: []u8) []T {
    comptime {
        if (@bitSizeOf(T) % 8 != 0) {
            @compileError("Type's bit size is not devisable by 8");
        }
    }

    var ret: []T = undefined;
    ret.ptr = @alignCast(@ptrCast(src.ptr));
    ret.len = src.len / @sizeOf(T);

    return ret;
}

pub fn alloc_byte(self: Allocator, size: usize) AllocErr![]u8 {
    if (self.alloc(self.ptr, size)) |buf| return buf;

    return AllocErr.OutOfMemory;
}
pub fn alloc(self: Allocator, comptime T: type, size: usize) AllocErr![]T {
    return byte_to_any(T, try self.alloc_byte(
        size * @sizeOf(T),
    ));
}
pub fn create(self: Allocator, comptime T: type) AllocErr!T {
    return (try self.alloc(T, 1))[0];
}

pub fn resize_byte(self: Allocator, buf: []u8, new_size: usize) ResizeErr![]u8 {
    if (self.resize(self.ptr, buf, new_size)) return buf;

    return ResizeErr.FailedToResize;
}
pub fn resize(self: Allocator, comptime T: type, buf: []T, new_size: usize) ResizeErr![]T {
    return byte_to_any(T, try self.resize_byte(
        any_to_byte(T, buf),
        new_size * @sizeOf(T),
    ));
}

pub fn free_byte(self: Allocator, buf: []u8) void {
    self.free(self.ptr, buf);
}
pub fn free(self: Allocator, comptime T: type, buf: []T) void {
    self.free_byte(any_to_byte(T, buf));
}
