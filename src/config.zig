const utils = @import("utils.zig");
//GPIO */
pub const GPIOA_BASE = 0x48000000;
pub const GPIOB_BASE = 0x48000400;
pub const GPIOC_BASE = 0x48000800;
pub const GPIOD_BASE = 0x48000C00;
pub const GPIOE_BASE = 0x48001000;
pub const GPIOF_BASE = 0x48000400;
pub const GPIOG_BASE = 0x48000800;
pub const GPIOH_BASE = 0x48000C00;
pub const GPIOI_BASE = 0x48002000;

pub const RCC_BASE = 0x40021000;
// pub const RCC_AHB1ENR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x48));
pub const RCC_AHB2ENR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x4C));
// pub const RCC_APB2ENR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x60));
//
const TSC_BASE = 0x4002_4000;
pub const TSC_IOHCR = @as(*volatile u32, @ptrFromInt(TSC_BASE + 0x10));

pub const RCC_APB1ENR1 = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x0058)); // APB1 peripheral clock enable register 1 */
//
//internal clock sources calibraton register
pub const RCC_ICSCR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x0004));
pub const RCC_PLLCFGR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x000C));
pub const RCC_CFGR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x0008));

pub const FLASH_ACR = @as(*volatile u32, @ptrFromInt(0x40022000));
