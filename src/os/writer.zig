const os = @import("os.zig");

pub fn BufWriter(comptime size: comptime_int) type {
    return struct {
        fd: i32,
        buf: [size]u8 = undefined,
        pos: u16 = 0,

        const BufWriterInner = @This();

        pub fn init(fd: i32) @This() {
            return BufWriterInner{
                .buf = undefined,
                .fd = fd,
                .pos = 0,
            };
        }

        pub fn write(self: *BufWriterInner, msg: []const u8) void {
            const new_pos = self.pos + msg.len;
            if (new_pos > self.buf.len) {
                self.flush();
                return self.write(msg);
            }

            @memcpy(self.buf[self.pos..new_pos], msg);
            self.pos += @intCast(msg.len);
        }

        pub fn write_many(self: *BufWriterInner, comptime n: comptime_int, msgs: [n][]const u8) void {
            inline for (msgs) |msg| {
                self.write(msg);
            }
        }

        pub fn flush(self: *BufWriterInner) void {
            os.write(self.buf[0..self.pos], self.fd);
            self.pos = 0;
        }
    };
}
