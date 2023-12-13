pub const sysdepend = @import("sysdepend/sysdepend.zig");
pub const sysinit = @import("sysinit/sysinit.zig");
pub const tstd = @import("tstdlib/tstdlib.zig");
// pub const mutex = @import("tkernel/mutex.zig");
// pub const timer = @import("tkernel/timer.zig");
// pub const winfo = @import("tkernel/winfo.zig");
// pub const task = @import("tkernel/task.zig");
// pub const int = @import("tkernel/int.zig");
// pub const check = @import("tkernel/check.zig");
// pub const klock = @import("tkernel/klock.zig");
// pub const memory = @import("tkernel/memory.zig");
// pub const rdy_que = @import("tkernel/ready_queue.zig");
// pub const sysmgr = @import("tkernel/sysmgr.zig");
// pub const tskmng = @import("tkernel/task_manage.zig");
// pub const tsksync = @import("tkernel/task_sync.zig");
// pub const timer_calls = @import("tkernel/time_calls.zig");
// pub const tkinit = @import("tkernel/tkinit.zig");
// pub const wait = @import("tkernel/wait.zig");

pub const TCB = struct {
    // tskque: QUEUE, // Task queue */
    tskid: isize, // Task isize */
    exinf: *void, // Extended information */
    tskatr: u32, // Task attribute */
    task: isize, // Task startup address */
    // tskctxb: sysdepend.sysdepend.CTXB, // Task context block */
    sstksz: i32, // stack size */

    isysmode: i8, // Task operation mode initial value */
    sysmode: i16, // Task operation mode, quasi task part call level */

    ipriority: u8, // Priority at task startup */
    bpriority: u8, // Base priority */
    priority: u8, // Current priority */

    // u8 //TSTAT*/ state; // Task state (Int. expression) */

    klockwait: bool = true, // true at wait kernel lock */
    klocked: bool = true, // true at hold kernel lock */

    // wspec: *const winfo.WSPEC, // Wait specification */
    wid: isize, // Wait object isize */
    wupcnt: isize, // Number of wakeup requests queuing */
    suscnt: isize, // Number of SUSPEND request nests */
    // wercd: inc_tk.errno.TkError, // Wait error code set area */
    // winfo: winfo.WINFO, // Wait information */
    // wtmeb: timer.TMEB, // Wait timer event block */

    isstack: *void, // stack pointer initial value */

    // if (comptime (USE_LEGACY_API and USE_RENDEZVOUS)){
    //     wrdvno: RNO, // For creating rendezvous number */
    // }
    // if (comptime USE_MUTEX) {
    //     mtxlist: *MTXCB, // List of hold mutexes */
    // }
    // if (comptime USE_DBGSPT and @hasDecl((config, "USE_FUNC_TD_INF_TSK")) {
    //     stime: u32, // System execution time (ms) */
    //     utime: u32, // User execution time (ms) */
    // }
    // if (comptime USE_OBJECT_NAME) {
    //     name: [OBJECT_NAME_LENGTH]const u8; // name */
    // }
};
pub export var knl_ctxtsk: ?*TCB = null;
pub export var knl_schedtsk: ?*TCB = null;

pub const DDS_ENABLE = 0;
pub const DDS_DISABLE_IMPLICIT = -1; // set with implicit process */
pub const DDS_DISABLE = 2; // set by tk_dis_dsp() */
pub export var knl_dispatch_disabled: bool = false;

pub const CHAR_BIT = 8;
pub const SCHAR_MIN = -128;
pub const SCHAR_MAX = 127;
pub const UCHAR_MAX = 255;
pub const CHAR_MIN = SCHAR_MIN;
pub const CHAR_MAX = SCHAR_MAX;
pub const MB_LEN_MAX = 2;

pub const SHRT_MIN = -32768;
pub const SHRT_MAX = 32767;
pub const USHRT_MAX = 65535;

pub const LONG_MIN = 2147483648;
pub const LONG_MAX = 2147483647;
pub const ULONG_MAX = 4294967295;

pub const INT_MIN = if (@sizeOf(isize) == 16) SHRT_MIN else LONG_MIN;
pub const INT_MAX = if (@sizeOf(isize) == 16) SHRT_MAX else LONG_MAX;
pub const UINT_MAX = if (@sizeOf(isize) == 16) USHRT_MAX else ULONG_MAX;
