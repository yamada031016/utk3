const knlink = @import("knlink");
const hw_setting = knlink.sysdepend.hw_setting;
const config = @import("config");
const sysinit = knlink.sysinit;
const VectorTable = knlink.sysdepend.vector_tbl.VectorTable;
const libsys = @import("libsys");
const sysdef = libsys.sysdepend.sysdef;
const TkError = @import("libtk").errno.TkError;
const interrupt = knlink.sysdepend.interrupt;
const print = @import("devices").serial.print;
const serial = @import("devices").serial;
const hexdump = serial.hexdump;
const intPrint = serial.intPrint;

const builtin = @import("builtin");
const dbg = builtin.mode == .Debug;

// if (comptime  CPU_CORE_ARMV7M) {
extern const __start: usize;
extern const __data_org: usize;
extern const __data_start: usize;
extern const __data_end: usize;
extern const __bss_start: usize;
extern const __bss_end: usize;

// if (comptime  USE_NOINIT) {
// pub extern const __noinit_end: *void;
// }

extern const vector_tbl: VectorTable;
// extern const __vector_org: usize;

export fn Reset_Handler() callconv(.C) noreturn {
    // Startup Hardware
    hw_setting.knl_startup_hw();
    if (dbg) {
        // knlink.sysdepend.devinit.knl_start_device();
    }

    if (comptime !config.USE_STATIC_IVT) {
        // Load Vector Table from ROM to RAM
        var src: *volatile usize = @as(*volatile usize, @ptrCast(@constCast((&vector_tbl))));
        var top: *volatile usize = @ptrFromInt(0x2000_0000);

        // for (0..sysdef.cpu.N_SYSVEC + sysdef.cpu.N_INTVEC) |_| {
        for (0..@sizeOf(VectorTable)) |_| {
            // *top++ = *src++;
            top.* = src.*;
            top = @ptrFromInt(@intFromPtr(top) + @sizeOf(usize));
            src = @ptrFromInt(@intFromPtr(src) + @sizeOf(usize));
        }

        // Set Vector Table offset to SRAM
        // @as(*volatile usize, @ptrFromInt(sysdef.core.SCB_VTOR)).* = interrupt.exchdr_tbl[0];
        // あってんのかこれで
        @as(*volatile usize, @ptrFromInt(sysdef.core.SCB_VTOR)).* = @intFromPtr(&vector_tbl);
    }

    // Load .data to ram
    var data_src = @as(*volatile usize, @ptrCast(&__data_org));
    var data_top = @as(*volatile usize, @ptrCast(&__data_start));
    var data_end: *volatile usize = @as(*volatile usize, @ptrCast(&__data_end));

    // hexdump("&__start", @intFromPtr(&__start));
    hexdump("&__data_org", @intFromPtr(&__data_org));
    // hexdump("data_src", @intFromPtr(data_src));
    // hexdump("&__data_start", @intFromPtr(&__data_start));
    // hexdump("&__data_end", @intFromPtr(&__data_end));
    // hexdump("&__bss_start", @intFromPtr(&__bss_start));
    // hexdump("&__bss_end", @intFromPtr(&__bss_end));

    // hexdump("data_src", data_src.*);
    // hexdump("before data_end", data_end.*);
    // hexdump("before data_top addr", @intFromPtr(data_top));
    // hexdump("before data_end addr", @intFromPtr(data_end));
    while (data_top != data_end) {
        // *top++ = *src++;
        data_top.* = data_src.*;
        data_top = @ptrFromInt(@intFromPtr(data_top) + @sizeOf(usize));
        data_src = @ptrFromInt(@intFromPtr(data_src) + @sizeOf(usize));
        // hexdump("data_top", @intFromPtr(data_top));
        // hexdump("data_src", @intFromPtr(data_src));
    } else {
        // hexdump("after data_src", data_src.*);
        // hexdump("after data_top", data_top.*);
        // hexdump("after data_end", data_end.*);
        // hexdump("after data_top addr", @intFromPtr(data_top));
        // hexdump("after data_end addr", @intFromPtr(data_end));
    }
    print("\x1b[32m<>Reset_Handler!!!\x1b[0m");

    // Initialize .bss
    // if (comptime config.USE_NOINIT) {
    // top = @ptrCast(&__noinit_end);
    // } else {
    var bss_top = @as(*volatile usize, @ptrCast(&__bss_start));
    // hexdump("__bss_start", @intFromPtr(&__bss_start));
    // hexdump("__bss_end", @intFromPtr(&__bss_end));
    // }
    var i = @intFromPtr(&__bss_end) - @intFromPtr(bss_top);
    i /= 8;
    // hexdump("i", @truncate(i / 4));
    // hexdump("i", i);
    while (i > 0) : (i -= 1) {
        // bss_top = @ptrFromInt(@intFromPtr(bss_top) + @sizeOf(usize));
        bss_top = @ptrFromInt(@intFromPtr(bss_top) + 8);
        bss_top.* = 0;
    }

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
    sysinit.main() catch |err| {
        // errをごまかす苦肉の策
        switch (err) {
            else => serial.eprint("Reset Handler failed."),
        }
    };
    unreachable;
}

// } // CPU_CORE_ARMV7M
