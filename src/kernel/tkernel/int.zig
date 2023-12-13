// *	Interrupt Control
const knlink = @import("knlink");
const inc_sys = @import("inc_sys");
const libtk = @import("libtk");
const TkError = libtk.errno.TkError;
const check = knlink.check;
const config = @import("config");
const knldef = inc_sys.knldef;
const syscall = libtk.syscall;
// const T_DEVREQ = syscall.T_DEVREQ;
const cpu_status = knlink.sysdepend.cpu_status;
const sysdef = inc_sys.sysdef;
const interrupt = knlink.sysdepend.interrupt;

// * Interrupt handler definition
pub fn tk_def_int(intno: usize, pk_dint: *const syscall.T_DINT) TkError!void {
    if (comptime config.USE_STATIC_IVT) {
        return TkError.UnsupportedFunction;
    } else {
        var intatr: u32 = 0;
        var inthdr: ?isize = null;

        check.CHECK_PAR(intno < sysdef.N_INTVEC);
        if (pk_dint != null) {
            check.CHECK_RSATR(pk_dint.intatr, syscall.TA_HLNG | syscall.TA_ASM);
            intatr = pk_dint.intatr;
            inthdr = pk_dint.inthdr;
        }
        {
            cpu_status.BEGIN_CRITICAL_SECTION();
            defer cpu_status.END_CRITICAL_SECTION();
            try interrupt.knl_define_inthdr(intno, intatr, inthdr);
        }
    }
}

// * return Interrupt handler
pub fn tk_ret_int() void {
    interrupt.knl_return_inthdr();
}
