const libsys = @import("libsys");
const TMP_STACK_SIZE = libsys.knldef.TMP_STACK_SIZE;
const INTPRI_VAL = libsys.sysdepend.sysdef.core.INTPRI_VAL;
const INTPRI_MAX_EXTINT_PRI = libsys.sysdepend.sysdef.cpu.INTPRI_MAX_EXTINT_PRI;
const knlink = @import("knlink");
const TCB = knlink.TCB;
const knl_lowpow_discnt = knlink.power.knl_lowpow_discnt;
const low_pow = knlink.sysdepend.cpu.power_save.low_pow;
const int = @import("libtk").sysdepend.int;
extern const knl_ctxtsk: ?*TCB;
extern var knl_schedtsk: ?*TCB;
extern const TCB_tskctxb: usize;
extern const TCB_tskatr: usize;
extern var knl_dispatch_disabled: bool;
// const knl_tmp_stack = knlink.sysdepend.core.cpu_cntl.knl_tmp_stack;
extern const knl_tmp_stack: [TMP_STACK_SIZE]u8;
const print = @import("devices").serial.print;

const intpri = INTPRI_VAL(INTPRI_MAX_EXTINT_PRI);

pub fn knl_dispatch_entry() callconv(.C) void {
    print("launched Pend SV Handler");
    print("knl_dispatch_entry start.");
    defer print("knl_dispatch_entry end.");

    knl_dispatch_disabled = true;
    const tmp_stack = @as(*volatile usize, @ptrFromInt(@intFromPtr(&knl_tmp_stack) + TMP_STACK_SIZE));

    asm volatile (
        \\.code 16
        \\.syntax unified
        \\.thumb
        \\.text
        \\.align 2
    );

    print("before save ctxtsk context");
    if (knl_ctxtsk != null) {
        print("knl_ctxtsk is not NULL");
        asm volatile (
            \\  push	{r4-r11,lr}
            // \\  push	{lr}
            // \\  str	sp, [r1], #(TCB_tskctxb + CTXB_ssp)	// Save 'ssp' to TCB
            \\  str	sp, %[ssp] // Save ssp to TCB
            :
            : [ssp] "m" (knl_ctxtsk.?.tskctxb.ssp.*),
              // \\  str	sp, [%[ssp]] // Save ssp to TCB
              // :
              // : [ssp] "{r0}" (knl_ctxtsk.?.tskctxb.ssp),
        );
        knl_ctxtsk = null;
    }

    print("before set tmp_stack");
    asm volatile (
        \\  ldr	sp, %[_tmp_stack]    // Set temporal stack
        :
        : [_tmp_stack] "m" (tmp_stack.*),
    );

    int.core.set_basepri(intpri);

    print("before dispatch ctxtsk to schedtsk");
    if (knl_schedtsk != null) {
        print("knl_schedtsk is not null");
        knl_ctxtsk = knl_schedtsk;
        asm volatile (
            \\  ldr	sp, %[ssp] // Restore ssp from TCB
            :
            : [ssp] "m" (knl_schedtsk.?.tskctxb.ssp.*),
        );
    }

    print("before low_pow()");
    if (!knl_lowpow_discnt) {
        print("execute low_pow()");
        // This function is unimplement.
        low_pow();
    }
    int.core.set_basepri(0);

    // /*----------------- Restore "schedtsk" context. -----------------*/
    print("before restore schedtsk context");
    knl_dispatch_disabled = false;
    // int.core.set_basepri(0);
    asm volatile (
    // \\  pop	{lr}
        \\  pop	{r4-r11,lr}
        \\  bx	lr
        // \\ bx %[task]
        // :
        // : [task] "r" (knl_ctxtsk.?.tskctxb.ssp.pc.?),
    );
}
