//Queuing operation */
const knlink = @import("knlink");

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
