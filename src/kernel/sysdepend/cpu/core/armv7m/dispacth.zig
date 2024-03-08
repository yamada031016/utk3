const libsys = @import("libsys");
const TMP_STACK_SIZE = libsys.knldef.TMP_STACK_SIZE;
const INTPRI_VAL = libsys.sysdepend.sysdef.core.INTPRI_VAL;
const INTPRI_MAX_EXTINT_PRI = libsys.sysdepend.sysdef.cpu.INTPRI_MAX_EXTINT_PRI;
const knlink = @import("knlink");
const TCB = knlink.TCB;
const knl_lowpow_discnt = knlink.power.knl_lowpow_discnt;
const low_pow = knlink.sysdepend.cpu.power_save.low_pow;
const int = @import("libtk").sysdepend.int;
extern var knl_ctxtsk: ?*TCB;
extern var knl_schedtsk: ?*TCB;
extern var knl_dispatch_disabled: bool;
var knl_tmp_stack = knlink.sysdepend.core.cpu_cntl.knl_tmp_stack;
// extern const knl_tmp_stack: [TMP_STACK_SIZE]u8;
// const libtm = @import("libtm");
// const tm_printf = libtm.tm_printf;

const intpri = INTPRI_VAL(INTPRI_MAX_EXTINT_PRI);

pub fn knl_dispatch_entry() callconv(.Naked) void {
    @setRuntimeSafety(false);
    // tm_printf("\nknl_dispatch_entry start.\n", .{});

    knl_dispatch_disabled = true;

    if (knl_ctxtsk) |_| {
        // tm_printf("knl_ctxtsk is not NULL", .{});
        // libtm.hexPrint("ssp before:\t", @intFromPtr(knl_ctxtsk.?.tskctxb.ssp));
        var i: usize = 9;
        asm volatile (
            \\  push	{r4-r11}
            \\  push	{lr}
            // \\  str sp , %[sp]
            // :
            // : [sp] "m" (&i),
            \\ mov %[sp], sp
            : [sp] "=r" (i),
        );
        // libtm.hexPrint("i:\t", i);
        // libtm.hexPrint("i addr:\t", @intFromPtr(&i));
        knl_ctxtsk.?.tskctxb.ssp = @ptrFromInt(i);
        // libtm.hexPrint("ssp after:\t", @intFromPtr(knl_ctxtsk.?.tskctxb.ssp));
        knl_ctxtsk = null;
    }
    // else {
    var tmp_stack = @intFromPtr(&knl_tmp_stack) + TMP_STACK_SIZE;
    // var tmp_stack = @as(*usize, @ptrFromInt(@intFromPtr(&knl_tmp_stack) + TMP_STACK_SIZE));
    asm volatile (
        \\  mov	sp, %[_tmp_stack]    // Set temporal stack
        :
        : [_tmp_stack] "r" (tmp_stack),
    );
    // }

    while (true) {
        int.core.set_basepri(intpri);
        defer int.core.set_basepri(0);

        if (knl_schedtsk) |schedtsk| {
            // tm_printf("knl_schedtsk is not null", .{});
            knl_ctxtsk = schedtsk;
            var i = @intFromPtr(knl_ctxtsk.?.tskctxb.ssp);
            // libtm.hexPrint("ssp:\t", i);
            asm volatile (
                \\ mov	sp, %[ssp]	// Restore 'ssp' from TCB
                :
                : [ssp] "r" (i),
                  // \\ ldr sp, %[ssp]
                  // :
                  // : [ssp] "m" (knl_ctxtsk.?.tskctxb.ssp.*),
            );
            break; // end infinite loop
        }

        if (!knl_lowpow_discnt) {
            // This function is unimplement.
            // low_pow();
        }
    }

    // ----------------- Restore "schedtsk" context. -----------------
    // tm_printf("before restore schedtsk", .{});
    knl_dispatch_disabled = false;

    asm volatile (
        \\  pop	{lr}
        \\  pop	{r4-r11}
    );
    // tm_printf("after pop()", .{});
    @setRuntimeSafety(true);
    asm volatile (
        \\  bx	lr
    );
    // unreachable;
}
