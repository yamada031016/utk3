// System dependencies

const knlink = @import("knlink");
const libtk = @import("libtk");
const ID = libtk.typedef.ID;
const PRI = libtk.typedef.PRI;
const RELTIM = libtk.typedef.RELTIM;
// * Object name information		td_ref_dsname, td_set_dsname

pub const TN = enum(u8) {
    TSK = 0x01,
    SEM = 0x02,
    FLG = 0x03,
    MBX = 0x04,
    MBF = 0x05,
    POR = 0x06,
    MTX = 0x07,
    MPL = 0x08,
    MPF = 0x09,
    CYC = 0x0a,
    ALM = 0x0b,
};
// Semaphore state information		td_ref_sem

pub const TD_RSEM = struct {
    exinf: *anyopaque, // Extended information
    wtsk: ID, // Wait task ID
    semcnt: isize, // Current semaphore value
};

// Event flag state information		td_ref_flg
pub const TD_RFLG = struct {
    exinf: *anyopaque, // Extended information
    wtsk: ID, // Wait task ID
    flgptn: usize, // Current event flag pattern
};

// Mail box state information		td_ref_mbx
pub const TD_RMBX = struct {
    exinf: *anyopaque, // Extended information
    wtsk: ID, // Wait task ID
    // pk_msg: *T_MSG, // Next received message
};

// Mutex state information		td_ref_mtx

pub const TD_RMTX = struct {
    exinf: *anyopaque, // Extended information
    htsk: ID, // Locking task ID
    wtsk: ID, // Lock wait task ID
};

// * Message buffer state information 	td_ref_mbf

pub const TD_RMBF = struct {
    exinf: *anyopaque, // Extended information
    wtsk: ID, // Lock wait task ID
    stsk: ID, // Lock wait task ID
    msgsz: isize, // Next received message size (byte)
    frbufsz: i32, // Free buffer size (byte)
    maxmsz: isize, // Maximum length of message (byte)
};

// Rendezvous port state information	td_ref_por

pub const TD_RPOR = struct {
    exinf: *anyopaque, // Extended information
    wtsk: ID, // Lock wait task ID
    atsk: ID, // Lock wait task ID
    maxcmsz: isize, // Maximum length of call message (byte)
    maxrmsz: isize, // Maximum length of replay message (byte)
};

// Fixed size memory pool state information	td_ref_mpf
pub const TD_RMPF = struct {
    exinf: *anyopaque, // Extended information
    wtsk: ID, // Lock wait task ID
    frbcnt: i32, // Number of free blocks
};

// Variable size memory pool state information	td_ref_mpl
pub const TD_RMPL = struct {
    exinf: *anyopaque, // Extended information
    wtsk: ID, // Wait task ID
    frsz: i32, // Total size of free area (byte)
    maxsz: i32, // Size of maximum continuous free area (byte)
};

// Cycle handler state information	td_ref_cyc
pub const TD_RCYC = struct {
    exinf: *anyopaque, // Extended information
    lfttim: RELTIM, // Remaining time until next handler startup
    cycstat: usize, // Cycle handler status
};

// Alarm handler state information	td_ref_alm
pub const TD_RALM = struct {
    exinf: *anyopaque, // Extended information
    lfttim: RELTIM, // Remaining time until handler startup
    almstat: usize, // Alarm handler status
};

// Subsystem state information		td_ref_ssy
pub const TD_RSSY = struct {
    ssypri: PRI, // Subsystem priority
    resblksz: i32, // Resource management block size (byte)
};

// Task state information		td_ref_tsk
pub const TD_RTSK = struct {
    exinf: *anyopaque, // Extended information
    tskpri: PRI, // Current priority
    tskbpri: PRI, // Base priority
    tskstat: usize, // Task state
    tskwait: u32, // Wait factor
    wid: ID, // Wait object ID
    wupcnt: isize, // Number of wakeup requests queuing
    suscnt: isize, // Number of SUSPEND request nests
    // task: FP, // Task startup address
    stksz: i32, // stack size (byte)
    istack: *anyopaque, // stack pointer initial value
};

// * Task statistics information		td_inf_tsk
pub const TD_ITSK = struct {
    stime: RELTIM, // Cumulative system execution time (milliseconds)
    utime: RELTIM, // Cumulative user execution time (milliseconds)
};

// * System state information		td_ref_sys
pub const TD_RSYS = struct {
    sysstat: usize, // System state
    runtskid: ID, // ID of task in execution state
    schedtskid: ID, // ID of task that should be in execution state
};

// System call/extended SVC trace definition 	td_hok_svc
pub const TD_HSVC = struct {
    // enter:FP,		// Hook routine before calling
    // leave:FP,		// Hook routine after calling
};

// Task dispatch trace definition		td_hok_dsp
pub const TD_HDSP = struct {
    // exec:FP,		// Hook routine when starting execution
    // stop:FP,		// Hook routine when stopping execution
};

// * Exception/Interrupt trace definition			td_hok_int
pub const TD_HINT = struct {
    // enter:FP,		// Hook routine before calling handler
    // leave:FP,		// Hook routine after calling handler
};
