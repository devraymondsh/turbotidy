pub fn alignBackward(comptime T: type, addr: T, alignment: T) T {
    // TODO: Panic
    // assert(isValidAlignGeneric(T, alignment));

    // 000010000 // example alignment
    // 000001111 // subtract 1
    // 111110000 // binary not
    return addr & ~(alignment - 1);
}

pub fn alignForward(comptime T: type, addr: T, alignment: T) T {
    // TODO: Panic
    // assert(isValidAlignGeneric(T, alignment));

    return alignBackward(T, addr + (alignment - 1), alignment);
}

pub fn ceilPowerOfTwo(n_arg: u64) u64 {
    var n = n_arg;
    n -= 1;
    n |= n >> 1;
    n |= n >> 2;
    n |= n >> 4;
    n |= n >> 8;
    n |= n >> 16;
    n |= n >> 32;
    n += 1;

    return n;
}

pub fn asBinary(comptime T: type, n: T) [@bitSizeOf(T)]u8 {
    const Bits = @bitSizeOf(T);
    const ones: @Vector(Bits, u8) = @splat('1');
    const zeroes: @Vector(Bits, u8) = @splat('0');
    const bits: @Vector(Bits, bool) = @bitCast(@bitReverse(n));

    return @select(u8, bits, ones, zeroes);
}
pub fn asBinaryNoLeading(comptime T: type, n: T, buf: *[@bitSizeOf(T)]u8) []const u8 {
    buf.* = asBinary(T, n);
    return buf[@clz(n)..];
}

fn nibSwap(comptime T: type, n: T) T {
    const MaskVec = @Vector(@sizeOf(T), u8);
    const high: T = @bitCast(@as(MaskVec, @splat(0xF0)));
    const low: T = @bitCast(@as(MaskVec, @splat(0x0F)));

    return @byteSwap(((n << 4) & high) | ((n >> 4) & low));
}
pub fn asHex(comptime T: type, n: T) [@sizeOf(T) * 2]u8 {
    const Nibs = @sizeOf(T) * 2;
    const nibs: @Vector(Nibs, u4) = @bitCast(nibSwap(T, n));
    const mask: @Vector(Nibs, u4) = @splat(0b1010);
    const zeroes: @Vector(Nibs, u8) = @splat('0');
    const alphas: @Vector(Nibs, u8) = @splat('a');

    return @select(
        u8,
        nibs < mask,
        nibs +% zeroes,
        nibs -% mask +% alphas,
    );
}
pub fn asHexNoLeading(comptime T: type, n: T, buf: *[@sizeOf(T) * 2]u8) []const u8 {
    buf.* = asHex(T, n);
    return buf[@clz(n) / 4 ..];
}
