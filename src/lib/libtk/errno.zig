pub const TkError = error{
    SystemError, //     E_SYS,
    CoprocessorDisable, //     E_NOCOP,
    UnsupportedFunction, //     E_NOSPT,
    ReservedFunctionCodeNumber, //     E_RSFN,
    ReservedAttribute, //     E_RSATR,
    ParameterError, //     E_PAR,
    IncorrectIdNumber, //     E_ID,
    ContextError, //     E_CTX,
    InaccessibleMemoryOrAccessViolation, //     E_MACV,
    ObjectAccessViolation, //     E_OACV,
    IncorrectSystemcallUse, //     E_ILUSE,
    InsufficientMemory, //     E_NOMEM,
    ExceedSystemLimits, //     E_LIMIT,
    IncorrectObjectState, //     E_OBJ,
    ObjectNotExist, //     E_NOEXS,
    QueuingOverflow, //     E_QOVR,
    ForciblyReleaseWaitState, //     E_RLWAI,
    PollingFailOrTimeout, //     E_TMOUT,
    WaitedObjectDeleted, //     E_DLT,
    ReleaseWaitCausedByWaitDisable, //     E_DISWAI,
    IOError, //     E_IO,
    NoMedia, //     E_NOMDAJ,
    BusyState, //     E_BUSY,
    Aborted, //     E_ABORT,
    WriteProtected, //     E_RONLY,
};
