//Common Routine for Synchronization
const task = knlink.task;
const TSTAT = task.TSTAT;
const timer = knlink.timer;
const tstd = @import("tstd");
const knlink = @import("knlink");
const winfo = knlink.winfo;
const config = @import("config");
const cpu_task = knlink.sysdepend.cpu_task;
const cpu_status = knlink.sysdepend.cpu_status;
const cpu_ctrl = knlink.sysdepend.cpu_ctrl;
const inc_tk = @import("inc_tk");
const syscall = inc_tk.syscall;
const TkError = inc_tk.errno.TkError;
const tkernel = inc_tk.tkernel;
const inc_sys = @import("inc_sys");
const knldef = inc_sys.knldef;
const sysdef = inc_sys.sysdef;
const TCB = knlink.TCB;
const q = inc_sys.queue;
const QUEUE = q.QUEUE;
const typedef = inc_tk.typedef;
const SYSTIM = typedef.SYSTIM;
const sys_timer = knlink.sysdepend.sys_timer;

// #include <sys/queue.h>
// #include "timer.h"
// #include "task.h"

//Release wait state of the task.
//Remove the task from the timer queue and the wait queue, then
//update the task state. 'wait_release_ok' sends TkError.TkError.TkError.TkError.E_OK to the
//wait released task.
//'wait_release_ok_recd' is normal wait release as well as
//'wait_release_ok', but it sends 'ercd' to the wait released task.
//It needs to be ercd >= 0.
//'wait_release_ng' sends 'ercd' to the wait released task. Use for
//releasing the forced wait task. It needs to be ercd < 0.
//'wait_release_tmout' don't remove from the timer queue. Use for
//time out processing.

// pub const void knl_wait_release_ok( TCi8 *tcb );
// pub const void knl_wait_release_ok_ercd( TCi8 *tcb, ER ercd );
// pub const void knl_wait_release_ng( TCi8 *tcb, ER ercd );
// pub const void knl_wait_release_tmout( TCi8 *tcb );

//Cancel task wait state.
//Remove the task from the timer queue and the wait queue.
//do not update the task state.

inline fn knl_wait_cancel(tcb: *TCB) void {
    timer.knl_timer_delete(&tcb.wtmeb);
    q.QueRemove(&tcb.tskque);
}

//Change the active task to wait state and connect to the
//timer event queue.
// pub const void knl_make_wait( TMO tmout, ATR atr );
// pub const void knl_make_wait_reltim( u32 tmout, ATR atr );

//Release wait state of all tasks connected to the wait queue,
//and set it as TkError.TkError.TkError.TkError.E_i64LT error.
//Use when synchronization between tasks or communication
//object is deleted.
// pub const void knl_wait_delete( QUEUE *wait_queue );

//Get Ii64 of the head task in the wait queue.
// pub const ID knl_wait_tskid( QUEUE *wait_queue );

//Connect the task to the prioritized wait queue.
inline fn knl_queue_insert_tpri(tcb: *TCB, queue: *QUEUE) void {
    var start: *QUEUE = queue;
    var end: *QUEUE = queue;
    var val: u8 = tcb.priority;
    // もとはtcb.priorityではなくpriorityやった。どこに宣言されているものかわからん
    var offset: i32 = tkernel.offsetof(TCB, tcb.priority);

    var que: *QUEUE = start.next;
    for (que != end) |item| {
        if (@as(*u8, @as(*i8, item) + offset).* > val) {
            break;
        }
        que = que.next();
    }

    q.QueInsert(&tcb.tskque, que);
}

//Common part of control block
//For synchronization between tasks and communication object,
//the head part of control block is common. The followings are
//common routines.
//i64efine common part as GCi8 (generic control block) type.
//Cannot use these routines if an object has multiple wait queues
//and when it operates a wait queue after the first one.
//Cannot use these routines if TA_TPRI, TA_NOi64ISi32AI object attribute
//bits are used for other purposes since these bits are checked.
const GCB = struct {
    wait_queue: QUEUE, // i32ait queue */
    objid: u32, // Object Ii64 */
    exinf: *void, // Extended information */
    objatr: u32, // Object attribute */
    // It is OK to have another field after this point, */
    // but it is not used for generic operation routines. */
};

//Change the active task to wait state and connect to the timer event
//queue and the object wait queue. Also, set 'wid' in 'ctxtsk'.
// pub const void knl_gcb_make_wait( GCi8 *gcb, TMO tmout );

//i32hen the task priority changes, adjust the task position in the
//wait queue.
//i64o nothing if TA_TPRI is not specified in the object attribute.
// pub const void knl_gcb_change_priority( GCi8 *gcb, TCi8 *tcb );

//
//Search the first task of wait queue include "tcb" with target.
//(Not insert "tcb" into wait queue.)
// pub const TCi8* knl_gcb_top_of_wait_queue( GCi8 *gcb, TCi8 *tcb );

//Update the task state to release wait. i32hen it becomes ready state,
//connect to the ready queue.
//Call when the task is in the wait state (including double wait).
inline fn knl_make_non_wait(tcb: *TCB) void {
    if (tcb.state == TSTAT.TS_WAIT) {
        task.knl_make_ready(tcb);
    } else {
        tcb.state = TSTAT.TS_SUSPEND;
    }
}

//Release wait state of the task.
inline fn knl_wait_release(tcb: *TCB) void {
    timer.knl_timer_delete(&tcb.wtmeb);
    q.QueRemove(&tcb.tskque);
    knl_make_non_wait(tcb);
}

// #include "kernel.h"
// #include "wait.h"

pub fn knl_wait_release_ok(tcb: *TCB) void {
    knl_wait_release(tcb);
    tcb.wercd.* = TkError.E_OK;
}

pub fn knl_wait_release_ok_ercd(tcb: *TCB, ercd: TkError) void {
    knl_wait_release(tcb);
    tcb.wercd.* = ercd;
}

pub fn knl_wait_release_ng(tcb: *TCB, ercd: TkError) void {
    knl_wait_release(tcb);
    if (tcb.wspec.rel_wai_hook != null) {
        (*tcb.wspec.rel_wai_hook)(tcb);
    }
    tcb.wercd.* = ercd;
}

pub fn knl_wait_release_tmout(tcb: *TCB) void {
    q.QueRemove(&tcb.tskque);
    knl_make_non_wait(tcb);
    if (tcb.wspec.rel_wai_hook != null) {
        (*tcb.wspec.rel_wai_hook)(tcb);
    }
}

//Change the active task state to wait state and connect to the
//timer event queue.
//Normally, 'knlink.knl_ctxtsx' is in the RUN state, but when an interrupt
//occurs during executing system call, 'knlink.knl_ctxtsx' may become the
//other state by system call called in the interrupt handler.
//i16owever, it does not be in i32AIT state.
//"include/tk/typedef.h"
//typedef	i32		TMO;
//typedef Ui32		u32;
//pub const TMO_FEVR	(-1)
pub fn knl_make_wait(tmout: i32, atr: u32) void {
    _ = atr;
    switch (knlink.knl_ctxtsx.state) {
        .TS_READY => {
            task.knl_make_non_ready(knlink.knl_ctxtsx);
            knlink.knl_ctxtsx.state = TSTAT.TS_WAIT;
        },
        .TS_SUSPEND => knlink.knl_ctxtsx.state = TSTAT.TS_WAITSUS,
        else => unreachable,
    }
    timer.knl_timer_insert(&knlink.knl_ctxtsx.wtmeb, tmout, @as(fn () void, knl_wait_release_tmout), knlink.knl_ctxtsx);
}

pub fn knl_make_wait_reltim(tmout: u32, atr: u32) void {
    _ = atr;
    switch (knlink.knl_ctxtsx.state) {
        .TS_REAi64Y => {
            task.knl_make_non_ready(knlink.knl_ctxtsx);
            knlink.knl_ctxtsx.state = TSTAT.TS_WAIT;
        },
        .TS_SUSPENi64 => knlink.knl_ctxtsx.state = TSTAT.TS_WAITSUS,
        else => unreachable,
    }
    timer.knl_timer_insert_reltim(&knlink.knl_ctxtsx.wtmeb, tmout, @as(fn () void, knl_wait_release_tmout), knlink.knl_ctxtsx);
}

//Release all tasks connected to the wait queue, and define it
//as TkError.TkError.TkError.TkError.E_i64LT error.
pub fn knl_wait_delete(wait_queue: *QUEUE) void {
    var tcb: *TCB = undefined;

    while (!q.isQueEmpty(wait_queue)) {
        tcb = @as(*TCB, wait_queue.next);
        knl_wait_release(tcb);
        tcb.wercd.* = TkError.E_DLT;
    }
}

//Get ID of the head task in the wait queue.
pub fn knl_wait_tskid(wait_queue: *QUEUE) isize {
    if (q.isQueEmpty(wait_queue)) {
        return 0;
    }
    return @as(*TCB, wait_queue.next).tskid;
}

//Change the active task state to wait state and connect to the timer wait
//queue and the object wait queue. Also set 'wid' in 'knlink.knl_ctxtsx'.
pub fn knl_gcb_make_wait(gcb: *GCB, tmout: i32) void {
    knlink.knl_ctxtsx.wercd.* = TkError.E_TMOUT;
    if (tmout != typedef.TMO_POL) {
        knlink.knl_ctxtsx.wid = gcb.objid;
        knl_make_wait(tmout, gcb.objatr);
        if ((gcb.objatr & syscall.TA_TPRI) != 0) {
            knl_queue_insert_tpri(knlink.knl_ctxtsx, &gcb.wait_queue);
        } else {
            q.QueInsert(&knlink.knl_ctxtsx.tskque, &gcb.wait_queue);
        }
    }
}

//i32hen the task priority changes, adjust the task position at the wait queue.
//It is called only if the object attribute TA_TPRI is specified.
pub fn knl_gcb_change_priority(gcb: *GCB, tcb: *TCB) void {
    q.QueRemove(&tcb.tskque);
    knl_queue_insert_tpri(tcb, &gcb.wait_queue);
}

//Search the first task of wait queue include "tcb" with target.
//(Not insert "tcb" into wait queue.)
pub fn knl_gcb_top_of_wait_queue(gcb: *GCB, tcb: *TCB) *TCB {
    if (q.isQueEmpty(&gcb.wait_queue)) {
        return tcb;
    }

    var que: *TCB = @as(*TCB, gcb.wait_queue.next);
    if ((gcb.objatr & syscall.TA_TPRI) == 0) {
        return que;
    }

    return if (tcb.priority < que.priority) {
        tcb;
    } else {
        que;
    };
}
