//Macro for Error Check
const config = @import("config");
const libtk = @import("libtk");
const TkError = libtk.errno.TkError;
const typedef = libtk.typedef;
const ID = typedef.ID;
const TMO = typedef.TMO;
const ATR = typedef.ATR;
const PRI = typedef.PRI;

//Check object ID range (TkError.E_ID)

// if (comptime config.CHK_ID) {
pub inline fn CHECK_TSKID(tskid: ID) TkError!void {
    if (!in_indp() and (tskid == TSK_SELF)) {
        return TkError.IncorrectObjectState;
    } else if (!CHK_TSKID(tskid)) {
        return TkError.IncorrectIdNumber;
    }
}

pub inline fn CHECK_TSKID_SELF(tskid: ID) TkError!void {
    if (!((!in_indp() and (tskid) == TSK_SELF) or CHK_TSKID(tskid))) {
        return TkError.IncorrectIdNumber;
    }
}

pub inline fn CHECK_SEMID(semid: ID) TkError!void {
    if (!CHK_SEMID(semid)) {
        return TkError.IncorrectIdNumber;
    }
}

pub inline fn CHECK_FLGID(flgid: ID) TkError!void {
    if (!CHK_FLGID(flgid)) {
        return TkError.IncorrectIdNumber;
    }
}

pub inline fn CHECK_MBXID(mbxid: ID) TkError!void {
    if (!CHK_MBXID(mbxid)) {
        return TkError.IncorrectIdNumber;
    }
}

pub inline fn CHECK_MBFID(mbfid: ID) TkError!void {
    if (!CHK_MBFID(mbfid)) {
        return TkError.IncorrectIdNumber;
    }
}

pub inline fn CHECK_PORID(porid: ID) TkError!void {
    if (!CHK_PORID(porid)) {
        return TkError.IncorrectIdNumber;
    }
}
pub inline fn CHECK_MTXID(pisid: ID) TkError!void {
    if (!CHK_MTXID(pisid)) {
        return TkError.IncorrectIdNumber;
    }
}

pub inline fn CHECK_MPLID(mplid: ID) TkError!void {
    if (!CHK_MPLID(mplid)) {
        return TkError.IncorrectIdNumber;
    }
}
pub inline fn CHECK_MPFID(mpfid: ID) TkError!void {
    if (!CHK_MPFID(mpfid)) {
        return TkError.IncorrectIdNumber;
    }
}
pub inline fn CHECK_CYCID(cycid: ID) TkError!void {
    if (!CHK_CYCID(cycid)) {
        return TkError.IncorrectIdNumber;
    }
}
pub inline fn CHECK_ALMID(almid: ID) TkError!void {
    if (!CHK_ALMID(almid)) {
        return TkError.IncorrectIdNumber;
    }
}
// } // CHK_ID
//
//Check whether its own task is specified (TkError.E_OBJ)
pub inline fn CHECK_NONSELF(tskid: ID) TkError!void {
    if (comptime config.CHK_SELF) {
        if (!in_indp() and tskid == knl_ctxtsk.tskid) {
            return TkError.IncorrectObjectState;
        }
    }
}

//Check task priority value (TkError.E_PAR)

// if (comptime config.CHK_PAR)
pub inline fn CHECK_PRI(pri: PRI) TkError!void {
    if (!CHK_PRI(pri)) {
        return TkError.ParameterError;
    }
}
pub inline fn CHECK_PRI_INI(pri: PRI) TkError!void {
    if (pri != TPRI_INI and !CHK_PRI(pri)) {
        return TkError.ParameterError;
    }
}

pub inline fn CHECK_PRI_RUN(pri: PRI) TkError!void {
    if ((pri) != TPRI_RUN and !CHK_PRI(pri)) {
        return TkError.ParameterError;
    }
}

//Check timeout specification value (TkError.E_PAR)
// if (comptime  CHK_PAR)
pub inline fn CHECK_TMOUT(tmout: TMO) TkError!void {
    if (!((tmout) >= typedef.TMO_FEVR)) {
        return TkError.ParameterError;
    }
}

pub inline fn CHECK_RELTIM(tmout: TMO) TkError!void {
    if (tmout >= 0x80000000) {
        return TkError.ParameterError;
    }
}
// }

//Check other parameter errors (TkError.E_PAR)

pub inline fn CHECK_PAR(exp: bool) TkError!void {
    if (comptime config.CHK_PAR) {
        if (!(exp)) {
            return TkError.ParameterError;
        }
    } // CHK_PAR
}

//Check reservation attribute error (TkError.E_RSu32)
pub inline fn CHECK_RSATR(atr: ATR, maxatr: isize) TkError!void {
    if (comptime config.CHK_RSATR) {
        if ((atr) & ~(maxatr)) {
            return TkError.ReservedAttribute;
        }
    } // CHK_RSu32
}

//Check unsupported function (TkError.E_NOSPT)
pub inline fn CHECK_NOSPT(exp: bool) TkError!void {
    if (comptime config.CHK_NOSPT) {
        if (!(exp)) {
            return TkError.UnsupportedFunction;
        }
    } // CHK_NOSPT
}

//Check whether task-independent part is running (TkError.E_CTX)
pub inline fn CHECK_INTSK() TkError!void {
    if (comptime config.CHK_CTX) {
        if (in_indp()) {
            return TkError.ContextError;
        }
    } // CHK_CTX
}

//Check whether dispatch is in disabled state (TkError.E_CTX)
pub inline fn CHECK_DISPATCH() TkError!void {
    if (comptime config.CHK_CTX) {
        if (in_ddsp()) {
            return TkError.ContextError;
        }
    }
    unreachable;
}

pub inline fn CHECK_DISPATCH_POL(tmout: TMO) TkError!void {
    if (comptime config.CHK_CTX) {
        if ((tmout) != typedef.TMO_POL and in_ddsp()) {
            return TkError.ContextError;
        }
    }
    unreachable;
}

//Check other context errors (TkError.E_CTX)
pub inline fn CHECK_CTX(exp: bool) TkError!void {
    if (comptime config.CHK_CTX) {
        if (!(exp)) {
            return TkError.ContextError;
        }
    }
    unreachable;
}
