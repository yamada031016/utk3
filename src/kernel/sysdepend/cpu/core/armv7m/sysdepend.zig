//System-Dependent local defined

// const exc_hdl = @import("exc_hdl.zig");
pub const interrupt = @import("interrupt.zig");
pub const sys_timer = @import("sys_timer.zig");
pub const cpu_cntl = @import("cpu_cntl.zig");
pub const cpu_status = @import("cpu_status.zig");
pub const offset = @import("offset.zig");
pub const cpu_task = @import("cpu_task.zig");
const SStackFrame = cpu_task.SStackFrame;

// Task context block */
pub const CTXB = struct {
    // ssp: *anyopaque, // System stack pointer */
    // sspを*SStackFrameに変換するコードがあったので最初からSStack*にした
    ssp: *SStackFrame, // System stack pointer */
};

// Control register operation */

pub inline fn knl_get_ipsr() u32 {
    var ipsr: u32 = undefined;
    asm volatile (
        \\mrs %0,
        \\ipsr:
        // ++ "\n" ++
        \\=r(ipsr)
    );
    return ipsr;
}

pub inline fn knl_get_xpsr() u32 {
    var xpsr: u32 = undefined;
    asm volatile (
        \\mrs %0,
        \\psr:
        // ++ "\n" ++
        \\=r(xpsr)
    );
    return xpsr;
}

pub inline fn knl_get_primask() u32 {
    var primask: u32 = undefined;
    asm volatile (
        \\mrs %0,
        \\primask:
        // ++ "\n" ++
        \\=r(primask)
    );
    return primask;
}
