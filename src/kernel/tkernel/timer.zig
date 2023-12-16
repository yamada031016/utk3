// *	Timer Control
const knlink = @import("knlink");
const tstd = knlink.tstd;
const config = @import("config");
const cpu_status = knlink.sysdepend.cpu_status;
const libtk = @import("libtk");
const libsys = @import("libsys");
const knldef = libsys.knldef;
const TkError = libtk.errno.TkError;
const queue = libsys.queue;
const TkQueue = queue.TkQueue;
const typedef = libtk.typedef;
const SYSTIM = typedef.SYSTIM;
const sys_timer = knlink.sysdepend.sys_timer;

// * SYSTIM internal expression and conversion */
// typedef	D	i64;	// SYSTIM int. expression */

inline fn knl_toLSYSTIM(time: *SYSTIM) i64 {
    var ltime: i64 = undefined;
    knlink.hilo_ll(ltime, time.hi, time.lo);
    return ltime;
}

inline fn knl_toSYSTIM(ltime: i64) SYSTIM {
    var time: SYSTIM = undefined;
    knlink.ll_hilo(time.hi, time.lo, ltime);
    return time;
}

// * Absolute time (can be considered the lower 32bit of SYSTIM) */
// typedef	UW	ABSTIM;

pub const ABSTIM_DIFF_MIN = 0x7FFFFFFF;

inline fn knl_abstim_reached(curtim: u32, evttim: u32) bool {
    return @as(u32, curtim - evttim) <= @as(u32, ABSTIM_DIFF_MIN);
}

// * Definition of timer event block */
// typedef void	(*CBACK)(void *);	// Type of callback function */

pub const TMEB = struct {
    // queue: queue.QueNode(usize), // Timer event queue */
    const Node = struct {
        const This = @This();
        data: usize,
        next: ?*This,
        prev: ?*This,

        fn dequeue(this: *This) void {
            if (this.*.next.? != this) {
                this.prev.?.next = this.next;
                this.*.next.?.prev = this.prev;
            }
        }
    };
    queue: ?*Node,
    time: u32, // Event time */
    // callback function pointerの型は仮置きしただけ
    callback: *const fn () void, // Callback function */
    arg: *void, // Argument to be sent to callback function */
};

// * Current time (Software clock) */
pub var knl_current_time: i64 = 0; // System operation time */
pub var knl_real_time_ofs: i64 = undefined; // Difference from actual time */

// * Time-event queue */
pub var knl_timer_queue: TkQueue(usize) = TkQueue(usize).init();

// * Delete from time-event queue */
inline fn knl_timer_delete(event: *TMEB) void {
    event.queue.?.dequeue();
    // queue.QueRemove(&event.queue);
}

// * Current time (Software clock)
// *	'current_time' shows the total operation time since
// *	operating system Starts. 'real_time_ofs' shows difference
// *	between the current time and the operating system clock
// *	(current_time). Do not change 'current_time' when setting
// *	time by 'set_tim()'. Set 'real_time_ofs' with the time
// *   	difference between 'current_time' and setup time.
// *	Therefore 'current_time' does not affect with time change
// *	and it increases simply.
// Noinit(EXPORT i64	knl_current_time);	// System operation time */
// Noinit(EXPORT i64	knl_real_time_ofs);	// Actual time - System operation time */

// * Timer event queue */
// Noinit(EXPORT QUEUE	knl_timer_queue);

// * Start system timer */
pub fn knl_timer_startup() TkError!void {
    knl_real_time_ofs = 0;
    knl_current_time = knl_real_time_ofs;
    // knl_timer_queue already initialized.
    // knl_timer_queue.init();

    // Start timer interrupt */
    sys_timer.knl_start_hw_timer();
}

// if (comptime USE_SHUTDOWN) {
// // * Stop system timer */
// pub fn knl_timer_shutdown() void {
// 	knl_terminate_hw_timer();
// }
// }

// * Insert timer event to timer event queue */
fn knl_enqueue_tmeb(event: *TMEB) void {
    var ofs: u32 = knl_current_time - ABSTIM_DIFF_MIN;
    var q = knl_timer_queue.next.?;
    while (q != &knl_timer_queue) : (q = q.next.?) {
        if (@as(u32, event.time - ofs) < @as(u32, ((@as(*TMEB, q).time) - ofs))) {
            break;
        }
    }
    queue.QueInsert(&event.queue, q);
}

// * Set timeout event
// *	Register the timer event 'event' onto the timer queue to
// *	start after the timeout 'tmout'. At timeout, start with the
// *	argument 'arg' on the callback function 'callback'.
// *	When 'tmout' is TMO_FEVR, do not register onto the timer
// *	queue, but initialize queue area in case 'timer_delete'
// *	is called later.
// *
// *	"include/tk/typedef.h"
// *	typedef	W		TMO;
// *	typedef UW		RELTIM;
// *	pub const TMO_FEVR	(-1)
// callbackは適当
pub fn knl_timer_insert(event: *TMEB, tmout: i32, callback: fn () void, arg: *void) void {
    event.callback = callback;
    event.arg = arg;

    if (tmout == typedef.TMO_FEVR) {
        queue.QueInit(&event.queue);
    } else {
        // To guarantee longer wait time specified by 'tmout',
        // add TIMER_PERIOD on wait time */
        event.time = knl_current_time + tmout + knldef.TIMER_PERIOD;
        knl_enqueue_tmeb(event);
    }
}

pub fn knl_timer_insert_reltim(event: *TMEB, tmout: u32, callback: fn () void, arg: *void) void {
    event.callback = callback;
    event.arg = arg;

    // To guarantee longer wait time specified by 'tmout',
    // add TIMER_PERIOD on wait time */
    event.time = knl_current_time + tmout + knldef.TIMER_PERIOD;
    knl_enqueue_tmeb(event);
}

// * Set time specified event
// *	Register the timer event 'evt' onto the timer queue to start at the
// *	(absolute) time 'time'.
// *	'time' is not an actual time. It is system operation time.
// */
pub fn knl_timer_insert_abs(evt: *TMEB, time: u32, cback: fn () void, arg: *void) void {
    evt.callback = cback;
    evt.arg = arg;
    evt.time = time;
    knl_enqueue_tmeb(evt);
}

// * System timer interrupt handler
// *	This interrupt handler starts every TIMER_PERIOD millisecond
// *	interval by hardware timer. Update the software clock and start the
// *	timer event upon arriving at start time.

pub fn knl_timer_handler() void {
    // var event: *TMEB = undefined;

    sys_timer.knl_clear_hw_timer_interrupt(); // Clear timer interrupt */

    {
        cpu_status.BEGIN_CRITICAL_SECTION();
        defer cpu_status.END_CRITICAL_SECTION();
        knl_current_time = knl_current_time + knldef.TIMER_PERIOD;
        var cur: u32 = knl_current_time;

        // if (comptime USE_DBGSPT and defined(USE_FUNC_TD_INF_TSK)) {
        //     if (knl_ctxtsk != null) {
        //         // Task at execution */
        //         if (knl_ctxtsk.sysmode > 0) {
        //             knl_ctxtsk.stime += knldef.TIMER_PERIOD;
        //         } else {
        //             knl_ctxtsk.utime += knldef.TIMER_PERIOD;
        //         }
        //     }
        // }

        // Execute event that passed occurring time. */
        while (!queue.isQueEmpty(&knl_timer_queue)) {
            const event = @as(*TMEB, knl_timer_queue.next);

            if (!knl_abstim_reached(cur, event.time)) {
                break;
            }

            queue.QueRemove(event.?.queue);
            if (event.*.callback != null) {
                // どうかけばええんや
                (event.*.callback)(event.arg);
            }
        }
    }
    sys_timer.knl_end_of_hw_timer_interrupt(); // Clear timer interrupt */
}
