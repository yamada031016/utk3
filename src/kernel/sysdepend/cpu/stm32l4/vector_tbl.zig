const knlink = @import("knlink");
const sysdef = @import("libsys").sysdepend.sysdef;
const print = @import("devices").serial.print;
const interrupt = knlink.sysdepend.interrupt;
// if (comptime  CPU_STM32L4) {
const knl_dispatch_entry = knlink.sysdepend.core.dispatch.knl_dispatch_entry;

pub const Handler = *const fn () callconv(.C) void;

pub fn irq_handler() callconv(.C) void {
    print("launched irq handler!");
    while (true) {
        asm volatile ("nop");
    }
}

pub fn systick_handler() callconv(.C) void {
    knlink.timer.knl_timer_handler();
    return;
}

pub fn default_handler() callconv(.C) void {
    print("launched default handler!");
    while (true) {
        asm volatile ("nop");
    }
}

pub fn nmi_handler() callconv(.C) void {
    print("launched nmi handler!");
    while (true) {
        asm volatile ("nop");
    }
}

pub fn hard_handler() callconv(.C) void {
    print("launched hard fault handler!");
    while (true) {
        asm volatile ("nop");
    }
}

pub fn mpu_handler() callconv(.C) void {
    print("launched mpu fault handler!");
    while (true) {
        asm volatile ("nop");
    }
}

pub fn bus_handler() callconv(.C) void {
    print("launched bus fault handler!");
    while (true) {
        asm volatile ("nop");
    }
}

pub fn usage_handler() callconv(.C) void {
    print("launched usage fault handler!");
    while (true) {
        asm volatile ("nop");
    }
}

pub fn svcall_handler() callconv(.C) void {
    print("launched svcall handler!");
    while (true) {
        asm volatile ("nop");
    }
}

pub fn debug_monitor_handler() callconv(.C) void {
    print("launched debug_monitor handler!");
    while (true) {
        asm volatile ("nop");
    }
}

extern fn Reset_Handler() noreturn;

pub const VectorTable = extern struct {
    top_of_stack: usize,
    reset_handler: Handler,
    nmi_handler: Handler = default_handler,
    hard_fault_handler: Handler = default_handler,
    mpu_fault_handler: Handler = default_handler,
    bus_fault_handler: Handler = default_handler,
    usage_fault_handler: Handler = default_handler,
    reserved1: [4]usize = undefined,
    svcall: Handler = default_handler,
    debug_monitor_handler: Handler = default_handler,
    reserved2: usize = undefined,
    pend_sv: *const fn () callconv(.Naked) void,
    systick: Handler,
    irq: [32]Handler = [_]Handler{irq_handler} ** 32,
};

pub export const vector_tbl: VectorTable linksection(".vector") = .{
    .top_of_stack = sysdef.cpu.INITIAL_SP,
    .reset_handler = Reset_Handler,
    .nmi_handler = nmi_handler,
    .hard_fault_handler = hard_handler,
    .mpu_fault_handler = mpu_handler,
    .bus_fault_handler = bus_handler,
    .usage_fault_handler = usage_handler,
    .svcall = svcall_handler,
    .debug_monitor_handler = debug_monitor_handler,
    .pend_sv = knl_dispatch_entry,
    .systick = systick_handler,
};
// } // CPU_STM32L4 */
