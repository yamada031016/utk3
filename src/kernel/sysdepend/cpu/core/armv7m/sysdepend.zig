//System-Dependent local defined

// const exc_hdl = @import("exc_hdl.zig");
pub const interrupt = @import("interrupt.zig");
pub const sys_timer = @import("sys_timer.zig");
pub const cpu_cntl = @import("cpu_cntl.zig");
pub const cpu_status = @import("cpu_status.zig");
pub const offset = @import("offset.zig");
pub const cpu_task = @import("cpu_task.zig");
pub const dispatch = @import("dispacth.zig");
const SStackFrame = cpu_task.SStackFrame;

// Task context block */
pub const CTXB = struct {
    // ssp: *anyopaque, // System stack pointer */
    // sspを*SStackFrameに変換するコードがあったので最初からSStack*にした
    ssp: *SStackFrame, // System stack pointer */
};

// Control register operation */

pub inline fn knl_get_ipsr() u32 {
    var _ipsr: u32 = undefined;
    asm volatile ("mrs %[ret], ipsr"
        : [ret] "=r" (_ipsr),
    );
    return _ipsr;
}

pub inline fn knl_get_xpsr() u32 {
    var _xpsr: u32 = undefined;
    asm volatile ("mrs %[ret], xpsr"
        : [ret] "=r" (_xpsr),
    );
    return _xpsr;
}

pub inline fn knl_get_primask() u32 {
    var _primask: u32 = undefined;
    asm volatile ("mrs %[ret], primask"
        : [ret] "=r" (_primask),
    );
    return _primask;
}
