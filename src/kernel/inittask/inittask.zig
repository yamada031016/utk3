const config = @import("config");
const knlink = @import("knlink");
const devinit = knlink.sysdepend.devinit;
const inittask = knlink.inittask;
const usermain = knlink.usermain.usermain;
const TkError = @import("libtk").errno.TkError;
const print = @import("devices").serial.print;
const hw_setting = knlink.sysdepend.hw_setting;
const syscall = @import("libtk").syscall;

const INITTASK_STKSZ = 1 * 1024;

fn init_task_main() TkError!void {
    var fin: i32 = 1;
    // Start Sub-system & device driver
    if (start_system()) {
        if (comptime config.USE_SYSTEM_MESSAGE and config.USE_TMONITOR) {
            // print("\n\nmicroT-Kernel Version %x.%02x\n\n", VER_MAJOR, VER_MINOR);
            print("\n\nmicroT-Kernel Version 3.0\n\n");
        }

        // if (comptime USE_USERINIT) {
        //     // Perform user defined initialization sequence
        //     fin = (*(MAIN_FP)RI_USERINIT)(0, NULL);
        // }
        if (fin > 0) {
            fin = usermain(); // User Main Program
        }
        // if (comptime USE_USERINIT) {
        //     // Perform user defined finalization sequence
        //     (*(MAIN_FP)RI_USERINIT)(-1, NULL);
        // }
    } else |err| {
        return err;
        // SYSTEM_MESSAGE("!ERROR! Init Task start\n");	// Start message
    }
    shutdown_system(fin); // Never return
    unreachable;
}

// if (comptime !config.USE_IMALLOC) {
pub var init_task_stack: [INITTASK_STKSZ / @sizeOf(isize)]isize = undefined;
// }

// Initial task creation parameter
// pub const knl_init_ctsk = syscall.T_CTSK{
//     .exinf = @as(?*void, @ptrFromInt(inittask.INITTASK_EXINF))[0], // exinf
//     .tskatr = inittask.INITTASK_TSKATR, // tskatr
//     .task = &init_task_main, // task
//     .itskpri = inittask.INITTASK_ITSKPRI, // itskpri
//     .stksz = inittask.INITTASK_STKSZ, // stksz
//     // if (comptime USE_OBJECT_NAME){
//     // 	.dsname = INITTASK_DSNAME,		// dsname
//     //     }
//     .bufptr = @as(*void, @ptrFromInt(inittask.INITTASK_STACK)), // bufptr
// };

// Start System
//	Start each subsystem and each device driver.
//	Return from function after starting.
fn start_system() TkError!void {
    if (config.func.USE_DEVICE) {
        // knl_initialize_devmgr() catch |err| {
        //     return err;
        // };
    }
    devinit.knl_start_device() catch |err| {
        return err;
    };
}

// Stop System
//	Never return from this function.
//	fin  =	 0 : Power off
//		-1 : reset and re-start	(Reset -> Boot -> Start)
//		-2 : fast re-start		(Start)
//		-3 : Normal re-start		(Boot -> Start)
//	fin are not always supported.
fn shutdown_system(fin: i32) void {
    if (comptime config.USE_SHUTDOWN) {
        // Platform dependent finalize sequence
        devinit.knl_finish_device();

        // Shutdown message output
        if (fin >= 0) {
            print("\r\n<< SYSTEM SHUTDOWN >>");
        } else {
            // Re-start sequence (platform dependent)
            hw_setting.knl_restart_hw(fin);
        }

        // knl_tkernel_exit(); // Stop system
    } else {
        // cpu_status.DISABLE_INTERRUPT();
        while (true) {}
    }
}
