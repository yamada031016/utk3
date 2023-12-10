const config = @import("config");
const devinit = @import("knlink").sysdepend.devinit;

fn start_system() !void {
    if (config.func.USE_DEVICE) {
        // knl_initialize_devmgr() catch |err| {
        //     return err;
        // };
    }
    devinit.knl_start_device() catch |err| {
        return err;
    };
}
