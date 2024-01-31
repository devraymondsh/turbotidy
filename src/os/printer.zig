const os = @import("os.zig");

pub fn BufPrinter(comptime size: comptime_int) type {
    return struct {
        buf: [size]u8 = undefined,
        pos: u16 = 0,

        const BufPrinterInner = @This();

        pub fn init() @This() {
            return BufPrinterInner{
                .buf = undefined,
                .pos = 0,
            };
        }

        pub fn print(self: *BufPrinterInner, msg: []const u8) void {
            const new_pos = self.pos + msg.len;
            if (new_pos > self.buf.len) {
                self.flush();
                return self.print(msg);
            }

            @memcpy(self.buf[self.pos..new_pos], msg);
            self.pos += @intCast(msg.len);
        }

        pub fn print_many(self: *BufPrinterInner, comptime n: comptime_int, msgs: [n][]const u8) void {
            inline for (msgs) |msg| self.print(msg);
        }

        pub fn flush(self: *BufPrinterInner) void {
            os.print(self.buf[0..self.pos]);
            self.pos = 0;
        }
    };
}
