const syslib = @import("libtk").syslib;
const serial = @import("devices").serial;

const builtin = @import("builtin");
const dbg = builtin.mode == .Debug;

pub fn tm_putchar(data: u8) void {
    if (comptime dbg) {
        var imask: usize = undefined;
        {
            syslib.core.DI(&imask);
            defer syslib.core.EI(imask);
            serial.put(data);
        }
    }
}

pub fn tm_putstring(string: []const u8) void {
    if (comptime dbg) {
        var imask: usize = undefined;
        {
            syslib.core.DI(&imask);
            defer syslib.core.EI(imask);
            serial.puts(string);
        }
    }
}

pub fn tm_printf(comptime string: []const u8, args: anytype) void {
    _ = args;
    if (comptime dbg) {
        tm_putstring(string);
    }
    tm_putstring("\r\n");
}

// fn format(string: []const u8, args: anytype) []const u8 {
//     const ArgsType = @TypeOf(args);
//     const args_type_info = @typeInfo(ArgsType);
//     if (args_type_info != .Struct) {
//         @compileError("expected tuple or struct argument, found " ++ @typeName(ArgsType));
//     }
//     //argsを適宜取り出すやつの予定
//     comptime var i = 0;
//     // arg_list: for (args) |arg| {
//     inline while (i < string.len) {
//         const start_index = i;
//
//         inline while (i < string.len) : (i += 1) {
//             switch (string[i]) {
//                 '{', '}' => break,
//                 else => {},
//             }
//         }
//
//         comptime var end_index = i;
//
//         if (start_index != end_index) {
//             tm_putstring(string[start_index..end_index]);
//         }
//
//         i += 1; // skip {
//
//         const fmt_start = i;
//         inline while (i < string.len and string[i] != '}') : (i += 1) {
//             asm volatile ("nop");
//         }
//         const fmt_end = i;
//
//         if (i >= string.len) @compileError("missing closing }");
//
//         i += 1; // skip }
//
//         if (string[i] == '{') {
//             switch (string[i + 1]) {
//                 '}' => {
//                     i += 1; // no specifier
//                     break;
//                 },
//                 'd' => fmtDec(arg),
//                 'x' => fmtHex(arg),
//                 's' => arg,
//                 else => unreachable,
//             }
//             for (fmt_str, 0..) |value, j| {
//                 fmt[i + j] = value;
//             }
//             i += fmt_str.len;
//             i += 2;
//             continue :arg_list;
//         }
//         fmt[i] = string[i];
//         i += 1;
//     }
//     // }
// }

fn fmtDec(decimal: usize) []u8 {
    var vdata = decimal;
    var buf: [10]usize = undefined;
    var str: [10]usize = undefined;
    for (0..127) |i| {
        buf[9 - i] = vdata % 10;
        vdata /= 10;
        if (vdata == 0)
            break;
    }
    // std.debug.print("a: {any}", .{a});
    for (buf, 0..) |value, i| {
        // std.debug.print("value: {}", .{value});
        if (value > 10) {
            continue;
        }
        switch (value) {
            0 => str[i] = '0',
            1 => str[i] = '1',
            2 => str[i] = '2',
            3 => str[i] = '3',
            4 => str[i] = '4',
            5 => str[i] = '5',
            6 => str[i] = '6',
            7 => str[i] = '7',
            8 => str[i] = '8',
            9 => str[i] = '9',
            else => unreachable,
        }
    }
    return str;
}

fn fmtHex(number: usize) []u8 {
    var vdata = number;
    var buf: [10]usize = undefined;
    var str: [10]usize = undefined;

    for (0..9) |i| {
        buf[9 - i] = vdata % 16;
        vdata /= 16;
        if (vdata == 0) break;
    }
    for (buf, 0..) |value, i| {
        if (value > 16) {
            continue;
        }
        switch (value) {
            0 => str[i] = '0',
            1 => str[i] = '1',
            2 => str[i] = '2',
            3 => str[i] = '3',
            4 => str[i] = '4',
            5 => str[i] = '5',
            6 => str[i] = '6',
            7 => str[i] = '7',
            8 => str[i] = '8',
            9 => str[i] = '9',
            10 => str[i] = 'A',
            11 => str[i] = 'B',
            12 => str[i] = 'C',
            13 => str[i] = 'D',
            14 => str[i] = 'E',
            15 => str[i] = 'F',
            else => unreachable,
        }
    }
    return str;
}

// args must be {} or {err}
pub fn tm_eprintf(string: []const u8, args: anytype) void {
    if (comptime dbg) {
        serial.print("\x1b[31m");
        defer serial.puts("\x1b[0m");
        serial.puts("[ERROR]\t");
        serial.print(string);
        if (args.len == 1) {
            serial.puts("[ERROR]\t");
            serial.print(@errorName(args[0]));
        }
    }
}
