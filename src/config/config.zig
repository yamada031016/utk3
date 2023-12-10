const utils = @import("utils");
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

const RCC_BASE = 0x40021000;
// pub const RCC_AHB1ENR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x48));
pub const RCC_CR = RCC_BASE + 0x0;
pub const RCC_AHB2ENR = RCC_BASE + 0x4C;
// pub const RCC_APB2ENR = @as(*volatile u32, @ptrFromInt(RCC_BASE + 0x60));
//
const TSC_BASE = 0x4002_4000;
pub const TSC_IOHCR = TSC_BASE + 0x10;

pub const RCC_APB1ENR1 = RCC_BASE + 0x0058; // APB1 peripheral clock enable register 1 */
pub const RCC_APB2ENR = RCC_BASE + 0x00F0; // APB1 peripheral clock enable register 1 */
//
//internal clock sources calibraton register
pub const RCC_ICSCR = RCC_BASE + 0x0004;
pub const RCC_PLLCFGR = RCC_BASE + 0x000C;
pub const RCC_CFGR = RCC_BASE + 0x0008;
pub const RCC_PLLSAI1CFGR = RCC_BASE + 0x0010;
pub const RCC_CIER = RCC_BASE + 0x0018;

pub const FLASH_ACR = 0x40022000;

//USART */
const USART1_BASE = 0x40013800;
const USART2_BASE = 0x40004400;
const USART3_BASE = 0x40004800;
const UART4_BASE = 0x40004C00;
const UART5_BASE = 0x40005000;

pub const USART1_CR1 = USART2_BASE + 0x0000;
pub const USART1_CR2 = USART2_BASE + 0x0004;
pub const USART1_CR3 = USART2_BASE + 0x0008;
pub const USART1_BRR = USART2_BASE + 0x000C;
pub const USART1_GTPR = USART2_BASE + 0x0010;
pub const USART1_RTOR = USART2_BASE + 0x0014;
pub const USART1_RQR = USART2_BASE + 0x0018;
pub const USART1_ISR = USART2_BASE + 0x001C;
pub const USART1_ICR = USART2_BASE + 0x0020;
pub const USART1_RDR = USART2_BASE + 0x0024;
pub const USART1_TDR = USART2_BASE + 0x0028;
