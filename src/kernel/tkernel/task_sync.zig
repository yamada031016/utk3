// *	Task with Synchronize Function
const knlink = @import("knlink");
const tstd = knlink.tstd;
const check = knlink.check;
const task = knlink.task;
const TSTAT = task.TSTAT;
// const winfo = knlink.winfo;
const cpu_task = knlink.sysdepend.core.cpu_task;
const cpu_status = knlink.sysdepend.core.cpu_status;
const cpu_ctrl = knlink.sysdepend.core.cpu_ctrl;
const config = @import("config");
const libtk = @import("libtk");
const syscall = libtk.syscall;
const TkError = libtk.errno.TkError;
const ID = libtk.typedef.ID;

// * Suspend
pub fn tk_sus_tsk(tskid: ID) TkError!void {
    if (comptime config.func.USE_FUNC_TK_SUS_TSK) {
        check.CHECK_TSKID(tskid);
        check.CHECK_NONSELF(tskid);

        var tcb = task.get_tcb(tskid);
        {
            cpu_status.BEGIN_CRITICAL_SECTION();
            defer cpu_status.END_CRITICAL_SECTION();

            var state = tcb.state;
            if (!task.knl_task_alive(state)) {
                if (state == TSTAT.NONEXIST) {
                    return TkError.ObjectNotExist;
                } else {
                    return TkError.IncorrectObjectState;
                }
            }
            if (tcb == knlink.knl_ctxtsk and task.knl_dispatch_disabled >= knlink.DDS_DISABLE) {
                return TkError.ContextError;
            }
            if (tcb.suscnt == knlink.INT_MAX) {
                return TkError.QueuingOverflow;
            }
            // Update suspend request count */
            tcb.suscnt += 1;

            // Move to forced wait state */
            if (state == TSTAT.READY) {
                task.knl_make_non_ready(tcb);
                tcb.state = TSTAT.SUSPEND;
            } else if (state == TSTAT.WAIT) {
                tcb.state = TSTAT.WAITSUS;
            }
        }
    } else {
        return TkError.UnsupportedFunction;
    }
}

// * Resume task */
pub fn tk_rsm_tsk(tskid: ID) TkError!void {
    if (comptime config.func.USE_FUNC_TK_RSM_TSK) {
        CHECK_TSKID(tskid);
        CHECK_NONSELF(tskid);

        var tcb: *TCB = get_tcb(tskid);
        var err: TkError = TkError.E_OK;

        {
            cpu_status.BEGIN_CRITICAL_SECTION();
            defer cpu_status.END_CRITICAL_SECTION();
            switch (tcb.state) {
                .NONEXIST => return TkError.ObjectNotExist,
                .DORMANT, .READY, .WAIT => return TkError.IncorrectObjectState,
                .SUSPEND => {
                    tcb.suscnt -= 1;
                    if (tcb.suscnt == 0) {
                        task.knl_make_ready(tcb);
                    }
                },
                .WAITSUS => {
                    tcb.suscnt -= 1;
                    if (tcb.suscnt == 0) {
                        tcb.state = TSTAT.WAIT;
                    }
                },
                else => return TkError.SystemError,
            }
        }
    } else {
        return TkError.UnsupportedFunction;
    }
}

// * Force resume task */
pub fn tk_frsm_tsk(tskid: ID) TkError!void {
    if (comptime USE_FUNC_TK_FRSM_TSK) {
        check.CHECK_TSKID(tskid);
        check.CHECK_NONSELF(tskid);

        var tcb: *TCB = get_tcb(tskid);

        {
            cpu_status.BEGIN_CRITICAL_SECTION();
            defer cpu_status.END_CRITICAL_SECTION();
            switch (tcb.state) {
                .NONEXIST => return TkError.ObjectNotExist,
                .DORMANT, .READY, .WAIT => return TkError.IncorrectObjectState,
                .SUSPEND => {
                    tcb.suscnt -= 1;
                    if (tcb.suscnt == 0) {
                        task.knl_make_ready(tcb);
                    }
                },
                .WAITSUS => {
                    tcb.suscnt -= 1;
                    if (tcb.suscnt == 0) {
                        tcb.state = TSTAT.WAIT;
                    }
                },
                else => return TkError.SystemError,
            }
        }
    } else {
        return TkError.UnsupportedFunction;
    }
}

// * Definition of task wait specification */
// const knl_wspec_slp: winfo.WSPEC = struct { syscall.TTW_SLP, null, null };

// * Move its own task state to wait state */
pub fn tk_slp_tsk(tmout: TMO) TkError!void {
    if (comptime USE_FUNC_TK_SLP_TSK) {
        check.CHECK_TMOUT(tmout);
        check.CHECK_DISPATCH();

        {
            cpu_status.BEGIN_CRITICAL_SECTION();
            defer cpu_status.END_CRITICAL_SECTION();
            if (knl_ctxtsk.wupcnt > 0) {
                knl_ctxtsk.wupcnt -= 1;
            } else {
                if (tmout != libtk.typedef.TMO_POL) {
                    knl_ctxtsk.wspec = &knl_wspec_slp;
                    knl_ctxtsk.wid = 0;
                    knl_ctxtsk.wercd = &ercd;
                    task.knl_make_wait(tmout, TA_NULL);
                    QueInit(&knl_ctxtsk.tskque);
                }
                return TkError.PollingFailOrTimeout;
            }
        }
    } else {
        return TkError.UnsupportedFunction;
    }
}

// * Wakeup task */
pub fn tk_wup_tsk(tskid: ID) TkError!void {
    if (comptime USE_FUNC_TK_WUP_TSK) {
        check.CHECK_TSKID(tskid);
        check.CHECK_NONSELF(tskid);

        var tcb = get_tcb(tskid);

        {
            cpu_status.BEGIN_CRITICAL_SECTION();
            defer cpu_status.END_CRITICAL_SECTION();
            var state = tcb.state;
            if (!task.knl_task_alive(state)) {
                if (state == TSTAT.NONEXIST) {
                    return TkError.ObjectNotExist;
                } else {
                    return TkError.IncorrectObjectState;
                }
            } else if ((state & TSTAT.WAIT) != 0 and tcb.wspec == &knl_wspec_slp) {
                wait.knl_wait_release_ok(tcb);
            } else if (tcb.wupcnt == knlink.INT_MAX) {
                return TkError.QueuingOverflow;
            } else {
                tcb.wupcnt += 1;
            }
        }
    } else {
        return TkError.UnsupportedFunction;
    }
}

// * Cancel wakeup request */
// 潜在的にエラーコードを返すので返却値を明示的に変更した
pub fn tk_can_wup(tskid: ID) TkError!isize {
    if (comptime USE_FUNC_TK_CAN_WUP) {
        check.CHECK_TSKID_SELF(tskid);

        var tcb = get_tcb_self(tskid);

        {
            cpu_status.BEGIN_CRITICAL_SECTION();
            defer cpu_status.END_CRITICAL_SECTION();
            switch (tcb.state) {
                .NONEXIST => return TkError.ObjectNotExist,
                .DORMANT => return TkError.IncorrectObjectState,
                else => {
                    tcb.wupcnt = 0;
                    // 謎コード ercdに入れてた
                    return tcb.wupcnt;
                },
            }
        }
    }
}

// * Definition of task delay wait specification */
const knl_wspec_dly: WSPEC = struct { TTW_DLY, null, null };

// * Task delay */
pub fn tk_dly_tsk(dlytim: libtk.typedef.RELTIM) TkError!void {
    if (comptime config.func.USE_FUNC_TK_DLY_TSK) {
        check.CHECK_RELTIM(dlytim);
        check.CHECK_DISPATCH();

        if (dlytim > 0) {
            cpu_status.BEGIN_CRITICAL_SECTION();
            defer cpu_status.END_CRITICAL_SECTION();
            knlink.knl_ctxtsk.wspec = &knl_wspec_dly;
            knlink.knl_ctxtsk.wid = 0;
            knlink.knl_ctxtsk.wercd = &ercd;
            knl_make_wait_reltim(dlytim, null);
            QueInit(&knlink.knl_ctxtsk.tskque);
        }
    } else {
        return TkError.UnsupportedFunction;
    }
}
