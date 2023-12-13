pub const cpu = @import("cpu/stm32l4/sysdef.zig");
pub const core = @import("cpu/core/sysdef.zig");
//System dependencies definition (Nucleo-64 STM32L467 depended)
//Included also from assembler program. */

// CPU-dependent definition */
// const  = @import{ <sys/sysdepend/cpu/stm32l4/sysdef.h>

//Clock control definition */

// RCC register initial value */
pub const RCC_CFGR_INIT = 0x00000000; // SYSCLK = HCLK = PCLK1 = PCLK2
pub const RCC_PLLCFGR_INIT = 0x00000A00; // M = 1, N = 10, P = 7, Q = 2, R =2
pub const RCC_PLLSAI1CFGR_INIT = 0x00000800; // N = 8, P = 7, Q = 2, R =2
pub const RCC_PLLSAI2CFGR_INIT = 0x00000800; // N = 8, P = 7, R =2

pub const RCC_CFGR_SW_INIT = cpu.RCC_CFGR_SW_PLL;
pub const RCC_PLLCFGR_PLLSRC_INIT = cpu.RCC_PLLCFGR_PLLSRC_HSI;

// Clock frequency 　*/
pub const SYSCLK = 80; // System clock */
pub const HCLK = SYSCLK; // Peripheral clock (AHB) */
pub const PCLK1 = HCLK; // Peripheral clock (APB1) */
pub const PCLK2 = HCLK; // Peripheral clock (APB2) */
pub const TMCLK = HCLK; // System timer clock input (MHz) */
pub const TMCLK_KHz = TMCLK * 1000; // System timer clock input (kHz) */

// Maximum value of Power-saving mode switching prohibition request.
//Use in tk_set_pow API. */
pub const LOWPOW_LIMIT = 0x7fff; // Maximum number for disabling */
