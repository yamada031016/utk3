// *	Ready Queue Operation Routine
const tstd = @import("tstd");
const knlink = @import("knlink");
const TCB = knlink.TCB;
// const inc_sys = @import("inc_sys");
// const queue = inc_sys.queue;
// const QUEUE = queue.QUEUE;
// const INT_BITWIDTH = inc_sys.machine.INT_BITWIDTH;

// * Definition of ready queue structure
// *	In the ready queue, the task queue 'tskque' is provided per priority.
// *	The task TCB is registered onto queue with the applicable priority.
// *	For effective ready queue search, the bitmap area 'bitmap' is provided
// *	to indicate whether there are tasks in task queue per priority.
// *
// *	Also, to search a task at the highest priority in the ready queue
// *    	effectively, put the highest task priority in the 'top_priority' field.
// *	If the ready queue is empty, set the value in this field to NUM_TSKPRI.
// *	In this case, to return '0' with refering 'tskque[top_priority]',
// *      there is 'null' field which is always '0'.
// *
// *	Multiple READY tasks with kernel lock do not exist at the same time.

const BITMAPSZ = @sizeOf(usize) * 8;
const NUM_BITMAP = (knlink.NUM_TSKPRI + BITMAPSZ - 1) / BITMAPSZ;

pub const RDYQUE = struct {
    top_priority: isize, // Highest priority in ready queue */
    tskque: [knlink.NUM_TSKPRI]QUEUE, // Task queue per priority */
    null: *void, // When the ready queue is empty, */
    bitmap: [NUM_BITMAP]usize, // Bitmap area per priority */
    klocktsk: *TCB, // READY task with kernel lock */
};

pub const knl_ready_queue = RDYQUE{};

// if (comptime knlink.NUM_TSKPRI <= INT_BITWIDTH) {
pub inline fn knl_ready_queue_calc_top_priority(bitmap: usize, pos: isize) isize {
    while (pos < knlink.NUM_TSKPRI) : (pos += 1) {
        if (bitmap & (1 << pos)) {
            return pos;
        }
    }
    return knlink.NUM_TSKPRI;
}
// }

// * Ready queue initialization
pub inline fn knl_ready_queue_initialize(rq: *RDYQUE) void {
    var i: isize = 0;

    rq.top_priority = knlink.NUM_TSKPRI;
    while (i < knlink.NUM_TSKPRI) : (i += 1) {
        queue.QueInit(&rq.tskque[i]);
    }
    rq.null = null;
    rq.klocktsk = null;
    tstd.knl_memset(rq.bitmap, 0, @sizeOf(rq.bitmap));
}

// * Return the highest priority task in ready queue
pub inline fn knl_ready_queue_top(rq: *RDYQUE) *TCB {
    // If there is a task at kernel lock, that is the highest priority task */
    if (rq.klocktsk != null) {
        return rq.klocktsk;
    }

    return @as(*TCB, rq.tskque[rq.top_priority].next);
}

// * Return the priority of the highest priority task in the ready queue
pub inline fn knl_ready_queue_top_priority(rq: *const RDYQUE) isize {
    return rq.top_priority;
}

// * Insert task in ready queue
// *	Insert it at the end of the same priority tasks with task priority
// *	indicated with 'tcb'. Set the applicable bit in the bitmap area and
// *	update 'top_priority' if necessary. When updating 'top_priority,'
// *	return TRUE, otherwise FALSE.
pub inline fn knl_ready_queue_insert(rq: *RDYQUE, tcb: *TCB) bool {
    var priority: isize = tcb.priority;

    queue.QueInsert(&tcb.tskque, &rq.tskque[priority]);
    if (comptime knlink.NUM_TSKPRI <= INT_BITWIDTH) {
        rq.bitmap[0] |= (1 << priority);
    } else {
        tstd.knl_bitset(rq.bitmap, priority);
    }

    if (tcb.klocked) {
        rq.klocktsk = tcb;
    }

    if (priority < rq.top_priority) {
        rq.top_priority = priority;
        return true;
    }
    return false;
}

// * Insert task at head in ready queue
pub inline fn knl_ready_queue_insert_top(rq: *RDYQUE, tcb: *TCB) void {
    var priority: isize = tcb.priority;

    queue.QueInsert(&tcb.tskque, rq.tskque[priority].next);
    if (comptime knlink.NUM_TSKPRI <= INT_BITWIDTH) {
        rq.bitmap[0] |= (1 << priority);
    } else {
        tstd.knl_bitset(rq.bitmap, priority);
    }

    if (tcb.klocked) {
        rq.klocktsk = tcb;
    }

    if (priority < rq.top_priority) {
        rq.top_priority = priority;
    }
}

// * Delete task from ready queue
// *	Take out TCB from the applicable priority task queue, and if the task
// *	queue becomes empty, clear the applicable bit from the bitmap area.
// *	In addition, update 'top_priority' if the deleted task had the highest
// *	priority. In such case, use the bitmap area to search the second
// *	highest priority task.
pub inline fn knl_ready_queue_delete(rq: *RDYQUE, tcb: *TCB) void {
    var priority: isize = tcb.priority;
    // if (comptime knlink.NUM_TSKPRI > INT_BITWIDTH) {
    //     var i: isize = undefined;
    //     _ = i;
    // }

    if (rq.klocktsk == tcb) {
        rq.klocktsk = null;
    }

    queue.QueRemove(&tcb.tskque);
    if (tcb.klockwait) {
        // Delete from kernel lock wait queue */
        tcb.klockwait = false;
        return;
    }
    if (!queue.isQueEmpty(&rq.tskque[priority])) {
        return;
    }

    if (comptime knlink.NUM_TSKPRI <= INT_BITWIDTH) {
        rq.bitmap[0] &= ~(1 << priority);
    } else {
        tstd.knl_bitclr(rq.bitmap, priority);
    }
    if (priority != rq.top_priority) {
        return;
    }

    // if (comptime knlink.NUM_TSKPRI <= INT_BITWIDTH) {
    rq.top_priority = knl_ready_queue_calc_top_priority(rq.bitmap[0], priority);
    // } else {
    //     i = knl_bitsearch1(rq.bitmap, priority, knlink.NUM_TSKPRI - priority);
    //     if (i >= 0) {
    //         rq.top_priority = priority + i;
    //     } else {
    //         rq.top_priority = knlink.NUM_TSKPRI;
    //     }
    // }
}

// * Move the task, whose ready queue priority is 'priority', at head of
// * queue to the end of queue. Do nothing, if the queue is empty.
inline fn knl_ready_queue_rotate(rq: *RDYQUE, priority: isize) void {
    var tskque: *QUEUE = &rq.tskque[priority];

    var tcb: *TCB = @as(*TCB, queue.QueRemoveNext(tskque));
    if (tcb != null) {
        queue.QueInsert(@as(*QUEUE, tcb), tskque);
    }
}

// * Put 'tcb' to the end of ready queue.
inline fn knl_ready_queue_move_last(rq: *RDYQUE, tcb: *TCB) *TCB {
    var tskque: *QUEUE = &rq.tskque[tcb.priority];

    queue.QueRemove(&tcb.tskque);
    queue.QueInsert(&tcb.tskque, tskque);

    return @as(*TCB, tskque.next); // New task at head of queue */
}
