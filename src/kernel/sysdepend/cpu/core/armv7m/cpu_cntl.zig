const knlink = @import("knlink");
const cpudef = libtk.sysdepend.cpudef;
const cpu_task = knlink.sysdepend.cpu_task;
const SStackFrame = cpu_task.SStackFrame;
const task = knlink.task;
const TCB = knlink.TCB;
const libsys = @import("libsys");
const sysdef = libsys.sysdepend.sysdef;
const libtk = @import("libtk");
const write = libtk.syslib.cpu.write;
const int = libtk.sysdepend.int;
const config = @import("config");

// if (comptime CPU_CORE_ARMV7M) {
//CPU-Dependent Control

// Temporal stack used when 'dispatch_to_schedtsk' is called */
// Noinit(knl_tmp_stack:[TMP_STACK_SIZE]u8);

// Task independent status */
// armv7mだとアセンブリで使わないのでexportいらない
pub const knl_taskindp: i32 = 0;

//Set task register contents (Used in tk_set_reg()) */
pub fn knl_set_reg(tcb: *TCB, regs: *const cpudef.T_REGS, eit: *const cpudef.T_EIT, cregs: *const cpudef.T_CREGS) void {
    var ssp: *SStackFrame = undefined;
    // if (comptime config.USE_FPU) {
    //     var tmpp: *u32 = @as(*u32, if (cregs != null) {
    //         cregs.ssp;
    //     } else {
    //         tcb.tskctxb.ssp;
    //     });
    //     if (tcb.tskatr & cpudef.TA_FPU) {
    //         if (tmpp.* & cpu_task.EXPRN_NO_FPU) { // FPU register is not saved */
    //             ssp = @as(*SStackFrame, tmpp);
    //         } else { // FPU register is saved */
    //             // ssp = @as(*SStackFrame, @as(*SStackFrame_wFPU, tmpp).r_);
    //         }
    //     } else {
    //         ssp = @as(*SStackFrame, tmpp);
    //     }
    // } else {
    ssp = @as(*SStackFrame, if (cregs != null) {
        cregs.ssp;
    } else {
        tcb.tskctxb.ssp;
    });
    // }

    if (regs != null) {
        for (0..3) |i| {
            ssp.r[i] = regs.r[i];
        }
        for (4..11) |i| {
            ssp.r_[i - 4] = regs.r[i];
        }
    }

    if (eit != null) {
        ssp.pc = eit.pc;
    }

    if (cregs != null) {
        tcb.tskctxb.ssp = cregs.ssp;
    }
}

//Get task register contents (Used in tk_get_reg())
pub fn knl_get_reg(tcb: *TCB, regs: *cpudef.T_REGS, eit: *cpudef.T_EIT, cregs: *cpudef.T_CREGS) void {
    // if (comptime USE_FPU) {
    //     var tmpp: *u32 = @as(*u32, tcb.tskctxb.ssp);
    //     if (tcb.tskatr & TA_FPU) {
    //         if (tmpp.* & EXPRN_NO_FPU) { // FPU register is not saved */
    //             ssp = @as(*SStackFrame, tmpp);
    //         } else { // FPU register is saved */
    //             ssp = @as(*SStackFrame, &(@as(*SStackFrame_wFPU, tmpp).exp_ret));
    //         }
    //     } else {
    //         ssp = @as(*SStackFrame, tmpp);
    //     }
    // } else {
    var ssp: *SStackFrame = @as(*SStackFrame, tcb.tskctxb.ssp);
    // }

    if (regs != null) {
        for (0..3) |i| {
            regs.r[i] = ssp.r[i];
        }
        for (4..11) |i| {
            regs.r[i] = ssp.r_[i - 4];
        }
        regs.r[12] = ssp.ip;
        regs.lr = ssp.lr;
    }

    if (eit != null) {
        eit.pc = ssp.pc;
        eit.taskmode = 0;
    }

    if (cregs != null) {
        cregs.ssp = tcb.tskctxb.ssp;
    }
}

// if (comptime  USE_FPU) {
// if (comptime  USE_FUNC_TK_SET_CPR) {
// //Set task register contents (Used in tk_set_reg())
// pub fn knl_set_cpr(  tcb: *TCB,  copno: isize, copregs: *const T_COPREGS) TkError!void {
// 	var i: isize = 0;
//
// 	var ssp: *SStackFrame_wFPU = @as(*SStackFrame_wFPU,tcb.tskctxb.ssp);
//
// 	if(ssp.ufpu & EXPRN_NO_FPU ) {	// FPU register is not saved */
// 		return TkError.E_CTX;
// 	}
//
// 	for (i < 16) {
//             i+=1;
//             ssp.s[i] = copregs.s[i];
//             ssp.s_[i] = copregs.s[i + 16];
// 	}
// 	ssp.fpscr = copregs.fpscr;
// 	// return TkError.E_OK;
// }
// } // USE_FUNC_TK_SET_CPR */
//
// if (comptime  USE_FUNC_TK_GET_CPR) {
// //Get task FPU register contents (Used in tk_get_cpr())
// pub fn knl_get_cpr( TCB *tcb, isize copno, T_COPREGS *copregs) TkError!void {
// 	var i: isize = 0;
//
// 	var ssp: *SStackFrame_wFPU = @as(*SStackFrame_wFPU,tcb.tskctxb.ssp);
//
// 	if(ssp.ufpu & EXPRN_NO_FPU ) {	// FPU register is not saved */
// 		return TkError.E_CTX;
// 	}
//
// 	for ( i < 16 ) {
//             i+=1;
//             copregs.s[i] = ssp.s[i];
//             copregs.s[i + 16] = ssp.s_[i];
// 	}
// 	copregs.fpscr = ssp.fpscr;
//
// 	// return TkError.E_OK;
// }
// } // USE_FUNC_TK_GET_CPR */
// } // USE_FPU */

//Task dispatcher startup
pub fn knl_force_dispatch() void {
    task.knl_dispatch_disabled = knlink.DDS_DISABLE_IMPLICIT;
    knlink.knl_ctxtsk = null;
    write(sysdef.core.SCB_ICSR, sysdef.core.ICSR_PENDSVSET); // pendsv exception */
    int.core.set_basepri(0);
}

pub fn knl_dispatch() void {
    write(sysdef.core.SCB_ICSR, sysdef.core.ICSR_PENDSVSET); // pendsv exception */
}

// } // CPU_CORE_ARMV7M */
