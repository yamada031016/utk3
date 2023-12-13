const knlink = @import("knlink");
const task = knlink.task;
const TCB = knlink.TCB;
const cpu_cntl = knlink.sysdepend.cpu_ctrl;
const libtk = @import("libtk");
const syslib = libtk.syslib;
const cpudef = libtk.cpudef;
const TkError = libtk.errno.TkError;
const cpu_task = knlink.sysdepend.cpu_task;
const cpu_status = knlink.sysdepend.cpu_status;
const libsys = @import("libsys");
const sysdef = libsys.sysdepend.sysdef.cpu;
const int = libtk.int_armv7m;

// if (comptime  CPU_CORE_ARMV7M) {
//Interrupt control */

// if (comptime  !USE_STATIC_IVT) {
// Exception handler table (RAM) */
pub export const exchdr_tbl: [sysdef.N_SYSVEC + sysdef.N_INTVEC]usize linksection(".data_vector") = undefined;
// }

// HLL(High level programming language) Interrupt Handler */
// Noinit( knl_inthdr_tbl:[N_isizeVEC]isize);	// HLL Interrupt Handler Table */
pub var knl_inthdr_tbl: [sysdef.N_INTVEC]*const fn () void = undefined;
pub fn knl_hll_inthdr() void {
    cpu_status.ENTER_TASK_INDEPENDENT();
    defer cpu_status.LEAVE_TASK_INDEPENDENT();

    var intno: u32 = knlink.sysdepend.sysdepend.knl_get_ipsr() - 16;
    var inthdr: *const fn () void = knl_inthdr_tbl[intno];
    // (inthdr.*)(intno);
    inthdr(intno);
}

//System-timer Interrupt handler */
pub fn knl_systim_inthdr() callconv(.C) void {
    cpu_status.ENTER_TASK_INDEPENDENT();
    defer cpu_status.LEAVE_TASK_INDEPENDENT();
    knlink.timer.knl_timer_handler();
}

//Set interrupt handler (Used in tk_def_int()) */
pub fn knl_define_inthdr(intno: isize, intatr: u32, inthdr: ?*const fn () void) void {
    if (inthdr != null) {
        if ((intatr & libtk.syscall.TA_HLNG) != 0) {
            knl_inthdr_tbl[intno] = inthdr;
            inthdr = knl_hll_inthdr;
        }
    } else { // Clear interrupt handler */
        inthdr = knlink.sysdepend.exc_hdr.Default_Handler;
    }
    var intvet: *volatile isize = @as(*isize, &exchdr_tbl[sysdef.N_SYSVEC]);
    intvet[intno] = inthdr;
}

//Return interrupt handler (Used in tk_ret_int()) */
pub fn knl_return_inthdr() void {
    // No processing in ARM. */
    return;
}

//Interrupt initialize
pub fn knl_init_interrupt() TkError!void {
    // Register exception handler used on OS */
    return;
}
// }	// CPU_CORE_ARMV7M */
