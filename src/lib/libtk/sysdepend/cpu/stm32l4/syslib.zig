const libsys = @import("libsys");
const sysdef = libsys.sysdepend.sysdef;
//micro T-Kernel System Library  (STM32L4 depended)
//Interrupt Control */
// Interrupt number */
pub const MIN_NVIC_INTNO = 0; // Minimum value of NVIC interrupt number */
pub const MAX_NVIC_INTNO = sysdef.cpu.N_INTVEC - 1; // Maximum value of NVIC interrupt number */
pub const MIN_EXTI_INTNO = 200; // Minimum value of EXTI interrupt number */
pub const MAX_EXTI_INTNO = 239; // Maximum value of EXTO interrupt number */

// Interrupt mode ( Use SetIntMode ) */
pub const IM_EDGE = 0x0000; // Edge trigger */
pub const IM_HI = 0x0002; // Interrupt at rising edge */
pub const IM_LOW = 0x0001; // Interrupt at falling edge */
pub const IM_BOTH = 0x0003; // Interrupt at both edge */

//I/O port access
//for memory mapped I/O */

pub inline fn read(port_addr: usize) usize {
    return @as(*volatile usize, @ptrFromInt(port_addr)).*;
}

pub inline fn write(port_addr: usize, data: usize) void {
    @as(*volatile usize, @ptrFromInt(port_addr)).* = data;
}

// 値を格納したあと2Clock待つ必要があるレジスタ用
pub inline fn setReg(addr: usize, data: usize) void {
    write(addr, data);
    for (0..1000) |_| {
        asm volatile ("nop");
    }
}
