const libtm = @import("libtm");

const MAX_DIGIT = 10;
const SENTINEL = 255;

pub const baseNumber = enum(u8) {
    const This = @This();

    decimal = 10,
    hexadecimal = 16,
    octalNumber = 8,

    pub fn convert(format: u8) This {
        switch (format) {
            'd' => return baseNumber.decimal,
            'x' => return baseNumber.hexadecimal,
            'o' => return baseNumber.octalNumber,
            else => unreachable,
        }
    }
};

pub fn fmtNumber(target: anytype, format: u8) []u8 {
    const base = baseNumber.convert(format);

    var str: [MAX_DIGIT]u8 = num2str: {
        var tmp: [MAX_DIGIT]u8 = undefined;
        for (num2array(@intCast(target), base), 1..) |value, i| {
            if (value == SENTINEL) {
                break :num2str tmp;
            }
            tmp[MAX_DIGIT - i] = num2char(value);
        }
    };
    return &str;
}

inline fn num2char(num: usize) u8 {
    switch (num) {
        0 => return '0',
        1 => return '1',
        2 => return '2',
        3 => return '3',
        4 => return '4',
        5 => return '5',
        6 => return '6',
        7 => return '7',
        8 => return '8',
        9 => return '9',
        10 => return 'A',
        11 => return 'B',
        12 => return 'C',
        13 => return 'D',
        14 => return 'E',
        15 => return 'F',
        else => unreachable,
    }
}

inline fn num2array(number: usize, base: baseNumber) [MAX_DIGIT]u8 {
    var target = number;
    var tmp: [MAX_DIGIT]u8 = [_]u8{SENTINEL} ** MAX_DIGIT;
    for (0..MAX_DIGIT - 1) |i| {
        tmp[i] = @intCast(target % @intFromEnum(base));
        target /= @intFromEnum(base);
        if (target == 0) break;
    }

    return tmp;
}
