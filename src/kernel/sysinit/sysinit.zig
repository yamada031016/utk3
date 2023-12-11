const knlink = @import("knlink");
const print = @import("devices").serial.print;
// const inittask = knlink.inittask;
const devinit = knlink.sysdepend.devinit;
// const tkinit = knlink.tkinit;
// const timer = knlink.timer;
// const task_manage = knlink.tskmng;
const utils = @import("utils");
const write = utils.write;
const read = utils.read;
const hw_setting = knlink.sysdepend.hw_setting;
const config = @import("config");
// const cpu_ctrl = knlink.sysdepend.cpu_ctrl;
// const cpu_status = knlink.sysdepend.cpu_status;
const TkError = @import("libtk").errno.TkError;
// const interrupt = knlink.sysdepend.interrupt;

// Start micro T-Kernel
//    Initialize sequence before micro T-Kernel start.
//    Perform preparation necessary to start micro T-Kernel.
pub fn main() !void {
    errdefer |err| {
        print("[ERROR] sysinit failed.");
        print(@errorName(err));
    }
    // cpu_status.DISABLE_INTERRUPT();

    if (comptime config.USE_TMONITOR) {
        // // Initialize T-Monitor Compatible Library
        // libtm_init();
    }

    if (comptime config.USE_IMALLOC) {
        // // Initialize Internal memory allocation (Imalloc)
        // knl_init_Imalloc() catch |err| {
        //            // SYSTEM_MESSAGE("!ERROR! init_Imalloc\n");
        //     while(true){}
        //     return 0;
        //        };
    }

    // Initialize Device before micro T-Kernel starts
    devinit.knl_init_device() catch |err| {
        print("[ERROR] knl_init_device() failed.");
        while (true) {}
        return err;
    };

    // Interrupt initialize
    // interrupt.knl_init_interrupt() catch |err| {
    //     // SYSTEM_MESSAGE("!ERROR! init_initialize\n");
    //     while (true) {}
    //     return err;
    // };

    // Initialize Kernel-objects
    // tkinit.knl_init_object() catch |err| {
    // SYSTEM_MESSAGE("!ERROR! kernel object initialize\n");
    // if (USE_SHUTDOWN) {
    //     knl_shutdown_hw();
    // }
    //     return err;
    // };

    // Start System Timer
    // timer.knl_timer_startup() catch |err| {
    //     return err;
    // SYSTEM_MESSAGE("!ERROR! System timer startup\n");
    // if (USE_SHUTDOWN) {
    //     knl_shutdown_hw();
    // }
    // };

    // Create & start initial task
    // if (task_manage.tk_cre_tsk(&inittask.knl_init_ctsk)) |value| {
    //     if (task_manage.tk_sta_tsk(value, 0)) {
    //         cpu_cntl.knl_force_dispatch();
    //         // Start Initial Task.
    //         unreachable;
    //     } else |err| {
    //         return err;
    //         // SYSTEM_MESSAGE("!ERROR! Initial Task can not start\n");
    //     }
    // } else |err| {
    //     return err;
    //     // SYSTEM_MESSAGE("!ERROR! Initial Task can not creat\n");
    // }
    // After this, Error handling

    print("SYSINIT main function!");
}
// Exit micro T-Kernel from Initial Task.
pub fn knl_tkernel_exit() TkError!noreturn {
    if (comptime config.USE_SHUTDOWN) {
        // knl_timer_shutdown(); // Stop System timer
        hw_setting.knl_shutdown_hw(); // Hardware-dependent Finalization
        unreachable;
    }
    return TkError.UnsupportedFunction;
}
