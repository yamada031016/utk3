const config = @import("config");
const knlink = @import("knlink");
const cpu_status = knlink.sysdepend.core.cpu_status;
const devinit = knlink.sysdepend.devinit;
const inittask = knlink.inittask;
const usermain = knlink.usermain.usermain;
const TkError = @import("libtk").errno.TkError;
const hw_setting = knlink.sysdepend.hw_setting;
const syscall = @import("libtk").syscall;
const libtm = @import("libtm");

const init_task_stack: [INITTASK_STKSZ / @sizeOf(isize)]isize = [_]isize{1} ** 256;

const INITTASK_EXINF = 0x0;
const INITTASK_ITSKPRI = 10;
const INITTASK_DSNAME = "inittsk";
const INITTASK_TSKATR = if (config.USE_IMALLOC) syscall.TA_HLNG | syscall.TA_RNG0 else syscall.TA_HLNG | syscall.TA_RNG0 | syscall.TA_USERBUF;
// sspをRAM領域に置くためconstではない
var INITTASK_STACK = if (config.USE_IMALLOC) null else init_task_stack;
const INITTASK_STKSZ = 1 * 1024;

pub fn init_task_main() TkError!void {
    var fin: i32 = 1;
    libtm.log.TkLog(.info, .kernel, "inittask!", .{});
    // Start Sub-system & device driver
    if (start_system()) {
        if (comptime config.USE_SYSTEM_MESSAGE and config.USE_TMONITOR) {
            libtm.log.TkLog(.info, .kernel, "microT-Kernel Version 3.0\r\n", .{});
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
        libtm.log.TkLog(.err, .kernel, "failed to start inittask", .{});
        return err;
    }
    shutdown_system(fin); // Never return
    unreachable;
}

// if (comptime !config.USE_IMALLOC) {
// }

// Initial task creation parameter
pub const knl_init_ctsk = syscall.T_CTSK{
    // .exinf = @as(?*anyopaque, @ptrFromInt(inittask.INITTASK_EXINF))[0], // exinf
    .exinf = @as(?*anyopaque, @ptrFromInt(INITTASK_EXINF)), // exinf
    .tskatr = INITTASK_TSKATR, // tskatr
    .task = @ptrCast(@alignCast(@constCast(&init_task_main))), // task
    // .task = @as(*usize, @ptrFromInt(@intFromPtr(&init_task_main))),
    .itskpri = INITTASK_ITSKPRI, // itskpri
    .stksz = INITTASK_STKSZ, // stksz
    // .dsname = if (config.USE_OBJECT_NAME) INITTASK_DSNAME else undefined, // dsname
    .bufptr = @as(*anyopaque, @ptrCast(@constCast(&INITTASK_STACK))), // bufptr
};

// Start System
//	Start each subsystem and each device driver.
//	Return from function after starting.
fn start_system() TkError!void {
    if (config.func.USE_DEVICE) {
        // knl_initialize_devmgr() catch |err| {
        //     return err;
        // };
    }
    devinit.knl_start_device();
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
            libtm.log.TkLog(.info, .kernel, "<< SYSTEM SHUTDOWN >>", .{});
        } else {
            // Re-start sequence (platform dependent)
            hw_setting.knl_restart_hw(fin);
        }

        knlink.sysinit.knl_tkernel_exit(); // Stop system
    } else {
        cpu_status.DISABLE_INTERRUPT();
        libtm.log.TkLog(.info, .kernel, "microT-Kernel shutdown...\r\n", .{});
        while (true) {
            asm volatile ("nop");
        }
    }
}
