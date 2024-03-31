pub const sysdepend = @import("sysdepend/sysdepend.zig");
pub const machine = @import("machine.zig");
pub const queue = @import("queue.zig");
pub const knldef = @import("knldef.zig");
const libtm = @import("libtm");
const tm_printf = libtm.tm_printf;

extern const __data_start: usize;
extern const __rom_end: usize;
extern const __end: usize;

pub fn printMemoryUsage() void {
    const rom_usage = getRomUsage();
    const ram_usage = getRamUsage();
    tm_printf("total\t(byte)", .{ram_usage + rom_usage});
    tm_printf("rom\t(byte)", .{rom_usage});
    tm_printf("ram\t(byte)", .{ram_usage});
}

pub fn getRomUsage() usize {
    return (@intFromPtr(&__rom_end) - 0x0800_0000) / 8;
}

pub fn getRamUsage() usize {
    return (@intFromPtr(&__end) - @intFromPtr(&__data_start)) / 8;
}

pub fn printSystemTime() void {
    tm_printf("time:", .{getSystemTime()});
}
pub fn getSystemTime() usize {
    return @import("libtk").syslib.cpu.read(@intFromEnum(@import("libsys").sysdepend.sysdef.TIM16.CNT));
}
