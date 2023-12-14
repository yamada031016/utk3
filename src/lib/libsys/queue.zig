//Queuing operation */
const knlink = @import("knlink");

// Double-link queue (ring) */
// pub const QUEUE = struct {
//     next: ?*QUEUE,
//     prev: ?*QUEUE,
// };
//
// // Queue initialization */
// pub inline fn QueInit(que: *?QUEUE) void {
//     if (que.*) |*elem| {
//         elem.next = elem;
//         elem.prev = elem;
//     } else {
//         // que is null
//     }
// }
//
// // true if the queue is empty */
// pub inline fn isQueEmpty(que: *const ?QUEUE) bool {
//     // 多分,アドレスが同じ == 同じqueueという理屈でいいと思う
//     // que.next == queだとZigでは構造体の==ができないのでエラー
//     if (que.*) |elem| {
//         return &elem.next.? == &elem;
//     } else {
//         // que is null
//         return true;
//     }
// }
//
// // Insert in queue
// //Inserts entry directly prior to que */
// pub inline fn QueInsert(entry: *QUEUE, que: *QUEUE) void {
//     entry.prev.? = que.prev.?;
//     entry.next.? = que;
//     que.prev.next.? = entry;
//     que.prev.? = entry;
// }
//
// // Delete from queue
// //Deletes entry from queue
// //No action is performed if entry is empty. */
// pub inline fn QueRemove(entry: *QUEUE) void {
//     if (entry.next.? != entry) {
//         entry.prev.next.? = entry.next.?;
//         entry.next.prev.? = entry.prev.?;
//     }
// }
//
// // Remove top entry
// //Deletes the entry directly after que from the queue,
// //and returns the deleted entry.
// //Returns null if que is empty. */
// pub inline fn QueRemoveNext(que: *QUEUE) ?*QUEUE {
//     if (que.next.? == que) {
//         return null;
//     }
//
//     var entry: *QUEUE = que.next.?;
//     que.next.? = entry.next.?;
//     entry.next.prev.? = que;
//
//     return entry;
// }

// Zig std queue
pub const TCBNode = struct {
    data: *knlink.TCB,
    next: ?*TCBNode,
    prev: ?*TCBNode,
};

pub fn TkQueue(comptime T: type) type {
    return struct {
        const This = @This();
        const Node = struct {
            data: T,
            next: ?*Node,
            prev: ?*Node,
        };
        start: ?*Node,
        end: ?*Node,

        pub fn init() This {
            return This{
                .start = null,
                .end = null,
            };
        }

        pub fn enqueue(this: *This, value: T) void {
            const node = Node{ .data = value, .next = null, .prev = null };
            if (this.end) |end| end.*.next = @constCast(&node) else this.start = @constCast(&node);
            this.end = @constCast(&node);
        }

        pub fn dequeue(this: *This) ?T {
            const start = this.start orelse return null;
            if (start.next) |next|
                this.start = next
            else {
                this.start = null;
                this.end = null;
            }
            return start.data;
        }

        pub fn isEmpty(this: *This) ?T {
            return if (this.start == null) true else false;
        }
    };
}
