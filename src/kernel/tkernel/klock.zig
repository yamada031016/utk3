// *	Locked task is the highest run priority.
// *	Unable to nest lock.
const knlink = @import("knlink");
// const inc_sys = @import("inc_sys");
const config = @import("config");
// const knldef = inc_sys.knldef;
const cpu_status = knlink.sysdepend.cpu_status;

const ready_queue = knlink.rdy_que;
// const queue = inc_sys.queue;

// * Object lock
// *	Do not call from critical section
pub fn knl_LockOBJ(loc: *const OBJLOCK) void {
    var klocked: bool = false;
    while (!klocked) {
        cpu_status.BEGIN_CRITICAL_SECTION();
        defer cpu_status.END_CRITICAL_SECTION();
        klocked = knlink.knl_ctxtsk.klocked;
        if (!klocked) {
            if (loc.wtskq.next) |_| {
                // nextの値はloc.wtskqかもしれぬ
                // その時はQueInit(value)とかける？
                // Ready for lock */
                ready_queue.knl_ready_queue_delete(&ready_queue.knl_ready_queue, knlink.knl_ctxtsk);
                knlink.knl_ctxtsk.klockwait = true;
                queue.QueInsert(&knlink.knl_ctxtsk.tskque, &loc.wtskq);

                knlink.knl_schedtsk = ready_queue.knl_ready_queue_top(&ready_queue.knl_ready_queue);
            } else {
                // Lock */
                queue.QueInit(&loc.wtskq);

                klocked = true;
                knlink.knl_ctxtsk.klocked = klocked;
                ready_queue.knl_ready_queue.klocktsk = knlink.knl_ctxtsk;
            }
        }
    }
}

// * Object unlock
// *	It may be called from a critical section.
pub fn knl_UnlockOBJ(loc: *OBJLOCK) void {
    cpu_status.BEGIN_CRITICAL_SECTION();
    defer cpu_status.END_CRITICAL_SECTION();
    knlink.knl_ctxtsk.klocked = false;
    ready_queue.knl_ready_queue.klocktsk = null;

    var tcb: *knlink.TCB = @as(*knlink.TCB, queue.QueRemoveNext(&loc.wtskq));
    if (tcb) |_| {
        // Wake lock wait task */
        tcb.klockwait = false;
        tcb.klocked = true;
        ready_queue.knl_ready_queue_insert_top(&ready_queue.knl_ready_queue, tcb);
    } else {
        // Free lock */
        loc.wtskq.next = null;
    }

    knlink.knl_schedtsk = ready_queue.knl_ready_queue_top(&ready_queue.knl_ready_queue);
}

const OBJLOCK = struct {
    wtskq: queue.QUEUE, // Wait task queue */
};

inline fn knl_InitOBJLOCK(loc: *OBJLOCK) void {
    loc.wtskq.next = null;
}

inline fn knl_isLockedOBJ(loc: *OBJLOCK) bool {
    return if (loc.wtskq.next) true else false;
}
