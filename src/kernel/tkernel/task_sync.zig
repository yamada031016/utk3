// *	Task with Synchronize Function
const tstd = @import("tstd");
const knlink = @import("knlink");
const winfo = knlink.winfo;
const config = @import("config");
const cpu_task = knlink.sysdepend.cpu_task;
const cpu_status = knlink.sysdepend.cpu_status;
const cpu_ctrl = knlink.sysdepend.cpu_ctrl;
const inc_tk = @import("inc_tk");
const syscall = inc_tk.syscall;

// #include "kernel.h"
// #include "wait.h"
// #include "check.h"
// #include "limits.h"

// if (comptime USE_FUNC_TK_SUS_TSK) {
// // * Suspend
// pub fn tk_sus_tsk( tskid: ID ) TkError!void {
// 	CHECK_TSKID(tskid);
// 	CHECK_NONSELF(tskid);
//
// 	var tcb: *TCB = get_tcb(tskid);
//
// 	BEGIN_CRITICAL_SECTION;
// 	defer END_CRITICAL_SECTION;
// 	var state: TSTAT = @as(TSTAT,tcb.state);
// 	if ( !knl_task_alive(state) ) {
// 		if ( state == TSTAT.TS_NONEXIST ) {
//                 return TkError.E_NOEXS;
//              } else {
//                 return TkError.E_OBJ;
//              }
// 	}
// 	if ( tcb == knl_ctxtsk and knl_dispatch_disabled >= DDS_DISABLE ) {
// 		return TkError.E_CTX;
// 	}
// 	if ( tcb.suscnt == INT_MAX ) {
// 		return TkError.E_QOVR;
// 	}
// 	// Update suspend request count */
// 	tcb.suscnt +=1;
//
// 	// Move to forced wait state */
// 	if ( state == TSTAT.TS_READY ) {
// 		knl_make_non_ready(tcb);
// 		tcb.state = TSTAT.TS_SUSPEND;
//
// 	} else if ( state == TSTAT.TS_WAIT ) {
// 		tcb.state = TSTAT.TS_WAITSUS;
// 	}
// 	// return TkError.E_OK;
// }
// // }

// if (comptime USE_FUNC_TK_RSM_TSK) {
// * Resume task */
// pub fn tk_rsm_tsk( tskid: ID ) TkError!void {
// 	CHECK_TSKID(tskid);
// 	CHECK_NONSELF(tskid);
//
// 	var tcb: *TCB = get_tcb(tskid);
//          var err: TkError = TkError.E_OK;
//
// 	BEGIN_CRITICAL_SECTION;
// 	defer END_CRITICAL_SECTION;
// 	switch ( tcb.state ) {
// 	  .TS_NONEXIST => return TkError.E_NOEXS,
// 	  .TS_DORMANT, .TS_READY, .TS_WAIT => return TkError.E_OBJ,
// 	  .TS_SUSPEND => {
//                 tcb.suscnt-=1;
// 		if ( tcb.suscnt == 0 ) {
// 			knl_make_ready(tcb);
// 		}
//          },
// 	 .TS_WAITSUS => {
//                 tcb.suscnt-=1;
// 		if ( tcb.suscnt == 0 ) {
// 			tcb.state = TSTAT.TS_WAIT;
// 		}
//          },
//          else => return TkError.E_SYS,
// 	}
// 	// return err;
// }
// }

// if (comptime USE_FUNC_TK_FRSM_TSK) {
// // * Force resume task */
// pub fn tk_frsm_tsk( tskid: ID ) TkError!void {
// 	CHECK_TSKID(tskid);
// 	CHECK_NONSELF(tskid);
//
// 	var tcb: *TCB = get_tcb(tskid);
//
// 	BEGIN_CRITICAL_SECTION;
// 	defer END_CRITICAL_SECTION;
// 	switch ( tcb.state ) {
// 	  .TS_NONEXIST =>  return  TkError.E_NOEXS,
// 	  .TS_DORMANT, .TS_READY, .TS_WAIT => return TkError.E_OBJ,
// 	  .TS_SUSPEND => {
//                 tcb.suscnt-=1;
// 		if ( tcb.suscnt == 0 ) {
// 			knl_make_ready(tcb);
// 		}
//          },
// 	 .TS_WAITSUS => {
//                 tcb.suscnt-=1;
// 		if ( tcb.suscnt == 0 ) {
// 			tcb.state = TSTAT.TS_WAIT;
// 		}
//          },
//          else => return  TkError.E_SYS,
// 	}
//
// 	// return ercd;
// }
// }

// * Definition of task wait specification */
const knl_wspec_slp: winfo.WSPEC = struct { syscall.TTW_SLP, null, null };

// if (comptime USE_FUNC_TK_SLP_TSK) {
// // * Move its own task state to wait state */
// pub fn tk_slp_tsk( tmout: TMO ) TkError!void {
// 	CHECK_TMOUT(tmout);
// 	CHECK_DISPATCH();
//
// 	BEGIN_CRITICAL_SECTION;
// 	defer END_CRITICAL_SECTION;
// 	if ( knl_ctxtsk.wupcnt > 0 ) {
// 		knl_ctxtsk.wupcnt-=1;
// 	} else {
// 		if ( tmout != TMO_POL ) {
// 			knl_ctxtsk.wspec = &knl_wspec_slp;
// 			knl_ctxtsk.wid = 0;
// 			knl_ctxtsk.wercd = &ercd;
// 			knl_make_wait(tmout, TA_NULL);
// 			QueInit(&knl_ctxtsk.tskque);
// 		}
//             return TkError.E_TMOUT;
// 	}
// 	// return ercd;
// }
// }
//
// if (comptime USE_FUNC_TK_WUP_TSK) {
// // * Wakeup task */
// pub fn tk_wup_tsk( tskid: ID ) TkError!void {
// 	CHECK_TSKID(tskid);
// 	CHECK_NONSELF(tskid);
//
// 	var tcb: *TCB = get_tcb(tskid);
//
// 	BEGIN_CRITICAL_SECTION;
//         defer END_CRITICAL_SECTION;
// 	var state: TSTAT = @as(TSTAT,tcb.state);
// 	if ( !knl_task_alive(state) ) {
// 		if ( state == TSTAT.TS_NONEXIST ){
//                  return TkError.E_NOEXS
//              }  else {
//                  return TkError.E_OBJ
//                  } ;
// 	} else if ( (state & TSTAT.TS_WAIT) != 0 and tcb.wspec == &knl_wspec_slp ) {
// 		knl_wait_release_ok(tcb);
// 	} else if ( tcb.wupcnt == INT_MAX ) {
// 		return TkError.E_QOVR;
// 	} else {
// 		tcb.wupcnt +=1;
// 	}
// }
// }
//
// if (comptime USE_FUNC_TK_CAN_WUP) {
// // * Cancel wakeup request */
//      // 潜在的にエラーコードを返すので返却値を明示的に変更した
// pub fn tk_can_wup( tskid: ID ) TkError!isize {
// 	CHECK_TSKID_SELF(tskid);
//
// 	var tcb: *TCB = get_tcb_self(tskid);
//
// 	BEGIN_CRITICAL_SECTION;
// 	defer END_CRITICAL_SECTION;
// 	switch ( tcb.state ) {
// 	  .TS_NONEXIST => return TkError.E_NOEXS,
// 	  .TS_DORMANT => return TkError.E_OBJ,
//           else => {
// 		tcb.wupcnt = 0;
//                  // 謎コード ercdに入れてた
// 		return tcb.wupcnt;
//              }
// 	}
// }
// }
//
// if (comptime USE_FUNC_TK_DLY_TSK) {
// // * Definition of task delay wait specification */
// const  knl_wspec_dly: WSPEC = struct{ TTW_DLY, null, null };
//
// // * Task delay */
// pub fn tk_dly_tsk( dlytim: RELTIM ) TkError!void {
// 	CHECK_RELTIM(dlytim);
// 	CHECK_DISPATCH();
// 	if ( dlytim > 0 ) {
// 		BEGIN_CRITICAL_SECTION;
// 	        defer END_CRITICAL_SECTION;
// 		knl_ctxtsk.wspec = &knl_wspec_dly;
// 		knl_ctxtsk.wid = 0;
//              //エラー返さないように見えるけど、
//              //下の関数内でエラーコードをセットしてんのか???
// 		knl_ctxtsk.wercd = &ercd;
// 		knl_make_wait_reltim(dlytim, TA_NULL);
// 		QueInit(&knl_ctxtsk.tskque);
// 	}
// 	// return TkError.E_OK;
// }
// }
