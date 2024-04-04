// *	Task Control
// * Internal expression of task state
// *	Can check with 'state & TS_WAIT' whether the task is in the wait state.
// *	Can check with 'state & TS_SUSPEND' whether the task is in the forced
// *	wait state.
const config = @import("config");
const knlink = @import("knlink");
const ready_queue = knlink.rdy_que;
const cpu_task = knlink.sysdepend.core.cpu_task;
const TCB = knlink.TCB;
const libsys = @import("libsys");
const knldef = libsys.knldef;
const libtk = @import("libtk");
// const syslib = libtk.syslib;
const syscall = libtk.syscall;
// const tkernel = libtk.tkernel;
const TkError = libtk.errno.TkError;
const queue = libsys.queue;
const TkQueue = queue.TkQueue;
const PRI = libtk.typedef.PRI;
const libtm = @import("libtm");

pub const TSTAT = enum(u8) {
    NONEXIST = 0, // Unregistered state */
    READY = 1, // RUN or READY state */
    WAIT = 2, // WAIT state */
    SUSPEND = 4, // SUSPEND state */
    WAITSUS = 6, // Both WAIT and SUSPEND state */
    DORMANT = 8, // DORMANT state */
};

pub export var knl_dispatch_disabled: bool = false;

// * If the task is alive ( except NON-EXISTENT,DORMANT ), return TRUE.
pub inline fn knl_task_alive(state: TSTAT) bool {
    return (state & (TSTAT.READY | TSTAT.WAIT | TSTAT.SUSPEND)) != 0;
}

// * Task priority internal/external expression conversion macro
pub inline fn int_priority(x: PRI) PRI {
    return x - knldef.MIN_TSKPRI;
}
pub inline fn ext_tskpri(x: PRI) isize {
    return x + knldef.MIN_TSKPRI;
}

// * Task control information
pub var knl_tcb_table: [knldef.NUM_TSKID]*TCB = undefined;
fn knl_tcb_table_init() void {
    knl_tcb_table = tcb_table: {
        var tmp: [knldef.NUM_TSKID]*TCB = undefined;
        var _tcb: [knldef.NUM_TSKID]TCB = undefined;
        for (0..knldef.NUM_TSKID) |i| {
            var dummy: *TCB = undefined;
            var dummy_stack: *knlink.sysdepend.core.cpu_task.SStackFrame = undefined;
            _tcb[i] = TCB{
                .tskque = @constCast(&TCB.Node{ .next = dummy, .prev = dummy }),
                // .tskque = null,
                .tskid = i + 1,
                .task = @as(*usize, @ptrCast(&dummy)),
                .exinf = null,
                .tskatr = 999,
                .tskctxb = knlink.sysdepend.core.CTXB{ .ssp = @ptrCast(&dummy_stack) },
                .sstksz = 999,
                .isysmode = 127,
                .sysmode = 999,
                .ipriority = 32,
                .bpriority = 32,
                .priority = 32, //min Pri
                .state = TSTAT.NONEXIST,
                .wid = 999,
                .wupcnt = 999,
                .suscnt = 999,
                .wercd = TkError.SystemError,
                .isstack = @ptrCast(&dummy_stack),
            };
            tmp[i] = &_tcb[i];
        }
        break :tcb_table tmp;
    };
}
// pub var knl_tcb_table: [knldef.NUM_TSKID]*TCB = tcb_table: {
//     var tmp: [knldef.NUM_TSKID]*TCB = undefined;
//     for (0..knldef.NUM_TSKID) |i| {
//         var dummy: *TCB = undefined;
//         var dummy_stack: *knlink.sysdepend.core.cpu_task.SStackFrame = undefined;
//         _tcb = TCB{
//             .tskque = @constCast(&TCB.Node{ .next = dummy, .prev = null }),
//             // .tskque = null,
//             .tskid = i + 1,
//             .task = @as(*usize, @ptrCast(&dummy)),
//             .exinf = null,
//             .tskatr = 999,
//             .tskctxb = knlink.sysdepend.core.CTXB{ .ssp = @ptrCast(&dummy_stack) },
//             .sstksz = 999,
//             .isysmode = 127,
//             .sysmode = 999,
//             .ipriority = 32,
//             .bpriority = 32,
//             .priority = 32, //min Pri
//             .state = TSTAT.TS_DORMANT,
//             .wid = 999,
//             .wupcnt = 999,
//             .suscnt = 999,
//             .wercd = TkError.SystemError,
//             .isstack = @ptrCast(&dummy_stack),
//         };
//         tmp[i] = &_tcb;
//     }
//     break :tcb_table tmp;
// };

pub var knl_free_tcb = TkQueue(*TCB).init();

// * Get TCB from task ID.
pub inline fn get_tcb(id: usize) *TCB {
    return knl_tcb_table[knldef.INDEX_TSK(id)];
}

pub inline fn get_tcb_self(id: isize) TCB {
    if (id == syscall.TSK_SELF) {
        return knlink.knl_ctxtsk.?.*;
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

// * Reselect task to execute
// *	Set 'schedtsk' to the head task at the ready queue.
pub inline fn knl_reschedule() void {
    const toptsk: *TCB = ready_queue.knl_ready_queue.top();
    if (knlink.knl_schedtsk) |elem| {
        if (elem != toptsk) {
            elem.* = toptsk.*;
        }
    }
}

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
    libtm.log.TkLog(.debug, .api, "start {}()", .{@src().fn_name});
    defer libtm.log.TkLog(.debug, .api, "end {}()", .{@src().fn_name});
    errdefer libtm.log.TkLog(.err, .api, "failed {}()", .{@src().fn_name});

    // Get system information */
    if (knldef.NUM_TSKID < 1) {
        return TkError.SystemError;
    }

    // Initialize task execution control information */
    knlink.knl_ctxtsk = null;
    knlink.knl_schedtsk = null;
    knl_tcb_table_init();
    // knl_ready_queueはinit済み
    // ready_queue.RdyQueue().init();
    knl_dispatch_disabled = knlink.DDS_ENABLE;

    // Register all TCBs onto FreeQue */
    for (knl_tcb_table, 0..32) |tcb, i| {
        tcb.tskid = knldef.ID_TSK(i);
        // if (i == 0) {
        // serial.hexdump("tcb addr", @intFromPtr(tcb));
        // }
        tcb.state = TSTAT.NONEXIST;
        // if (comptime USE_LEGACY_API and USE_RENDEZVOUS) {
        //     tcb.wrdvno = tskid;
        // }
        // if (tcb.tskque != null) {
        knl_free_tcb.enqueue(tcb);
        // }
    }
}

// * Prepare task execution.
pub fn knl_make_dormant(tcb: *TCB) void {
    libtm.log.TkLog(.debug, .api, "start {}()", .{@src().fn_name});
    defer libtm.log.TkLog(.debug, .api, "end {}()", .{@src().fn_name});

    // Initialize variables which should be reset at DORMANT state */
    tcb.state = TSTAT.DORMANT;
    tcb.bpriority = tcb.ipriority;
    tcb.priority = tcb.ipriority;
    tcb.sysmode = tcb.isysmode;
    tcb.wupcnt = 0;
    tcb.suscnt = 0;
    tcb.klockwait = false;
    tcb.klocked = false;
    // if (comptime config.USE_DBGSPT and defined(USE_FUNC_TD_INF_TSK)) {
    //     tcb.stime = 0;
    //     tcb.utime = 0;
    // }
    tcb.wercd = undefined;

    if (comptime config.func.USE_MUTEX) {
        tcb.mtxlist = null;
    }
    // Set context to start task */
    cpu_task.knl_setup_context(tcb);
}

// * Set task to READY state.
// *	Update the task state and insert in the ready queue. If necessary,
// *	update 'knl_schedtsk' and request to start task dispatcher.
pub fn knl_make_ready(tcb: *TCB) void {
    tcb.state = TSTAT.READY;
    if (ready_queue.knl_ready_queue.insert(tcb)) {
        knlink.knl_schedtsk = tcb;
    }
}

// * Set task to non-executable state.
// *	Delete the task from the ready queue.
// *	If the deleted task is 'knl_schedtsk', set 'knl_schedtsk' to the
// *	highest priority task in the ready queue.
// *	'tcb' task must be READY.
pub fn knl_make_non_ready(tcb: *TCB) void {
    ready_queue.knl_ready_queue.delete(tcb);
    if (knlink.knl_schedtsk.? == tcb) {
        libtm.log.TkLog(.debug, .api, "non ready!", .{});
        knlink.knl_schedtsk = ready_queue.knl_ready_queue.top();
    }
}

// * Change task priority.
pub fn knl_change_task_priority(tcb: *TCB, priority: PRI) void {
    if (tcb.state == TSTAT.READY) {
        // * When deleting a task from the ready queue,
        // * a value in the 'priority' field in TCB is needed.
        // * Therefore you need to delete the task from the
        // * ready queue before changing 'tcb.priority.'
        ready_queue.knl_ready_queue.delete(tcb);
        tcb.priority = priority;
        ready_queue.knl_ready_queue_insert(&ready_queue.knl_ready_queue, tcb);
        knl_reschedule();
    } else {
        const oldpri: PRI = tcb.priority;
        _ = oldpri;
        tcb.priority = @truncate(priority); // isize -> u8

        // If the hook routine at the task priority change is defined,
        // execute it */

        // winfo実装してから
        // if ((tcb.state & TSTAT.TS_WAIT) != 0 and tcb.wspec.chg_pri_hook) {
        //     // function pointer table ?
        //     (*tcb.wspec.chg_pri_hook)(tcb, oldpri);
        // }
    }
}

// * Rotate ready queue.
pub fn knl_rotate_ready_queue(priority: isize) void {
    ready_queue.knl_ready_queue.rotate(priority);
    knl_reschedule();
}

// * Rotate the ready queue including the highest priority task.
pub fn knl_rotate_ready_queue_run() void {
    if (knlink.knl_schedtsk != null) {
        ready_queue.knl_ready_queue.rotate(ready_queue.knl_ready_queue.top_priority());
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
