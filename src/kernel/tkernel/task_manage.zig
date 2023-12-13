// *	Task Management Function
const tstd = @import("tstd");
const knlink = @import("knlink");
const check = knlink.check;
const task = knlink.task;
const TSTAT = task.TSTAT;
const memory = knlink.memory;
const wait = knlink.wait;
const config = @import("config");
const cpu_task = knlink.sysdepend.cpu_task;
const cpu_status = knlink.sysdepend.cpu_status;
const cpu_ctrl = knlink.sysdepend.cpu_ctrl;
const TCB = knlink.TCB;
const inc_sys = @import("inc_sys");
const sysdef = inc_sys.sysdef;
const libtk = @import("libtk");
const syscall = libtk.syscall;
const TkError = libtk.errno.TkError;
const queue = inc_sys.queue;
const QUEUE = queue.QUEUE;
const print = @import("devices").serial.print;

// * Create task
pub fn tk_cre_tsk(pk_ctsk: *syscall.T_CTSK) TkError!isize {
    // Valid value of task attribute */
    var VALID_TSKATR: u32 = if (comptime config.CHK_RSATR) syscall.TA_HLNG | syscall.TA_RNG3 | syscall.TA_USERBUF | syscall.TA_COPS else undefined;
    if (comptime (config.CHK_RSATR and config.USE_OBJECT_NAME)) {
        VALID_TSKATR |= syscall.TA_DSNAME;
    }
    var sstksz: i32 = undefined;
    var stack: *void = undefined;

    check.CHECK_RSATR(pk_ctsk.tskatr, VALID_TSKATR);
    // if (comptime !USE_IMALLOC) {
    // TA_USERBUF must be specified if configured in no Imalloc */
    check.CHECK_PAR((pk_ctsk.tskatr & syscall.TA_USERBUF) != 0);
    // }
    check.CHECK_PAR(pk_ctsk.stksz >= 0);
    check.CHECK_PRI(pk_ctsk.itskpri);

    if ((pk_ctsk.tskatr & syscall.TA_USERBUF) != 0) {
        // Use user buffer */
        sstksz = pk_ctsk.stksz;
        check.CHECK_PAR(sstksz >= sysdef.MIN_SYS_STACK_SIZE);
        stack = pk_ctsk.bufptr;
    } else {
        // if (comptime USE_IMALLOC) {
        //     // Allocate system stack area */
        //     sstksz = pk_ctsk.stksz + DEFAULT_SYS_STKSZ;
        //     sstksz = (sstksz + 7) / 8 * 8; // Align to a multiple of 8 */
        //     stack = knl_Imalloc(@as(u32, sstksz));
        //     if (stack == null) {
        //         return TkError.E_NOMEM;
        //     }
        // }
    }

    cpu_status.BEGIN_CRITICAL_SECTION();
    defer cpu_status.END_CRITICAL_SECTION();
    // defer cpu_status.END_CRITICAL_SECTION();
    // Get control block from FreeQue */
    var tcb: *TCB = @as(*TCB, queue.QueRemoveNext(&task.knl_free_tcb));
    if (tcb == null) {
        cpu_status.END_CRITICAL_SECTION();
        return TkError.ExceedSystemLimits;
    }

    // Initialize control block */
    tcb.exinf = pk_ctsk.exinf;
    tcb.tskatr = pk_ctsk.tskatr;
    tcb.task = pk_ctsk.task;
    tcb.ipriority = @as(u8, task.int_priority(pk_ctsk.itskpri));
    tcb.sstksz = sstksz;
    if (comptime config.USE_OBJECT_NAME) {
        if ((pk_ctsk.tskatr & syscall.TA_DSNAME) != 0) {
            tstd.knl_strncpy(@as([]const u8, tcb.name), @as([]const u8, pk_ctsk.dsname), config.OBJECT_NAME_LENGTH);
        }
    }

    // Set stack pointer */
    tcb.isstack = @as(*i8, stack) + sstksz;

    // Set initial value of task operation mode */
    tcb.isysmode = 1;
    tcb.sysmode = 1;

    // make it to DORMANT state */
    task.knl_make_dormant(tcb);

    // ercd = tcb.tskid;

    if (comptime config.USE_IMALLOC) {
        // if ( (ercd < E_OK) && ((pk_ctsk.tskatr & TA_USERBUF) == 0) ) {
        // 	knl_Ifree(stack);
        // }
    }

    return tcb.tskid;
}

// * Task deletion
// *	Call from critical section
fn knl_del_tsk(tcb: *TCB) void {
    if (comptime config.USE_IMALLOC) {
        if ((tcb.tskatr & syscall.TA_USERBUF) == 0) {
            // User buffer is not used */
            // Free system stack */
            var stack: *void = @as(*i8, tcb.isstack) - tcb.sstksz;
            memory.knl_Ifree(stack);
        }
    }

    // Return control block to FreeQue */
    queue.QueInsert(&tcb.tskque, &task.knl_free_tcb);
    tcb.state = TSTAT.TS_NONEXIST;
}

// if (comptime USE_FUNC_TK_DEL_TSK) {
// * Delete task
pub fn tk_del_tsk(tskid: u32) TkError!void {
    check.CHECK_TSKID(tskid);
    check.CHECK_NONSELF(tskid);

    var tcb: *TCB = task.get_tcb(tskid);

    cpu_status.BEGIN_CRITICAL_SECTION();
    defer cpu_status.END_CRITICAL_SECTION();
    var state: TSTAT = @as(TSTAT, tcb.state);
    if (state != TSTAT.TS_DORMANT) {
        if (state == TSTAT.TS_NONEXIST) {
            return TkError.ObjectNotExist;
        } else {
            return TkError.IncorrectObjectState;
        }
    } else {
        knl_del_tsk(tcb);
    }
}
// }

// * Start task
pub fn tk_sta_tsk(tskid: u32, stacd: isize) TkError!void {
    check.CHECK_TSKID(tskid);
    check.CHECK_NONSELF(tskid);

    var tcb: *TCB = task.get_tcb(tskid);

    cpu_status.BEGIN_CRITICAL_SECTION();
    defer cpu_status.END_CRITICAL_SECTION();
    var state: TSTAT = @as(TSTAT, tcb.*.state);
    if (state != TSTAT.TS_DORMANT) {
        if (state == TSTAT.TS_NONEXIST) {
            return TkError.ObjectNotExist;
        } else {
            return TkError.IncorrectObjectState;
        }
    } else {
        cpu_task.knl_setup_stacd(tcb, stacd);
        task.knl_make_ready(tcb);
    }
}

// * Task finalization
// *	Call from critical section
fn knl_ter_tsk(tcb: *TCB) void {
    var state: TSTAT = @as(TSTAT, tcb.state);
    if (state == TSTAT.TS_READY) {
        task.knl_make_non_ready(tcb);
    } else if ((state & TSTAT.TS_WAIT) != 0) {
        wait.knl_wait_cancel(tcb);
        if (tcb.wspec.rel_wai_hook != null) {
            (*tcb.wspec.rel_wai_hook)(tcb);
        }
    }

    // if (comptime config.USE_MUTEX) {
    //     // signal mutex */
    //     mutex.knl_signal_all_mutex(tcb);
    // }
    cpu_task.knl_cleanup_context(tcb);
}

// if (comptime USE_FUNC_TK_EXT_TSK) {
// * End its own task
pub fn tk_ext_tsk() void {
    // if (comptime cpu_task.DORMANT_STACK_SIZE) {
    // To avoid destroying stack used in 'knl_make_dormant',
    // allocate the dummy area on the stack. */
    // volatileついてた
    // var _dummy: [cpu_task.DORMANT_STACK_SIZE]i8 = undefined;
    // }

    // Check context error */
    if (comptime config.CHK_CTX2) {
        if (cpu_status.in_indp()) {
            // SYSTEM_MESSAGE("tk_ext_tsk was called in the task independent\n");
            while (true) {}
            unreachable;
        }
    }
    if (comptime config.CHK_CTX1) {
        if (cpu_status.in_ddsp()) {
            // SYSTEM_MESSAGE("tk_ext_tsk was called in the dispatch disabled\n");
        }
    }

    // enableしてないけどええんか？
    cpu_status.DISABLE_INTERRUPT();
    knl_ter_tsk(knlink.knl_ctxtsk);
    task.knl_make_dormant(knlink.knl_ctxtsk);

    cpu_ctrl.knl_force_dispatch();
    // unreachableなはず。なら下のコードはなんのために?

    if (comptime cpu_task.DORMANT_STACK_SIZE) {
        // volatileついてた
        var _dummy: [cpu_task.DORMANT_STACK_SIZE]i8 = undefined;
        // Avoid WARNING (This code does not execute) */
        _dummy[0] = _dummy[0];
    }
}
// }

// if (comptime USE_FUNC_TK_EXD_TSK) {
// * End and delete its own task
pub fn tk_exd_tsk() void {
    // Check context error */
    if (comptime config.CHK_CTX2) {
        if (cpu_status.in_indp()) {
            print("tk_exd_tsk was called in the task independent");
            return;
        }
    }
    if (comptime config.CHK_CTX1) {
        if (cpu_status.in_ddsp()) {
            print("tk_exd_tsk was called in the dispatch disabled");
        }
    }

    // enableしてないけどええんか？
    cpu_status.DISABLE_INTERRUPT();
    knl_ter_tsk(knlink.knl_ctxtsk);
    knl_del_tsk(knlink.knl_ctxtsk);

    cpu_ctrl.knl_force_dispatch();
    unreachable;
}
// }

// if (comptime USE_FUNC_TK_TER_TSK) {
// * Termination of other task
pub fn tk_ter_tsk(tskid: u32) TkError!void {
    // ER	ercd = E_OK;

    check.CHECK_TSKID(tskid);
    check.CHECK_NONSELF(tskid);

    var tcb: *TCB = task.get_tcb(tskid);

    cpu_status.BEGIN_CRITICAL_SECTION();
    defer cpu_status.END_CRITICAL_SECTION();
    var state: TSTAT = @as(TSTAT, tcb.state);
    if (!task.knl_task_alive(state)) {
        if (state == TSTAT.TS_NONEXIST) {
            return TkError.ObjectNotExist;
        } else {
            return TkError.IncorrectObjectState;
        }
    } else if (tcb.klocked) {
        // Normally, it does not become this state.
        // * When the state is page-in wait in the virtual memory
        // * system and when trying to terminate any task,
        // * it becomes this state.
        return TkError.IncorrectObjectState;
    } else {
        knl_ter_tsk(tcb);
        task.knl_make_dormant(tcb);
    }
}
// }

// if (comptime USE_FUNC_TK_CHG_PRI) {
// * Change task priority
pub fn tk_chg_pri(tskid: u32, tskpri: isize) TkError!void {
    var priority: isize = undefined;

    check.CHECK_TSKID_SELF(tskid);
    check.CHECK_PRI_INI(tskpri);

    var tcb: *TCB = task.get_tcb_self(tskid);

    cpu_status.BEGIN_CRITICAL_SECTION();
    defer cpu_status.END_CRITICAL_SECTION();
    if (tcb.state == TSTAT.TS_NONEXIST) {
        return TkError.ObjectNotExist;
    }

    // Conversion priority to internal expression */
    if (tskpri == syscall.TPRI_INI) {
        priority = tcb.ipriority;
    } else {
        priority = task.int_priority(tskpri);
    }

    // if (comptime config.USE_MUTEX) {
    //     // Mutex priority change limit */
    //     knl_chg_pri_mutex(tcb, priority) catch |err| {
    //         return err;
    //     };
    //
    //     tcb.bpriority = @as(u8, priority);
    //     // 謎の処理
    //     priority = ercd;
    // } else {
    tcb.bpriority = priority;
    // }

    // Change priority */
    task.knl_change_task_priority(tcb, priority);
    // return TkError.E_OK;
}
// }

// if (comptime USE_FUNC_TK_ROT_RDQ) {
// * Rotate ready queue
pub fn tk_rot_rdq(tskpri: isize) TkError!void {
    check.CHECK_PRI_RUN(tskpri);

    cpu_status.BEGIN_CRITICAL_SECTION();
    defer cpu_status.END_CRITICAL_SECTION();
    // ここらへんtry使いそうな予感がする
    if (tskpri == syscall.TPRI_RUN) {
        if (cpu_status.in_indp()) {
            task.knl_rotate_ready_queue_run();
        } else {
            task.knl_rotate_ready_queue(knlink.knl_ctxtsk.priority);
        }
    } else {
        task.knl_rotate_ready_queue(task.int_priority(tskpri));
    }
}
// }

// if (comptime USE_FUNC_TK_GET_TID) {
// * Refer task ID at execution */
pub fn tk_get_tid() isize {
    return if (knlink.knl_ctxtsk == null) 0 else knlink.knl_ctxtsk.tskid;
}
// }

// if (comptime USE_FUNC_TK_REF_TSK) {
// * Refer task state */
pub fn tk_ref_tsk(tskid: u32, pk_rtsk: *syscall.T_RTSK) TkError!void {
    check.CHECK_TSKID_SELF(tskid);

    var tcb: *TCB = task.get_tcb_self(tskid);

    tstd.knl_memset(pk_rtsk, 0, @sizeOf(*pk_rtsk));

    cpu_status.BEGIN_CRITICAL_SECTION();
    defer cpu_status.END_CRITICAL_SECTION();
    var state: TSTAT = @as(TSTAT, tcb.state);
    if (state == TSTAT.TS_NONEXIST) {
        return TkError.ObjectNotExist;
    } else {
        if ((state == TSTAT.TS_READY) and (tcb == knlink.knl_ctxtsk)) {
            pk_rtsk.tskstat = TSTAT.TTS_RUN;
        } else {
            pk_rtsk.tskstat = @as(usize, state) << 1;
        }
        if ((state & TSTAT.TS_WAIT) != 0) {
            pk_rtsk.tskwait = tcb.wspec.tskwait;
            pk_rtsk.wid = tcb.wid;
        }
        pk_rtsk.exinf = tcb.exinf;
        pk_rtsk.tskpri = task.ext_tskpri(tcb.priority);
        pk_rtsk.tskbpri = task.ext_tskpri(tcb.bpriority);
        pk_rtsk.wupcnt = tcb.wupcnt;
        pk_rtsk.suscnt = tcb.suscnt;
    }
}
// }

// if (comptime USE_FUNC_TK_REL_WAI) {
// * Release wait */
pub fn tk_rel_wai(tskid: u32) TkError!void {
    check.CHECK_TSKID(tskid);

    var tcb: *TCB = task.get_tcb(tskid);

    cpu_status.BEGIN_CRITICAL_SECTION();
    defer cpu_status.END_CRITICAL_SECTION();
    var state: TSTAT = @as(TSTAT, tcb.state);
    if ((state & TSTAT.TS_WAIT) == 0) {
        if (state == TSTAT.TS_NONEXIST) {
            return TkError.E_NOEXS;
        } else {
            return TkError.E_OBJ;
        }
    } else {
        wait.knl_wait_release_ng(tcb, TkError.E_RLWAI);
    }
}
// }

// *	Debug support function */
// if (comptime USE_DBGSPT) {
//
// #if USE_OBJECT_NAME
// //
//  * Get object name from control block
//  */
// EXPORT ER knl_task_getname(ID id, u8 **name)
// {
// 	TCB	*tcb;
// 	ER	ercd = E_OK;
//
// 	CHECK_TSKID_SELF(id);
//
// 	BEGIN_DISABLE_INTERRUPT;
// 	tcb = get_tcb_self(id);
// 	if ( tcb.state == TS_NONEXIST ) {
// 	        END_CRITICAL_SECTION;
// 		return TkError.E_NOEXS;
// 	}
// 	if ( (tcb.tskatr & TA_DSNAME) == 0 ) {
// 		ercd = E_OBJ;
// 		goto error_exit;
// 	}
// 	*name = tcb.name;
//
//     error_exit:
// 	END_DISABLE_INTERRUPT;
//
// 	return ercd;
// }
// #endif // USE_OBJECT_NAME */
//
// #ifdef USE_FUNC_TD_LST_TSK
// //
//  * Refer task usage state
//  */
// pub fn INT td_lst_tsk( ID list[], INT nent )
// {
// 	TCB	*tcb, *end;
// 	INT	n = 0;
//
// 	BEGIN_DISABLE_INTERRUPT;
// 	end = knl_tcb_table + NUM_TSKID;
// 	for ( tcb = knl_tcb_table; tcb < end; tcb++ ) {
// 		if ( tcb.state == TS_NONEXIST ) {
// 			continue;
// 		}
//
// 		if ( n++ < nent ) {
// 			*list++ = tcb.tskid;
// 		}
// 	}
// 	END_DISABLE_INTERRUPT;
//
// 	return n;
// }
// #endif // USE_FUNC_TD_LST_TSK */
//
// #ifdef USE_FUNC_TD_REF_TSK
// //
//  * Refer task state
//  */
// pub fn ER td_ref_tsk( ID tskid, TD_RTSK *pk_rtsk )
// {
// 	TCB	*tcb;
// 	TSTAT	state;
// 	ER	ercd = E_OK;
//
// 	CHECK_TSKID_SELF(tskid);
//
// 	tcb = get_tcb_self(tskid);
//
// 	knl_memset(pk_rtsk, 0, sizeof(*pk_rtsk));
//
// 	BEGIN_DISABLE_INTERRUPT;
// 	state = (TSTAT)tcb.state;
// 	if ( state == TS_NONEXIST ) {
// 		ercd = E_NOEXS;
// 	} else {
// 		if ( ( state == TS_READY ) && ( tcb == knl_ctxtsk ) ) {
// 			pk_rtsk.tskstat = TTS_RUN;
// 		} else {
// 			pk_rtsk.tskstat = (UINT)state << 1;
// 		}
// 		if ( (state & TS_WAIT) != 0 ) {
// 			pk_rtsk.tskwait = tcb.wspec.tskwait;
// 			pk_rtsk.wid     = tcb.wid;
// 		}
// 		pk_rtsk.exinf     = tcb.exinf;
// 		pk_rtsk.tskpri    = ext_tskpri(tcb.priority);
// 		pk_rtsk.tskbpri   = ext_tskpri(tcb.bpriority);
// 		pk_rtsk.wupcnt    = tcb.wupcnt;
// 		pk_rtsk.suscnt    = tcb.suscnt;
//
// 		pk_rtsk.task      = tcb.task;
// 		pk_rtsk.stksz     = tcb.sstksz;
// 		pk_rtsk.istack    = tcb.isstack;
// 	}
// 	END_DISABLE_INTERRUPT;
//
// 	return ercd;
// }
// #endif // USE_FUNC_TD_REF_TSK */
//
// #ifdef USE_FUNC_TD_INF_TSK
// //
//  * Get task statistic information
//  */
// pub fn ER td_inf_tsk( ID tskid, TD_ITSK *pk_itsk, BOOL clr )
// {
// 	TCB	*tcb;
// 	ER	ercd = E_OK;
//
// 	CHECK_TSKID_SELF(tskid);
//
// 	tcb = get_tcb_self(tskid);
//
// 	BEGIN_DISABLE_INTERRUPT;
// 	if ( tcb.state == TS_NONEXIST ) {
// 		ercd = E_NOEXS;
// 	} else {
// 		pk_itsk.stime = tcb.stime;
// 		pk_itsk.utime = tcb.utime;
// 		if ( clr ) {
// 			tcb.stime = 0;
// 			tcb.utime = 0;
// 		}
// 	}
// 	END_DISABLE_INTERRUPT;
//
// 	return ercd;
// }
// #endif // USE_FUNC_TD_INF_TSK */
//
// }