const utils = @import("utils.zig");
const config = @import("config.zig");

pub export fn main() noreturn {
    utils.write(config.RCC_AHB2ENR, 0x0000_0001);
    for (0..1000) |i| {
        _ = i;
    }
    utils.write(utils.GPIO_MODER('A'), 0xFFFF_F7FF);
    utils.write(utils.GPIO_OTYPER('A'), 0x0000_0000);
    utils.write(utils.GPIO_OSPEEDR('A'), 0x0C00_0000);
    utils.write(utils.GPIO_PUPDR('A'), 0x6400_0000);
    utils.write(utils.GPIO_AFRL('A'), 0x0000_7700);
    config.TSC_IOHCR.* = 0xFFFF_FFFF;

    while (true) {
        utils.write(utils.GPIO_BSRR('A'), (1 << 5));
        for (0..100_000) |i| {
            _ = i;
        }
        utils.write(utils.GPIO_BSRR('A'), (0 << 5));
        utils.write(utils.GPIO_BSRR('A'), (1 << 21));
        for (0..100_000) |i| {
            _ = i;
        }
    }
}

test "test" {
    const std = @import("std");
    _ = std;
}
