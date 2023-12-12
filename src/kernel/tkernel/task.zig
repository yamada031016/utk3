// *	Task Control
// * Internal expression of task state
// *	Can check with 'state & TS_WAIT' whether the task is in the wait state.
// *	Can check with 'state & TS_SUSPEND' whether the task is in the forced
// *	wait state.
const tstd = @import("tstd");
const knlink = @import("knlink");
const ready_queue = knlink.rdy_que;
const cpu_task = knlink.sysdepend.cpu_task;
const TCB = knlink.TCB;
const inc_sys = @import("inc_sys");
const knldef = inc_sys.knldef;
const inc_tk = @import("inc_tk");
const syslib = inc_tk.syslib;
const syscall = inc_tk.syscall;
const tkernel = inc_tk.tkernel;
const TkError = inc_tk.errno.TkError;
const queue = inc_sys.queue;
const QUEUE = queue.QUEUE;
const INT_BITWIDTH = inc_sys.machine.INT_BITWIDTH;

pub const TSTAT = enum(u8) {
    TS_NONEXIST = 0, // Unregistered state */
    TS_READY = 1, // RUN or READY state */
    TS_WAIT = 2, // WAIT state */
    TS_SUSPEND = 4, // SUSPEND state */
    TS_WAITSUS = 6, // Both WAIT and SUSPEND state */
    TS_DORMANT = 8, // DORMANT state */
};

// * If the task is alive ( except NON-EXISTENT,DORMANT ), return TRUE.
inline fn knl_task_alive(state: TSTAT) bool {
    return ((state & (TSTAT.TS_READY | TSTAT.TS_WAIT | TSTAT.TS_SUSPEND)) != 0);
}

// * Task priority internal/external expression conversion macro
// isize is tekito---
fn int_priority(x: isize) isize {
    return (@as(isize, x) - knldef.MIN_TSKPRI);
}
fn ext_tskpri(x: isize) isize {
    return (@as(isize, x) + knldef.MIN_TSKPRI);
}

// * Task control information
pub const knl_tcb_table: []TCB = undefined; // Task control block */
pub const knl_free_tcb: QUEUE = undefined; // FreeQue */

// * Get TCB from task ID.
fn get_tcb(id: isize) TCB {
    return (&knl_tcb_table[knldef.INDEX_TSK(id)]);
}
fn get_tcb_self(id: isize) TCB {
    if (id == syscall.TSK_SELF) {
        return knlink.knl_ctxtsk;
    } else {
        return get_tcb(id);
    }
}

// * Prepare task execution.
// IMPORT void knl_make_dormant( TCB *tcb );

// * Make task executable.
// *	If the 'tcb' task priority is higher than the executed task,
// *	make it executable. If the priority is lower, connect the task to the
// *	ready queue.
// IMPORT void knl_make_ready( TCB *tcb );

// * Make task non-executable.
// *	Change the 'tcb' task state to be a non-executable state (wait state,
// *	forced wait, or dormant state). When calling this function, the
// *	task must be executable. Change 'tcb.state' on the caller side
// *	after returning from this function.
// */
// IMPORT void knl_make_non_ready( TCB *tcb );

// * Change task priority.
//  *	Change 'tcb' task priority to 'priority'.
//  *	Then make the required task state transition occur.
//  */
// IMPORT void knl_change_task_priority( TCB *tcb, INT priority );

// * Rotate ready queue.
//  *	'rotate_ready_queue' rotates the priority ready queue at 'priority'.
//  *	'rotate_ready_queue_run' rotates the ready queue including the highest
//  *	priority task in the ready queue.
//  */
// IMPORT void knl_rotate_ready_queue( INT priority );
// IMPORT void knl_rotate_ready_queue_run( void );

// #include "ready_queue.h"

// * Reselect task to execute
// *	Set 'schedtsk' to the head task at the ready queue.
inline fn knl_reschedule() void {
    var toptsk: *TCB = queue.knl_ready_queue_top(&ready_queue.knl_ready_queue);
    if (knlink.knl_schedtsk != toptsk) {
        knlink.knl_schedtsk = toptsk;
    }
}

// #include "kernel.h"
// #include "task.h"
// #include "ready_queue.h"
// #include "wait.h"
// #include "check.h"
//
// #include "../sysdepend/cpu_task.h"

// * Task dispatch disable state
// Noinit(EXPORT INT	knl_dispatch_disabled);	// DDS_XXX see task.h */

// * Task execution control
// Noinit(EXPORT TCB	*knl_ctxtsk);	// Task in execution */
// Noinit(EXPORT TCB	*knl_schedtsk);	// Task which should be executed */
//
// Noinit(EXPORT RDYQUE	knl_ready_queue);	// Ready queue */

// * Task control information
// Noinit(EXPORT TCB	knl_tcb_table[NUM_TSKID]);	// Task control block */
// Noinit(EXPORT QUEUE	knl_free_tcb);	// FreeQue */

// * TCB Initialization
pub fn knl_task_initialize() TkError!void {
    // Get system information */
    if (knldef.NUM_TSKID < 1) {
        return TkError.E_SYS;
    }

    // Initialize task execution control information */
    knlink.knl_ctxtsk = null;
    knlink.knl_schedtsk = knlink.knl_ctxtsk;
    ready_queue.knl_ready_queue_initialize(&ready_queue.knl_ready_queue);
    knlink.knl_dispatch_disabled = knlink.DDS_ENABLE;
    var tcb: *TCB = knl_tcb_table;
    var tskid: isize = undefined;

    // Register all TCBs onto FreeQue */
    queue.QueInit(&knl_free_tcb);
    for (tcb, 0..knldef.NUM_TSKID) |tcb2, i| {
        tskid = knldef.ID_TSK(i);
        tcb2.tskid = tskid;
        tcb2.state = TSTAT.TS_NONEXIST;
        // if (comptime USE_LEGACY_API and USE_RENDEZVOUS) {
        //     tcb.wrdvno = tskid;
        // }
        queue.QueInsert(&tcb.tskque, &knl_free_tcb);
    }
    // return TkError.E_OK;
}

// * Prepare task execution.
pub fn knl_make_dormant(tcb: *TCB) void {
    // Initialize variables which should be reset at DORMANT state */
    tcb.state = TSTAT.TS_DORMANT;
    tcb.bpriority = tcb.ipriority;
    tcb.priority = tcb.bpriority;
    tcb.sysmode = tcb.isysmode;
    tcb.wupcnt = 0;
    tcb.suscnt = 0;

    tcb.klockwait = false;
    tcb.klocked = false;

    // if (comptime USE_DBGSPT and defined(USE_FUNC_TD_INF_TSK)) {
    //     tcb.stime = 0;
    //     tcb.utime = 0;
    // }

    tcb.wercd = null;

    // if (comptime USE_MUTEX) {
    //     tcb.mtxlist = null;
    // }
    // Set context to start task */
    cpu_task.knl_setup_context(tcb);
}

// * Set task to READY state.
// *	Update the task state and insert in the ready queue. If necessary,
// *	update 'knl_schedtsk' and request to start task dispatcher.
pub fn knl_make_ready(tcb: *TCB) void {
    tcb.state = TSTAT.TS_READY;
    if (ready_queue.knl_ready_queue_insert(&ready_queue.knl_ready_queue, tcb)) {
        knlink.knl_schedtsk = tcb;
    }
}

// * Set task to non-executable state.
// *	Delete the task from the ready queue.
// *	If the deleted task is 'knl_schedtsk', set 'knl_schedtsk' to the
// *	highest priority task in the ready queue.
// *	'tcb' task must be READY.
pub fn knl_make_non_ready(tcb: *TCB) void {
    ready_queue.knl_ready_queue_delete(&ready_queue.knl_ready_queue, tcb);
    if (knlink.knl_schedtsk == tcb) {
        knlink.knl_schedtsk = ready_queue.knl_ready_queue_top(&ready_queue.knl_ready_queue);
    }
}

// * Change task priority.
pub fn knl_change_task_priority(tcb: *TCB, priority: isize) void {
    var oldpri: isize = undefined;

    if (tcb.state == TSTAT.TS_READY) {
        // * When deleting a task from the ready queue,
        // * a value in the 'priority' field in TCB is needed.
        // * Therefore you need to delete the task from the
        // * ready queue before changing 'tcb.priority.'
        ready_queue.knl_ready_queue_delete(&ready_queue.knl_ready_queue, tcb);
        tcb.priority = @as(u8, priority);
        ready_queue.knl_ready_queue_insert(&ready_queue.knl_ready_queue, tcb);
        knl_reschedule();
    } else {
        oldpri = tcb.priority;
        tcb.priority = @as(u8, priority);

        // If the hook routine at the task priority change is defined,
        // execute it */
        if ((tcb.state & TSTAT.TS_WAIT) != 0 and tcb.wspec.chg_pri_hook) {
            // function pointer table ?
            (*tcb.wspec.chg_pri_hook)(tcb, oldpri);
        }
    }
}

// * Rotate ready queue.
pub fn knl_rotate_ready_queue(priority: isize) void {
    ready_queue.knl_ready_queue_rotate(&ready_queue.knl_ready_queue, priority);
    knl_reschedule();
}

// * Rotate the ready queue including the highest priority task.
pub fn knl_rotate_ready_queue_run() void {
    if (knlink.knl_schedtsk != null) {
        ready_queue.knl_ready_queue_rotate(&ready_queue.knl_ready_queue, ready_queue.knl_ready_queue_top_priority(&ready_queue.knl_ready_queue));
        knl_reschedule();
    }
}

// *	Debug support function
// if (comptime USE_DBGSPT) {
//
// #ifdef USE_FUNC_TD_RDY_QUE
// //
//  * Refer ready queue
//  */
// SYSCALL INT td_rdy_que( PRI pri, ID list[], INT nent )
// {
// 	QUEUE	*q, *tskque;
// 	INT	n = 0;
//
// 	CHECK_PRI(pri);
//
// 	BEGIN_DISABLE_INTERRUPT;
// 	tskque = &knl_ready_queue.tskque[int_priority(pri)];
// 	for ( q = tskque.next; q != tskque; q = q.next ) {
// 		if ( n++ < nent ) {
// 			*(list++) = ((TCB*)q).tskid;
// 		}
// 	}
// 	END_DISABLE_INTERRUPT;
//
// 	return n;
// }
// #endif // USE_FUNC_TD_RDY_QUE */
//
// }
