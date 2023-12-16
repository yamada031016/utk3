//CPU dependent definition  (ARMv7-M core depended) */
const syscall = @import("libtk").syscall;
const config = @import("config");

// Using FPU (depend on CPU)
//  TA_COP0		FPU ( = TA_FPU)

pub const TA_COPS = if (config.USE_FPU) syscall.TA_COP0 else 0;

pub const TA_FPU = syscall.TA_COP0; // dummy. An error occurs when checking API calls. */

// General purpose register		tk_get_reg tk_set_reg
pub const T_REGS = struct {
    r: [13]i32, // General purpose register R0-R12 */
    lr: *void, // Link register R14 */
};

// Exception-related register		tk_get_reg tk_set_reg */
pub const T_EIT = struct {
    pc: *void, // Program counter R15 */
    xpsr: u32, // Program status register */
    taskmode: u32, // Task mode flag */
};

// Control register			tk_get_reg tk_set_reg
pub const T_CREGS = struct {
    ssp: *void, // System stack pointer R13_svc */
};

// if (comptime  NUM_COPROCESSOR > 0) {
// Co-processor register
pub const T_COPREGS = struct {
    s: [32]i32, // FPU General purpose register S0-S31 */
    fpscr: u32, // Floating-point Status and Control Register */
};
// }  // NUM_COPROCESSOR  */
