///	User Configuration Definition for function
pub const USE_SEMAPHORE = false;
pub const USE_MUTEX = false;
pub const USE_EVENTFLAG = false;
pub const USE_MAILBOX = false;
pub const USE_MESSAGEBUFFER = false;
pub const USE_RENDEZVOUS = false;
pub const USE_MEMORYPOOL = false;
pub const USE_FIX_MEMORYPOOL = false;
pub const USE_TIMEMANAGEMENT = false;
pub const USE_CYCLICHANDLER = false;
pub const USE_ALARMHANDLER = false;
pub const USE_DEVICE = false;
pub const USE_FAST_LOCK = false;
pub const USE_MULTI_LOCK = false;

// Task management
pub const USE_FUNC_TK_DEL_TSK = false;
pub const USE_FUNC_TK_EXT_TSK = false;
pub const USE_FUNC_TK_EXD_TSK = true;
pub const USE_FUNC_TK_TER_TSK = false;
pub const USE_FUNC_TK_CHG_PRI = false;
pub const USE_FUNC_TK_REL_WAI = false;
pub const USE_FUNC_TK_GET_REG = false;
pub const USE_FUNC_TK_SET_REG = false;
pub const USE_FUNC_TK_GET_CPR = false;
pub const USE_FUNC_TK_SET_CPR = false;
pub const USE_FUNC_TK_REF_TSK = false;
pub const USE_FUNC_TK_SUS_TSK = false;
pub const USE_FUNC_TK_RSM_TSK = false;
pub const USE_FUNC_TK_FRSM_TSK = false;
pub const USE_FUNC_TK_SLP_TSK = false;
pub const USE_FUNC_TK_WUP_TSK = false;
pub const USE_FUNC_TK_CAN_WUP = false;
pub const USE_FUNC_TK_DLY_TSK = false;
pub const USE_FUNC_TD_LST_TSK = false;
pub const USE_FUNC_TD_REF_TSK = false;
pub const USE_FUNC_TD_INF_TSK = false;
pub const USE_FUNC_TD_GET_REG = false;
pub const USE_FUNC_TD_SET_REG = false;

// Semaphore management API
pub const USE_FUNC_TK_DEL_SEM = false;
pub const USE_FUNC_TK_REF_SEM = false;
pub const USE_FUNC_TD_LST_SEM = false;
pub const USE_FUNC_TD_REF_SEM = false;
pub const USE_FUNC_TD_SEM_QUE = false;

// Mutex management API
pub const USE_FUNC_TK_DEL_MTX = false;
pub const USE_FUNC_TK_REF_MTX = false;
pub const USE_FUNC_TD_LST_MTX = false;
pub const USE_FUNC_TD_REF_MTX = false;
pub const USE_FUNC_TD_MTX_QUE = false;

// Event flag management API
pub const USE_FUNC_TK_DEL_FLG = false;
pub const USE_FUNC_TK_REF_FLG = false;
pub const USE_FUNC_TD_LST_FLG = false;
pub const USE_FUNC_TD_REF_FLG = false;
pub const USE_FUNC_TD_FLG_QUE = false;

// Mailbox management API
pub const USE_FUNC_TK_DEL_MBX = false;
pub const USE_FUNC_TK_REF_MBX = false;
pub const USE_FUNC_TD_LST_MBX = false;
pub const USE_FUNC_TD_REF_MBX = false;
pub const USE_FUNC_TD_MBX_QUE = false;

// Messagebuffer management API
pub const USE_FUNC_TK_DEL_MBF = false;
pub const USE_FUNC_TK_REF_MBF = false;
pub const USE_FUNC_TD_LST_MBF = false;
pub const USE_FUNC_TD_REF_MBF = false;
pub const USE_FUNC_TD_SMBF_QUE = false;
pub const USE_FUNC_TD_RMBF_QUE = false;

// Rendezvous management API (Legacy API);
pub const USE_FUNC_TK_DEL_POR = false;
pub const USE_FUNC_TK_FWD_POR = false;
pub const USE_FUNC_TK_REF_POR = false;
pub const USE_FUNC_TD_LST_POR = false;
pub const USE_FUNC_TD_REF_POR = false;
pub const USE_FUNC_TD_CAL_QUE = false;
pub const USE_FUNC_TD_ACP_QUE = false;

// Memory pool management API
pub const USE_FUNC_TK_DEL_MPL = false;
pub const USE_FUNC_TK_REF_MPL = false;
pub const USE_FUNC_TD_LST_MPL = false;
pub const USE_FUNC_TD_REF_MPL = false;
pub const USE_FUNC_TD_MPL_QUE = false;

// Fix-Memory Pool management API
pub const USE_FUNC_TK_DEL_MPF = false;
pub const USE_FUNC_TK_REF_MPF = false;
pub const USE_FUNC_TD_LST_MPF = false;
pub const USE_FUNC_TD_REF_MPF = false;
pub const USE_FUNC_TD_MPF_QUE = false;

// Time management API
pub const USE_FUNC_TK_SET_UTC = false;
pub const USE_FUNC_TK_GET_UTC = false;
pub const USE_FUNC_TK_SET_TIM = false;
pub const USE_FUNC_TK_GET_TIM = false;
pub const USE_FUNC_TK_GET_OTM = false;
pub const USE_FUNC_TD_GET_TIM = false;
pub const USE_FUNC_TD_GET_OTM = false;

// Cyclic handler management API
pub const USE_FUNC_TK_DEL_CYC = false;
pub const USE_FUNC_TK_STA_CYC = false;
pub const USE_FUNC_TK_STP_CYC = false;
pub const USE_FUNC_TK_REF_CYC = false;
pub const USE_FUNC_TD_LST_CYC = false;
pub const USE_FUNC_TD_REF_CYC = false;

// Alarm handler management API
pub const USE_FUNC_TK_DEL_ALM = false;
pub const USE_FUNC_TK_STP_ALM = false;
pub const USE_FUNC_TK_REF_ALM = false;
pub const USE_FUNC_TD_LST_ALM = false;
pub const USE_FUNC_TD_REF_ALM = false;

// System status management API
pub const USE_FUNC_TK_ROT_RDQ = false;
pub const USE_FUNC_TK_GET_TID = false;
pub const USE_FUNC_TK_DIS_DSP = false;
pub const USE_FUNC_TK_ENA_DSP = false;
pub const USE_FUNC_TK_REF_SYS = false;
pub const USE_FUNC_TK_REF_VER = false;
pub const USE_FUNC_TD_REF_SYS = false;
pub const USE_FUNC_TD_RDY_QUE = false;
