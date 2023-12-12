//winfo.h
//Definition of Wait Information for Synchronization/Communication Object
const task = knlink.task;
const TSTAT = task.TSTAT;
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
const TkError = inc_tk.errno.TkError;
const tkernel = inc_tk.tkernel;
const inc_sys = @import("inc_sys");
const knldef = inc_sys.knldef;
const sysdef = inc_sys.sysdef;
const TCB = knlink.TCB;
const q = inc_sys.queue;
const QUEUE = q.QUEUE;
const typedef = inc_tk.typedef;
const SYSTIM = typedef.SYSTIM;
const sys_timer = knlink.sysdepend.sys_timer;

// * Semaphore wait (TTW_SEM)

const WINFO_SEM = struct {
    cnt: isize, // Request resource number
};

// * Event flag wait (TTW_FLG)

const WINFO_FLG = struct {
    waiptn: usize, // Wait bit pattern
    wfmode: usize, // Wait mode
    p_flgptn: *usize, // Address that has a bit pattern at wait released
};

// * Mailbox wait (TTW_MBX)

const WINFO_MBX = struct {
    ppk_msg: **syscall.T_MSG, // Address that has the head of a message packet
};

// * Message buffer receive/send wait (TTW_RMBF, TTW_SMBF)

const WINFO_RMBF = struct {
    msg: *void, // Address that has a received message
    p_msgsz: *isize, // Address that has a received message size
};

const WINFO_SMBF = struct {
    msg: *const void, // Send message head address
    msgsz: isize, // Send message size
};

// * Rendezvous call/accept/end wait (TTW_CAL, TTW_ACP, TTW_RDV)

const WINFO_CAL = struct {
    calptn: usize, // Bit pattern that indicates caller select condition
    msg: *void, // Address that has a message
    cmsgsz: isize, // Call message size
    p_rmsgsz: *isize, // Address that has a reply message size
};

const WINFO_ACP = struct {
    acpptn: usize, // Bit pattern that indicates receiver select condition
    msg: *void, // Address that has a call message
    p_rdvno: *isize, // Address that has the rendezvous number
    p_cmsgsz: *isize, // Address that has the call message size
};

const WINFO_RDV = struct {
    rdvno: isize, // Rendezvous number
    msg: *void, // Address that has a message
    maxrmsz: isize, // Maximum length of reply message
    p_rmsgsz: *isize, // Address that has a reply message size
};

// * Variable size memory pool wait (TTW_MPL)

const WINFO_MPL = struct {
    blksz: i32, // Memory block size
    p_blk: **void, // Address that has the head of a memory block
};

// * Fixed size memory pool wait (TTW_MPF)

const WINFO_MPF = struct {
    p_blf: **void, // Address that has the head of a memory block
};

// * Definition of wait information in task control block

// const WINFO = union {
//     if (comptime  USE_SEMAPHORE) {
//         sem:WINFO_SEM,
//     }
//     if (comptime  USE_EVENTFLAG) {
//         flg:WINFO_FLG,
//     }
//     if (comptime  USE_MAILBOX) {
//         mbx:WINFO_MBX,
//     }
//     if (comptime  USE_MESSAGEBUFFER) {
//         rmbf:WINFO_RMBF,
//         smbf:WINFO_SMBF,
//     }
//     if (comptime  USE_LEGACY_API and USE_RENDEZVOUS) {
//         cal:WINFO_CAL,
//         acp:WINFO_ACP,
//         rdv:WINFO_RDV,
//     }
//     if (comptime  USE_MEMORYPOOL) {
//         mpl:WINFO_MPL,
//     }
//     if (comptime  USE_FIX_MEMORYPOOL) {
//         mpf:WINFO_MPF,
//     }
// };

// * Definition of wait specification structure

const WSPEC = struct {
    tskwait: u32, // Wait factor
    chg_pri_hook: fn (*TCB, isize) void, // Process at task priority change
    rel_wai_hook: fn (*TCB) void, // Process at task wait release
};
