const knlink = @import("knlink");
const hw_setting = knlink.sysdepend.hw_setting;
const config = @import("config");
const sysinit = knlink.sysinit;
const VectorTable = knlink.sysdepend.vector_tbl.VectorTable;
// const inc_tk = @import("inc_tk");
// const TkError = inc_tk.errno.TkError;
const libsys = @import("libsys");
const sysdef = libsys.sysdepend.sysdef;
const TkError = @import("libtk").errno.TkError;
// const interrupt = knlink.sysdepend.interrupt;

// if (comptime  CPU_CORE_ARMV7M) {

// Low level memory manager information
pub const knl_lowmem_top: *void = undefined; // Head of area (Low address)
pub const knl_lowmem_limit: *void = undefined; // Head of area (Low address)

pub extern const __data_org: *usize;
pub extern const __data_start: *usize;
pub extern const __data_end: *usize;
pub extern const __bss_start: *usize;
pub extern const __bss_end: *usize;

// if (comptime  USE_NOINIT) {
// pub extern const __noinit_end: *void;
// }

extern const vector_tbl: VectorTable;

export fn Reset_Handler() callconv(.C) noreturn {
    comptime var i = 0;
    _ = i;

    // Startup Hardware
    hw_setting.knl_startup_hw();
    knlink.sysdepend.devinit.knl_start_device();

    if (comptime !config.USE_STATIC_IVT) {
        // Load Vector Table from ROM to RAM
        var src: *u32 = @ptrCast(@constCast(&vector_tbl));
        _ = src;
        // var top: *u32 = @ptrCast(@constCast(&interrupt.exchdr_tbl));

        // while (i < (sysdef.N_SYSVEC + sysdef.N_INTVEC)) : (i += 1) {
        // top.* += 1;
        // src.* += 1;
        // top.* = src.*;
        // }

        // Set Vector Table offset to SRAM
        // @as(*volatile u32, @ptrFromInt(sysdef.sysdepend.SCB_VTOR)).* = @as(u32, interrupt.exchdr_tbl[0]);
    }

    // Load .data to ram
    // src = @as(*u32, @ptrCast(&__data_org));
    // top = @as(*u32, @ptrCast(&__data_start));
    // var end: *u32 = @as(*u32, @ptrCast(&__data_end));
    // while (top != end) {
    //     top.* += 1;
    //     src.* += 1;
    //     top.* = src.*;
    // }

    // Initialize .bss
    if (comptime config.USE_NOINIT) {
        // top = @ptrCast(&__noinit_end);
    } else {
        // top = @as(*u32, @ptrCast(@alignCast(__bss_start)));
    }
    // i = @divExact((@as(isize, @intCast(__bss_end.*)) - @as(isize, @intCast(top.*))), @sizeOf(u32));
    // while (i > 0) : (i -= 1) {
    //     top.* += 1;
    //     top.* = 0;
    // }

    if (comptime config.USE_IMALLOC) {
        //     // Set System memory area
        //     if (INTERNAL_RAM_START > SYSTEMAREA_TOP) {
        //         knl_lowmem_top = @as(*u32, INTERNAL_RAM_START);
        //     } else {
        //         knl_lowmem_top = @as(*u32, SYSTEMAREA_TOP);
        //     }
        //     if (@as(u32, knl_lowmem_top) < @as(u32, &__bss_end)) {
        //         knl_lowmem_top = @as(*u32, &__bss_end);
        //     }
        //
        //     if ((SYSTEMAREA_END != 0) and (INTERNAL_RAM_END > CNF_SYSTEMAREA_END)) {
        //         knl_lowmem_limit = @as(*u32)(SYSTEMAREA_END - EXC_STACK_SIZE);
        //     } else {
        //         knl_lowmem_limit = @as(*u32)(INTERNAL_RAM_END - EXC_STACK_SIZE);
        //     }
    }

    // Configure exception priorities
    // var reg: u32 = @as(*volatile u32, @ptrFromInt(sysdef.sysdepend.SCB_AIRCR)).*;
    // reg = (reg & (~@as(usize, @intCast(sysdef.sysdepend.AIRCR_PRIGROUP7)))) | sysdef.sysdepend.AIRCR_PRIGROUP3; // PRIGRP:SUBisize = 4 : 4
    // @as(*volatile u32, @ptrFromInt(sysdef.sysdepend.SCB_AIRCR)).* = (reg & 0x0000FFFF) | sysdef.sysdepend.AIRCR_VECTKEY;
    //
    // @as(*volatile u32, @ptrFromInt(sysdef.sysdepend.SCB_SHPR2)).* = sysdef.sysdepend.SCB_SHPR2_VAL; // SVC pri = 0
    // @as(*volatile u32, @ptrFromInt(sysdef.sysdepend.SCB_SHPR3)).* = sysdef.sysdepend.SCB_SHPR3_VAL; // SysTick = 1 , PendSV = 7

    if (comptime config.USE_FPU) {
        //     // Enable FPU
        //     @as(*volatile u32, FPU_CPACR).* |= FPU_CPACR_FPUENABLE;
        //     @as(*volatile u32, FPU_FPCCR).* |= (FPU_FPCCR_ASPEN | FPU_FPCCR_LSPEN);
    } // USE_FPU

    // Startup Kernel
    try sysinit.main();
    unreachable;
    // while (1)
    //   ; // guard - infinite loops
}

// } // CPU_CORE_ARMV7M
