//Hardware-Dependent System Timer (SysTick) Processing
const config = @import("config");
const libsys = @import("libsys");
const knldef = libsys.knldef;
const sysdef = libsys.sysdepend.sysdef;
const write = syslib.cpu.write;
const read = syslib.cpu.read;
const knlink = @import("knlink");
const hw_setting = knlink.sysdepend.hw_setting;
const syslib = libtk.syslib;
const libtk = @import("libtk");
const TkError = libtk.errno.TkError;
const interrupt = knlink.sysdepend.interrupt;

//Timer start processing
//Initialize the timer and start the periodical timer interrupt. */
pub inline fn knl_start_hw_timer() void {
    var imask: usize = 0;

    syslib.core.DI(&imask);
    defer syslib.core.EI(imask);

    // Set System timer CLK source to Core, Systick exception enable */
    write(sysdef.core.SYST_CSR, 0x00000006);

    // Set counter: TMCLK(MHz) */
    var n = @as(usize, @intCast(knldef.TIMER_PERIOD * sysdef.TMCLK_KHz - 1));
    write(sysdef.core.SYST_RVR, n);

    // Start timer count
    write(sysdef.core.SYST_CSR, 0x00000007);
}

//Clear timer interrupt
//Clear the timer interrupt request. Depending on the type of
//hardware, there are two timings for clearing: at the beginning
//and the end of the interrupt handler.
//'clear_hw_timer_interrupt()' is called at the beginning of the
//timer interrupt handler.
//'end_of_hw_timer_interrupt()' is called at the end of the timer
//interrupt handler.
//Use either or both according to hardware.
pub inline fn knl_clear_hw_timer_interrupt() void {
    _ = read(sysdef.core.SYST_CSR); // Clear COUNTFLAG */
    write(sysdef.core.SCB_ICSR, sysdef.core.ICSR_PENDSTCLR);
}

pub inline fn knl_end_of_hw_timer_interrupt() void {
    // No processing */
    return;
}

//Timer stop processing
//Stop the timer operation.
//Called when system stops.
pub inline fn knl_terminate_hw_timer() void {
    // Timer interrupt disable */
    write(sysdef.core.SYST_CSR, 0x00000000);
}

//Get processing time from the previous timer interrupt to the
//current (nanosecond)
//Consider the possibility that the timer interrupt occurred
//during the interrupt disable and calculate the processing time
//within the following
//range: 0 <= Processing time < TIMER_PERIOD//2
pub inline fn knl_get_hw_timer_nsec() u32 {
    var imask: usize = undefined;

    syslib.core.DI(&imask);
    defer syslib.core.EI(imask);
    var max: u32 = read(sysdef.core.SYST_RVR); // Setting count */
    var unf: u32 = read(sysdef.core.SYST_CSR) & 0x10000; // COUNTFLAG */
    var ofs: u32 = read(sysdef.core.SYST_CVR) & 0x00ffffff; // Current Remained count */
    if (unf == 0) { // Reload not occurred */
        unf = read(sysdef.core.SYST_CSR) & 0x10000; // Check COUNTFLAG again */
        if (unf != 0) { // Reload occurred */
            ofs = read(sysdef.core.SYST_CVR) & 0x00ffffff;
        }
    }
    ofs = max - ofs; // Elapsed count */
    if (unf != 0) ofs += max + 1; // Reload occured, Adjust */

    return @as(u32, ((@as(i64, ofs) * 1000000) / sysdef.TMCLK_KHz));
}
