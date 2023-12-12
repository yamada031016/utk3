// *	Initialize micro T-Kernel objects.
const task = knlink.task;
const timer = knlink.timer;
const tstd = @import("tstd");
const knlink = @import("knlink");
const winfo = knlink.winfo;
const config = @import("config");
const cpu_task = knlink.sysdepend.cpu_task;
const cpu_status = knlink.sysdepend.cpu_status;
const cpu_ctrl = knlink.sysdepend.cpu_ctrl;
const inc_tk = @import("inc_tk");
const syscall = inc_tk.syscall;
const inc_sys = @import("inc_sys");
const knldef = inc_sys.knldef;
const sysdef = inc_sys.sysdef;
const TkError = inc_tk.errno.TkError;
const TCB = knlink.TCB;
const queue = inc_sys.queue;
const QUEUE = queue.QUEUE;
const typedef = inc_tk.typedef;
const SYSTIM = typedef.SYSTIM;
const sys_timer = knlink.sysdepend.sys_timer;

// #include "kernel.h"
// #include "timer.h"

// * Each kernel-object initialization */
pub fn knl_init_object() TkError!void {
    task.knl_task_initialize() catch |err| {
        return err;
    };
    //
    // if (comptime config.USE_SEMAPHORE) {
    //     knl_semaphore_initialize() catch |err| {
    //         return err;
    //     };
    // }
    // if (comptime config.USE_EVENTFLAG) {
    //     knl_eventflag_initialize() catch |err| {
    //         return err;
    //     };
    // }
    // if (comptime config.USE_MAILBOX) {
    //     knl_mailbox_initialize catch |err| {
    //         return err;
    //     };
    // }
    // if (comptime config.USE_MESSAGEBUFFER) {
    //     knl_messagebuffer_initialize catch |err| {
    //         return err;
    //     };
    // }
    // if (comptime (config.USE_LEGACY_API and config.USE_RENDEZVOUS)) {
    //     knl_rendezvous_initialize catch |err| {
    //         return err;
    //     };
    // }
    // if (comptime config.USE_MUTEX) {
    //     knl_mutex_initialize catch |err| {
    //         return err;
    //     };
    // }
    // if (comptime config.USE_MEMORYPOOL) {
    //     knl_memorypool_initialize catch |err| {
    //         return err;
    //     };
    // }
    // if (comptime config.USE_FIX_MEMORYPOOL) {
    //     knl_fix_memorypool_initialize catch |err| {
    //         return err;
    //     };
    // }
    // if (comptime config.USE_CYCLICHANDLER) {
    //     knl_cyclichandler_initialize catch |err| {
    //         return err;
    //     };
    // }
    // if (comptime config.USE_ALARMHANDLER) {
    //     knl_alarmhandler_initialize catch |err| {
    //         return err;
    //     };
    // }
    // return E_OK;
}
