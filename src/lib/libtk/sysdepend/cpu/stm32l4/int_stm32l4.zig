const sysdef = @import("libsys").sysdepend.sysdef;
const libtk = @import("libtk");
const syslib = libtk.syslib;
const int = libtk.sysdepend.int;
// if (comptime  CPU_STM32L4) {

// int_stm32l4.c
//Interrupt controller (STM32L4)

//EXTI (Extended interrupt controller) functions
fn EnableInt_exti(intno: usize, level: isize) void {
    _ = level;
    if (intno < 32) {
        @as(*volatile u32, sysdef.EXTI_IMR1).* |= @as(u32, 1 << intno);
    } else {
        @as(*volatile u32, sysdef.EXTI_IMR2).* |= @as(u32, 1 << (intno - 32));
    }
}

fn DisableInt_exti(intno: usize) void {
    if (intno < 32) {
        @as(*volatile u32, sysdef.EXTI_IMR1).* &= @as(u32, 1 << intno);
    } else {
        @as(*volatile u32, sysdef.EXTI_IMR2).* &= @as(u32, 1 << (intno - 32));
    }
}

fn ClearInt_exti(intno: usize) void {
    if (intno < 32) {
        @as(*volatile u32, sysdef.EXTI_PR1).* |= @as(u32, 1 << intno);
    } else {
        @as(*volatile u32, sysdef.EXTI_PR2).* |= @as(u32, 1 << (intno - 32));
    }
}

fn CheckInt_exti(intno: usize) bool {
    var pif: u32 = undefined;

    if (intno < 32) {
        pif = @as(*volatile u32, sysdef.EXTI_PR1).* & @as(u32, 1 << intno);
    } else {
        pif = @as(*volatile u32, sysdef.EXTI_PR2).* & @as(u32, intno - 32);
    }
    return if (pif) true else false;
}

fn SetIntMode_exti(intno: usize, mode: usize) void {
    if (mode & syslib.IM_HI) {
        if (intno < 32) {
            @as(*volatile u32, sysdef.EXTI_RTSR1).* |= @as(u32, 1 << intno);
        } else {
            @as(*volatile u32, sysdef.EXTI_RTSR2).* |= @as(u32, intno - 32);
        }
    }
    if (mode & syslib.IM_LOW) {
        if (intno < 32) {
            @as(*volatile u32, sysdef.EXTI_FTSR1).* |= @as(u32, 1 << intno);
        } else {
            @as(*volatile u32, sysdef.EXTI_FTSR2).* |= @as(u32, intno - 32);
        }
    }
}

// Interrupt control API
// Enable interrupt */
pub fn EnableInt(intno: usize, level: isize) void {
    if (intno <= syslib.MAX_NVIC_INTNO) {
        int.EnableInt_nvic(intno, level);
    } else if (intno >= syslib.MIN_EXTI_INTNO and intno <= syslib.MAX_EXTI_INTNO) {
        EnableInt_exti(intno - syslib.MIN_EXTI_INTNO, level);
    }
}

// Disable interrupt */
pub fn DisableInt(intno: usize) void {
    if (intno <= syslib.MAX_NVIC_INTNO) {
        int.DisableInt_nvic(intno);
    } else if (intno >= syslib.MIN_EXTI_INTNO and intno <= syslib.MAX_EXTI_INTNO) {
        DisableInt_exti(intno - syslib.MIN_EXTI_INTNO);
    }
}

// Clear interrupt */
pub fn ClearInt(intno: usize) void {
    if (intno <= syslib.MAX_NVIC_INTNO) {
        int.ClearInt_nvic(intno);
    } else if (intno >= syslib.MIN_EXTI_INTNO and intno <= syslib.MAX_EXTI_INTNO) {
        ClearInt_exti(intno - syslib.MIN_EXTI_INTNO);
    }
}

// Issue EOI to interrupt controller */
pub fn EndOfInt(intno: usize) void {
    _ = intno;
    // No opetarion. */
    return;
}

// Check active state */
pub fn CheckInt(intno: usize) bool {
    var rtncd: bool = undefined;

    if (intno <= syslib.MAX_NVIC_INTNO) {
        rtncd = int.CheckInt_nvic(intno);
    } else if (intno >= syslib.MIN_EXTI_INTNO and intno <= syslib.MAX_EXTI_INTNO) {
        rtncd = CheckInt_exti(intno - syslib.MIN_EXTI_INTNO);
    } else {
        rtncd = false;
    }
    return rtncd;
}

// Set interrupt mode */
pub fn SetIntMode(intno: usize, mode: usize) void {
    if (intno >= syslib.MIN_EXTI_INTNO and intno <= syslib.MAX_EXTI_INTNO) {
        SetIntMode_exti(intno - syslib.MIN_EXTI_INTNO, mode);
    }
}
// } // CPU_STM32L4 */
