const config = @import("config");
const serial = @import("devices").serial;

pub fn knl_start_device() !void {
    if (config.USE_SDEV_DRV) {
        if (config.dev.DEVCNF_USE_SER) {
            const dummy = 1; //USART2指定
            serial.dev_init_serial(dummy) catch |err| {
                return err;
            };
        }
    }
}
