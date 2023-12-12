//	micro T-Kernel/SM(System Maneger) Definition
const knlink = @import("knlink");
const inc_sys = @import("inc_sys");
const inc_tk = @import("inc_tk");
const syslib = inc_tk.syslib;
const syscall = inc_tk.syscall;
const tkernel = inc_tk.tkernel;
const fastmlock = @import("libtk").fastmlock;
const queue = inc_sys.queue;
const QUEUE = queue.QUEUE;
const INT_BITWIDTH = inc_sys.machine.INT_BITWIDTH;

// #include <tk/tkernel.h>
// #include <sys/queue.h>

// #include "kernel.h"

// *	Device management function

// USE_MULTI_LOCKがfalseなのでmlock*は定義されていない
// * Lock for device management exclusive control
// pub const knl_DevMgrLock: syslib.FastMLock = undefined;
// fn LockDM() void {
//     fastmlock.MLock(&knl_DevMgrLock, 0);
// }
// fn UnlockDM() void {
//     fastmlock.MUnlock(&knl_DevMgrLock, 0);
// }
//
// // * Lock for device registration exclusive control
// fn LockREG() void {
//     fastmlock.MLock(&knl_DevMgrLock, 1);
// }
// fn UnlockREG() void {
//     fastmlock.MUnlock(&knl_DevMgrLock, 1);
// }

// * Device registration information
pub const DevCB = struct {
    q: QUEUE,
    devnm: [syscall.L_DEVNM + 1]u8, // Device name */
    ddev: syscall.T_DDEV, // Registration information */
    openq: QUEUE, // Open device management queue */
};

pub var knl_DevCBtbl: []DevCB = undefined;
// Device registration information table */
pub var knl_UsedDevCB: QUEUE = undefined; // In-use queue */

pub fn DID(devcb: DevCB) u8 {
    return (devcb - knl_DevCBtbl + 1) << 8;
}
// u8, ID tekito
pub fn DEVID(devcb: DevCB, unitno: u8) u8 {
    return DID(devcb) + (unitno);
}
pub fn DEVCB(devid: isize) u8 {
    return knl_DevCBtbl + (((devid) >> 8) - 1);
}
pub fn UNITNO(devid: isize) u8 {
    return (devid) & 0xff;
}

// * Open management information
pub const OpnCB = struct {
    q: QUEUE,
    resq: QUEUE, // For connection from resource
    // management */
    resid: isize, // Section resource ID */
    devcb: *DevCB, // Target device */
    unitno: isize, // Subunit number
    // (0: Physical device) */
    omode: usize, // Open mode */
    requestq: QUEUE, // Request management queue */
    waitone: u16, // Number of individual request
    // waits */
    waireqlst: *syscall.T_DEVREQ, // List of multiple request waits */
    nwaireq: isize, // Number of multiple request waits */
    abort_tskid: isize, // Abort completion wait task */
    abort_cnt: isize, // Number of abort completion wait
    // requests */
    abort_semid: isize, // Semaphore for abort completion wait */
};

// rqの型は多分これ？
pub fn RESQ_OPNCB(rq: OpnCB) u8 {
    return @as(*OpnCB, @as(*i8, rq) - tkernel.offsetof(OpnCB, resq));
}

// * Request management information
pub const ReqCB = struct {
    q: QUEUE,
    opncb: *OpnCB, // Open device */
    tskid: isize, // Processing task */
    req: syscall.T_DEVREQ, // Request packet */
};

// * Resource management information
pub const ResCB = struct {
    openq: QUEUE, // Open device management queue */
    dissus: isize, // Suspend disable request count */
};

// * Request function types

// typedef ER  (*OPNFN)( ID devid, UINT omode, void *exinf );
// typedef ER  (*ABTFN)( ID tskid, T_DEVREQ *devreq, INT nreq, void *exinf );
// typedef INT (*WAIFN)( T_DEVREQ *devreq, INT nreq, TMO tmout, void *exinf );
// typedef INT (*EVTFN)( INT evttyp, void *evtinf, void *exinf );
// typedef ER  (*CLSFN)( ID devid, UINT option, void *exinf );
// typedef ER  (*EXCFN)( T_DEVREQ *devreq, TMO tmout, void *exinf );

// pub const IMPORT_DEFINE=1;
// if (comptime IMPORT_DEFINE) {
// device.c */
// IMPORT	FastMLock	knl_DevMgrLock;
// IMPORT	DevCB		knl_DevCBtbl[];
// IMPORT	QUEUE		knl_UsedDevCB;
// IMPORT	DevCB*		knl_searchDevCB( CONST UB *devnm );
// IMPORT	INT			knl_phydevnm( UB *pdevnm, CONST UB *ldevnm );
// IMPORT	ER			knl_initialize_devmgr( void );
// IMPORT	ER			knl_finish_devmgr( void );
// // deviceio.c */
// IMPORT ER knl_check_devdesc( ID dd, UINT mode, OpnCB **p_opncb );
// IMPORT void knl_devmgr_startup( void );
// IMPORT void knl_devmgr_cleanup( void );
// IMPORT ER knl_initDevIO( void );
// IMPORT ER knl_finishDevIO( void );
// }
