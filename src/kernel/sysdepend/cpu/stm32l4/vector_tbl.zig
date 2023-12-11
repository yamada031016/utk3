const sysdef = @import("libsys").sysdepend.sysdef;
const knlink = @import("knlink");
// const reset_hdl = knlink.sysdepend.reset_hdl;
// const exc_hdr = knlink.sysdepend.exc_hdr;
// const interrupt = knlink.sysdepend.interrupt;
// if (comptime  CPU_STM32L4) {
//Exception/Interrupt Vector Table

// const  = @import{ "kernel.h"
// const  = @import{ "../../sysdepend.h"

//Exception/Interrupt Vector Table

extern fn knl_dispatch_entry() callconv(.C) void;

pub const Handler = *const fn () callconv(.C) void;

pub fn default_handler() callconv(.C) void {
    while (true) {}
}

extern fn Reset_Handler() noreturn;

pub const VectorTable = extern struct {
    top_of_stack: u32,
    reset_handler: Handler,
    nmi_handler: Handler = default_handler,
    hard_fault_handler: Handler = default_handler,
    mpu_fault_handler: Handler = default_handler,
    bus_fault_handler: Handler = default_handler,
    usage_fault_handler: Handler = default_handler,
    reserved1: [4]u8 = undefined,
    svcall: Handler = default_handler,
    debug_monitor_handler: Handler = default_handler,
    reserved2: u8 = undefined,
    // pend_sv: Handler,
    // systick: Handler,
    irq: [32]Handler = [_]Handler{default_handler} ** 32,
};

pub export const vector_tbl: VectorTable linksection(".vector") = .{
    .top_of_stack = sysdef.INITIAL_SP,
    .reset_handler = Reset_Handler,
    // .nmi_handler = exc_hdr.NMI_Handler,
    // .hard_fault_handler = exc_hdr.HardFault_Handler,
    // .mpu_fault_handler = exc_hdr.MemManage_Handler,
    // .bus_fault_handler = exc_hdr.BusFault_Handler,
    // .usage_fault_handler = exc_hdr.UsageFault_Handler,
    // .svcall = exc_hdr.Svcall_Handler,
    // .debug_monitor_handler = exc_hdr.DebugMon_Handler,
    // .pend_sv = knl_dispatch_entry,
    // .systick = interrupt.knl_systim_inthdr,
    // .irq = [_]Handler{knlink.default_handler} ** 32,
};
// } // CPU_STM32L4 */
