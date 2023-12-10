const utils = @import("utils");
const config = @import("config");
const knlink = @import("knlink");
const write = utils.write;
const serial = @import("devices").serial;

pub export fn main() noreturn {
    knlink.sysdepend.hw_setting.knl_startup_hw();
    write(config.USART1_CR1, 0); // reset
    write(config.USART1_CR2, 0); // reset
    write(config.USART1_CR3, 0); // reset
    write(config.USART1_ICR, 0x00121BDF); // clear
    write(config.USART1_CR3, 1 << 8 | 1 << 9); // set RTS/CTS enable
    write(config.USART1_BRR, ((80 * 1000 * 1000) + 115200 / 2) / 115200); // from mtk3
    write(config.USART1_CR1, 1 << 0 | 1 << 3 | 1 << 2 | 1 << 6 | 1 << 7 | 1 << 8); // set usart, te enable

    serial.print("やぁ");
    while (true) {}
}

test "test" {
    const std = @import("std");
    _ = std;
}
