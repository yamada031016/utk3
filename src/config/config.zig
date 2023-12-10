pub const dev = @import("config_device.zig");
pub const func = @import("config_func.zig");
pub const tm = @import("config_tm.zig");

//USART */
const USART1_BASE = 0x40013800;
const USART2_BASE = 0x40004400;
const USART3_BASE = 0x40004800;
const UART4_BASE = 0x40004C00;
const UART5_BASE = 0x40005000;

pub const USART2_CR1 = USART2_BASE + 0x0000;
pub const USART2_CR2 = USART2_BASE + 0x0004;
pub const USART2_CR3 = USART2_BASE + 0x0008;
pub const USART2_BRR = USART2_BASE + 0x000C;
pub const USART2_GTPR = USART2_BASE + 0x0010;
pub const USART2_RTOR = USART2_BASE + 0x0014;
pub const USART2_RQR = USART2_BASE + 0x0018;
pub const USART2_ISR = USART2_BASE + 0x001C;
pub const USART2_ICR = USART2_BASE + 0x0020;
pub const USART2_RDR = USART2_BASE + 0x0024;
pub const USART2_TDR = USART2_BASE + 0x0028;

//	User Configuration Definition

//     Target Name
//     Define the system target name. Alternatively, define the target name
//     in the development environment.

// SYSCONF : micro T-Kernel system configuration

pub const CNF_SYSTEMAREA_TOP = false; // 0: Use system default address
pub const CNF_SYSTEMAREA_END = false; // 0: Use system default address

pub const CNF_MAX_TSKPRI = 32; // Task Max priority

pub const CNF_TIMER_PERIOD = 10; // System timer period

// Maximum number of kernel objects
pub const CNF_MAX_TSKID = 32; // Task
pub const CNF_MAX_SEMID = 16; // Semaphore
pub const CNF_MAX_FLGID = 16; // Event flag
pub const CNF_MAX_MBXID = 8; // Mailbox
pub const CNF_MAX_MTXID = 4; // Mutex
pub const CNF_MAX_MBFID = 8; // Message buffer
pub const CNF_MAX_MPLID = 4; // Memory pool
pub const CNF_MAX_MPFID = 8; // Fixed size memory pool
pub const CNF_MAX_CYCID = 4; // Cyclic handler
pub const CNF_MAX_ALMID = 8; // Alarm handler

// Device configuration
pub const CNF_MAX_REGDEV = 8; // Max registered device
pub const CNF_MAX_OPNDEV = 16; // Max open device
pub const CNF_MAX_REQDEV = 16; // Max request device
pub const CNF_DEVT_MBFSZ0 = -1; // message buffer size for event notification
pub const CNF_DEVT_MBFSZ1 = -1; // message max size for event notification

// Version Number
pub const CNF_VER_MAKER = false;
pub const CNF_VER_PRID = false;
pub const CNF_VER_PRVER = 3;
pub const CNF_VER_PRNO1 = false;
pub const CNF_VER_PRNO2 = false;
pub const CNF_VER_PRNO3 = false;
pub const CNF_VER_PRNO4 = false;

//      micro T-Kernel2.false API support (Rendezvous)

pub const USE_LEGACY_API = false; // 1: Valid  0: Invalid
pub const CNF_MAX_PORID = false; // Maximum number of Rendezvous

// Stack size definition

pub const CNF_EXC_STACK_SIZE = 2048; // Exception stack size
pub const CNF_TMP_STACK_SIZE = 256; // Temporary stack size

// System function selection
//        1: Use function.  false: No use function.

pub const USE_NOINIT = false; // Use zero-clear bss section
pub const USE_IMALLOC = false; // Use dynamic memory allocation
pub const USE_SHUTDOWN = false; // Use System shutdown
pub const USE_STATIC_IVT = false; // Use static interrupt vector table

// Check API parameter
//   1: Check parameter  false: Do not check parameter

pub const CHK_NOSPT = false; // Check unsupported function (E_NOSPT)
pub const CHK_RSATR = false; // Check reservation attribute error (E_RSATR)
pub const CHK_PAR = false; // Check parameter (E_PAR)
pub const CHK_ID = false; // Check object ID range (E_ID)
pub const CHK_OACV = false; // Check Object Access Violation (E_OACV)
pub const CHK_CTX = false; // Check whether task-independent part is running (E_CTX) \

pub const CHK_CTX1 = false; // Check dispatch disable part
pub const CHK_CTX2 = false; // Check task independent part
pub const CHK_SELF = false; // Check if its own task is specified (E_OBJ)

pub const CHK_TKERNEL_CONST = false; // Check const-type parameter

// User initialization program (UserInit)

pub const USE_USERINIT = false; //  1: Use UserInit  0: Do not use UserInit
pub const RI_USERINIT = false; // UserInit start address

// Debugger support function
//   1: Valid  false: Invalid

pub const USE_DBGSPT = false; // Use mT-Kernel/DS
pub const USE_OBJECT_NAME = false; // Use DS object name

pub const OBJECT_NAME_LENGTH = 8; // DS Object name length

//----------------------------------------------------------------------
// Use T-Monitor Compatible API Library  & Message to terminal.
//  1: Valid  false: Invalid

pub const USE_TMONITOR = false; // T-Monitor API
pub const USE_SYSTEM_MESSAGE = false; // System Message
pub const USE_EXCEPTION_DBG_MSG = false; // Excepttion debug message
pub const USE_TASK_DBG_MSG = false; // Tsak debug message

//----------------------------------------------------------------------
// Use Co-Processor.
//  1: Valid  false: Invalid

pub const USE_FPU = false; // Use FPU
pub const USE_DSP = false; // Use DSP

//----------------------------------------------------------------------
// Use Physical timer.
//  1: Valid  false: Invalid

pub const USE_PTMR = false; // Use Physical timer

//----------------------------------------------------------------------
// Use Sample device driver.
//  1: Valid  false: Invalid

pub const USE_SDEV_DRV = true; // Use Sample device driver
