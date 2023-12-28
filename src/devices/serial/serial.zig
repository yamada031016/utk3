const config = @import("config");
const libtk = @import("libtk");
const syslib = libtk.syslib;
const write = syslib.cpu.write;
const read = syslib.cpu.read;
const TkError = libtk.errno.TkError;

const builtin = @import("builtin");
const dbg = builtin.mode == .Debug;

pub fn put(data: u8) void {
    // wait TXE
    while ((read(config.USART2_ISR) & 1 << 7) == 0) {} else {
        // transmit buffer is empty
        write(config.USART2_TDR, data);
    }
    // wait TC
    while ((read(config.USART2_ISR) & 1 << 6) == 0) {}
}

pub fn puts(string: []const u8) void {
    for (string) |char| {
        put(char);
    }
}

pub fn print(string: []const u8) void {
    puts(string);
    puts("\r\n");
}

// std.fmt.format参考にする.
// 未実装
pub fn tm_printf(comptime fmt: []const u8, args: anytype) void {
    _ = args;
    _ = fmt;
    unreachable;
}

pub fn hexdump(name: []const u8, data: usize) void {
    var vdata = data;
    var a: [10]usize = undefined;

    for (0..10) |i| {
        a[9 - i] = vdata % 16;
        vdata /= 16;
        if (vdata == 0) break;
    }
    puts(name);
    puts("\t\t\t0x");
    for (a) |value| {
        if (value > 16) {
            continue;
        }
        _ = switch (value) {
            0 => puts("0"),
            1 => puts("1"),
            2 => puts("2"),
            3 => puts("3"),
            4 => puts("4"),
            5 => puts("5"),
            6 => puts("6"),
            7 => puts("7"),
            8 => puts("8"),
            9 => puts("9"),
            10 => puts("A"),
            11 => puts("B"),
            12 => puts("C"),
            13 => puts("D"),
            14 => puts("E"),
            15 => puts("F"),
            else => unreachable,
        };
    }
    puts("\r\n");
}

pub fn intPrint(name: []const u8, data: usize) void {
    var vdata = data;
    var a: [10]usize = undefined;
    puts(name);
    puts("\t\t\t");
    for (0..10) |i| {
        a[9 - i] = vdata % 10;
        // std.debug.print("vdata: {}", .{vdata % 10});
        vdata /= 10;
        if (vdata == 0) {
            break;
        }
    }
    // std.debug.print("a: {any}", .{a});
    for (a) |value| {
        // std.debug.print("value: {}", .{value});
        if (value > 10) {
            continue;
        }
        _ = switch (value) {
            0 => puts("0"),
            1 => puts("1"),
            2 => puts("2"),
            3 => puts("3"),
            4 => puts("4"),
            5 => puts("5"),
            6 => puts("6"),
            7 => puts("7"),
            8 => puts("8"),
            9 => puts("9"),
            else => unreachable,
        };
    }
    puts("\r\n");
}

// 今はUSART2のみ対象
pub fn dev_init_serial(unit: u8) void {
    _ = unit;
    write(config.USART2_CR1, 0); // reset
    write(config.USART2_CR2, 0); // reset
    write(config.USART2_CR3, 0); // reset
    write(config.USART2_ICR, 0x00121BDF); // clear
    write(config.USART2_CR3, 1 << 8 | 1 << 9); // set RTS/CTS enable
    write(config.USART2_BRR, ((80 * 1000 * 1000) + 115200 / 2) / 115200); // from mtk3
    write(config.USART2_CR1, 1 << 0 | 1 << 3 | 1 << 2 | 1 << 6 | 1 << 7 | 1 << 8); // set usart, te enable
    print("-" ** 30);
    print("serial init finish.");
}

pub fn eprint(string: []const u8) void {
    print("\x1b[31m");
    defer puts("\x1b[0m");
    puts("[ERROR]\t");
    print(string);
}

// デバッグビルド時のみ機能するやつ
fn debug_print_example(data: []const u8) void {
    if (comptime dbg) {
        print(data);
    }
}
