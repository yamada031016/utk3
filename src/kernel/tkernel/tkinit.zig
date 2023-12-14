// *	Initialize micro T-Kernel objects.
const task = knlink.task;
const knlink = @import("knlink");
const config = @import("config");
const libtk = @import("libtk");
const TkError = libtk.errno.TkError;

// * Each kernel-object initialization */
pub fn knl_init_object() TkError!void {
    task.knl_task_initialize() catch |err| {
        @import("devices").serial.print("tkinit error!");
        return err;
    };

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
}
