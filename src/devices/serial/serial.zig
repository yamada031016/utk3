const config = @import("config");
const utils = @import("utils");
const write = utils.write;
const read = utils.read;

pub fn put(data: u8) void {
    // wait TXE
    while ((read(config.USART1_ISR) & 1 << 7) == 0) {} else {
        // transmit buffer is empty
        write(config.USART1_TDR, data);
    }
    // wait TC
    while ((read(config.USART1_ISR) & 1 << 6) == 0) {}
}

pub fn puts(string: []const u8) void {
    for (string) |char| {
        put(char);
    }
}

pub fn print(string: []const u8) void {
    puts(string);
    put('\n');
}

// std.fmt.format参考にする.
// 未実装
pub fn tm_printf(comptime fmt: []const u8, args: anytype) void {
    _ = args;
    _ = fmt;
    unreachable;
}
