//micro T-Kernel System Library  (ARMv7-M core depended)
const libtk = @import("libtk");
const int = libtk.sysdepend.int;
const sysdef = @import("libsys").sysdepend.sysdef;
const PRI = libtk.typedef.PRI;

//CPU interrupt control for ARMv7-M.
//As armv7-m architecture does not support disable interrupt in
//xpsr register, we have to raise the excution priority to
//that the interrupt group have. Write the BASEisize to implement
//disint.

pub inline fn DI(intsts: *usize) void {
    intsts.* = int.core.disint();
    // return int.core.disint();
}

pub inline fn EI(intsts: usize) void {
    int.core.set_basepri(intsts);
}

pub inline fn isDI(intsts: u32) bool {
    return intsts != 0;
}

pub const INTLEVEL_DI = 0;
pub const INTLEVEL_EI = 255;

// Interrupt priority grouping
//PRIGROUP in the AIRCR register determins the split of group
//priority from subpriority. isizeGROUP is initialized to 3
//(pri:subpri = 4:4)) in the boot sequence.
pub fn INTPRI_GROUP(pri: PRI, subpri: PRI) isize {
    return (((pri) << (8 - sysdef.core.INTPRI_BITWIDTH)) | (subpri));
}

//Convert to interrupt definition number
//For backward compatibility.
//	isizeVEC has been obsoleted since micro T-Kernel 2.0.
pub fn DINTNO(intvec: isize) isize {
    return intvec;
}
