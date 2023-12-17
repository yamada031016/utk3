//CPU-Dependent Task Start Processing
const knlink = @import("knlink");
const task = knlink.task;
const TCB = knlink.TCB;
const config = @import("config");

// if (comptime  _SYSDEPEND_CPU_CORE_CPUTASK_) {
// System stack configuration at task startup */
pub const SStackFrame = struct {
    exp_ret: usize, // Exception return */
    r_: [8]usize, // R4-R11 */
    // Exception entry stack
    r: [4]usize, // R0-R3 */
    ip: usize, // R12 */
    lr: ?*anyopaque, // lr */
    pc: ?*anyopaque, // pc */
    xpsr: usize, // xpsr */
};

// Size of system stack area destroyed by 'make_dormant()'
//In other words, the size of area required to write by 'knl_setup_context().'
pub const DORMANT_STACK_SIZE = @sizeOf(i32); //7  // To 'R4' position */

// if (comptime  USE_FPU) {
// const SStackFrame_wFPU = struct {
//         ufpu: u32,		// FPU usage flag */
// 		s_:[16]u32,		// S16-S31 */
//
// 		exp_ret: u32,	// Exception return */
//         r_:[8]u32,		// R4-R11 */
// 	// Exception entry stack
// 		r:[4]u32,		// R0-R3 */
// 		ip: u32,		// R12 */
// 	lr: *void,		// lr */
// 	pc: *void,		// pc */
// 		xpsr: u32,		// xpsr */
// 		s:[16]u32,		// S0-S15 */
// 		fpscr: u32,		// fpscr */
// };
//
// pub const EXPRN_NO_FPU = 0x00000010;	// FPU usage flag  0:use 1:no use */
// } // USE_FPU */

// Create stack frame for task startup
//Call from 'make_dormant()'
pub fn knl_setup_context(tcb: *TCB) void {
    var ssp: *SStackFrame = @ptrCast(@alignCast(tcb.isstack));
    ssp = @ptrFromInt(@intFromPtr(ssp) - 1);
    // CPU context initialization */
    ssp.exp_ret = 0xFFFFFFF9;
    ssp.lr = @ptrFromInt(0);
    ssp.xpsr = 0x01000000; // Initial SR */
    ssp.pc = @as(*void, @as(u32, tcb.task) & ~@as(usize, @intCast(0x00000001))); // Task startup address */
    tcb.tskctxb.ssp = ssp; // System stack pointer */
}

// Set task startup code
//Called by 'tk_sta_tsk()' processing.
// 暗黙の構造体の型変換でやりたい放題してるけど動くんか?
pub inline fn knl_setup_stacd(tcb: *TCB, stacd: usize) void {
    var ssp: *SStackFrame = tcb.tskctxb.ssp;

    ssp.r[0] = stacd;
    ssp.r[1] = @as(usize, @intFromPtr(tcb.exinf));
}

// Delete task contexts
pub inline fn knl_cleanup_context(tcb: *TCB) void {
    if (comptime config.USE_FPU) { // Clear CONTROL.FPCA */
        var control: u32 = undefined;

        if (tcb == knlink.knl_ctxtsk) {
            // Clear CONTROL.FPCA */
            // retを入れないとエラーになる。retが正しいかは知らん
            asm volatile ("mrs %0, control"
                : [ret] "=r" (control),
            );
            control &= (1 << 2);
            asm volatile ("msr control, %0"
                :
                : [ret] "r" (control),
            );
        }
    }
}
// } // _SYSDEPEND_CPU_CORE_CPUTASK_ */
