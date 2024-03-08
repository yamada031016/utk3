const config = @import("config");
const serial = @import("devices").serial;
const TkError = @import("libtk").errno.TkError;

pub fn knl_init_device() !void {
    return;
}

pub fn knl_start_device() void {
    if (config.USE_SDEV_DRV) {
        if (config.dev.DEVCNF_USE_SER) {
            const dummy = 1; //USART2指定
            serial.dev_init_serial(dummy);
        }
    }
}

pub fn knl_finish_device() TkError!void {
    return;
}
