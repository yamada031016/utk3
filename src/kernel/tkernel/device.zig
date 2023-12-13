//Device Management Function
const config = @import("config");
const knlink = @import("knlink");
const libtk = @import("libtk");
const TkError = libtk.errno.TkError;
const ID = libtk.typedef.ID;
const tstd = knlink.tstd;
// const tstd = knlink.tstdlib;
// const sysmgr = knlink.sysmgr;
// const DevCB = sysmgr.DevCB;
// const knldef = @import("inc_sys").knldef;
// const cpu_status = knlink.sysdepend.cpu_status;
// const inc_tk = @import("inc_tk");
// const TkError = inc_tk.errno.TkError;
// const syscall = inc_tk.syscall;
// const T_DEVREQ = syscall.T_DEVREQ;

// if ( comptime config.USE_DEVICE) {

// // Set Object Name in .exinf for DEBUG */
pub const OBJNAME_DMMBF = "DEvt"; // Event notification mbf */
pub const OBJNAME_DMSEM = "DMSy"; // semaphore of synchronous control */
pub const OBJNAME_DMLOCK = "DMLk"; // Multi-lock for Dev.Mgr. */

// extern const knl_DefaultIDev: T_IDEV;

//Device registration managemen

// extern const knl_DevCBtbl: []DevCB; // Device registration information table *////
// extern const knl_UsedDevCB: QUEUE; // In-use queue *////
// extern const knl_FreeDevCB: QUEUE; // Unused queue *////

pub const MAX_UNIT = 255; // Maximum number of subunits */

//Verify validity of device ID
inline fn knl_check_devid(devid: ID) TkError!void {
    if (comptime config.USE_DEVICE) {
        devid >>= 8;
        if (devid < 1 or devid > knldef.MAX_REGDEV) {
            return TkError.IncorrectIdNumber;
        }
    }
}

//Device Management: Input/Output
// pub const OpnCB knl_OpnCBtbl[]; // Open management information table */
// pub const QUEUE knl_FreeOpnCB;  // Unused queue */

pub inline fn DD(opncb: OpnCB) isize {
    return opncb - knl_OpnCBtbl + 1;
}
pub inline fn OPNCB(dd: isize) isize {
    return knl_OpnCBtbl + (dd - 1);
}

//         pub const ReqCB knl_ReqCBtbl[]; // Request management information table */
// pub const QUEUE knl_FreeReqCB;          // Unused queue */

pub inline fn REQID(reqcb: ReqCB) isize {
    return reqcb - knl_ReqCBtbl + 1;
}
pub inline fn REQCB(reqid: ID) isize {
    return knl_ReqCBtbl + reqid - 1;
}

//         pub const DEVREQ_REQCB(devreq)((ReqCB *)((B *)(devreq)-offsetof(ReqCB, req)))
//         pub const ResCB knl_resource_control_block;

// Suspend disable request count */
// pub const isize knl_DisSusCnt;

// Maximum number of suspend disable request counts */
pub const MAX_DISSUS = INT_MAX;
//Device driver abort function call
inline fn knl_call_abortfn(devcb: *DevCB, tskid: ID, devreq: *T_DEVREQ, nreq: isize) TkError!void {
    var abortfn: *const fn (taskid: isize, devreq: *T_DEVREQ, nreq: isize, exinf: *void) TkError!void = @as(*const fn (taskid: isize, devreq: *T_DEVREQ, nreq: isize, exinf: *void) TkError!void, devcb.ddev.abortfn);

    {
        cpu_status.DISABLE_INTERRUPT();
        defer cpu_status.ENABLE_INTERRUPT();
        knl_ctxtsk.sysmode += 1;
    }
    try abortfn(tskid, devreq, nreq, devcb.ddev.exinf);
    {
        cpu_status.DISABLE_INTERRUPT();
        defer cpu_status.ENABLE_INTERRUPT();
        knl_ctxtsk.sysmode -= 1;
    }
}

// pub const isize knl_request(isize dd, W start, void *buf, W size, i32 tmout, isize cmd);
// pub const bool knl_chkopen(DevCB *devcb, isize unitno);
// pub const void knl_delReqCB(ReqCB *reqcb);
// pub const ResCB *knl_GetResCB(void);
// pub const void knl_delOpnCB(OpnCB *opncb, bool free);
// pub const ER knl_close_device(OpnCB *opncb, usize option);

// Lock for device management exclusive control */
// Noinit(pub FastMLock knl_DevMgrLock);

// Device initial setting information */
// Noinit(pub	T_IDEV		knl_DefaultIDev);

// Device registration management */
// Noinit(pub	DevCB		knl_DevCBtbl[MAX_REGDEV]);	// Device registration information table */
// Noinit(pub	QUEUE		knl_UsedDevCB);	// In-use queue */
// Noinit(pub	QUEUE		knl_FreeDevCB);	// Unused queue */

// Search registration device */
pub fn knl_searchDevCB(devnm: []const u8) ?*DevCB {
    var q: *QUEUE = knl_UsedDevCB.next;
    var devcb: *DevCB = undefined;

    while (q != &knl_UsedDevCB) : (q = q.next) {
        devcb = @as(*DevCB, q);

        if (devcb.devnm[0] == devnm[0] and knl_strcmp(@as([]const u8, devcb.devnm), @as([]const u8, devnm)) == 0) {
            return devcb; // Found */
        }
    }
    return null;
}

// Get DevCB for new registration */
fn newDevCB(devnm: []const u8) ?*DevCB {
    var devcb: ?*DevCB = @as(*DevCB, QueRemoveNext(&knl_FreeDevCB));
    if (devcb.?.* == null) {
        return null; // No space */
    }

    knl_strncpy(@as([]const u8, devcb.devnm), @as([]const u8, devnm), knlink.syscall.L_DEVNM + 1);
    QueInit(&devcb.openq);

    QueInsert(&devcb.q, &knl_UsedDevCB);

    return devcb;
}

// Free DevCB */
fn delDevCB(devcb: *DevCB) void {
    QueRemove(&devcb.q);
    QueInsert(&devcb.q, &knl_FreeDevCB);
    devcb.devnm[0] = '\0';
}

// Device registration */
pub fn tk_def_dev(devnm: []const u8, pk_ddev: ?*const T_DDEV, pk_idev: *T_IDEV) TkError!isize {
    LockREG();
    defer UnlockREG();

    var len: isize = knl_strlen(@as([]const u8, devnm));
    if (len == 0 or len > knlink.syscall.L_DEVNM) {
        return TkError.ParameterError;
    }

    if (pk_ddev.? != null) |item| {
        if (item.*.nsub < 0 or item.*.nsub > MAX_UNIT) {
            return TkError.ParameterError;
        }

        // Make sure that the length of the logical device name does not exceed the character limit */
        if (item.*.nsub > 0) {
            len += 1;
        }
        if (item.*.nsub > 10) {
            len += 1;
        }
        if (item.*.nsub > 100) {
            len += 1;
        }
        if (len > knlink.syscall.L_DEVNM) {
            return TkError.ParameterError;
        }
    }

    LockDM();
    defer UnlockDM();

    // Search whether 'devnm' device is registered */
    var devcb: ?*DevCB = knl_searchDevCB(devnm);
    if (devcb.? == null) {
        if (pk_ddev.? == null) {
            return TkError.ObjectNotExist;
        }

        // Get 'devcb' for new registration because it is not registered */
        devcb = newDevCB(devnm);
        if (devcb == null) {
            return TkError.ExceedSystemLimits;
        }
    }

    if (pk_ddev) |item| {
        // Set/update device registration information */
        devcb.ddev = item.*;

        if (item != null) {
            // Device initial setting information */
            item.* = knl_DefaultIDev;
        }
    } else {
        if (!isQueEmpty(&devcb.openq)) {
            // In use (open) */
            return TkError.BusyState;
        }
        // Device unregistration */
        delDevCB(devcb);
    }

    return DID(devcb);
}

// Check device initial information */
pub fn tk_ref_idv(pk_idev: *T_IDEV) TkError!void {
    LockDM();
    defer UnlockDM();
    pk_idev.* = knl_DefaultIDev;
}

// Get physical device name
//Get the subunit number (return value)
//from the logical device name (ldevnm) and the physical
//device name (pdevnm). */
pub fn knl_phydevnm(pdevnm: []const u8, ldevnm: []const u8) isize {
    var c: u8 = ldevnm.*;

    while (c != 0) {
        if (c >= 0 and c <= 9) {
            break;
        }
        pdevnm.* += 1;
        pdevnm.* = c;
        ldevnm += 1;
    }
    pdevnm.* = 0;

    var unitno: isize = 0;
    if (c != 0) {
        c = ldevnm.*;
        while (c != 0) : (ldevnm += 1) {
            unitno = unitno * 10 + (c - 0);
        }
        unitno += 1;
    }
    return unitno;
}

// Get logical device name
//Get the logical device name from
//the physical device name (pdevnm) and the subunit number (unitno).
fn logdevnm(ldevnm: *u8, pdevnm: *u8, unitno: isize) void {
    var unostr: [12]u8 = undefined;

    tstd.knl_strcpy(@as([]const u8, ldevnm), @as([]const u8, pdevnm));
    if (unitno > 0) {
        var cp: *u8 = &unostr[11];
        cp.* = 0;
        while (ldevnm.* != 0) {
            ldevnm += 1;
        }
        unitno -= 1;
        // do-while文だったのでuintnoが0でも一回は実行したい. (0の場合、であってるんかは知らん)
        while (unitno >= 0) : (cp -= 1) {
            cp.* = @as(u8, '0' + (unitno % 10));
            unitno /= 10;
        }
        tstd.knl_strcat(@as([]const u8, ldevnm), @as([]const u8, cp));
    }
}

// Get device name */
pub fn tk_get_dev(devid: isize, devnm: *u8) TkError!isize {
    knl_check_devid(devid) catch |err| {
        return err;
    };

    LockDM();
    defer UnlockDM();

    var devcb: *DevCB = sysmgr.DEVCB(devid);
    if ((devcb.devnm[0] == '\0') or (sysmgr.UNITNO(devid) > devcb.ddev.nsub)) {
        return TkError.E_NOEXS;
    }
    logdevnm(devnm, devcb.devnm, UNITNO(devid));

    return sysmgr.DID(devcb);
}

// Get device information */
pub fn tk_ref_dev(devnm: []const u8, pk_rdev: ?*T_RDEV) isize {
    var pdevnm: [knlink.syscall.L_DEVNM + 1]u8 = undefined;

    var unitno: isize = knl_phydevnm(pdevnm, devnm);

    LockDM();
    defer UnlockDM();

    var devcb: ?*DevCB = knl_searchDevCB(pdevnm);
    if (devcb.? == null or unitno > devcb.ddev.nsub) {
        return TkError.ObjectNotExist;
    }

    if (pk_rdev) |item| {
        item.*.devatr = devcb.?.*.ddev.devatr;
        item.*.blksz = devcb.?.*.ddev.blksz;
        item.*.nsub = devcb.?.*.ddev.nsub;
        item.*.subno = unitno;
    }
    return DEVID(devcb, unitno);
}

// Get device information */
pub fn tk_oref_dev(dd: isize, pk_rdev: *T_RDEV) TkError!isize {
    var opncb: *OpnCB = undefined;

    LockDM();
    defer UnlockDM();

    knl_check_devdesc(dd, 0, &opncb) catch |err| {
        return err;
    };
    var devcb: *DevCB = opncb.devcb;
    var unitno: isize = opncb.unitno;

    if (pk_rdev != null) {
        pk_rdev.devatr = devcb.ddev.devatr;
        pk_rdev.blksz = devcb.ddev.blksz;
        pk_rdev.nsub = devcb.ddev.nsub;
        pk_rdev.subno = unitno;
    }

    return DEVID(devcb, unitno);
}

// Get registration device list */
pub fn tk_lst_dev(pk_ldev: *T_LDEV, start: isize, ndev: isize) TkError!isize {
    var devcb: *DevCB = undefined;

    if (start < 0 or ndev < 0) {
        return TkError.ParameterError;
    }
    LockDM();
    defer UnlockDM();

    var end: isize = start + ndev;
    var n: isize = 0;
    var q: *QUEUE = knl_UsedDevCB.next;
    while (q != &knl_UsedDevCB) : ({
        q = q.next;
        n += 1;
    }) {
        if (n >= start and n < end) {
            devcb = @as(*DevCB, q);
            pk_ldev.devatr = devcb.ddev.devatr;
            pk_ldev.blksz = devcb.ddev.blksz;
            pk_ldev.nsub = devcb.ddev.nsub;
            knl_strncpy(@as([]const u8, pk_ldev.devnm), @as([]const u8, devcb.devnm, knlink.syscall.L_DEVNM));
            pk_ldev += 1;
        }
    }
    if (start >= n) {
        return TkError.ObjectNotExist;
    }

    return n - start;
}

// Send driver request event */
pub fn tk_evt_dev(devid: isize, evttyp: isize, evtinf: *void) TkError!isize {
    knl_check_devid(devid) catch |err| {
        return err;
    };
    if (evttyp < 0) {
        return TkError.E_PAR;
    }

    {
        LockDM();
        defer UnlockDM();

        var devcb: *DevCB = DEVCB(devid);
        if ((devcb.devnm[0] == '\0') or (tstd.UNITNO(devid) > devcb.ddev.nsub)) {
            return TkError.E_NOEXS;
        }

        var eventfn: EVTFN = @as(EVTFN, devcb.ddev.eventfn);
        var exinf: *void = devcb.ddev.exinf;
    }
    // Device driver call */
    {
        cpu_status.DISABLE_INTERRUPT();
        defer cpu_status.ENABLE_INTERRUPT();
        knl_ctxtsk.sysmode += 1;
    }
    (*eventfn)(evttyp, evtinf, exinf) catch |err| {
        return err;
    };
    {
        cpu_status.DISABLE_INTERRUPT();
        defer cpu_status.ENABLE_INTERRUPT();
        knl_ctxtsk.sysmode -= 1;
    }
}

// Initialization of device registration information table */
fn initDevCB() TkError!void {
    var num: isize = MAX_REGDEV;

    QueInit(&knl_UsedDevCB);
    QueInit(&knl_FreeDevCB);

    var devcb: *DevCB = knl_DevCBtbl;
    num -= 1;
    while (num > 0) : (num -= 1) {
        QueInsert(&devcb.q, &knl_FreeDevCB);
        devcb.devnm[0] = '\0';
        devcb += 1;
    }
}

// Initialization of device initial setting information */
fn initIDev() TkError!void {
    if (comptime knlink.knldef.DEVT_MBFSZ0 >= 0) {
        var cmbf: T_CMBF = undefined;

        // Generate message buffer for event notification */
        knl_strncpy(@as([]const u8, &cmbf.exinf), @as([]const u8, OBJNAME_DMMBF), @sizeOf(cmbf.exinf));
        cmbf.mbfatr = knlink.syscall.TA_TFIFO;
        cmbf.bufsz = knlink.knldef.DEVT_MBFSZ0;
        cmbf.maxmsz = knlink.knldef.DEVT_MBFSZ1;
        tk_cre_mbf(&cmbf) catch |err| {
            knl_DefaultIDev.evtmbfid = 0;
            return err;
        };
    }
    //         else{// Do not use message buffer for event notification */
    // ercd = E_OK;
    // }
    // ercdがE_OK以外だと上記でreturnするのでercdの代入は0という意味?
    knl_DefaultIDev.evtmbfid = 0;
    // if (comptime  DEVT_MBFSZ0 >= 0) {
    // }
    // return ercd;
}

// Initialization of Devive management */
pub fn knl_initialize_devmgr() TkError!void {
    // Generate lock for device management exclusive control */
    errdefer knl_finish_devmgr();
    CreateMLock(&knl_DevMgrLock, @as(*u8, OBJNAME_DMLOCK)) catch |err| {
        return err;
    };

    // Generate device registration information table */
    initDevCB() catch |err| {
        return err;
    };

    // Initialization of device input/output-related */
    knl_initDevIO() catch |err| {
        return err;
    };

    // Initialization of device initial setting information */
    initIDev() catch |err| {
        return err;
    };
    knl_devmgr_startup();
}

// Unregister device initial setting information */
fn delIDev() TkError!void {
    // ER	ercd = E_OK;
    if (comptime knldef.DEVT_MBFID0 >= 0) {
        // Delete message buffer for event notification */
        if (knl_DefaultIDev.evtmbfid > 0) {
            tk_del_mbf(knl_DefaultIDev.evtmbfid) catch |err| {
                return err;
            };
            knl_DefaultIDev.evtmbfid = 0;
        }
    } // DEVT_MBFisize0 >= 0 */
}

// Finalization sequence of system management */
pub fn knl_finish_devmgr() TkError!void {
    knl_devmgr_cleanup();

    // Unregister device initial setting information */
    deliIDev() catch |err| {
        return err;
    };

    // Finalization sequence of device input/output-related */
    knl_finishDevIO() catch |err| {
        return err;
    };

    // Delete lock for device management exclusive control */
    DeleteMLock(&knl_DevMgrLock);
}

// } // config.USE_DEVICE */
