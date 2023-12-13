// *	power-saving function
// const knlink = @import("knlink");
// const inc_sys = @import("inc_sys");
// const queue = inc_sys.queue;
// const QUEUE = queue.QUEUE;

// #include "kernel.h"
// #include "check.h"

// * Number of times for disabling power-saving mode switch
// *	If it is 0, the mode switch is enabled.

// if( TK_SUPPORT_LOWPOWER) {
// pub var knl_lowpow_discnt: usize = 0;
// // //
// //  * Set Power-saving mode
// //  */
// // SYSCALL ER tk_set_pow( UINT pwmode )
// // {
// // 	ER	ercd = E_OK;
// //
// // 	CHECK_INTSK();
// //
// // 	BEGIN_CRITICAL_SECTION;
// //
// // 	switch ( pwmode ) {
// // 	  case TPW_DOSUSPEND:
// // 		off_pow();
// // 		break;
// // 	  case TPW_DISLOWPOW:
// // 		if ( knl_lowpow_discnt >= LOWPOW_LIMIT ) {
// // 			ercd = E_QOVR;
// // 		} else {
// // 			knl_lowpow_discnt++;
// // 		}
// // 		break;
// // 	  case TPW_ENALOWPOW:
// // 		if ( knl_lowpow_discnt <= 0 ) {
// // 			ercd = E_OBJ;
// // 		} else {
// // 			knl_lowpow_discnt--;
// // 		}
// // 		break;
// //
// // 	  default:
// // 		ercd = E_PAR;
// // 	}
// // 	END_CRITICAL_SECTION;
// //
// // 	return ercd;
// // }
// }
