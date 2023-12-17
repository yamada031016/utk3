const knlink = @import("knlink");
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
// const cpu_status = knlink.sysdepend.cpu_status;
const TkError = @import("libtk").errno.TkError;
const interrupt = knlink.sysdepend.interrupt;

// Start micro T-Kernel
//    Initialize sequence before micro T-Kernel start.
//    Perform preparation necessary to start micro T-Kernel.
pub fn main() !void {
    errdefer |err| {
        print(@errorName(err));
        print("[ERROR] sysinit failed.");
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
        // while (true) {}
        return err;
    };

    // Interrupt initialize
    interrupt.knl_init_interrupt() catch |err| {
        print("[ERROR] knl_init_interrupt() failed.");
        // while (true) {}
        return err;
    };

    // Initialize Kernel-objects
    // この関数でおそらくメモリ関係のバグあり
    tkinit.knl_init_object() catch |err| {
        print("!ERROR! kernel object initialize\n");
        if (config.USE_SHUTDOWN) {
            hw_setting.knl_shutdown_hw(); // Hardware-dependent Finalization
        }
        // while (true) {}
        return err;
    };

    // Start System Timer
    timer.knl_timer_startup() catch |err| {
        print("!ERROR! System timer startup\n");
        if (config.USE_SHUTDOWN) {
            hw_setting.knl_shutdown_hw(); // Hardware-dependent Finalization
        }
        return err;
    };

    // Create & start initial task
    if (tskmng.tk_cre_tsk(&inittask.knl_init_ctsk)) |value| {
        if (tskmng.tk_sta_tsk(value, 0)) {
            cpu_cntl.knl_force_dispatch();
            // Start Initial Task.
            unreachable;
        } else |err| {
            print("!ERROR! Initial Task can not start");
            return err;
        }
    } else |err| {
        print("!ERROR! Initial Task can not creat");
        return err;
    }
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
