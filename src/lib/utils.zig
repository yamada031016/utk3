pub inline fn read(port_addr: usize) usize {
    return @as(*volatile usize, @ptrFromInt(port_addr)).*;
}

pub inline fn write(port_addr: usize, data: usize) void {
    @as(*volatile usize, @ptrFromInt(port_addr)).* = data;
}

// 値を格納したあと2Clock待つ必要があるレジスタ用
pub inline fn setReg(addr: usize, data: usize) void {
    write(addr, data);
    for (0..1000) |_| {}
}
