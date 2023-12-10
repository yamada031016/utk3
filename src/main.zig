const utils = @import("utils");
const sysdef = @import("libsys").sysdepend.sysdef;
const knlink = @import("knlink");
const write = utils.write;
const serial = @import("devices").serial;

pub export fn main() noreturn {
    knlink.sysdepend.hw_setting.knl_startup_hw();
    try knlink.sysdepend.devinit.knl_start_device();

    write(sysdef.GPIO_BSRR('A'), 1 << 5);
    serial.print("やぁ");
    while (true) {}
}

test "test" {
    const std = @import("std");
    _ = std;
}
