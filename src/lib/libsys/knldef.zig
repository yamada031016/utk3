const knlink = @import("knlink");
const config = @import("config");
const libtk = @import("libtk");
const PRI = libtk.typedef.PRI;
const ID = libtk.typedef.ID;
//micro T-Kernel system definition form Configulation

// Check configuration data */
// if (comptime ( CNF_TIMER_PERIOD < MIN_TIMER_PERIOD or CNF_TIMER_PERIOD > MAX_TIMER_PERIOD )) {
// // # error "CNF_TIMER_PERIOD is out of range."
// }
//
// if (comptime  CNF_MAX_TSKPRI < 16) {
// // # error "The maximum task priority must be 16 or higher."
// }
//
// if (comptime  USE_PTMR and !CPU_HAS_PTMR) {
// // # error "USE_PTMR cannot be specified."
// }
//
// if (comptime  USE_FPU and !CPU_HAS_FPU) {
// // # error "USE_FPU cannot be specified."
// }
//
// if (comptime  USE_DSP and !CPU_HAS_DSP) {
// // # error "USE_DSP cannot be specified."
// }

// System memory area definition */
pub const SYSTEMAREA_TOP = config.CNF_SYSTEMAREA_TOP;
pub const SYSTEMAREA_END = config.CNF_SYSTEMAREA_END;

// Task priority configuration */
pub const MIN_TSKPRI = 1; // Minimum priority number = highest priority */
pub const MAX_TSKPRI = config.CNF_MAX_TSKPRI; // Maximum priority number = lowest priority */
pub const NUM_TSKPRI = config.CNF_MAX_TSKPRI; // Number of priority levels */
pub fn CHK_PRI(pri: PRI) bool {
    return (MIN_TSKPRI <= pri and pri <= MAX_TSKPRI);
}

// System Timer period
pub const TIMER_PERIOD = config.CNF_TIMER_PERIOD;

// Kernel object configuration */

// Task configuration */
pub const MIN_TSKID = 1;
pub const MAX_TSKID = config.CNF_MAX_TSKID;
pub const NUM_TSKID = MAX_TSKID;
pub fn CHK_TSKID(id: isize) bool {
    return (MIN_TSKPRI <= id and id <= MAX_TSKPRI);
}
pub fn INDEX_TSK(id: usize) usize {
    return (id - MIN_TSKPRI);
}
pub fn ID_TSK(index: isize) isize {
    return (index + MIN_TSKPRI);
}

// Semaphore configuration */
// if (comptime  USE_SEMAPHORE) {
// pub const MAX_SEMID	=CNF_MAX_SEMID;
// pub const MIN_SEMID	=1;
// pub const NUM_SEMID	=MAX_SEMID;
// pub fn CHK_SEMID(id: isize) bool {return (MIN_SEMID <= id and id <= MAX_SEMID);}
// pub fn INDEX_SEM(id: isize) isize {return (id-MIN_SEMID);}
// pub fn ID_SEM(index: isize) isize {return (index+MIN_SEMID);}
// }else{
pub const MAX_SEMID = 0;
// }

// Event flag configuration */
// if (comptime  USE_EVENTFLAG) {
// pub const MIN_FLGID	=1;
// pub const MAX_FLGID	=CNF_MAX_FLGID;
// pub const NUM_FLGID	=MAX_FLGID;
// pub fn CHK_FLGID(id: isize) bool {return (MIN_FLGID <= id and id <= MAX_FLGID);}
// pub fn INDEX_FLG(id: isize) isize {return (id-MIN_FLGID);}
// pub fn ID_FLG(index: isize)isize{return (index+MIN_FLGID);}
// }else {
pub const MAX_FLGID = 0;
// }

// Mailbox configuration */
// if (comptime  USE_MAILBOX) {
// pub const MIN_MBXID	=1;
// pub const MAX_MBXID	=CNF_MAX_MBXID;
// pub const NUM_MBXID	=MAX_MBXID;
// pub fn CHK_MBXID(id: isize) bool {return (MIN_MBXID <= id and id <= MAX_MBXID);}
// pub fn INDEX_MBX(id: isize) isize {return (id-MIN_MBXID);}
// pub fn ID_MBX(index: isize) isize {return (index+MIN_MBXID);}
// }else {
pub const MAX_MBXID = 0;
// }

// Mutex configuration */
// if (comptime  USE_MUTEX) {
// pub const MIN_MTXID	=1;
// pub const MAX_MTXID	=CNF_MAX_MTXID;
// pub const NUM_MTXID	=MAX_MTXID;
// pub fn CHK_MTXID(id: isize) bool {return (MIN_MTXID <= id and id <= MAX_MTXID);}
// pub fn INDEX_MTX(id: isize) isize {return (id-MIN_MTXID);}
// pub fn ID_MTX(index: isize) isize {return (index+MIN_MTXID);}
// }else {
pub const NUM_MTXID = 0;
// }

// Message buffer configuration */
// if (comptime  USE_MESSAGEBUFFER) {
// pub const MIN_MBFID	=1;
// pub const MAX_MBFID	=CNF_MAX_MBFID;
// pub const NUM_MBFID	=MAX_MBFID;
// pub fn CHK_MBFID(id: isize)	 bool {return (MIN_MBFID <= id and id <= MAX_MBFID);}
// pub fn INDEX_MBF(id: isize) isize {return 	(id-MIN_MBFID);}
// pub fn ID_MBF(index: isize) isize {return 	(index+MIN_MBFID);}
// }else {
pub const MAX_MBFID = 0;
// }

// Memory pool configuration */
// if (comptime  USE_MEMORYPOOL) {
// pub const MIN_MPLID	=1;
// pub const MAX_MPLID	=CNF_MAX_MPLID;
// pub const NUM_MPLID	=MAX_MPLID;
// pub fn CHK_MPLID(id: isize)	 bool {return (MIN_MPLID <= id and id <= MAX_MPLID);}
// pub fn INDEX_MPL(id: isize) isize {return 	(id-MIN_MPLID);}
// pub fn ID_MPL(index: isize) isize {return 	(index+MIN_MPLID);}
// }else {
pub const MAX_MPLID = 0;
// }

// Fixed size memory pool configuration */
// if (comptime  USE_FIX_MEMORYPOOL) {
// pub const MIN_MPFID	=1;
// pub const MAX_MPFID	=CNF_MAX_MPFID;
// pub const NUM_MPFID	=MAX_MPFID;
// pub fn CHK_MPFID(id: isize)	 bool {return (MIN_MPFID <= id and id <= MAX_MPFID);}
// pub fn INDEX_MPF(id: isize) isize {return 	(id-MIN_MPFID);}
// pub fn isize_MPF(index: isize) isize {return 	(index+MIN_MPFID);}
// }else {
pub const MAX_MPFID = 0;
// }

// Cyclic handler configuration */
// if (comptime  USE_CYCLICHANDLER) {
// pub const MIN_CYCID	=1;
// pub const MAX_CYCID	=CNF_MAX_CYCID;
// pub const NUM_CYCID	=MAX_CYCID;
// pub fn CHK_CYCID(id: isize)	 bool {return (MIN_CYCID <= id and id <= MAX_CYCID);}
// pub fn INDEX_CYC(id: isize) isize {return 	(id-MIN_CYCID);}
// pub fn isize_CYC(index: isize) isize {return 	(index+MIN_CYCID);}
// }else {
pub const MAX_CYCID = 0;
// }

// Alarm handler configuration */
// if (comptime  USE_ALARMHANDLER) {
// pub const MIN_ALMID	=1;
// pub const MAX_ALMID	=CNF_MAX_ALMID;
// pub const NUM_ALMID	=MAX_ALMID;
// pub fn CHK_ALMID(id: isize)	 bool {return (MIN_ALMID <= id and id <= MAX_ALMID);}
// pub fn INDEX_ALM(id: isize) isize {return 	(id-MIN_ALMID);}
// pub fn isize_ALM(index: isize) isize {return 	(index+MIN_ALMID);}
// }else {
pub const MAX_ALMID = 0;
// }

// Rendezvous configuration */
// if (comptime  USE_LEGACY_API and USE_RENDEZVOUS) {
// pub const MIN_PORID	=1;
// pub const MAX_PORID	=CNF_MAX_PORID;
// pub const NUM_PORID	=MAX_PORID;
// pub fn CHK_PORID(id: isize)	 bool {return (MIN_PORID <= id and id <= MAX_PORID);}
// pub fn INDEX_POR(id: isize) isize {return (id-MIN_PORID);}
// pub fn isize_POR(index: isize) isize {return (index+MIN_PORID);}
// }else {
pub const MAX_PORID = 0;
// } // USE_LEGACY_API and USE_RENDEZVOUS */

// Device configuration */
// if (comptime  USE_DEVICE) {
// pub const MAX_REGDEV	=CNF_MAX_REGDEV;
// pub const MAX_OPNDEV	=CNF_MAX_OPNDEV;
// pub const MAX_REQDEV	=CNF_MAX_REQDEV;
// pub const DEVT_MBFSZ0	=CNF_DEVT_MBFSZ0;
// pub const DEVT_MBFSZ1	=CNF_DEVT_MBFSZ1;
// }else {
pub const MAX_REGDEV = 0;
// } // USE_DEVICE */

// Stack size definition */
pub const EXC_STACK_SIZE = config.CNF_EXC_STACK_SIZE;
pub const TMP_STACK_SIZE = config.CNF_TMP_STACK_SIZE;

// Version Number */
pub const VER_MAKER = config.CNF_VER_MAKER;
pub const VER_PRID = config.CNF_VER_PRID;
pub const VER_MAJOR = 3;
pub const VER_MINOR = 0;
pub const VER_SPVER = (0x6000 | (VER_MAJOR << 8) | VER_MINOR);
pub const VER_PRVER = config.CNF_VER_PRVER;
pub const VER_PRNO1 = config.CNF_VER_PRNO1;
pub const VER_PRNO2 = config.CNF_VER_PRNO2;
pub const VER_PRNO3 = config.CNF_VER_PRNO3;
pub const VER_PRNO4 = config.CNF_VER_PRNO4;
