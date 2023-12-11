const config = @import("config");
const utils = @import("utils");
const write = utils.write;
const read = utils.read;
const TkError = @import("libtk").errno.TkError;

pub fn put(data: u8) void {
    // wait TXE
    while ((read(config.USART2_ISR) & 1 << 7) == 0) {} else {
        // transmit buffer is empty
        write(config.USART2_TDR, data);
    }
    // wait TC
    while ((read(config.USART2_ISR) & 1 << 6) == 0) {}
}

pub fn puts(string: []const u8) void {
    for (string) |char| {
        put(char);
    }
}

pub fn print(string: []const u8) void {
    puts(string);
    puts("\r\n");
}

// std.fmt.format参考にする.
// 未実装
pub fn tm_printf(comptime fmt: []const u8, args: anytype) void {
    _ = args;
    _ = fmt;
    unreachable;
}

// 今はUSART2のみ対象
pub fn dev_init_serial(unit: u8) void {
    _ = unit;
    write(config.USART2_CR1, 0); // reset
    write(config.USART2_CR2, 0); // reset
    write(config.USART2_CR3, 0); // reset
    write(config.USART2_ICR, 0x00121BDF); // clear
    write(config.USART2_CR3, 1 << 8 | 1 << 9); // set RTS/CTS enable
    write(config.USART2_BRR, ((80 * 1000 * 1000) + 115200 / 2) / 115200); // from mtk3
    write(config.USART2_CR1, 1 << 0 | 1 << 3 | 1 << 2 | 1 << 6 | 1 << 7 | 1 << 8); // set usart, te enable
}
