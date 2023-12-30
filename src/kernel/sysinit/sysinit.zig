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

// Start micro T-Kernel
//    Initialize sequence before micro T-Kernel start.
//    Perform preparation necessary to start micro T-Kernel.
pub fn main() !void {
    print("\x1b[32m<>SYSINIT main function.\x1b[0m");
    errdefer |err| {
        serial.eprint(@errorName(err));
        serial.eprint("sysinit failed.");
    }
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
    devinit.knl_init_device() catch |err| {
        serial.eprint("knl_init_device() failed.");
        return err;
    };

    // Interrupt initialize
    interrupt.knl_init_interrupt() catch |err| {
        serial.eprint("knl_init_interrupt() failed.");
        return err;
    };

    // Initialize Kernel-objects
    tkinit.knl_init_object() catch |err| {
        serial.eprint("kernel object initialize");
        if (config.USE_SHUTDOWN) {
            hw_setting.knl_shutdown_hw(); // Hardware-dependent Finalization
        }
        return err;
    };

    // Start System Timer
    timer.knl_timer_startup() catch |err| {
        serial.eprint("System timer startup");
        if (config.USE_SHUTDOWN) {
            hw_setting.knl_shutdown_hw(); // Hardware-dependent Finalization
        }
        return err;
    };

    // Create & start initial task
    if (tskmng.tk_cre_tsk(&inittask.knl_init_ctsk)) |tskid| {
        if (tskmng.tk_sta_tsk(tskid, 0)) {
            cpu_cntl.knl_force_dispatch();
            // Start Initial Task.
            unreachable;
        } else |err| {
            serial.eprint("Initial Task can not start");
            return err;
        }
    } else |err| {
        serial.eprint("Initial Task can not creat");
        return err;
    }

    // After this, Error handling
    while (true) {}
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
