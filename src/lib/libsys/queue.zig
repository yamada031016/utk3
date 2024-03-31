//Queuing operation */
const knlink = @import("knlink");
const serial = @import("devices").serial;
const print = @import("devices").serial.print;

// Zig std queue
pub fn QueNode(comptime T: type) type {
    return struct {
        const This = @This();
        data: T,
        next: ?*This,
        prev: ?*This,
    };
}

pub fn TkQueue(comptime T: type) type {
    return struct {
        const This = @This();
        pub const Node = struct {
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
            // serial.hexdump("tcb in enqueue", @intFromPtr(value));
            var node = Node{ .data = value, .next = null, .prev = this.end };
            this.end = &node;
            if (node.prev) |prev_node| {
                prev_node.next = &node;
            } else {
                this.start = &node;
            }
        }

        pub fn dequeue(this: *This) ?T {
            const start = this.start orelse return null;
            if (start.next) |next| {
                this.start = next;
            } else {
                this.start = null;
                this.end = null;
            }
            return start.data;
        }

        pub fn dequeueNext(this: *This) ?T {
            print("dequeueNext");
            // const start: ?*Node = if (this.start) |_start| _start else null;
            const start = this.start.?.next orelse return null;
            this.start = start;
            // if (start) |new_start| {
            // _ = new_start;
            print("que exists.");
            // this.start = new_start.next;
            // new_start.prev = null;
            // } else {
            // print("que null.");
            // this.end = null;
            // }
            // start.prev = null;
            // start.next = null;
            return this.start.?.data;
        }

        pub fn isEmpty(this: *This) bool {
            return this.start == null;
            // return if (this.start == this.end) true else false;
        }
    };
}
