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
const libtm = @import("libtm");
const tm_printf = libtm.tm_printf;

const BITMAPSZ = @sizeOf(usize) * 8;
const NUM_BITMAP = (knldef.NUM_TSKPRI + BITMAPSZ - 1) / BITMAPSZ;

pub fn RdyQueue() type {
    return extern struct {
        const This = @This();
        start: ?*TCB.Node,
        end: ?*TCB.Node,
        top_priority: PRI, // Highest priority in ready queue */
        tskque: [knldef.NUM_TSKPRI]?*TCB, // Task queue per priority */
        bitmap: [NUM_BITMAP]usize, // Bitmap area per priority */
        klocktsk: ?*TCB, // READY task with kernel lock */

        pub fn init() This {
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
            tm_printf("ready queue top() start", .{});
            defer tm_printf("ready queue top() end", .{});
            tm_printf("top pri", .{this.top_priority});
            return this.tskque[this.top_priority - 1].?;
        }

        // * Return the priority of the highest priority task in the ready queue
        pub fn getTopPriority(this: *This) PRI {
            return this.top_priority;
        }

        // * Insert task in ready queue
        // *	Insert it at the end of the same priority tasks with task priority
        // *	indicated with 'tcb'. Set the applicable bit in the bitmap area and
        // *	update 'top_priority' if necessary. When updating 'top_priority,'
        // *	return TRUE, otherwise FALSE.
        pub fn insert(this: *This, tcb: *TCB) bool {
            tm_printf("rdyque insert start", .{});
            defer tm_printf("rdyque insert end", .{});

            const priority: usize = tcb.priority;
            var target: ?*TCB = this.tskque[priority - 1];

            if (target) |elem| {
                tm_printf("target exists", .{});
                // elem: *TCB
                // if (elem.tskque) |que| {
                //     tm_printf("tskque exists", .{});
                elem.tskque.prev = tcb;
                tcb.tskque.next = elem;
                tcb.tskque.prev = tcb;
                // } else {
                //     tm_printf("tskque is null", .{});
                // }
                // var tsk = tcb.tskque.?.next;
                // while (tsk != null) : (tsk = tsk.?.tskque.?.next) {}
                // tsk = elem;
            } else {
                this.tskque[priority - 1] = tcb;
                tm_printf("usermain tskid", .{this.tskque[9].?.tskid});
                tm_printf("tskque update", .{});
            }

            if (knldef.NUM_TSKPRI <= INT_BITWIDTH) {
                tm_printf("bitmap before", .{this.bitmap[0]});
                this.bitmap[0] |= @as(u32, 1) << @as(u5, @intCast(priority));
            } else {
                tstd.knl_bitset(this.bitmap, priority);
            }
            tm_printf("bitmap after", .{this.bitmap[0]});

            if (tcb.klocked) {
                this.klocktsk = tcb;
            }

            tm_printf("top pri", .{this.top_priority});
            if (priority < this.top_priority) {
                this.top_priority = priority;
                tm_printf("top pri", .{this.top_priority});
                return true;
            } else {
                return false;
            }
        }
        // * Insert task at head in ready queue
        pub fn insert_top(this: *This, tcb: *TCB) void {
            const priority: PRI = tcb.priority;

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
            tm_printf("ready queue delete() start", .{});
            defer tm_printf("ready queue delete() end", .{});
            const priority: PRI = tcb.priority;
            // if (comptime knldef.NUM_TSKPRI > INT_BITWIDTH) {
            //     var i: isize = undefined;
            //     _ = i;
            // }

            if (this.klocktsk == tcb) {
                tm_printf("klocktsk in delete()", .{});
                this.klocktsk = null;
            }

            // queue.QueRemove(&tcb.tskque);
            // tcb.tskque.dequeue();
            if (tcb.klockwait) {
                // Delete from kernel lock wait queue */
                tm_printf("klockwait in delete()", .{});
                tcb.klockwait = false;
                return;
            }
            if (this.tskque[priority - 1] == null) {
                tm_printf("tskque in delete()", .{});
                // tskque is empty
                return;
            } else {
                this.tskque[priority - 1] = null;
            }

            tm_printf("bitmap before", .{this.bitmap[0]});
            if (comptime knldef.NUM_TSKPRI <= INT_BITWIDTH) {
                // this.bitmap[0] &= ~(1 << priority);
                this.bitmap[0] ^= (@as(u32, 1) << @as(u5, @intCast(priority)));
            } else {
                tstd.knl_bitclr(this.bitmap, priority);
            }
            // if (priority != this.top_priority) {
            //     tm_printf("top pri", .{this.top_priority});
            //     tm_printf(" pri", .{tcb.priority});
            //     tm_printf("pri in delete()", .{});
            //     return;
            // }

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

        fn calc_top_priority(this: *This, bitmap: PRI, pos: PRI) PRI {
            if (comptime knldef.NUM_TSKPRI <= INT_BITWIDTH) {
                _ = this;
                // because of pos is contant.
                tm_printf("pos", .{pos});
                tm_printf("bitmap", .{bitmap});
                var i = pos;
                while (i < knldef.NUM_TSKPRI - 1) : (i += 1) {
                    if (bitmap ^ @as(u32, 1) << @as(u5, @intCast(i)) == 0) {
                        return i;
                    }
                } else {
                    return knldef.NUM_TSKPRI;
                }
            }
        }

        // * Move the task, whose ready queue priority is 'priority', at head of
        // * queue to the end of queue. Do nothing, if the queue is empty.
        pub fn rotate(this: *This, priority: PRI) void {
            const tskque = &this.tskque[priority];

            var tcb: ?*TCB = tskque.*.dequeue();
            if (tcb) {
                tskque.*.enqueue(&tcb);
            }
        }

        // * Put 'tcb' to the end of ready queue.
        pub fn move_last(this: *This, tcb: *TCB) *TCB {
            const tskque = &this.tskque[tcb.priority];
            _ = tcb.tskque.*.dequeue();
            tskque.*.insert(tcb.tskque);
            return tskque.*.next.?.data; // New task at head of queue */
        }
    };
}

pub export var knl_ready_queue = RdyQueue().init();

test "ready queue insert" {
    const std = @import("std");
    const expect = std.testing.expect;
    const syscall = libtk.syscall;
    var test_ready_queue = RdyQueue().init();
    const test_tsk = syscall.T_CTSK{
        .exinf = null,
        .tskatr = syscall.TA_HLNG | syscall.TA_RNG0,
        .task = null,
        .itskpri = 7,
        .stksz = 1 * 1024,
        .bufptr = null,
    };
    test_ready_queue.insert(&test_tsk);
    expect(test_ready_queue.getTopPriority() == 7);
}
