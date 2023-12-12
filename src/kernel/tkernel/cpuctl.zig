//	cpuctl.c CPU Control

// Dispatch disable
// if (comptime USE_FUNC_TK_DIS_DSP) {
//     pub fn tk_dis_dsp() TkError!void {
//         CHECK_CTX(!in_loc());
//         knl_dispatch_disabled = DDS_DISABLE;
//         return E_OK;
//     }
// }

//Dispatch enable
// if (comptime USE_FUNC_TK_ENA_DSP) {
//     pub fn tk_ena_dsp() TkError!void {
//         CHECK_CTX(!in_loc());
//         knl_dispatch_disabled = DDS_ENABLE;
//         if ( knl_ctxtsk != knl_schedtsk ) {
//             knl_dispatch();
//         }
//         return E_OK;
//     }
// }

// if (comptime TK_SUPPORT_REGOPS) {
//     if (comptime USE_FUNC_TK_SET_REG) {
//         ////Set task register contents
//         pub fn tk_set_reg( tskid: isize, pk_regs: *const T_REGS, pk_eit: *const T_EIT, pk_cregs: *const T_CREGS) TkError!void {
//             CHECK_IDSK();
//             CHECK_TSKID(tskid);
//             CHECK_NONSELF(tskid);
//
//             var tcb: *TCB = get_tcb(tskid);
//
//             BEGIN_CRITICAL_SECTION;
//             defer END_CRITICAL_SECTION;
//             if ( tcb.state == TSTAT.TS_NONEXIST ) {
//                 return TkError.E_NOEXS;
//             } else {
//                 knl_set_reg(tcb, pk_regs, pk_eit, pk_cregs);
//             }
//
//             // return ercd;
//         }
//
//         ////Get task register contents
//         pub fn tk_get_reg(tskid: isize, pk_regs: *const T_REGS, pk_eit: *const T_EIT, pk_cregs: *const T_CREGS ) TkError!void {
//             CHECK_IDSK();
//             CHECK_TSKID(tskid);
//             CHECK_NONSELF(tskid);
//
//             var tcb: *TCB = get_tcb(tskid);
//
//             BEGIN_CRITICAL_SECTION;
//             defer END_CRITICAL_SECTION;
//             if ( tcb.state == TSTAT.TS_NONEXIST ) {
//                 // ercd = E_NOEXS;
//         } else {
//                 knl_get_reg(tcb, pk_regs, pk_eit, pk_cregs);
//             }
//
//             return ercd;
//         }
//     }
// }

// if (comptime NUM_COPROCESSOR > 0 ) {
//     if (comptime USE_FUNC_TK_SET_CPR ) {
//         // Set coprocessor registers contents
//         pub fn tk_set_cpr( tskid: isize, copno: isize, pk_copregs: *const T_COPREGS ) TkError!void {
//             CHECK_IDSK();
//             CHECK_TSKID(tskid);
//             CHECK_NONSELF(tskid);
//
//             var tcb: *TCB = get_tcb(tskid);
//             if((copno < 0)  or (copno >= NUM_COPROCESSOR)
//             or !(tcb.tskatr & (TA_COP0 << copno))) {
//                 return TkError.E_PAR;
//             }
//
//             BEGIN_CRITICAL_SECTION;
//             defer END_CRITICAL_SECTION;
//             if ( tcb.state == TSTAT.TS_NONEXIST ) {
//                 return TkError.E_NOEXS;
//         } else {
//                 try knl_set_cpr(tcb, copno, pk_copregs);
//             }
//
//             // return ercd;
//         }
//     }
//
//     if (comptime USE_FUNC_TK_GET_CPR) {
//         // ////Get coprocessor registers contents
//         pub fn tk_get_cpr( tskid: isize, copno: isize, pk_copregs: *const T_COPREGS)
//             TkError!void {
//             CHECK_IDSK();
//             CHECK_TSKID(tskid);
//             CHECK_NONSELF(tskid);
//
//             tcb = get_tcb(tskid);
//             var tcb: *TCB = get_tcb(tskid);
//             if((copno < 0)  or (copno >= NUM_COPROCESSOR)
//                 or !(tcb.tskatr & (TA_COP0 << copno))) {
//                 return TkError.E_PAR;
//             }
//
//             BEGIN_CRITICAL_SECTION;
//             if ( tcb.state == TSTAT.TS_NONEXIST ) {
//                 END_CRITICAL_SECTION;
//                 return TkError.E_NOEXS;
//         } else {
//                 knl_get_cpr(tcb, copno, pk_copregs) catch |err| {
//                     END_CRITICAL_SECTION;
//                     return err;
//                 }
//             }
//             // return ercd;
//         }
//     }
// }

// if (comptime USE_DBGSPT) {
//     if (comptime TK_SUPPORT_REGOPS) {
//             if (comptime USE_FUNC_TD_SET_REG) {
//             ////Set task register
//             pub fn td_set_reg( tskid: isize, regs: *const T_REGS, eit: *const T_EIT,
//                     cregs: *const T_CREGS ) TkError!void {
//                     CHECK_TSKisize(tskid);
//
//                     var tcb: *TCB = get_tcb(tskid);
//                     if ( tcb == knl_ctxtsk ) {
//                             return TkError.E_OBJ;
//                     }
//
// 	        BEGIN_DISABLE_INTERRUPT;
// 	        defer END_DISABLE_INTERRUPT;
//                     if ( tcb.state == TSTAT.TS_NONEXIST ) {
//                         return TkError.E_NOEXS;
//                     } else {
//                         knl_set_reg(tcb, regs, eit, cregs) catch |err| {
//                             return err;
//                         }
//                     }
//             }
//             }
//     if (comptime USTkError.E_FUNC_TD_GET_REG) {
//         ////Get task register
//         pub fn td_get_reg( tskid: isize, regs: *const T_REGS, eit: *const T_EIT,
//                             cregs: *const T_CREGS ) TkError!void {
//                 CHECK_TSKisize(tskid);
//
//                 var tcb: *TCB = get_tcb(tskid);
//                 if ( tcb == knl_ctxtsk ) {
//                         return TkError.E_OBJ;
//                 }
//
// 	        BEGIN_DISABLE_INTERRUPT;
// 	        defer END_DISABLE_INTERRUPT;
//                 if ( tcb.state == TSTAT.TS_NONEXIST ) {
//                     return TkError.E_NOEXS;
//                 } else {
//                     knl_get_reg(tcb, regs, eit, cregs) catch |err| {
//                         return err;
//                     }
//                 }
//                 // return ercd;
//         }
//     }
// }
// }
