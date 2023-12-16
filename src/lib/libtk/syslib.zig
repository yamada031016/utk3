//micro T-Kernel System Library

// "typedef.h"

//System dependencies  (CPU Intrrupt contrl , I/O port access) */
// pub const SYSLIB_PATH_(a)		#a
// pub const SYSLIB_PATH(a)		SYSLIB_PATH_(a)
// pub const SYSLIB_SYSDEP()		SYSLIB_PATH(sysdepend/TARGET_DIR/syslib.h)
// const  = @import{ SYSLIB_SYSDEP()
pub const cpu = @import("sysdepend/cpu/stm32l4/syslib.zig");
pub const core = @import("sysdepend/cpu/core/armv7m/syslib.zig");

//Fast Lock */
const FastLock = struct {
    cnt: isize,
    id: isize,
    name: *const u8,
};

//Multi Lock
//Can use the maximum of 16 or 32 independent locks with a single FastMLock.
//Divided by the lock number (no). Can specify 0-15 or 0-31 for 'no.'
//(Slightly less efficient than FastLock) */
const FastMLock = struct {
    flg: usize,
    wai: isize,
    id: isize,
    name: *const u8,
};

//Physical timer */
// if (comptime  TK_SUPPORT_PTIMER) {
pub const TA_ALM_PTMR = 0;
pub const TA_CYC_PTMR = 1;

pub const T_DPTMR = struct {
    exinf: *void, // Extended Information */
    ptmratr: u32, // Physical Timer Attribute */
    ptmrhdr: isize, // Physical Timer Handler Address */
};

pub const T_RPTMR = struct {
    ptmrclk: u32, // Physical Timer Clock Frequency */
    maxcount: u32, // Maximum Count */
    defhdr: bool, // Handler Support */
};
// }

//4-character object name
//(Example)
//T_CTSK	ctsk;
//SetOBJNAME(ctsk.exinf, "TEST");
const objname = union {
    s: [4]u8,
    i: *void,
};

pub fn SetOBJNAME(exinf: *void, name: []const u8) void {
    var d: *u8 = @as(*u8, @ptrCast(&exinf));
    var s: *u8 = @as(*u8, @ptrCast(name));
    for (0..3) |_| {
        d.* += 1;
        s.* += 1;
        d.* = s.*;
    }
}
