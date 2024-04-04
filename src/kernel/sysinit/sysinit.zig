const knlink = @import("knlink");
const serial = @import("devices").serial;
const print = @import("devices").serial.print;
const inittask = knlink.inittask;
const devinit = knlink.sysdepend.devinit;
const tkinit = knlink.tkinit;
const timer = knlink.timer;
const tskmng = knlink.task_manage;
const utils = @import("utils");
const write = utils.write;
const read = utils.read;
const hw_setting = knlink.sysdepend.hw_setting;
const config = @import("config");
const cpu_cntl = knlink.sysdepend.core.cpu_cntl;
const cpu_status = knlink.sysdepend.core.cpu_status;
const TkError = @import("libtk").errno.TkError;
const interrupt = knlink.sysdepend.interrupt;
const libtm = @import("libtm");

// Start micro T-Kernel
//    Initialize sequence before micro T-Kernel start.
//    Perform preparation necessary to start micro T-Kernel.
pub fn main() !noreturn {
    libtm.log.TkLog(.info, .kernel, "start SYSINIT main function.", .{});
    // errdefer |err| libtm.tm_eprintf(@src().fn_name, @src().file, err);

    cpu_status.DISABLE_INTERRUPT();

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
    try devinit.knl_init_device();

    // Interrupt initialize
    try interrupt.knl_init_interrupt();

    // Initialize Kernel-objects
    tkinit.knl_init_object() catch |err| {
        if (config.USE_SHUTDOWN) {
            hw_setting.knl_shutdown_hw(); // Hardware-dependent Finalization
        }
        return err;
    };

    // Start System Timer
    timer.knl_timer_startup() catch |err| {
        if (config.USE_SHUTDOWN) {
            hw_setting.knl_shutdown_hw(); // Hardware-dependent Finalization
        }
        return err;
    };

    libtm.log.TkLog(.info, .kernel, "sysinit time: {}", .{@import("libsys").getSystemTime()});
    // Create & start initial task
    if (tskmng.tk_cre_tsk(&inittask.knl_init_ctsk)) |tskid| {
        if (tskmng.tk_sta_tsk(tskid, 0)) {
            // Start Initial Task.
            cpu_cntl.knl_force_dispatch();
            unreachable;
        } else |err| {
            // serial.eprint("Initial Task cannot start");
            // libtm.tm_eprintf(@src().fn_name, @src().file, err);
            return err;
        }
    } else |err| {
        // serial.eprint("Initial Task cannot creat");
        // libtm.tm_eprintf(@src().fn_name, @src().file, err);
        return err;
    }

    unreachable;
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
