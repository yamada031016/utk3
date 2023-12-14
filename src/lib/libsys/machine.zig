//Machine type definition */

// ===== System dependencies definitions ================================ */

// if (comptime  _IOTE_M367_ */
// const  = @import{ "sysdepend/iote_m367/machine.h" */
// pub const Csym(sym) sym */
// } */
//*/
// if (comptime  _IOTE_STM32L4_ */
// const  = @import{ "sysdepend/iote_stm32l4/machine.h" */
// pub const Csym(sym) sym */
// } */
//*/
// if (comptime  _IOTE_RX231_ */
// const  = @import{ "sysdepend/iote_rx231/machine.h" */
// pub const Csym(sym) _##sym */
// } */
//*/
// if (comptime  _IOTE_RZA2M_ */
// const  = @import{ "sysdepend/iote_rza2m/machine.h" */
// pub const Csym(sym) sym */
// } */
//*/
// ----- μT-Kernel BSP ------------------------------------------------- */
// const machine = @import("sysdepend/nucleo_l476/machine.h");
// 適当
// pub fn Csym(sym: fn () void) void {
//     sym;
// }
//*/
// if (comptime  _NUCLEO_H723_ */
// const  = @import{ "sysdepend/nucleo_h723/machine.h" */
// pub const Csym(sym) sym */
// } */
//*/
// if (comptime  _RTB_RX65N_ */
// const  = @import{ "sysdepend/rtb_rx65n/machine.h" */
// pub const Csym(sym) _##sym */
// } */
//*/
// if (comptime  _RSK_RX65N_ */
// const  = @import{ "sysdepend/rsk_rx65n/machine.h" */
// pub const Csym(sym) _##sym */
// } */
//*/
// if (comptime  _PICO_RP2040_ */
// const  = @import{ "sysdepend/pico_rp2040/machine.h" */
// pub const Csym(sym) sym */
// } */
//*/
// ===== C compiler dependencies definitions ============================= */
//
// if (comptime  __GNUC__) {
//
// pub const inline fn static __inline__
// pub const Asm __asm__ volatile
// pub const Noinit(decl) decl __attribute__((section(".noinit")))
// pub const Section(decl, name) decl __attribute__((section(#name)))
// pub const WEAK_FUNC __attribute__((weak))
//
// pub const _VECTOR_ENTRY(name) .word name
// pub const _WEAK_ENTRY(name) .weak name
//
// } // __GNUC__ */

// 追記
// ----- Nucleo-64 STM32L467 (CPU: STM32L476) definition ----- */

pub const NUCLEO_L476 = true; // Target system : Nucleo-64 STM32L467 */
pub const CPU_STM32L4 = true; // Target CPU : STM32L4 series */
pub const CPU_STM32L476 = true; // Target CPU : STM32L476 */
pub const CPU_CORE_ARMV7M = true; // Target CPU-Core type : ARMv7-M */
pub const CPU_CORE_ACM4F = true; // Target CPU-Core : ARM Cortex-M4 */

pub const TARGET_DIR = "nucleo_l476"; // Sysdepend-Directory name */
pub const TARGET_CPU_DIR = "stm32l4"; // Sysdepend-CPU-Directory name */

// ----- ARMv7-M definition ----- */
pub const ALLOW_MISALIGN = 0;
pub const INT_BITWIDTH = @bitSizeOf(usize);

// Endianness */
pub const BIGENDIAN = 0; // Default (Little Endian) */
