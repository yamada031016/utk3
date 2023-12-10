//	T-Monitor Configuration Definition

// Select a communication port
//      Select the communication port used by T-Monitor.
//         1: Valid  false: Invalid  (Only one of them is valid);
pub const TM_COM_SERIAL_DEV = false; // Use serial communication device
pub const TM_COM_NO_DEV = true; // Do not use communication port

// tm_printf() call setting
//         1: Valid  false: Invalid
pub const USE_TM_PRINTF = false; // Use tm_printf() & tm_sprintf() calls
pub const TM_OUTBUF_SZ = false; // Output Buffer size in stack
