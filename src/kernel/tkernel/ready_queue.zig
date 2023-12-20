// *	Ready Queue Operation Routine
const knlink = @import("knlink");
const tstd = knlink.tstd;
const TCB = knlink.TCB;
const libsys = @import("libsys");
const libtk = @import("libtk");
const knldef = libsys.knldef;
const PRI = libtk.typedef.PRI;
const queue = libsys.queue;
const TkQueue = queue.TkQueue;
const INT_BITWIDTH = libsys.machine.INT_BITWIDTH;
const serial = @import("devices").serial;

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
const NUM_BITMAP = (knldef.NUM_TSKPRI + BITMAPSZ - 1) / BITMAPSZ;

// pub const RDYQUE = struct {
//     top_priority: PRI, // Highest priority in ready queue */
//     tskque: [knldef.NUM_TSKPRI]queue.Queue, // Task queue per priority */
//     null: *void, // When the ready queue is empty, */
//     bitmap: [NUM_BITMAP]usize, // Bitmap area per priority */
//     klocktsk: *TCB, // READY task with kernel lock */
// };

// nullはOptional型があるので消してよし
pub fn RdyQueue() type {
    return struct {
        const This = @This();
        // const Node = struct {
        //     data: *TCB,
        //     next: ?*Node,
        //     prev: ?*Node,
        // };
        start: ?*TCB.Node,
        end: ?*TCB.Node,
        top_priority: PRI, // Highest priority in ready queue */
        tskque: [knldef.NUM_TSKPRI]?*TCB, // Task queue per priority */
        bitmap: [NUM_BITMAP]usize, // Bitmap area per priority */
        klocktsk: ?*TCB, // READY task with kernel lock */

        pub fn init() This {
            // for (0..knlink.NUM_TSKPRI) |i| {
            //     this.tskque[i].init();
            // }
            // tstd.knl_memset(This.bitmap, 0, @sizeOf(This.bitmap));
            return This{
                .start = null,
                .end = null,
                .top_priority = knldef.NUM_TSKPRI,
                .tskque = [_]?*TCB{null} ** knldef.NUM_TSKPRI,
                .klocktsk = null,
                .bitmap = [NUM_BITMAP]usize{0},
            };
        }

        // * Return the highest priority task in ready queue
        pub fn top(this: *This) *TCB {
            // If there is a task at kernel lock, that is the highest priority task */
            if (this.klocktsk) |elem| {
                return elem;
            }
            // return @as(*TCB, this.tskque[this.top_priority].next.?.data);
            return this.tskque[this.top_priority].next.?.data;
        }

        // * Return the priority of the highest priority task in the ready queue
        pub fn top_priority(this: *This) isize {
            return this.top_priority;
        }

        // * Insert task in ready queue
        // *	Insert it at the end of the same priority tasks with task priority
        // *	indicated with 'tcb'. Set the applicable bit in the bitmap area and
        // *	update 'top_priority' if necessary. When updating 'top_priority,'
        // *	return TRUE, otherwise FALSE.
        pub fn insert(this: *This, tcb: *TCB) bool {
            serial.print("rdyque insert start");
            defer serial.print("rdyque insert end");

            const priority: usize = tcb.priority;
            const target: ?*TCB = this.tskque[priority - 1];

            if (target) |elem| {
                // elem: *TCB
                var tsk = tcb.tskque.?.next;
                while (tsk != null) : (tsk = tsk.?.tskque.?.next) {}
                tsk = elem;
                // tcb.tskque.?.*.prev = elem.tskque.?.prev;
                // tcb.tskque.?.*.next = elem;
                // elem.tskque.?.prev.?.tskque.?.next = tcb;
                // elem.tskque.?.prev = tcb;
            } else {
                this.tskque[priority - 1] = tcb;
            }

            if (knldef.NUM_TSKPRI <= INT_BITWIDTH) {
                this.bitmap[0] |= @as(usize, 1) << @as(u5, @intCast(priority - 1));
            } else {
                tstd.knl_bitset(this.bitmap, priority);
            }

            if (tcb.klocked) {
                this.klocktsk = tcb;
            }

            if (priority < this.top_priority) {
                this.top_priority = priority;
                return true;
            }
            return false;
            // const node = This{ .data = value, .next = null };
            // if (this.end) |end| end.*.next = &node else this.start = &node;
            // this.end = &node;
        }
        // * Insert task at head in ready queue
        pub fn insert_top(this: *This, tcb: *TCB) void {
            var priority: PRI = tcb.priority;

            // queue.QueInsert(&tcb.tskque, rq.tskque[priority].next);
            if (this.tskque[priority].?.*.next) |elem| {
                tcb.tskque.*.prev = elem.*.prev;
                tcb.tskque.*.next = elem;
                elem.*.prev.?.*.next.? = &tcb.tskque;
                elem.*.prev.? = &tcb.tskque;
            } else {
                this.tskque[priority].next = &tcb.tskque;
            }

            if (comptime knldef.NUM_TSKPRI <= INT_BITWIDTH) {
                this.bitmap[0] |= (1 << priority);
            } else {
                tstd.knl_bitset(this.bitmap, priority);
            }

            if (tcb.klocked) {
                this.klocktsk = tcb;
            }

            if (priority < this.top_priority) {
                this.top_priority = priority;
            }
        }

        // * Delete task from ready queue
        // *	Take out TCB from the applicable priority task queue, and if the task
        // *	queue becomes empty, clear the applicable bit from the bitmap area.
        // *	In addition, update 'top_priority' if the deleted task had the highest
        // *	priority. In such case, use the bitmap area to search the second
        // *	highest priority task.
        pub fn delete(this: *This, tcb: *TCB) void {
            var priority: PRI = tcb.priority;
            // if (comptime knldef.NUM_TSKPRI > INT_BITWIDTH) {
            //     var i: isize = undefined;
            //     _ = i;
            // }

            if (this.klocktsk == tcb) {
                this.klocktsk = null;
            }

            // queue.QueRemove(&tcb.tskque);
            tcb.tskque.dequeue();
            if (tcb.klockwait) {
                // Delete from kernel lock wait queue */
                tcb.klockwait = false;
                return;
            }
            if (this.tskque[priority] == null) {
                // tskque is empty
                return;
            }

            if (comptime knldef.NUM_TSKPRI <= INT_BITWIDTH) {
                this.bitmap[0] &= ~(1 << priority);
            } else {
                tstd.knl_bitclr(this.bitmap, priority);
            }
            if (priority != this.top_priority) {
                return;
            }

            // if (comptime knldef.NUM_TSKPRI <= INT_BITWIDTH) {
            this.top_priority = this.calc_top_priority(this.bitmap[0], priority);
            // } else {
            //     i = knl_bitsearch1(rq.bitmap, priority, knldef.NUM_TSKPRI - priority);
            //     if (i >= 0) {
            //         rq.top_priority = priority + i;
            //     } else {
            //         rq.top_priority = knldef.NUM_TSKPRI;
            //     }
            // }
        }
        // if (comptime knldef.NUM_TSKPRI <= INT_BITWIDTH) {
        fn calc_top_priority(bitmap: usize, pos: isize) isize {
            for (pos..knldef.NUM_TSKPRI - 1) |_| {
                if (bitmap & (1 << pos)) {
                    return pos;
                }
            }
            return knldef.NUM_TSKPRI;
        }
        // }

        // * Move the task, whose ready queue priority is 'priority', at head of
        // * queue to the end of queue. Do nothing, if the queue is empty.
        pub fn rotate(this: *This, priority: PRI) void {
            var tskque = &this.tskque[priority];

            var tcb: ?*TCB = tskque.*.dequeue();
            if (tcb) {
                tskque.*.enqueue(&tcb);
            }
        }

        // * Put 'tcb' to the end of ready queue.
        pub fn move_last(this: *This, tcb: *TCB) *TCB {
            var tskque = &this.tskque[tcb.priority];
            _ = tcb.tskque.*.dequeue();
            tskque.*.insert(tcb.tskque);
            return tskque.*.next.?.data; // New task at head of queue */
        }
    };
}

pub var knl_ready_queue = RdyQueue().init();
