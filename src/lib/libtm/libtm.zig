pub const log = @import("log.zig");

const syslib = @import("libtk").syslib;
const serial = @import("devices").serial;
const fmtNumber = @import("fmt.zig").fmtNumber;

const builtin = @import("builtin");
const dbg = builtin.mode == .Debug;

pub fn tm_printf(comptime string: []const u8, args: anytype) void {
    if (comptime dbg) {
        defer tm_putstring("\r\n");

        if (args.len != 0) {
            tm_vprintf(string, args);
        } else {
            tm_putstring(string);
        }
    }
}

inline fn containBracket(string: []const u8) bool {
    var flag = false;
    inline for (string) |char| {
        if (char == '{') {
            flag = true;
            break;
        }
    }
    return flag;
}

pub fn tm_vprintf(comptime string: []const u8, args: anytype) void {
    var last: usize = 0;

    if (!containBracket(string)) {
        tm_putstring("format string does not have {}\n");
        // @compileError("format string does not have {}");
    }

    var pos: usize = 0;
    inline for (args) |value| {
        for (string, 0..) |char, i| {
            if (pos > i) {
                continue;
            }

            if (char == '{') {
                tm_putstring(string[pos..i]);
                pos = i + 1;
                switch (@typeInfo(@TypeOf(value))) {
                    .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                        switch (string[i + 1]) {
                            '}' => {
                                const str = num2str: {
                                    var tmp: [10]u8 = undefined;
                                    for (fmtNumber(value, 'd'), 0..) |v, j| {
                                        tmp[j] = v;
                                    }
                                    break :num2str tmp;
                                };
                                tm_putstring(&str);
                            },
                            'd', 'x', 'o' => |fmtType| {
                                const str = num2str: {
                                    var tmp: [10]u8 = undefined;
                                    for (fmtNumber(value, fmtType), 0..) |v, j| {
                                        tmp[j] = v;
                                    }
                                    break :num2str tmp;
                                };
                                tm_putstring(str[0..]);
                                pos += 1;
                            },
                            else => {
                                tm_putstring("invalid format character");
                                // @compileLog("invalid format character");
                            },
                        }
                    },
                    .Pointer => |arr| {
                        switch (@typeInfo(arr.child)) {
                            .Pointer => {
                                tm_putstring(@intFromPtr(value));
                            },
                            else => |elem| {
                                _ = elem;
                                // String: *const []u8などを想定
                                switch (string[i + 1]) {
                                    's' => {
                                        tm_putstring(value);
                                        pos += 1;
                                    },
                                    '}' => tm_putstring(value),
                                    else => {
                                        tm_putstring(value);
                                        // @compileError("invalid format character");
                                    },
                                }
                            },
                        }
                    },
                    else => |_type| {
                        @compileLog("invalid type", _type);
                        @compileError("format string in tm_printf() failed.");
                    },
                }
                pos += 1; // }の分進める
                break;
            }
            last = @max(i, pos) + 1;
        }
    } else {
        // {}の後にある文字列をすべて出力
        tm_putstring(string[pos..string.len]);
    }
}

// src: std.builtin.SourceLocationとしたいが、stdはimportできないし、どうすれば？
pub fn tm_eprintf(fn_name: [:0]const u8, file: [:0]const u8, err: anyerror) void {
    if (comptime dbg) {
        tm_putstring("\x1b[31m");
        tm_printf("[ERROR]\t{} occured.\n{} in {}", .{ @errorName(err), fn_name, file });
        tm_putstring("\x1b[0m");
    }
}

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
    var imask: usize = undefined;
    {
        syslib.core.DI(&imask);
        defer syslib.core.EI(imask);

        serial.puts(string);
    }
}
