const libtk = @import("libtk");
const syslib = libtk.syslib;
const int = libtk.sysdepend.int;
const sysdef = @import("libsys").sysdepend.sysdef;
const write = syslib.cpu.write;

// * Disable interrupt for NVIC
pub fn DisableInt_nvic(intno: usize) void {
    write(sysdef.core.NVIC_ICER(intno), 0x01 << (intno % 32));
}

//  Clear interrupt for NVIC
pub fn ClearInt_nvic(intno: usize) void {
    write(sysdef.core.NVIC_ICER(intno), 0x01 << (intno % 32));
}

// Check active state for NVIC
pub fn CheckInt_nvic(intno: usize) bool {
    return (syslib.cpu.read(sysdef.core.NVIC_ICPR(intno)) & (0x01 << (intno % 32))) == 0;
}

// if (comptime  CPU_CORE_ARMV7M) {

//Interrupt controller (ARMv7-M)

//CPU Interrupt Control for ARM Cortex-M4.

//Set Base Priority register
pub fn set_basepri(intsts: u32) void {
    asm volatile ("msr basepri, %0"
        :
        : [ret] "r" (intsts),
    );
}

// Get Base Priority register
pub fn get_basepri() u32 {
    var basepri: u32 = undefined;

    asm volatile ("mrs %0, basepri"
        : [ret] "=r" (basepri),
    );
    return basepri;
}

// Disable interrupt */
pub fn disint() u32 {
    var intsts: u32 = 0;

    var maxint: u32 = sysdef.core.INTPRI_VAL(sysdef.cpu.INTPRI_MAX_EXTINT_PRI);
    asm volatile ("mrs %0, basepri"
        : [ret] "=r" (intsts),
    );
    asm volatile ("msr basepri, %0"
        :
        : [ret] "r" (maxint),
    );

    return intsts;
}

// Set Interrupt Mask Level in CPU */
pub fn SetCpuIntLevel(level: isize) void {
    set_basepri((level + 1) << (8 - sysdef.INTPRI_BITWIDTH));
}

// Get Interrupt Mask Level in CPU */
pub fn GetCpuIntLevel() isize {
    var lv: isize = @as(isize, get_basepri()) >> (8 - sysdef.INTPRI_BITWIDTH) - 1;
    return if (lv < 0) syslib.INTLEVEL_EI else lv;
}

// Interrupt controller (NVIC) Control

// Enable interrupt for NVIC */
pub fn EnableInt_nvic(intno: usize, level: isize) void {
    var imask: usize = undefined;

    syslib.DI(imask);
    defer syslib.EI(imask);
    // Set interrupt priority level. */
    write(sysdef.NVIC_IPR(intno), @as(u8, @truncate(syslib.core.INTPRI_GROUP(level, 0))));

    // Enables the specified interrupt. */
    write(sysdef.NVIC_ISER(intno), 0x01 << (intno % 32));
}

// } // CPU_CORE_ARMV7M */
