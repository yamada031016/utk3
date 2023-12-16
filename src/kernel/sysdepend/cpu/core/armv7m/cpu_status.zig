//cpu-dependent status definition
const knlink = @import("knlink");
const cpu_cntl = knlink.sysdepend.cpu_cntl;
const cpu_task = knlink.sysdepend.cpu_task;
const libtk = @import("libtk");
const int = libtk.sysdepend.int;
const syslib = libtk.syslib;
const cpudef = libtk.sysdepend.cpudef;

pub export var _basepri_: usize = undefined;

// Start/End critical section
pub inline fn BEGIN_CRITICAL_SECTION() void {
    _basepri_ = int.core.disint();
}

pub inline fn END_CRITICAL_SECTION() void {
    if (!syslib.core.isDI(_basepri_) and knlink.knl_ctxtsk != knlink.knl_schedtsk and !knlink.knl_dispatch_disabled) {
        cpu_cntl.knl_dispatch();
    }
    int.core.set_basepri(_basepri_);
}

// Start/End interrupt disable section */
pub inline fn BEGIN_DISABLE_INTERRUPT() void {
    _basepri_ = int.disint();
}

pub inline fn END_DISABLE_INTERRUPT() void {
    int.core.set_basepri(_basepri_);
}
// Interrupt enable/disable */
pub inline fn ENABLE_INTERRUPT() void {
    int.core.set_basepri(0);
}

pub inline fn DISABLE_INTERRUPT() void {
    _ = int.core.disint();
}

// Enable interrupt nesting
//Enable the interrupt that has a higher priority than 'level.' */
pub inline fn ENABLE_INTERRUPT_UPTO(level: isize) void {
    _ = level;
    int.core.set_basepri(0);
}

// Task-independent control */
pub var knl_taskindp: i32 = 0; // Task independent status */

// If it is the task-independent part, true */
pub inline fn knl_isTaskIndependent() bool {
    return knl_taskindp > 0;
}

// Move to/Restore task independent part */
pub inline fn knl_EnterTaskIndependent() void {
    knl_taskindp += 1;
}

pub inline fn knl_LeaveTaskIndependent() void {
    knl_taskindp -= 1;
}

// Move to/Restore task independent part */
pub inline fn ENTER_TASK_INDEPENDENT() void {
    knl_EnterTaskIndependent();
}
pub inline fn LEAVE_TASK_INDEPENDENT() void {
    knl_LeaveTaskIndependent();
}

// Check system state */

// When a system call is called from the task independent part, true */
pub inline fn in_indp() bool {
    return (knl_isTaskIndependent() or knlink.knl_ctxtsk == null);
}

// When a system call is called during dispatch disable, true
//Also include the task independent part as during dispatch disable.
pub inline fn in_ddsp() bool {
    return (knlink.knl_dispatch_disabled or in_indp() or syslib.core.isDI(int.get_basepri()));
}

// When a system call is called during CPU lock (interrupt disable), true
//Also include the task independent part as during CPU lock.
pub inline fn in_loc() bool {
    return (syslib.core.isDI(int.core.get_basepri()) or in_indp());
}

// When a system call is called during executing the quasi task part, true
//Valid only when in_indp() == false because it is not discriminated from
//the task independent part.
pub inline fn in_qtsk() bool {
    return (knlink.knl_ctxtsk.sysmode > knlink.knl_ctxtsk.isysmode);
}
