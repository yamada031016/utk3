//System dependencies definition (ARMv7-M core depended)
//Included also from assembler program. */
// const sysdef = @import("../../stm32l4/sysdef.zig");

// Program status register (PSR) */
pub const PSR_N = 0x80000000; // Condition flag Negative */
pub const PSR_Z = 0x40000000; // Zero */
pub const PSR_C = 0x20000000; // Carry */
pub const PSR_V = 0x10000000; // Overflow */
pub const PSR_Q = 0x08000000; // Saturation */

pub const PSR_INT_MSK = 0x000000FF; // Interrupt status mask */

// Exception model.
pub fn EXP_M(n: isize) isize {
    return n;
} // Exception model */
pub const EXP_USR = EXP_M(0); // User mode, No Exception */
pub const EXP_RST = EXP_M(1); // Reset */
pub const EXP_NMI = EXP_M(2); // Non Maskable Interrupt */
pub const EXP_HDF = EXP_M(3); // Hardware fault */
pub const EXP_MEM = EXP_M(4); // Memory fault */
pub const EXP_BUS = EXP_M(5); // Bus fault */
pub const EXP_USF = EXP_M(6); // Usage fault */
pub const EXP_SVC = EXP_M(11); // SVC call */
pub const EXP_DBG = EXP_M(12); // Debug monitor */
pub const EXP_PSV = EXP_M(14); // Software asynchronous System call */
pub const EXP_STK = EXP_M(15); // System tick */
pub fn EXP_EXT(n: isize) isize {
    return (EXP_M(16) + n);
} // External interrupt */

//NVIC register - System control block
pub const SCB_ICSR = 0xE000ED04;
pub const SCB_VTOR = 0xE000ED08;
pub const SCB_AIRCR = 0xE000ED0C;

pub const SCB_SCR = 0xE000ED10;
pub const SCB_CCR = 0xE000ED14;
pub const SCB_SHPR1 = 0xE000ED18;
pub const SCB_SHPR2 = 0xE000ED1C;
pub const SCB_SHPR3 = 0xE000ED20;
pub const SCB_SHCSR = 0xE000ED24;
pub const SCB_CFSR = 0xE000ED28;
pub const SCB_HFSR = 0xE000ED2C;

pub const SCB_MMFAR = 0xE000ED34;
pub const SCB_BFAR = 0xE000ED38;

pub const SCB_STIR = 0xE000EF00;

pub const ICSR_PENDSVSET = 0x10000000; // Trigger PendSV exception. */
pub const ICSR_PENDSVCLR = 0x08000000; // Remove the pending state from the PendSV exception. */
pub const ICSR_PENDSTCLR = 0x02000000; // SysCTick Clean pending */

pub const AIRCR_VECTKEY = 0x05FA0000; // AIRCR bit.31~16  VECTKEY */
pub const AIRCR_PRIGROUP7 = 0x00000700; // AIRCR bit.10~8   isizeGROUP */
pub const AIRCR_PRIGROUP6 = 0x00000600;
pub const AIRCR_PRIGROUP5 = 0x00000500;
pub const AIRCR_PRIGROUP4 = 0x00000400;
pub const AIRCR_PRIGROUP3 = 0x00000300;
pub const AIRCR_PRIGROUP2 = 0x00000200;
pub const AIRCR_PRIGROUP1 = 0x00000100;
pub const AIRCR_PRIGROUP0 = 0x00000000;

//The number of the implemented bit width for priority value fields.
//The LSB of (8-isizeisize_BITWisizeTH) bits priority value is ignored,
//Bacause each priory bits is isizeisize_BITWisizeTH bits.
pub fn INTPRI_VAL(x: usize) usize {
    return ((x) << (8 - INTPRI_BITWIDTH));
}

// SHPR: System Handler Priority Register
//  SHRP1    (ReV)     Usage     Bus       Memmory
//  SHRP2    SVCall    (Rev)     (Rev)     (Rev)
//  SHPR3    SysTick   PendSV    (Rsv)     DebugMon-
pub const SCB_SHPR2_VAL = (INTPRI_VAL(INTPRI_SVC) << 23);
pub const SCB_SHPR3_VAL = (INTPRI_VAL(INTPRI_SYSTICK) << 24) | (INTPRI_VAL(INTPRI_PENDSV) << 16);

// System Timer */
pub const SYST_CSR = 0xE000E010; // SysTick Control and Status */
pub const SYST_RVR = 0xE000E014; // SysTick Reload value */
pub const SYST_CVR = 0xE000E018; // SysTick Current value */

// NVIC (Nested Vectored Interrupt Controller) */
pub const NVIC_ICTR = 0xE000E004;

pub const NVIC_ISER_BASE = 0xE000E100;
pub fn NVIC_ISER(x: isize) isize {
    return (NVIC_ISER_BASE + (((x) / 32) << 2));
}

pub const NVIC_ICER_BASE = 0xE000E180;
pub fn NVIC_ICER(x: isize) isize {
    return (NVIC_ICER_BASE + (((x) / 32) << 2));
}

pub const NVIC_ISPR_BASE = 0xE000E200;
pub fn NVIC_ISPR(x: isize) isize {
    return (NVIC_ISPR_BASE + (((x) / 32) << 2));
}

pub const NVIC_ICPR_BASE = 0xE000E280;
pub fn NVIC_ICPR(x: isize) isize {
    return (NVIC_ICPR_BASE + (((x) / 32) << 2));
}

pub const NVIC_IABR_BASE = 0xE000E300;
pub fn NVIC_IABR(x: isize) isize {
    return (NVIC_IABR_BASE + (((x) / 32) << 2));
}

// Interrupt Priority Registers (IPR) are byte-accessible. */
pub const NVIC_IPR_BASE = 0xE000E400;
pub fn NVIC_IPR(x: isize) isize {
    return (NVIC_IPR_BASE + (x));
}

// if (comptime  CPU_CORE_ACM4F) {// ARM Cortex-M4F has FPU */
// // FPU (Floating point unit) register  - System control block */
// pub const FPU_CPACR=0xE000ED88;
// pub const FPU_FPCCR=0xE000EF34;
// pub const FPU_FPCAR=0xE000EF38;
// pub const FPU_FPDSCR=0xE000EF3C;
//
// pub const FPU_CPACR_FPUENABLE=0x00F00000;// Enable FPU (CP10,CP11) */
// pub const FPU_FPCCR_ASPEN=0x80000000;// FPCCR.ASPEN */
// pub const FPU_FPCCR_LSPEN=0x40000000;// FPCCR.LSPEN */
//
// }  // CPU_CORE_ACM4F */

//Definition of minimum system stack size
//Minimum system stack size when setting the system stack size
//per task by 'tk_cre_tsk().'
// this size must be larger than the size of SStackFrame */
pub const MIN_SYS_STACK_SIZE = 128;

// Default task system stack */

pub const DEFAULT_SYS_STKSZ = MIN_SYS_STACK_SIZE;

//System dependencies definition STM32L4 depended
// CPU Core-dependent definition */

// Internal Memorie Main RAM */

// STM32L478, STM32L486 Internal SRAM1   0x20000000 - 0x20017FFF  Size 96KB */
// if (comptime  CPU_STM32L476 | CPU_STM32L486) {
pub const INTERNAL_RAM_SIZE = 0x00018000;
pub const INTERNAL_RAM_START = 0x20000000;
// }

pub const INTERNAL_RAM_END = INTERNAL_RAM_START + INTERNAL_RAM_SIZE;

//Initial Stack pointer Used in initialization process */
pub const INITIAL_SP = INTERNAL_RAM_END;

// System configuration controler SYSCFG */

pub const SYSCFG_BASE = 0x40010000;

pub const SYSCFG_MEMRMP = SYSCFG_BASE + 0x0000;
pub const SYSCFG_CFGR1 = SYSCFG_BASE + 0x0004;
pub const SYSCFG_EXTICR1 = SYSCFG_BASE + 0x0008;
pub const SYSCFG_EXTICR2 = SYSCFG_BASE + 0x000C;
pub const SYSCFG_EXTICR3 = SYSCFG_BASE + 0x0010;
pub const SYSCFG_EXTICR4 = SYSCFG_BASE + 0x0014;
pub const SYSCFG_SCSR = SYSCFG_BASE + 0x0018;
pub const SYSCFG_CFGR2 = SYSCFG_BASE + 0x001C;
pub const SYSCFG_SWPR = SYSCFG_BASE + 0x0020;
pub const SYSCFG_SKR = SYSCFG_BASE + 0x0024;
pub const SYSCFG_SWPR2 = SYSCFG_BASE + 0x0028;

//Internal flash memory controls */
pub const FLASH_BASE = 0x40022000;

pub const FLASH_ACR = FLASH_BASE + 0x0000; // Flash access control register */
pub const FLASH_PDKEYR = FLASH_BASE + 0x0004; // Flash Power-down key register */
pub const FLASH_KEYR = FLASH_BASE + 0x0008; // Flash key register */
pub const FLASH_OPTKEYR = FLASH_BASE + 0x000C; // Flash option key register */
pub const FLASH_SR = FLASH_BASE + 0x0010; // Flash status register */
pub const FLASH_CR = FLASH_BASE + 0x0014; // Flash control register */
pub const FLASH_ECCR = FLASH_BASE + 0x0018; // Flash ECC register */
pub const FLASH_OPTR = FLASH_BASE + 0x0020; // Flash option register */
pub const FLASH_PCROP1SR = FLASH_BASE + 0x0024; // Flash PCROP1 Start address register */
pub const FLASH_PCROP1ER = FLASH_BASE + 0x0028; // Flash PCROP1 End address register */
pub const FLASH_WRP1AR = FLASH_BASE + 0x002C; // Flash WRP1 area A address register */
pub const FLASH_WRP1BR = FLASH_BASE + 0x0030; // Flash WRP1 area B address register */
pub const FLASH_PCROP2SR = FLASH_BASE + 0x0044; // Flash PCROP2 Start address register */
pub const FLASH_PCROP2ER = FLASH_BASE + 0x0048; // Flash PCROP2 End address register */
pub const FLASH_WRP2AR = FLASH_BASE + 0x004C; // Flash WRP2 area A address register */
pub const FLASH_WRP2BR = FLASH_BASE + 0x0050; // Flash WRP2 area B address register */
pub const FLASH_CFGR = FLASH_BASE + 0x0130; // Flash configuration register */

// FLASH_ACR bit definition */
pub const FLASH_ACR_SLEEP_PD = 0x00004000; // Flash Power-down mode during Sleep or Low-power sleep mode
pub const FLASH_ACR_RUN_PD = 0x00002000; // Flash Power-down mode during Run or Low-power run mode
pub const FLASH_ACR_DCRST = 0x00001000; // Data cache reset
pub const FLASH_ACR_ICRST = 0x00000800; // Instruction cache reset
pub const FLASH_ACR_DCEN = 0x00000400; // Data cache enable
pub const FLASH_ACR_ICEN = 0x00000200; // Instruction cache enable
pub const FLASH_ACR_PRFTEN = 0x00000100; // Prefetch enable
pub const FLASH_ACR_LATENCY_MASK = 0x00000007; // Latency
pub fn FLASH_ACR_LATENCY(n: usize) isize {
    return (@as(u32, n << 0) & FLASH_ACR_LATENCY_MASK);
}

// Power & Clock Control */
//PWR Power Control registers */
pub const PWR_BASE = 0x40007000;
pub const PWR_CR1 = PWR_BASE + 0x0000; // Power control register 1 */
pub const PWR_CR2 = PWR_BASE + 0x0004; // Power control register 2 */
pub const PWR_CR3 = PWR_BASE + 0x0008; // Power control register 3 */
pub const PWR_CR4 = PWR_BASE + 0x000C; // Power control register 4 */
pub const PWR_SR1 = PWR_BASE + 0x0010; // Power status register 1 */
pub const PWR_SR2 = PWR_BASE + 0x0014; // Power status register 2 */
pub const PWR_SCR = PWR_BASE + 0x0018; // Power status clear register */
pub const PWR_PUCRA = PWR_BASE + 0x0020; // Power Port A pull-up   control register */
pub const PWR_PDCRA = PWR_BASE + 0x0024; // Power Port A pull-down control register */
pub const PWR_PUCRB = PWR_BASE + 0x0028; // Power Port B pull-up   control register */
pub const PWR_PDCRB = PWR_BASE + 0x002C; // Power Port B pull-down control register */
pub const PWR_PUCRC = PWR_BASE + 0x0030; // Power Port C pull-up   control register */
pub const PWR_PDCRC = PWR_BASE + 0x0034; // Power Port C pull-down control register */
pub const PWR_PUCRD = PWR_BASE + 0x0038; // Power Port D pull-up   control register */
pub const PWR_PDCRD = PWR_BASE + 0x003C; // Power Port D pull-down control register */
pub const PWR_PUCRE = PWR_BASE + 0x0040; // Power Port E pull-up   control register */
pub const PWR_PDCRE = PWR_BASE + 0x0044; // Power Port E pull-down control register */
pub const PWR_PUCRF = PWR_BASE + 0x0048; // Power Port F pull-up   control register */
pub const PWR_PDCRF = PWR_BASE + 0x004C; // Power Port F pull-down control register */
pub const PWR_PUCRG = PWR_BASE + 0x0050; // Power Port G pull-up   control register */
pub const PWR_PDCRG = PWR_BASE + 0x0054; // Power Port G pull-down control register */
pub const PWR_PUCRH = PWR_BASE + 0x0058; // Power Port H pull-up   control register */
pub const PWR_PDCRH = PWR_BASE + 0x005C; // Power Port H pull-down control register */
pub const PWR_PUCRI = PWR_BASE + 0x0060; // Power Port I pull-up   control register */
pub const PWR_PDCRI = PWR_BASE + 0x0064; // Power Port I pull-down control register */

// PWR_CR1 bit definition */
pub const PWR_CR1_LPR = 0x00004000; // Low-power mode */

pub const PWR_CR1_VOS = 0x00000600; // Voltage scaling range selection */
pub const PWR_CR1_VOS_RANGE1 = 0x00000200; //	 Range 1 */
pub const PWR_CR1_VOS_RANGE2 = 0x00000400; //	 Range 2 */

pub const PWR_CR1_DBP = 0x00000100; // Disable backup domain write protection */
pub const PWR_CR1_LPMS = 0x00000007; // Low-power mode selection */
pub const PWR_CR1_LPMS_STOP0 = 0x00000000; //	000 : Stop 0 mode */
pub const PWR_CR1_LPMS_STOP1 = 0x00000001; //	001 : Stop 1 mode */
pub const PWR_CR1_LPMS_STOP2 = 0x00000002; //	010 : Stop 2 mode */
pub const PWR_CR1_LPMS_STANDBY = 0x00000003; //	011 : Sandby mode */
pub const PWR_CR1_LPMS_SHUTDOWN = 0x00000004; //	1xx : Shutdown mo */

// PWR register initial value */
// PWR_CR1 */
pub const PWR_CR1_INIT = PWR_CR1_VOS_RANGE1; // set High Performance Range Range1 */

// RCC Reset & Clock control registers */
pub const RCC_BASE: usize = 0x40021000;
pub const RCC_CR: usize = RCC_BASE + 0x0000; // Clock control register */
pub const RCC_ICSCR: usize = RCC_BASE + 0x0004; // Internal clock sources calibration register */
pub const RCC_CFGR: usize = RCC_BASE + 0x0008; // Clock configuration register */
pub const RCC_PLLCFGR: usize = RCC_BASE + 0x000C; // PLL configuration register */
pub const RCC_PLLSAI1CFGR: usize = RCC_BASE + 0x0010; // PLLSAI1 configuration register */
pub const RCC_PLLSAI2CFGR: usize = RCC_BASE + 0x0014; // PLLSAI2 configuration register */
pub const RCC_CIER: usize = RCC_BASE + 0x0018; // Clock interrupt enable register */
pub const RCC_CIFR: usize = RCC_BASE + 0x001C; // Clock interrupt flag register */
pub const RCC_CICR = RCC_BASE + 0x0020; // Clock interrupt clear register */
pub const RCC_AHB1RSTR = RCC_BASE + 0x0028; // AHB1 peripheral reset register */
pub const RCC_AHB2RSTR = RCC_BASE + 0x002C; // AHB2 peripheral reset register */
pub const RCC_AHB3RSTR = RCC_BASE + 0x0030; // AHB3 peripheral reset register */
pub const RCC_APB1RSTR1 = RCC_BASE + 0x0038; // APB1 peripheral reset register 1 */
pub const RCC_APB1RSTR2 = RCC_BASE + 0x003C; // APB1 peripheral reset register 2 */
pub const RCC_APB2RSTR = RCC_BASE + 0x0040; // APB2 peripheral reset register */
pub const RCC_AHB1ENR = RCC_BASE + 0x0048; // AHB1 peripheral clock enable register */
pub const RCC_AHB2ENR = RCC_BASE + 0x004C; // AHB2 peripheral clock enable register */
pub const RCC_AHB3ENR = RCC_BASE + 0x0050; // AHB3 peripheral clock enable register */
pub const RCC_APB1ENR1 = RCC_BASE + 0x0058; // APB1 peripheral clock enable register 1 */
pub const RCC_APB1ENR2 = RCC_BASE + 0x005C; // APB1 peripheral clock enable register 2 */
pub const RCC_APB2ENR = RCC_BASE + 0x0060; // APB2 peripheral clock enable register */
pub const RCC_AHB1SMENR = RCC_BASE + 0x0068; // AHB1 peripheral clocks enable in Sleep and Stop modes register */
pub const RCC_AHB2SMENR = RCC_BASE + 0x006C; // AHB2 peripheral clocks enable in Sleep and Stop modes register */
pub const RCC_AHB3SMENR = RCC_BASE + 0x0070; // AHB3 peripheral clocks enable in Sleep and Stop modes register */
pub const RCC_APB1SMENR1 = RCC_BASE + 0x0078; // APB1 peripheral clocks enable in Sleep and Stop modes register 1 */
pub const RCC_APB1SMENR2 = RCC_BASE + 0x007C; // APB1 peripheral clocks enable in Sleep and Stop modes register 2 */
pub const RCC_APB2SMENR = RCC_BASE + 0x0080; // APB2 peripheral clocks enable in Sleep and Stop modes register */
pub const RCC_CCIPR = RCC_BASE + 0x0088; // Peripherals independent clock configuration register */
pub const RCC_BDCR = RCC_BASE + 0x0090; // Backup domain control register */
pub const RCC_CSR = RCC_BASE + 0x0094; // Control/status register */
pub const RCC_CRRCR = RCC_BASE + 0x0098; // Clock recovery RC register */
pub const RCC_CCIPR2 = RCC_BASE + 0x009C; // Peripherals independent clock configuration register */

// RCC_CR bit definition */
pub const RCC_CR_PLLSAI2RDY = 0x20000000; // SAI2 PLL clock ready flag
pub const RCC_CR_PLLSAI2ON = 0x10000000; // SAI2 PLL enable
pub const RCC_CR_PLLSAI1RDY = 0x08000000; // SAI1 PLL clock ready flag
pub const RCC_CR_PLLSAI1ON = 0x04000000; // SAI1 PLL enable
pub const RCC_CR_PLLRDY = 0x02000000; // Main PLL clock ready flag
pub const RCC_CR_PLLON = 0x01000000; // Main PLL enable
pub const RCC_CR_CSSON = 0x00080000; // Clock security system enable
pub const RCC_CR_HSEBYP = 0x00040000; // HSE crystal oscillator bypass
pub const RCC_CR_HSERDY = 0x00020000; // HSE clock ready flag
pub const RCC_CR_HSEON: usize = 0x00010000; // HSE clock enable
pub const RCC_CR_HSIASFS: usize = 0x00000800; // HSI16 automatic start from Stop
pub const RCC_CR_HSIRDY: usize = 0x00000400; // HSI16 clock ready flag
pub const RCC_CR_HSIKERON: usize = 0x00000200; // HSI16 always enable for peripheral kernels.
pub const RCC_CR_HSION: usize = 0x00000100; // HSI16 clock enable
pub const RCC_CR_MSIRANGE = 0x000000F0; // MSI clock ranges
pub const RCC_CR_MSIRGSEL = 0x00000008; // MSI clock range selection
pub const RCC_CR_MSIPLLEN = 0x00000004; // MSI clock PLL enable
pub const RCC_CR_MSIRDY = 0x00000002; // MSI clock ready flag
pub const RCC_CR_MSION = 0x00000001; // MSI clock enable

// MSI clock range value RCC_CR_MSIRANGE */
pub const RCC_CR_MSIRANGE_100K = 0x00000000; //	around 100 KHz
pub const RCC_CR_MSIRANGE_200K = 0x00000010; //	around 200 KHz
pub const RCC_CR_MSIRANGE_400K = 0x00000020; //	around 400 KHz
pub const RCC_CR_MSIRANGE_800K = 0x00000030; //	around 800 KHz
pub const RCC_CR_MSIRANGE_1M = 0x00000040; //	around   1 MHz
pub const RCC_CR_MSIRANGE_2M = 0x00000050; //	around   2 MHz
pub const RCC_CR_MSIRANGE_4M = 0x00000060; //	around   4 MHz
pub const RCC_CR_MSIRANGE_8M = 0x00000070; //	around   8 MHz
pub const RCC_CR_MSIRANGE_16M = 0x00000080; //	around  16 MHz
pub const RCC_CR_MSIRANGE_24M = 0x00000090; //	around  24 MHz
pub const RCC_CR_MSIRANGE_32M = 0x000000A0; //	around  32 MHz
pub const RCC_CR_MSIRANGE_48M = 0x000000B0; //	around  48 MHz

// RCC_CFGR bit definition */
pub const RCC_CFGR_MCOPRE = 0x70000000; // Microcontroller clock output prescaler
pub const RCC_CFGR_MCOSEL = 0x0F000000; // Microcontroller clock output
pub const RCC_CFGR_STOPWUCK = 0x00008000; // Wakeup from Stop and CSS backup clock selection
pub const RCC_CFGR_PPRE2 = 0x00003800; // APB high-speed prescaler APB2
pub const RCC_CFGR_PPRE1 = 0x00000700; // APB low-speed prescaler APB1
pub const RCC_CFGR_HPRE = 0x000000F0; // AHB prescaler
pub const RCC_CFGR_SWS = 0x0000000C; // System clock switch status
pub const RCC_CFGR_SW = 0x00000003; // System clock switch

pub const RCC_CFGR_SWS_MSI = 0x00000000; // MSI used for system clock
pub const RCC_CFGR_SWS_HSI16 = 0x00000004; // HSI16 used for system clock
pub const RCC_CFGR_SWS_HSE = 0x00000008; // HSE used for system clock
pub const RCC_CFGR_SWS_PLL = 0x0000000C; // PLL used for system clock

pub const RCC_CFGR_SW_MSI = 0x00000000; // Use MSI for system clock
pub const RCC_CFGR_SW_HSI16 = 0x00000001; // Use HSI16 for system clock
pub const RCC_CFGR_SW_HSE = 0x00000002; // Use HSE for system clock
pub const RCC_CFGR_SW_PLL = 0x00000003; // Use PLL for system clock

// RCC_PLLCFGR bit definition */
pub const RCC_PLLCFGR_PLLR = 0x06000000; // Main PLL division factor for PLLCLK system clock
pub const RCC_PLLCFGR_PLLREN = 0x01000000; // Main PLL PLLCLK output enable
pub const RCC_PLLCFGR_PLLQ = 0x00600000; // Main PLL division factor for PLL48M1CLK 48 MHz clock.
pub const RCC_PLLCFGR_PLLQEN = 0x00100000; // Main PLL PLL48M1CLK output enable
pub const RCC_PLLCFGR_PLLP = 0x00020000; // Main PLL division factor for PLLSAI3CLK SAI1 and SAI2 clock.
pub const RCC_PLLCFGR_PLLPEN = 0x00010000; // Main PLL PLLSAI3CLK output enable
pub const RCC_PLLCFGR_PLLN = 0x00007F00; // Main PLL multiplication factor for VCO
pub const RCC_PLLCFGR_PLLM = 0x000000F0; // Division factor for the main PLLinput clock
pub const RCC_PLLCFGR_PLLSRC = 0x00000003; // Main PLL entry clock source

pub const RCC_PLLCFGR_PLLSRC_NON = 0x00000000; // No clock
pub const RCC_PLLCFGR_PLLSRC_MSI = 0x00000001; // Use MSI for system clock
pub const RCC_PLLCFGR_PLLSRC_HSI = 0x00000002; // Use HSI16 for system clock
pub const RCC_PLLCFGR_PLLSRC_HSE = 0x00000003; // Use HSE for system clock

// RCC_APB1ENR1 bit definition */
pub const RCC_APB1ENR1_LPTIM1EN = 0x80000000; // Low power timer 1 clock enable
pub const RCC_APB1ENR1_OPAMPEN = 0x40000000; // OPAMP interface clock enable
pub const RCC_APB1ENR1_DAC1EN = 0x20000000; // DAC1 interface clock enable
pub const RCC_APB1ENR1_PWREN = 0x10000000; // Power interface clock enable
pub const RCC_APB1ENR1_CAN1EN = 0x02000000; // CAN1 clock enable
pub const RCC_APB1ENR1_CRSEN = 0x01000000; // Clock Recovery System clock enable
pub const RCC_APB1ENR1_I2C3EN = 0x00800000; // I2C3 clock enable
pub const RCC_APB1ENR1_I2C2EN = 0x00400000; // I2C2 clock enable
pub const RCC_APB1ENR1_I2C1EN = 0x00200000; // I2C1 clock enable
pub const RCC_APB1ENR1_UART5EN = 0x00100000; // UART5 clock enable
pub const RCC_APB1ENR1_UART4EN = 0x00080000; // UART4 clock enable
pub const RCC_APB1ENR1_USART3EN = 0x00040000; // USART3 clock enable
pub const RCC_APB1ENR1_USART2EN = 0x00020000; // USART2 clock enable
pub const RCC_APB1ENR1_SPI3EN = 0x00008000; // SPI3 clock enable
pub const RCC_APB1ENR1_SPI2EN = 0x00004000; // SPI2 clock enable
pub const RCC_APB1ENR1_WWDGEN = 0x00000800; // Window watchdog clock enable
pub const RCC_APB1ENR1_RTCAPBEN = 0x00000400; // RTC APB clock enable
pub const RCC_APB1ENR1_TIM7EN = 0x00000020; // TIM7 timer clock enable
pub const RCC_APB1ENR1_TIM6EN = 0x00000010; // TIM6 timer clock enable
pub const RCC_APB1ENR1_TIM5EN = 0x00000008; // TIM5 timer clock enable
pub const RCC_APB1ENR1_TIM4EN = 0x00000004; // TIM4 timer clock enable
pub const RCC_APB1ENR1_TIM3EN = 0x00000002; // TIM3 timer clock enable
pub const RCC_APB1ENR1_TIM2EN = 0x00000001; // TIM2 timer clock enable

// RCC_APB1ENR2 bit definition */
pub const RCC_APB1ENR2_LPTIM2EN = 0x00000020; // Low power timer 2 clock enable
pub const RCC_APB1ENR2_SWPMI1EN = 0x00000004; // Single wire protocol clock enable
pub const RCC_APB1ENR2_I2C4EN = 0x00000002; // I2C4 clock enable
pub const RCC_APB1ENR2_LPUART1EN = 0x00000001; // Low power UART 1 clock enable

// RCC_APB2ENR bit definition */
pub const RCC_APB2ENR_DFSDM1EN = 0x01000000; // DFSDM 1 Timer clock enable
pub const RCC_APB2ENR_SAI2EN = 0x00400000; // SAI 2 clock enable
pub const RCC_APB2ENR_SAI1EN = 0x00200000; // SAI1 clock enable
pub const RCC_APB2ENR_TIM17EN = 0x00040000; // TIM 17 Enable timer clock
pub const RCC_APB2ENR_TIM16EN = 0x00020000; // TIM16 Enable timer clock
pub const RCC_APB2ENR_TIM15EN = 0x00010000; // TIM 15 Enable timer clock
pub const RCC_APB2ENR_USART1EN = 0x00004000; // USART1 clock enable
pub const RCC_APB2ENR_TIM8EN = 0x00002000; // TIM 8 Timer clock enable
pub const RCC_APB2ENR_SPI1EN = 0x00001000; // SPI 1 clock enable
pub const RCC_APB2ENR_TIM1EN = 0x00000800; // TIM1 Enable timer clock
pub const RCC_APB2ENR_SDMMC1EN = 0x00000400; // Enable SDMMC clock
pub const RCC_APB2ENR_FWEN = 0x00000080; // Enable Firewall Clock
pub const RCC_APB2ENR_SYSCFGEN = 0x00000001; // SYSCFG + COMP + VREFBUF clock enable

// RCC_AHB2ENR bit definition */
pub const RCC_AHB2ENR_GPIOAEN = 0x00000001; // GPIOA clock enable
pub const RCC_AHB2ENR_GPIOBEN = 0x00000002; // GPIOB clock enable
pub const RCC_AHB2ENR_GPIOCEN = 0x00000004; // GPIOC clock enable
pub const RCC_AHB2ENR_GPIODEN = 0x00000008; // GPIOD clock enable
pub const RCC_AHB2ENR_GPIOEEN = 0x00000010; // GPIOE clock enable
pub const RCC_AHB2ENR_GPIOFEN = 0x00000020; // GPIOF clock enable
pub const RCC_AHB2ENR_GPIOGEN = 0x00000040; // GPIOG clock enable
pub const RCC_AHB2ENR_GPIOHEN = 0x00000080; // GPIOH clock enable
pub const RCC_AHB2ENR_GPIOIEN = 0x00000100; // GPIOI clock enable
pub const RCC_AHB2ENR_ADCEN = 0x00002000; // ADC clock enable

// RCC_CCIPR bit definition */
pub const RCC_CCIPR_USARTxSEL = 0x000003FF; // USART clock select
pub const RCC_CCIPR_LPUART1SEL = 0x00000C00; // LPUART1 clock select
pub const RCC_CCIPR_I2CxSEL = 0x0003F000; // I2Cx clock select
pub const RCC_CCIPR_LPTIMxSEL = 0x003C0000; // LPTIMx clock select
pub const RCC_CCIPR_SAIxSEL = 0x03C00000; // SAIx clock select
pub const RCC_CCIPR_CLK48SEL = 0x0C000000; // CLK48 clock select
pub const RCC_CCIPR_ADCSEL = 0x30000000; // ADC clock select
pub const RCC_CCIPR_SWPMI1SEL = 0x40000000; // SWPMI1 clock select
pub const RCC_CCIPR_DFSDM1SEL = 0x80000000; // DFSDM1 clock select

// System Timer clock */

// Settable interval range millisecond */
pub const MIN_TIMER_PERIOD = 1;
pub const MAX_TIMER_PERIOD = 50;

// ------------------------------------------------------------------------ */
// Number of Interrupt vectors */
pub const N_INTVEC = 82; // Number of Interrupt vectors */
pub const N_SYSVEC = 16; // Number of System Exceptions */

// The number of the implemented bit width for priority value fields. */
pub const INTPRI_BITWIDTH = 4;

// ------------------------------------------------------------------------ */
// Interrupt Priority Levels */
// pub export const INTPRI_MAX_EXTINT_PRI: usize = 1; // Highest Ext. interrupt level */
pub const INTPRI_SVC = 0; // SVCall */
pub const INTPRI_SYSTICK = 1; // SysTick */
pub const INTPRI_PENDSV = 15; // PendSV */

// Time-event handler interrupt level */
pub const TIMER_INTLEVEL = 0;

// ------------------------------------------------------------------------ */
// EXTI Extended interrupt controller */
pub const EXTI_BASE = 0x40010400;
pub const EXTI_IMR1 = EXTI_BASE + 0x00;
pub const EXTI_EMR1 = EXTI_BASE + 0x04;
pub const EXTI_RTSR1 = EXTI_BASE + 0x08;
pub const EXTI_FTSR1 = EXTI_BASE + 0x0C;
pub const EXTI_SWIER1 = EXTI_BASE + 0x10;
pub const EXTI_PR1 = EXTI_BASE + 0x14;
pub const EXTI_IMR2 = EXTI_BASE + 0x20;
pub const EXTI_EMR2 = EXTI_BASE + 0x24;
pub const EXTI_RTSR2 = EXTI_BASE + 0x28;
pub const EXTI_FTSR2 = EXTI_BASE + 0x2C;
pub const EXTI_SWIER2 = EXTI_BASE + 0x30;
pub const EXTI_PR2 = EXTI_BASE + 0x34;

// Watchdog Timer */

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

pub fn GPIO_MODER(n: []const u8) void {
    "GPIO" ++ n ++ "_BASE" + 0x00;
} // GPIO port mode register */
pub fn GPIO_OTYPER(n: []const u8) void {
    "GPIO" ++ n ++ "_BASE" + 0x04;
} // GPIO port output type register */
pub fn GPIO_OSPEEDR(n: []const u8) void {
    "GPIO" ++ n ++ "_BASE" + 0x08;
} // GPIO port output speed register */
pub fn GPIO_PUPDR(n: []const u8) void {
    "GPIO" ++ n ++ "_BASE" + 0x0C;
} // GPIO port pull-up/pull-down register */
pub fn GPIO_isizeR(n: []const u8) void {
    "GPIO" ++ n ++ "_BASE" + 0x10;
} // GPIO port input data register */
pub fn GPIO_ODR(n: []const u8) void {
    "GPIO" ++ n ++ "_BASE" + 0x14;
} // GPIO port output data register */
pub fn GPIO_BSRR(n: []const u8) void {
    "GPIO" ++ n ++ "_BASE" + 0x18;
} // GPIO port bit set/reset register */
pub fn GPIO_LCKR(n: []const u8) void {
    "GPIO" ++ n ++ "_BASE" + 0x1C;
} // GPIO port configuration lock register */
pub fn GPIO_AFRL(n: []const u8) void {
    "GPIO" ++ n ++ "_BASE" + 0x20;
} // GPIO alternate function low register */
pub fn GPIO_AFRH(n: []const u8) void {
    "GPIO" ++ n ++ "_BASE" + 0x24;
} // GPIO alternate function high register */
pub fn GPIO_BRR(n: []const u8) void {
    "GPIO" ++ n ++ "_BASE" + 0x28;
} // GPIO port bit reset register */
pub fn GPIO_ASCR(n: []const u8) void {
    "GPIO" ++ n ++ "_BASE" + 0x2C;
} // GPIO port analog switch control register */

// Physical timer for STM32L4 */
pub const CPU_HAS_PTMR = 1;

// Timer register definition */
pub const TIM2_BASE = 0x40000000;
pub const TIM3_BASE = 0x40000400;
pub const TIM4_BASE = 0x40000800;
pub const TIM5_BASE = 0x40000C00;
pub const TIM6_BASE = 0x40001000;
pub const TIM7_BASE = 0x40001400;

pub const TIMxCR1 = 0x00;
pub const TIMxCR2 = 0x04;
pub const TIMxSMCR = 0x08;
pub const TIMxDIER = 0x0C;
pub const TIMxSR = 0x10;
pub const TIMxEGR = 0x14;
pub const TIMxCCMR1 = 0x18;
pub const TIMxCCMR2 = 0x1C;
pub const TIMxCCER = 0x20;
pub const TIMxCNT = 0x24;
pub const TIMxPSC = 0x28;
pub const TIMxARR = 0x2C;
pub const TIMxCCR1 = 0x34;
pub const TIMxCCR2 = 0x38;
pub const TIMxCCR3 = 0x3C;
pub const TIMxCCR4 = 0x40;
pub const TIMxDCR = 0x48;
pub const TIMxDMAR = 0x4C;
pub const TIMxOR1 = 0x50;
pub const TIMxOR2 = 0x60;

pub const TIMxCR1_CEN = 1 << 0;
pub const TIMxCR1_OPM = 1 << 3;
pub const TIMxCR1_DIR = 1 << 4;
pub const TIMxDIER_UIE = 1 << 0;
pub const TIMxSR_UIF = 1 << 0;
pub const TIMxEGR_UG = 1 << 0;

// Prescaler value */
pub const TIM2PSC_PSC_INIT = 0;
pub const TIM3PSC_PSC_INIT = 0;
pub const TIM4PSC_PSC_INIT = 0;
pub const TIM5PSC_PSC_INIT = 0;

// Physical timer interrupt number */
pub const INTNO_TIM2 = 28;
pub const INTNO_TIM3 = 29;
pub const INTNO_TIM4 = 30;
pub const INTNO_TIM5 = 50;

// Physical timer interrupt priority */
pub const INTPRI_TIM2 = 5;
pub const INTPRI_TIM3 = 5;
pub const INTPRI_TIM4 = 5;
pub const INTPRI_TIM5 = 5;

// Phycail timer Maximum count */
pub const PTMR_MAX_CNT16 = 0x0000FFFF;
pub const PTMR_MAX_CNT32 = 0xFFFFFFFF;

// Coprocessor */
pub const CPU_HAS_FPU = true;
pub const CPU_HAS_DSP = false;

// Number of coprocessors to use. Depends on user configuration */
// if (comptime USE_FPU) {
// pub const NUM_COPROCESSOR	=1
// }else {
pub const NUM_COPROCESSOR = 0;
// }
