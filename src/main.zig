const utils = @import("utils.zig");
const config = @import("config.zig");

pub export fn main() noreturn {
    // const addr: *u32 = @as(*u32, @ptrFromInt(RCC_BASE));
    // // var f_ratency: u32 = CLKATR_LATENCY_MASK >> 8;
    // FLASH_ACR.* &= ~@as(u32, 0x0000_0007);
    // FLASH_ACR.* |= 0x0000_0002;
    //
    // addr.* |= 0x0000_0100; // HSI enable
    // while ((addr.* & 0x0000_0400) == 0) {} // Wait HSI ready
    // RCC_ICSCR.* &= ~@as(u32, 0x1F00_0000);
    // RCC_ICSCR.* |= 0x1000_0000;
    //
    // addr.* &= ~@as(u32, 0x1000_0000); // enable PLL
    // while ((addr.* & 0x2000_0000) == 0) {} // Wait PLL ready
    //
    // RCC_PLLCFGR.* &= ~@as(u32, 0x0000_0003);
    // RCC_PLLCFGR.* |= 0x0000_0002;
    // RCC_PLLCFGR.* &= ~@as(u32, 0x0000_7F00);
    // RCC_PLLCFGR.* |= 0x0000_0400 | 0x0000_1000;
    // RCC_PLLCFGR.* &= ~@as(u32, 0x0000_0070);
    // RCC_PLLCFGR.* |= 0x0000_0010;
    //
    // RCC_PLLCFGR.* &= ~@as(u32, 0x0600_0000);
    // RCC_PLLCFGR.* |= 0x0100_0000;
    // addr.* |= 0x0100_0000;
    // while ((addr.* & 0x2000_0000) == 0) {} // Wait PLL ready
    // RCC_CFGR.* &= ~@as(u32, 0x0000_0003);
    // RCC_CFGR.* |= 0x0000_0003;
    // while ((RCC_CFGR.* & 0x0000_000C) == 0x0000_000C) {} // Wait PLL ready
    //
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
