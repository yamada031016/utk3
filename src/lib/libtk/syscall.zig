//micro T-Kernel System Calls */
//
const TkError = @import("libtk").errno.TkError;
const PRI = @import("libtk").typedef.PRI;

// Task creation */
pub const TSK_SELF = 0; // Its own task specify */
pub const TPRI_INI = 0; // Specify priority at task startup */
pub const TPRI_RUN = 0; // Specify highest priority during running */

pub const TA_ASM = 0x00000000; // Program by assembler */
pub const TA_HLNG = 0x00000001; // Program by high level programming language */
pub const TA_USERBUF = 0x00000020; // Specify user buffer */
pub const TA_DSNAME = 0x00000040; // Use object name */

pub const TA_RNG0 = 0x00000000; // Execute by protection level 0 */
pub const TA_RNG1 = 0x00000100; // Execute by protection level 1 */
pub const TA_RNG2 = 0x00000200; // Execute by protection level 2 */
pub const TA_RNG3 = 0x00000300; // Execute by protection level 3 */

pub const TA_COP0 = 0x00001000; // Use coprocessor (isize=0) */
pub const TA_COP1 = 0x00002000; // Use coprocessor (isize=1) */
pub const TA_COP2 = 0x00004000; // Use coprocessor (isize=2) */
pub const TA_COP3 = 0x00008000; // Use coprocessor (isize=3) */

// Task state tskstat */
pub const TTSTAT = enum(usize) {
    RUN = 0x00000001, // RUN */
    RDY = 0x00000002, // READY */
    WAI = 0x00000004, // WAIT */
    SUS = 0x00000008, // SUSPEND */
    WAS = 0x0000000c, // WAIT-SUSPEND */
    DMT = 0x00000010, // DORMANT */
    NODISWAI = 0x00000080, // Wait disable rejection state */
};

// Wait factor tskwait */
pub const TTW = enum(u8) {
    SLP = 0x00000001, // Wait caused by wakeup wait */
    DLY = 0x00000002, // Wait caused by task delay */
    SEM = 0x00000004, // Semaphore wait */
    FLG = 0x00000008, // Event flag wait */
    MBX = 0x00000040, // Mail box wait */
    MTX = 0x00000080, // Mutex wait */
    SMBF = 0x00000100, // Message buffer send wait */
    RMBF = 0x00000200, // Message buffer receive wait */
    CAL = 0x00000400, // Rendezvous call wait */
    ACP = 0x00000800, // Rendezvous accept wait */
    RDV = 0x00001000, // Rendezvous end wait */
    MPF = 0x00002000, // Fixed size memory pool wait */
    MPL = 0x00004000, // Variable size memory pool wait */
};

// Semaphore generation */
pub const TA_TFIFO = 0x00000000; // Manage wait task by FIFO */
pub const TA_TPRI = 0x00000001; // Manage wait task by priority order */
pub const TA_FIRST = 0x00000000; // Give priority to task at head of wait queue */
pub const TA_CNT = 0x00000002; // Give priority to task whose request counts is less */
// pub const TA_DSNAME = 0x00000040; // Use object name */

// Mutex */
// pub const TA_TFIFO=0x00000000UL;// Manage wait task by FIFO */
// pub const TA_TPRI=	0x00000001UL;// Manage wait task by priority order */
// pub const TA_INHERIT=0x00000002UL;// Priority inherited protocol */
// pub const TA_CEILING=0x00000003UL;// Upper limit priority protocol */
// pub const TA_DSNAME	0x00000040UL;// Use object name */

// Event flag */
// pub const TA_TFIFO=0x00000000UL;// Manage wait task by FIFO */
// pub const TA_Tisize=	0x00000001UL;// Manage wait task by priority order */
// pub const TA_WSGL=	0x00000000UL;// Disable multiple tasks wait */
// pub const TA_WMUL=	0x00000008UL;// Enable multiple tasks wait */
// pub const TA_DSNAME=0x00000040UL;// Use object name */

// Event flag wait mode */
pub const TWF = enum(usize) {
    ANDW = 0x00000000, // AND wait */
    ORW = 0x00000001, // OR wait */
    CLR = 0x00000010, // All clear specify */
    BITCLR = 0x00000020, // Only condition bit clear specify */
};

// Mail box */
// pub const TA_TFIFO=0x00000000;// Manage wait task by FIFO */
// pub const TA_TPRI=0x00000001;// Manage wait task by priority order */
// pub const TA_MFIFO = 0x00000000; // Manage messages by FIFO */
// pub const TA_MPRI = 0x00000002; // Manage messages by priority order */
// pub const TA_DSNAME=0x00000040;// Use object name */

// Message buffer */
// pub const TA_TFIFO=0x00000000UL;// Manage wait task by FIFO */
// pub const TA_Tisize=	0x00000001UL;// Manage wait task by priority order */
// pub const TA_USERBUF = 0x00000020; // Specify user buffer */
// pub const TA_DSNAME=0x00000040UL;// Use object name */

// Rendezvous */
// pub const TA_TFIFO=0x00000000UL;// Manage wait task by FIFO */
// pub const TA_Tisize=	0x00000001UL;// Manage wait task by priority order */
// pub const TA_DSNAME=0x00000040UL;// Use object name */

// Handler */
// pub const TA_ASM=	0x00000000UL;// Program by assembler */
// pub const TA_HLNG=	0x00000001UL;// Program by high level programming language */

// Variable size memory pool */
// pub const TA_TFIFO=0x00000000UL;// Manage wait task by FIFO */
// pub const TA_Tisize=	0x00000001UL;// Manage wait task by priority order */
// pub const TA_USERBUF=0x00000020UL;// Specify user buffer */
// pub const TA_DSNAME=0x00000040UL;// Use object name */
// pub const TA_RNG0=	0x00000000UL;// Protection level 0 */
// pub const TA_RNG1=	0x00000100UL;// Protection level 1 */
// pub const TA_RNG2=	0x00000200UL;// Protection level 2 */
// pub const TA_RNG3=	0x00000300UL;// Protection level 3 */

// Fixed size memory pool */
// pub const TA_TFIFO=0x00000000UL;// Manage wait task by FIFO */
// pub const TA_Tisize=	0x00000001UL;// Manage wait task by priority order */
// pub const TA_USERBUF=0x00000020UL;// Specify user buffer */
// pub const TA_DSNAME=0x00000040UL;// Use object name */
// pub const TA_RNG0=	0x00000000UL;// Protection level 0 */
// pub const TA_RNG1=	0x00000100UL;// Protection level 1 */
// pub const TA_RNG2=	0x00000200UL;// Protection level 2 */
// pub const TA_RNG3=	0x00000300UL;// Protection level 3 */

// Cycle handler */
// pub const TA_ASM=	0x00000000UL;// Program by assembler */
// pub const TA_HLNG=	0x00000001UL;// Program by high level programming language */
pub const TA_STA = 0x00000002; // Cycle handler startup */
pub const TA_PHS = 0x00000004; // Save cycle handler phase */
// pub const TA_DSNAME=0x00000040UL;// Use object name */

pub const TCYC_STP = 0x00; // Cycle handler is not operating */
pub const TCYC_STA = 0x01; // Cycle handler is operating */

// Alarm handler address */
// pub const TA_ASM=	0x00000000UL;// Program by assembler */
// pub const TA_HLNG=	0x00000001UL;// Program by high level programming language */
// pub const TA_DSNAME=0x00000040UL;// Use object name */

pub const TALM_STP = 0x00; // Alarm handler is not operating */
pub const TALM_STA = 0x01; // Alarm handler is operating */

// System state */
pub const TSS_TSK = 0x00; // During execution of task part(context) */
pub const TSS_DDSP = 0x01; // During dispatch disable */
pub const TSS_DINT = 0x02; // During Interrupt disable */
pub const TSS_INDP = 0x04; // During execution of task independent part */
pub const TSS_QTSK = 0x08; // During execution of semi-task part */

// Power-saving mode */
pub const TPW_DOSUSPEND = 1; // Transit to suspend state */
pub const TPW_DISLOWPOW = 2; // Power-saving mode switch disable */
pub const TPW_ENALOWPOW = 3; // Power-saving mode switch enable */

// CPU dependent definition */
// pub const CPUDEF_PATH_(a)		#a
// pub const CPUDEF_PATH(a)		CPUDEF_PATH_(a)
// pub const CPUDEF_SYSDEP()		CPUDEF_PATH(sysdepend/TARGET_DIR/cpudef.h)
//
// const  = @import{ CPUDEF_SYSDEP()
// const cpudef = @import("sysdepend/nucleo_l476/cpudef.h");

// Task creation information 		tk_cre_tsk */
pub const T_CTSK = struct {
    // zero-pointerも許したい addressが0x0の場合
    exinf: ?*anyopaque, // Extended information */
    tskatr: u32, // Task attribute */
    // task: *const fn () TkError!void, // Task startup address */
    task: *usize, // Task startup address */
    itskpri: PRI, // Priority at task startup */
    stksz: isize, // User stack size (byte) */
    // if (comptime  config.USE_OBJECT_NAME) {
    //     dsname: [OBJECT_NAME_LENGTH]u8,	// Object name */
    // }
    bufptr: *anyopaque, // User buffer */
};

// Task state information 		tk_ref_tsk */
pub const T_RTSK = struct {
    exinf: *void, // Extended information */
    tskpri: isize, // Current priority */
    tskbpri: isize, // Base priority */
    tskstat: usize, // Task state */
    tskwait: u32, // Wait factor */
    wid: isize, // Wait object isize */
    wupcnt: isize, // Number of wakeup requests queuing */
    suscnt: isize, // Number of SUSPEND request nests */
};

// Semaphore creation information		tk_cre_sem */
pub const T_CSEM = struct {
    exinf: *void, // Extended information */
    sematr: u32, // Semaphore attribute */
    isemcnt: isize, // Semaphore initial count value */
    maxsem: isize, // Semaphore maximum count value */
    // if (comptime  USE_OBJECT_NAME) {
    //     dsname: [OBJECT_NAME_LENGTH]u8,	// Object name */
    // }
};

// Semaphore state information		tk_ref_sem */
pub const T_RSEM = struct {
    exinf: *void, // Extended information */
    wtsk: isize, // Wait task isize */
    semcnt: isize, // Current semaphore value */
};

// Mutex creation information		tk_cre_mtx */
pub const T_CMTX = struct {
    exinf: *void, // Extended information */
    mtxatr: u32, // Mutex attribute */
    ceilpri: isize, // Upper limit priority of mutex */
    // if (comptime  USE_OBJECT_NAME) {
    //     dsname:[OBJECT_NAME_LENGTH]u8,	// Object name */
    // }
};

// Mutex state information		tk_ref_mtx */
pub const T_RMTX = struct {
    exinf: *void, // Extended information */
    htsk: isize, // Locking task isize */
    wtsk: isize, // Lock wait task isize */
};

//
//Event flag creation information	tk_cre_flg */
pub const T_CFLG = struct {
    exinf: *void, // Extended information */
    flgatr: u32, // Event flag attribute */
    iflgptn: usize, // Event flag initial value */
    // if (comptime  USE_OBJECT_NAME) {
    //     dsname: [OBJECT_NAME_LENGTH]u8,	// Object name */
    // }
};

// Event flag state information		tk_ref_flg */
pub const T_RFLG = struct {
    exinf: *void, // Extended information */
    wtsk: isize, // Wait task isize */
    flgptn: usize, // Current event flag pattern */
};

// Mail box creation information	tk_cre_mbx */
pub const T_CMBX = struct {
    exinf: *void, // Extended information */
    mbxatr: u32, // Mail box attribute */
    // if (comptime  USE_OBJECT_NAME) {
    //     dsname:[OBJECT_NAME_LENGTH]u8,	// Object name */
    // }
};

// Mail box message header */
pub const T_MSG = struct {
    // void *msgque[1]
    msgque: [1]*void, // Area for message queue */
};

pub const T_MSG_PRI = struct {
    msgque: T_MSG, // Area for message queue */
    msgpri: isize, // Message priority */
};

// Mail box state information		tk_ref_mbx */
pub const T_RMBX = struct {
    exinf: *void, // Extended information */
    wtsk: isize, // Wait task isize */
    pk_msg: *T_MSG, // Next received message */
};

// Message buffer creation information	tk_cre_mbf */
pub const T_CMBF = struct {
    exinf: *void, // Extended information */
    mbfatr: u32, // Message buffer attribute */
    bufsz: isize, // Message buffer size (byte) */
    maxmsz: isize, // Maximum length of message (byte) */
    // if (comptime  USE_OBJECT_NAME) {
    //     dsname:[OBJECT_NAME_LENGTH]u8,	// Object name */
    // }
    bufptr: *void, // User buffer */
};

// Message buffer state information 	tk_ref_mbf */
pub const T_RMBF = struct {
    exinf: *void, // Extended information */
    wtsk: isize, // Receive wait task isize */
    stsk: isize, // Send wait task isize */
    msgsz: isize, // Next received message size (byte) */
    frbufsz: isize, // Free buffer size (byte) */
    maxmsz: isize, // Maximum length of message (byte) */
};

// Rendezvous port creation information	tk_cre_por */
pub const T_CPOR = struct {
    exinf: *void, // Extended information */
    poratr: u32, // Port attribute */
    maxcmsz: isize, // Maximum length of call message (byte) */
    maxrmsz: isize, // Maximum length of replay message (byte) */
    // if (comptime  USE_OBJECT_NAME) {
    //     dsname:[OBJECT_NAME_LENGTH]u8,	// Object name */
    // }
};

// Rendezvous port state information	tk_ref_por */
pub const T_RPOR = struct {
    exinf: *void, // Extended information */
    wtsk: isize, // Call wait task isize */
    atsk: isize, // Receive wait task isize */
    maxcmsz: isize, // Maximum length of call message (byte) */
    maxrmsz: isize, // Maximum length of replay message (byte) */
};

// Interrupt handler definition information	tk_def_int */
pub const T_DINT = struct {
    intatr: u32, // Interrupt handler attribute */
    inthdr: isize, // Interrupt handler address */
};

// Variable size memory pool creation information	tk_cre_mpl */
pub const T_CMPL = struct {
    exinf: *void, // Extended information */
    mplatr: u32, // Memory pool attribute */
    mplsz: isize, // Size of whole memory pool (byte) */
    // if (comptime  USE_OBJECT_NAME) {
    //     dsname: [OBJECT_NAME_LENGTH]u8,	// Object name */
    // }
    bufptr: *void, // User buffer */
};

// Variable size memory pool state information	tk_ref_mpl */
pub const T_RMPL = struct {
    exinf: *void, // Extended information */
    wtsk: isize, // Wait task isize */
    frsz: isize, // Total size of free area (byte) */
    maxsz: isize, // Size of maximum continuous free area (byte) */
};

// Fixed size memory pool state information	tk_cre_mpf */
pub const T_CMPF = struct {
    exinf: *void, // Extended information */
    mpfatr: u32, // Memory pool attribute */
    mpfcnt: isize, // Number of blocks in whole memory pool */
    blfsz: isize, // Fixed size memory block size (byte) */
    // if (comptime  USE_OBJECT_NAME) {
    //     dsname:[OBJECT_NAME_LENGTH]u8,	// Object name */
    // }
    bufptr: *void, // User buffer */
};

// Fixed size memory pool state information	tk_ref_mpf */
pub const T_RMPF = struct {
    exinf: *void, // Extended information */
    wtsk: isize, // Wait task isize */
    frbcnt: isize, // Number of free area blocks */
};

// Cycle handler creation information 	tk_cre_cyc */
pub const T_CCYC = struct {
    exinf: *void, // Extended information */
    cycatr: u32, // Cycle handler attribute */
    cychdr: isize, // Cycle handler address */
    cyctim: u32, // Cycle interval */
    cycphs: u32, // Cycle phase */
    // if (comptime  USE_OBJECT_NAME) {
    //     dsname:[OBJECT_NAME_LENGTH]u8,	// Object name */
    // }
};

// Cycle handler state information	tk_ref_cyc */
pub const T_RCYC = struct {
    exinf: *void, // Extended information */
    lfttim: u32, // Remaining time until next handler startup */
    cycstat: usize, // Cycle handler status */
};

// Alarm handler creation information		tk_cre_alm */
pub const T_CALM = struct {
    exinf: *void, // Extended information */
    almatr: u32, // Alarm handler attribute */
    almhdr: isize, // Alarm handler address */
    // if (comptime  USE_OBJECT_NAME) {
    //     dsname: [OBJECT_NAME_LENGTH]u8,	// Object name */
    // }
};

// Alarm handler state information	tk_ref_alm */
pub const T_RALM = struct {
    exinf: *void, // Extended information */
    lfttim: u32, // Remaining time until handler startup */
    almstat: usize, // Alarm handler state */
};

// Version information		tk_ref_ver */
pub const T_RVER = struct {
    maker: u16, // OS manufacturer */
    prid: u16, // OS identification number */
    spver: u16, // Specification version */
    prver: u16, // OS product version */
    prno: [4]u16, // Product number, Product management information */
};

// System state information		tk_ref_sys */
pub const T_RSYS = struct {
    sysstat: usize, // System state */
    runtskid: isize, // isize of task in execution state */
    schedtskid: isize, // isize of the task that should be the execution state */
};

// Subsystem definition information 		tk_def_ssy */
pub const T_DSSY = struct {
    ssyatr: u32, // Subsystem attribute */
    ssypri: isize, // Subsystem priority */
    svchdr: isize, // Extended SVC handler address */
    breakfn: isize, // Break function address */
    eventfn: isize, // Event function address */
};

// Subsystem state information		tk_ref_ssy */
pub const T_RSSY = struct {
    ssypri: isize, // Subsystem priority */
};

// Device manager */

pub const L_DEVNM = 8; // Device name length */

//
//Device attribute (u32)
//IIII IIII IIII IIII PRxx xxxx KKKK KKKK
//The first 16-bit is the device-dependent attribute and
//defined by each device.
//The last 16-bit is the standard attribute and defined
//like as followings.
pub const TD_PROTECT = 0x8000; // P: Write protected */
pub const TD_REMOVABLE = 0x4000; // R: Media remove enabled */

pub const TD_DEVKIND = 0x00ff; // K: Device/media type */
pub const TD_DEVTYPE = 0x00f0; //    Device type */

// Device type */
pub const TDK_UNDEF = 0x0000; // Undefined/Unknown */
pub const TDK_DISK = 0x0010; // Disk device */

// Disk type */
pub const TDK_DISK_UNDEF = 0x0010; // Other disks */
pub const TDK_DISK_RAM = 0x0011; // RAM disk (Use main memory) */
pub const TDK_DISK_ROM = 0x0012; // ROM disk (Use main memory) */
pub const TDK_DISK_FLA = 0x0013; // Flash ROM, other silicon disks */
pub const TDK_DISK_FD = 0x0014; // Floppy disk */
pub const TDK_DISK_HD = 0x0015; // Hard disk */
pub const TDK_DISK_CDROM = 0x0016; // CD-ROM */

// Device open mode */
pub const TD_READ = 0x0001; // Read only */
pub const TD_WRITE = 0x0002; // Write only */
pub const TD_UPDATE = 0x0003; // Read and write */
pub const TD_EXCL = 0x0100; // Exclusive */
pub const TD_WEXCL = 0x0200; // Exclusive write */
pub const TD_REXCL = 0x0400; // Exclusive read */

// Device close option */
pub const TD_EJECT = 0x0001; // Media eject */

// Suspend mode */
pub const TD_SUSPEND = 0x0001; // Suspend */
pub const TD_DISSUS = 0x0002; // Disable suspend */
pub const TD_ENASUS = 0x0003; // Enable suspend */
pub const TD_CHECK = 0x0004; // Get suspend disable request count */
pub const TD_FORCE = 0x8000; // Specify forced suspend */

// Device information */
pub const T_RDEV = struct {
    devatr: u32, // Device attribute */
    blksz: i32, // Specific data block size (-1: Unknown) */
    nsub: isize, // Number of subunits */
    subno: isize, // 0: Physical device, 1 - nsub: Subunit number +1 */
};

// Registration device information */
pub const T_LDEV = struct {
    devatr: u32, // Device attribute */
    blksz: i32, // Specific data block size (-1: Unknown) */
    nsub: isize, // Number of subunits */
    devnm: [L_DEVNM]u8, // Physical device name */
};

//Common attribute data number
//RW: Readable (tk_rea_dev)/writable (tk_wri_dev)
//R-: Readable (tk_rea_dev) only */
pub const TDN_EVENT = -1; // RW:Message buffer isize for event notification */
pub const TDN_DISKINFO = -2; // R-:Disk information */
pub const TDN_DISPSPEC = -3; // R-:Display device specification */
pub const TDN_PCMCIAINFO = -4; // R-:PC card information */

// Device event type */
pub const TDEvtTyp = enum(usize) {
    TDE_unknown = 0, // Undefined */
    TDE_MOUNT = 0x01, // Media insert */
    TDE_EJECT = 0x02, // Media eject */
    TDE_ILLMOUNT = 0x03, // Media incorrect insert */
    TDE_ILLEJECT = 0x04, // Media incorrect eject */
    TDE_REMOUNT = 0x05, // Media re-insert */
    TDE_CARDBATLOW = 0x06, // Card battery low */
    TDE_CARDBATFAIL = 0x07, // Card battery abnormal */
    TDE_REQEJECT = 0x08, // Media eject request */
    TDE_PDBUT = 0x11, // PD button state change */
    TDE_PDMOVE = 0x12, // PD position move */
    TDE_PDSTATE = 0x13, // PD state change */
    TDE_PDEXT = 0x14, // PD extended event */
    TDE_KEYDOWN = 0x21, // Key down */
    TDE_KEYUP = 0x22, // Key up */
    TDE_KEYMETA = 0x23, // Meta key state change */
    TDE_POWEROFF = 0x31, // Power switch off */
    TDE_POWERLOW = 0x32, // Power low */
    TDE_POWERFAIL = 0x33, // Power abnormal */
    TDE_POWERSUS = 0x34, // Automatic suspend */
    TDE_POWERUPTM = 0x35, // Clock update */
    TDE_CKPWON = 0x41, // Automatic power on notification */
};

// Device event message format */
pub const T_DEVEVT = struct {
    evttyp: TDEvtTyp, // Event type */
    // Information by each event type is added below */
};

// Device event message format with device isize */
pub const T_DEVEVT_ID = struct {
    evttyp: TDEvtTyp, // Event type */
    devid: isize, // Device isize */
    // Information by each event type is added below */
};

//Device registration information */
pub const T_DDEV = struct {
    exinf: *void, // Extended information */
    drvatr: u32, // Driver attribute */
    devatr: u32, // Device attribute */
    nsub: isize, // Number of subunits */
    blksz: i32, // Specific data block size (-1: Unknown) */
    openfn: isize, // Open function */
    closef: isize, // Close function */
    execf: isize, // Execute function */
    waitf: isize, // Completion wait function */
    abortf: isize, // Abort function */
    eventf: isize, // Event function */
};

// Open function:
//ER  openfn( isize devid, usize omode, void *exinf )
//Close function:
//ER  closefn( isize devid, usize option, void *exinf )
//Execute function:
//ER  execfn( T_DEVREQ *devreq, i32 tmout, void *exinf )
//Completion wait function:
//isize waitfn( T_DEVREQ *devreq, isize nreq, i32 tmout, void *exinf )
//Abort function:
//ER  abortfn( isize tskid, T_DEVREQ *devreq, isize nreq, void *exinf)
//Event function:
//isize eventfn( isize evttyp, void *evtinf, void *exinf )

// Driver attribute
pub const TDA_OPENREQ = 0x0001; // Every time open/close */

// Device initial setting information */
pub const T_IDEV = struct {
    evtmbfid: isize, // Message buffer isize for event notification */
};

// Device request packet
// I: Input parameter
// O: Output parameter
pub const T_DEVREQ = struct {
    next: ?*T_DEVREQ, // I:Link to request packet (null:End) */
    exinf: *void, // X:Extended information */
    devid: isize, // I:Target device isize */
    cmd: isize = 4, // I:Request command */
    abort: bool = true, // I:When executing abort request, true */
    start: i32, // I:Start data number */
    size: i32, // I:Request size */
    buf: *void, // I:Input/output buffer address */
    asize: i32, // O:Result size */
    err: TkError, // O:Result error */
};

// Request command */
pub const TDC_READ = 1; // Read request */
pub const TDC_WRITE = 2; // Write request */

// Driver request event */
pub const TDV_SUSPEND = -1; // Suspend */
pub const TDV_RESUME = -2; // Resume */
pub const TDV_CARDEVT = 1; // PC card event (Refer card manager) */
pub const TDV_USBEVT = 2; // USB event     (Refer USB manager) */

// System call prototype declaration */
// pub const isize tk_cre_tsk( CONST T_CTSK *pk_ctsk );
// pub const ER tk_del_tsk( isize tskid );
// pub const ER tk_sta_tsk( isize tskid, isize stacd );
// pub const void tk_ext_tsk( void );
// pub const void tk_exd_tsk( void );
// pub const ER tk_ter_tsk( isize tskid );
// pub const ER tk_dis_dsp( void );
// pub const ER tk_ena_dsp( void );
// pub const ER tk_chg_pri( isize tskid, isize tskpri );
// pub const ER tk_rot_rdq( isize tskpri );
// pub const ER tk_rel_wai( isize tskid );
// pub const isize tk_get_tid( void );
// pub const ER tk_ref_tsk( isize tskid, T_RTSK *pk_rtsk );
// pub const ER tk_sus_tsk( isize tskid );
// pub const ER tk_rsm_tsk( isize tskid );
// pub const ER tk_frsm_tsk( isize tskid );
// pub const ER tk_slp_tsk( i32 tmout );
// pub const ER tk_wup_tsk( isize tskid );
// pub const isize tk_can_wup( isize tskid );
// pub const ER tk_dly_tsk( u32 dlytim );

// if (comptime  TK_SUPPORT_REGOPS) {
//     // pub const ER tk_get_reg( isize tskid, T_REGS *pk_regs, T_EIT *pk_eit, T_CREGS *pk_cregs );
//     // pub const ER tk_set_reg( isize tskid, CONST T_REGS *pk_regs, CONST T_EIT *pk_eit, CONST T_CREGS *pk_cregs );
// } // TK_SUPPORT_REGOPS */

// if (comptime  NUM_COPROCESSOR > 0) {
//     // pub const ER tk_get_cpr( isize tskid, isize copno, T_COPREGS *pk_copregs);
//     // pub const ER tk_set_cpr(isize tskid, isize copno, CONST T_COPREGS *pk_copregs);
// }

// pub const isize tk_cre_sem( CONST T_CSEM *pk_csem );
// pub const ER tk_del_sem( isize semid );
// pub const ER tk_sig_sem( isize semid, isize cnt );
// pub const ER tk_wai_sem( isize semid, isize cnt, i32 tmout );
// pub const ER tk_ref_sem( isize semid, T_RSEM *pk_rsem );
//
// pub const isize tk_cre_mtx( CONST T_CMTX *pk_cmtx );
// pub const ER tk_del_mtx( isize mtxid );
// pub const ER tk_loc_mtx( isize mtxid, i32 tmout );
// pub const ER tk_unl_mtx( isize mtxid );
// pub const ER tk_ref_mtx( isize mtxid, T_RMTX *pk_rmtx );
//
// pub const isize tk_cre_flg( CONST T_CFLG *pk_cflg );
// pub const ER tk_del_flg( isize flgid );
// pub const ER tk_set_flg( isize flgid, usize setptn );
// pub const ER tk_clr_flg( isize flgid, usize clrptn );
// pub const ER tk_wai_flg( isize flgid, usize waiptn, usize wfmode, usize *p_flgptn, i32 tmout );
// pub const ER tk_ref_flg( isize flgid, T_RFLG *pk_rflg );
//
// pub const isize tk_cre_mbx( CONST T_CMBX* pk_cmbx );
// pub const ER tk_del_mbx( isize mbxid );
// pub const ER tk_snd_mbx( isize mbxid, T_MSG *pk_msg );
// pub const ER tk_rcv_mbx( isize mbxid, T_MSG **ppk_msg, i32 tmout );
// pub const ER tk_ref_mbx( isize mbxid, T_RMBX *pk_rmbx );
// pub const isize tk_cre_mbf( CONST T_CMBF *pk_cmbf );
// pub const ER tk_del_mbf( isize mbfid );
// pub const ER tk_snd_mbf( isize mbfid, CONST void *msg, isize msgsz, i32 tmout );
// pub const isize tk_rcv_mbf( isize mbfid, void *msg, i32 tmout );
// pub const ER tk_ref_mbf( isize mbfid, T_RMBF *pk_rmbf );
//
// pub const isize tk_cre_por( CONST T_CPOR *pk_cpor );
// pub const ER tk_del_por( isize porid );
// pub const isize tk_cal_por( isize porid, usize calptn, void *msg, isize cmsgsz, i32 tmout );
// pub const isize tk_acp_por( isize porid, usize acpptn, RNO *p_rdvno, void *msg, i32 tmout );
// pub const ER tk_fwd_por( isize porid, usize calptn, RNO rdvno, CONST void *msg, isize cmsgsz );
// pub const ER tk_rpl_rdv( RNO rdvno, CONST void *msg, isize rmsgsz );
// pub const ER tk_ref_por( isize porid, T_RPOR *pk_rpor );
//
// pub const ER tk_def_int( usize intno, CONST T_Disize *pk_dint );
// pub const void tk_ret_int( void );
//
// pub const isize tk_cre_mpl( CONST T_CMPL *pk_cmpl );
// pub const ER tk_del_mpl( isize mplid );
// pub const ER tk_get_mpl( isize mplid, isize blksz, void **p_blk, i32 tmout );
// pub const ER tk_rel_mpl( isize mplid, void *blk );
// pub const ER tk_ref_mpl( isize mplid, T_RMPL *pk_rmpl );
//
// pub const isize tk_cre_mpf( CONST T_CMPF *pk_cmpf );
// pub const ER tk_del_mpf( isize mpfid );
// pub const ER tk_get_mpf( isize mpfid, void **p_blf, i32 tmout );
// pub const ER tk_rel_mpf( isize mpfid, void *blf );
// pub const ER tk_ref_mpf( isize mpfid, T_RMPF *pk_rmpf );
//
// pub const ER tk_set_utc( CONST SYSTIM *pk_tim );
// pub const ER tk_get_utc( SYSTIM *pk_tim );
// pub const ER tk_set_tim( CONST SYSTIM *pk_tim );
// pub const ER tk_get_tim( SYSTIM *pk_tim );
// pub const ER tk_get_otm( SYSTIM *pk_tim );
//
// pub const isize tk_cre_cyc( CONST T_CCYC *pk_ccyc );
// pub const ER tk_del_cyc( isize cycid );
// pub const ER tk_sta_cyc( isize cycid );
// pub const ER tk_stp_cyc( isize cycid );
// pub const ER tk_ref_cyc( isize cycid, T_RCYC *pk_rcyc );
//
// pub const isize tk_cre_alm( CONST T_CALM *pk_calm );
// pub const ER tk_del_alm( isize almid );
// pub const ER tk_sta_alm( isize almid, u32 almtim );
// pub const ER tk_stp_alm( isize almid );
// pub const ER tk_ref_alm( isize almid, T_RALM *pk_ralm );
//
// pub const ER tk_ref_sys( T_RSYS *pk_rsys );
// pub const ER tk_set_pow( usize powmode);
// pub const ER tk_ref_ver( T_RVER *pk_rver );
//
// pub const ER tk_def_ssy( isize ssid, CONST T_DSSY *pk_dssy );
// pub const ER tk_ref_ssy( isize ssid, T_RSSY *pk_rssy );
//
// pub const isize tk_opn_dev( CONST u8 *devnm, usize omode );
// pub const ER tk_cls_dev( isize dd, usize option );
// pub const isize tk_rea_dev( isize dd, W start, void *buf, isize size, i32 tmout );
// pub const ER tk_srea_dev( isize dd, W start, void *buf, isize size, isize *asize );
// pub const isize tk_wri_dev( isize dd, W start, CONST void *buf, isize size, i32 tmout );
// pub const ER tk_swri_dev( isize dd, W start, CONST void *buf, isize size, isize *asize );
// pub const isize tk_wai_dev( isize dd, isize reqid, isize *asize, ER *ioer, i32 tmout );
// pub const isize tk_sus_dev( usize mode );
// pub const isize tk_get_dev( isize devid, u8 *devnm );
// pub const isize tk_ref_dev( CONST u8 *devnm, T_RDEV *pk_rdev );
// pub const isize tk_oref_dev( isize dd, T_RDEV *pk_rdev );
// pub const isize tk_lst_dev( T_LDEV *pk_ldev, isize start, isize ndev );
// pub const isize tk_evt_dev( isize devid, isize evttyp, void *evtinf );
// pub const isize tk_def_dev( CONST u8 *devnm, CONST T_DDEV *pk_ddev, T_isizeEV *pk_idev );
// pub const ER tk_ref_idv( T_isizeEV *pk_idev );
