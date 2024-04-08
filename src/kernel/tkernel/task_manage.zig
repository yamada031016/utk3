// *	Task Management FunNextction
const knlink = @import("knlink");
const tstd = knlink.tstd;
const check = knlink.check;
const task = knlink.task;
const TSTAT = task.TSTAT;
// const memory = knlink.memory;
const wait = knlink.wait;
const cpu_task = knlink.sysdepend.core.cpu_task;
const cpu_status = knlink.sysdepend.core.cpu_status;
const cpu_ctrl = knlink.sysdepend.core.cpu_cntl;
const TCB = knlink.TCB;
const libsys = @import("libsys");
const sysdef = libsys.sysdepend.sysdef;
const libtk = @import("libtk");
const syscall = libtk.syscall;
const TkError = libtk.errno.TkError;
const queue = libsys.queue;
const TkQueue = queue.TkQueue;
const config = @import("config");
const ATR = libtk.typedef.ATR;
const PRI = libtk.typedef.PRI;
const ID = libtk.typedef.ID;
const libtm = @import("libtm");

// * Create task
pub fn tk_cre_tsk(pk_ctsk: *const syscall.T_CTSK) TkError!usize {
    libtm.log.TkLog(.debug, .api, "start {}()", .{@src().fn_name});
    defer libtm.log.TkLog(.debug, .api, "end {}()", .{@src().fn_name});

    // Valid value of task attribute */
    var VALID_TSKATR: ATR = if (comptime config.CHK_RSATR) syscall.TA_HLNG | syscall.TA_RNG3 | syscall.TA_USERBUF | syscall.TA_COPS else undefined;
    if (comptime (config.CHK_RSATR and config.USE_OBJECT_NAME)) {
        VALID_TSKATR |= syscall.TA_DSNAME;
    }
    var sstksz: usize = pk_ctsk.stksz;
    var stack: *anyopaque = pk_ctsk.bufptr;

    try check.CHECK_RSATR(pk_ctsk.tskatr, VALID_TSKATR);
    if (comptime !config.USE_IMALLOC) {
        // TA_USERBUF must be specified if configured in no Imalloc */
        try check.CHECK_PAR((pk_ctsk.tskatr & syscall.TA_USERBUF) != 0);
    }
    try check.CHECK_PAR(pk_ctsk.stksz >= 0);
    try check.CHECK_PRI(pk_ctsk.itskpri);

    if ((pk_ctsk.tskatr & syscall.TA_USERBUF) != 0) {
        // Use user buffer
        sstksz = pk_ctsk.stksz;
        try check.CHECK_PAR(sstksz >= sysdef.core.MIN_SYS_STACK_SIZE);
        stack = pk_ctsk.bufptr;
    } else {
        if (comptime config.USE_IMALLOC) {
            // Allocate system stack area
            sstksz = pk_ctsk.stksz + sysdef.core.DEFAULT_SYS_STKSZ;
            sstksz = (sstksz + 7) & ~@as(usize, @intCast(0x07)); // Align to a multiple of 8 */
            // stack = knl_Imalloc(@as(u32, sstksz));
            if (stack == null) {
                return TkError.InsufficientMemory;
            }
        }
    }

    {
        cpu_status.BEGIN_CRITICAL_SECTION();
        defer cpu_status.END_CRITICAL_SECTION();

        var tcb = for (0..libsys.knldef.NUM_TSKID) |i| {
            if (task.knl_tcb_table[i].state == task.TSTAT.NONEXIST) {
                break task.knl_tcb_table[i];
            }
        } else {
            return TkError.ExceedSystemLimits;
        };

        // Initialize control block */
        tcb.exinf = pk_ctsk.exinf;
        tcb.tskatr = pk_ctsk.tskatr;
        tcb.task = pk_ctsk.task;
        // tcb.ipriority = task.int_priority(pk_ctsk.itskpri);
        tcb.ipriority = pk_ctsk.itskpri;
        tcb.sstksz = sstksz;
        if (comptime config.USE_OBJECT_NAME) {
            if ((pk_ctsk.tskatr & syscall.TA_DSNAME) != 0) {
                tstd.knl_strncpy(@as([]const u8, tcb.name), @as([]const u8, pk_ctsk.dsname), config.OBJECT_NAME_LENGTH);
            }
        }

        // Set stack pointer */
        tcb.isstack = @ptrFromInt(@intFromPtr(stack) + sstksz);

        // Set initial value of task operation mode */
        tcb.isysmode = 1;
        tcb.sysmode = 1;

        task.knl_make_dormant(tcb);

        if (comptime config.USE_IMALLOC) {
            // if ( (ercd < E_OK) && ((pk_ctsk.tskatr & TA_USERBUF) == 0) ) {
            // 	knl_Ifree(stack);
            // }
        }

        return tcb.tskid;
    }
}

// * Task deletion
// *	Call from critical section
fn knl_del_tsk(tcb: *TCB) void {
    if (comptime config.USE_IMALLOC) {
        if ((tcb.tskatr & syscall.TA_USERBUF) == 0) {
            // User buffer is not used */
            // Free system stack */
            // var stack: *void = @as(*i8, tcb.isstack) - tcb.sstksz;
            // memory.knl_Ifree(stack);
        }
    }

    // Return control block to FreeQue */
    // queue.QueInsert(&tcb.tskque, &task.knl_free_tcb);
    task.knl_free_tcb.enqueue(tcb);
    tcb.state = TSTAT.NONEXIST;
}

// if (comptime USE_FUNC_TK_DEL_TSK) {
// * Delete task
pub fn tk_del_tsk(tskid: u32) TkError!void {
    try check.CHECK_TSKID(tskid);
    try check.CHECK_NONSELF(tskid);

    const tcb: *TCB = task.get_tcb(tskid);

    cpu_status.BEGIN_CRITICAL_SECTION();
    defer cpu_status.END_CRITICAL_SECTION();
    const state: TSTAT = @as(TSTAT, tcb.state);
    if (state != TSTAT.TS_DORMANT) {
        if (state == TSTAT.TS_NONEXIST) {
            return TkError.ObjectNotExist;
        } else {
            return TkError.IncorrectObjectState;
        }
    } else {
        knl_del_tsk(tcb);
    }
}
// }

// Start task
pub fn tk_sta_tsk(tskid: usize, stacd: usize) TkError!void {
    libtm.log.TkLog(.debug, .api, "start {}()", .{@src().fn_name});
    defer libtm.log.TkLog(.debug, .api, "end {}()", .{@src().fn_name});

    try check.CHECK_TSKID(tskid);
    try check.CHECK_NONSELF(tskid);

    const tcb = task.get_tcb(tskid);

    {
        cpu_status.BEGIN_CRITICAL_SECTION();
        defer cpu_status.END_CRITICAL_SECTION();

        const state: TSTAT = tcb.state;
        switch (state) {
            .DORMANT => {
                cpu_task.knl_setup_stacd(tcb, stacd);
                task.knl_make_ready(tcb);
            },
            .NONEXIST => return TkError.ObjectNotExist,
            else => return TkError.IncorrectObjectState,
        }
    }
}

// * Task finalization
// *	Call from critical section
fn knl_ter_tsk(tcb: *TCB) void {
    const state: TSTAT = @as(TSTAT, tcb.state);
    if (state == TSTAT.READY) {
        task.knl_make_non_ready(tcb);
    } else if ((@intFromEnum(state) & @intFromEnum(TSTAT.WAIT)) != 0) {
        // wait.knl_wait_cancel(tcb);
        // if (tcb.wspec.rel_wai_hook != null) {
        //     (*tcb.wspec.rel_wai_hook)(tcb);
        // }
    }

    if (comptime config.func.USE_MUTEX) {
        //     // signal mutex */
        //     mutex.knl_signal_all_mutex(tcb);
    }
    cpu_task.knl_cleanup_context(tcb);
}

// * End its own task
pub fn tk_ext_tsk() void {
    if (comptime config.func.USE_FUNC_TK_EXT_TSK) {
        // if (comptime cpu_task.DORMANT_STACK_SIZE) {
        // To avoid destroying stack used in 'knl_make_dormant',
        // allocate the dummy area on the stack. */
        // volatileついてた
        // var _dummy: [cpu_task.DORMANT_STACK_SIZE]i8 = undefined;
        // }

        // Check context error */
        if (comptime config.CHK_CTX2) {
            if (cpu_status.in_indp()) {
                while (true) {
                    asm volatile ("nop");
                }
                unreachable;
            }
        }
        if (comptime config.CHK_CTX1) {
            if (cpu_status.in_ddsp()) {
                libtm.log.TkLog(.debug, .api, "{} was called in the dispatch disabled", .{@src().fn_name});
            }
        }

        cpu_status.DISABLE_INTERRUPT();
        if (knlink.knl_ctxtsk) |current_task| {
            knl_ter_tsk(current_task);
            task.knl_make_dormant(current_task);
        } else {
            libtm.log.TkLog(.debug, .api, "current task is null", .{});
        }

        cpu_ctrl.knl_force_dispatch();
        unreachable;

        // unreachableなはず。なら下のコードはなんのために?
        // if (comptime cpu_task.DORMANT_STACK_SIZE) {
        //     // volatileついてた
        //     var _dummy: [cpu_task.DORMANT_STACK_SIZE]i8 = undefined;
        //     // Avoid WARNING (This code does not execute) */
        //     _dummy[0] = _dummy[0];
        // }
    }
}

// * End and delete its own task
pub fn tk_exd_tsk() !void {
    if (comptime config.func.USE_FUNC_TK_EXD_TSK) {
        // Check context error */
        if (comptime config.CHK_CTX2) {
            if (cpu_status.in_indp()) {
                libtm.log.TkLog(.debug, .api, "{} was called in the task independent", .{@src().fn_name});
                return;
            }
        }
        if (comptime config.CHK_CTX1) {
            if (cpu_status.in_ddsp()) {
                libtm.log.TkLog(.debug, .api, "{} was called in the dispatch disabled", .{@src().fn_name});
            }
        }

        cpu_status.DISABLE_INTERRUPT();
        if (knlink.knl_ctxtsk) |current_task| {
            knl_ter_tsk(current_task);
            knl_del_tsk(current_task);
        }

        // cpu_ctrl.knl_force_dispatch();
        cpu_ctrl.knl_dispatch();
        unreachable;
    } else {
        return TkError.UnsupportedFunction;
    }
}

// * Termination of other task
pub fn tk_ter_tsk(tskid: u32) TkError!void {
    if (comptime config.func.USE_FUNC_TK_TER_TSK) {
        try check.CHECK_TSKID(tskid);
        try check.CHECK_NONSELF(tskid);

        const tcb = task.get_tcb(tskid);

        {
            cpu_status.BEGIN_CRITICAL_SECTION();
            defer cpu_status.END_CRITICAL_SECTION();
            const state: TSTAT = @as(TSTAT, tcb.state);
            if (!task.knl_task_alive(state)) {
                // task is not alive
                switch (state) {
                    .NONEXIST => return TkError.ObjectNotExist,
                    else => return TkError.IncorrectObjectState,
                }
            } else if (tcb.klocked) {
                // Normally, it does not become this state.
                // * When the state is page-in wait in the virtual memory
                // * system and when trying to terminate any task,
                // * it becomes this state.
                return TkError.IncorrectObjectState;
            } else {
                knl_ter_tsk(tcb);
                task.knl_make_dormant(tcb);
            }
        }
    }
}

// * Change task priority
pub fn tk_chg_pri(tskid: u32, tskpri: PRI) TkError!void {
    if (comptime config.func.USE_FUNC_TK_CHG_PRI) {
        var priority: PRI = undefined;

        try check.CHECK_TSKID_SELF(tskid);
        try check.CHECK_PRI_INI(tskpri);

        var tcb = task.get_tcb_self(tskid);

        {
            cpu_status.BEGIN_CRITICAL_SECTION();
            defer cpu_status.END_CRITICAL_SECTION();
            if (tcb.state == TSTAT.NONEXIST) {
                return TkError.ObjectNotExist;
            }

            // Conversion priority to internal expression */
            if (tskpri == syscall.TPRI_INI) {
                priority = tcb.ipriority;
            } else {
                priority = task.int_priority(tskpri);
            }

            if (comptime config.USE_MUTEX) {
                // Mutex priority change limit */
                try knlink.mutex.knl_chg_pri_mutex(tcb, priority);
                tcb.bpriority = priority;
                // 謎の処理: priority = ercd;
            } else {
                tcb.bpriority = priority;
            }

            // Change priority */
            task.knl_change_task_priority(tcb, priority);
        }
    }
}

// * Rotate ready queue
pub fn tk_rot_rdq(tskpri: isize) TkError!void {
    if (comptime config.func.USE_FUNC_TK_ROT_RDQ) {
        try check.CHECK_PRI_RUN(tskpri);

        {
            cpu_status.BEGIN_CRITICAL_SECTION();
            defer cpu_status.END_CRITICAL_SECTION();
            if (tskpri == syscall.TPRI_RUN) {
                if (cpu_status.in_indp()) {
                    task.knl_rotate_ready_queue_run();
                } else {
                    task.knl_rotate_ready_queue(knlink.knl_ctxtsk.priority);
                }
            } else {
                task.knl_rotate_ready_queue(task.int_priority(tskpri));
            }
        }
    }
}

// * Refer task ID at execution */
pub fn tk_get_tid() isize {
    if (comptime config.func.USE_FUNC_TK_GET_TID) {
        return if (knlink.knl_ctxtsk) |_| knlink.knl_ctxtsk.tskid else 0;
    }
}

// * Refer task state */
pub fn tk_ref_tsk(tskid: u32, pk_rtsk: *syscall.T_RTSK) TkError!void {
    if (comptime config.func.USE_FUNC_TK_REF_TSK) {
        try check.CHECK_TSKID_SELF(tskid);

        const tcb = task.get_tcb_self(tskid);

        tstd.knl_memset(pk_rtsk, 0, @sizeOf(*pk_rtsk));

        {
            cpu_status.BEGIN_CRITICAL_SECTION();
            defer cpu_status.END_CRITICAL_SECTION();
            const state = tcb.state;
            switch (state) {
                .NONEXIST => return TkError.ObjectNotExist,
                .READY => {
                    if (tcb == knlink.knl_ctxtsk) {
                        pk_rtsk.tskstat = syscall.TTSTAT.RUN;
                    } else {
                        pk_rtsk.tskstat = @intFromEnum(state) << 1;
                    }
                },
                .WAIT, .WAITSUS => {
                    pk_rtsk.tskwait = tcb.wspec.tskwait;
                    pk_rtsk.wid = tcb.wid;
                },
                else => {},
            }
            pk_rtsk.exinf = tcb.exinf;
            pk_rtsk.tskpri = task.ext_tskpri(tcb.priority);
            pk_rtsk.tskbpri = task.ext_tskpri(tcb.bpriority);
            pk_rtsk.wupcnt = tcb.wupcnt;
            pk_rtsk.suscnt = tcb.suscnt;
        }
    }
}

// * Release wait */
pub fn tk_rel_wai(tskid: u32) TkError!void {
    if (comptime config.func.USE_FUNC_TK_REL_WAI) {
        try check.CHECK_TSKID(tskid);

        const tcb: *TCB = task.get_tcb(tskid);

        {
            cpu_status.BEGIN_CRITICAL_SECTION();
            defer cpu_status.END_CRITICAL_SECTION();

            const state = tcb.state;
            switch (state) {
                .WAIT, .WAITSUS => wait.knl_wait_release_ng(tcb, TkError.E_RLWAI),
                .NONEXIST => return TkError.ObjectNotExist,
                else => return TkError.IncorrectObjectState,
            }
        }
    }
}

//Debug support function
// Get object name from control block
// 返却値の型は何かしらの整数?と思ってisize 仕様書に記載なし
// リファレンス実装でのAPI
// pub fn knl_task_getname(tskid: ID, name: []const u8) TkError!isize {
// Zig言語らしいAPI
//  - dsnameを直接返す. 引数のnameは不要.
pub fn knl_task_getname(tskid: ID) TkError![]const u8 {
    if (comptime config.USE_DBGSPT) {
        if (comptime config.USE_OBJECT_NAME) {
            try check.CHECK_TSKID_SELF(tskid);

            {
                cpu_status.BEGIN_DISABLE_INTERRUPT();
                defer cpu_status.END_DISABLE_INTERRUPT;
                const tcb = task.get_tcb_self(tskid);
                switch (tcb.state) {
                    .NONEXIST => return TkError.ObjectNotExist,
                    else => {},
                }
                if ((tcb.tskatr & syscall.TA_DSNAME) == 0) {
                    return TkError.IncorrectObjectState;
                }
                return tcb.name;
            }
        }
    }
}

// Refer task usage state
// 使用しているtskidのリストを最大nent個listに格納する.
// 戻り地に取得したtskidのリスト(!=list)の要素数を返す.
// nent < 戻り値の場合はlistのサイズが足りず、全て格納できていないことを示す.
// 上記の仕様は不自然なので新しいAPIを採用する.
// 仕様に誤解があれば元のAPIに戻す
// 仕様書通りのAPI
// pub fn  td_lst_tsk(  list:[]ID,  nent: isize ) isize {
// 新しいAPI
//  - 取得したtskidのリストを直接返す.
//  - 引数を削除
pub fn td_lst_tsk() []ID {
    if (comptime config.USE_DBGSPT) {
        if (comptime config.func.USE_FUNC_TD_LST_TSK) {
            cpu_status.BEGIN_DISABLE_INTERRUPT();
            defer cpu_status.END_DISABLE_INTERRUPT();
            var list: [libsys.knldef.NUM_TSKID]ID = undefined;
            var pos = 0;
            for (task.knl_tcb_table, 0..) |tcb, i| {
                _ = i;
                if (tcb.state == .NONEXIST)
                    continue;

                list[pos] = tcb.tskid;
                pos += 1;
            }
        }
    }
}

// Refer task state
pub fn td_ref_tsk(tskid: ID, pk_rtsk: *libtk.dbgspt.TD_RTSK) TkError!isize {
    if (comptime config.USE_DBGSPT) {
        if (comptime config.func.USE_FUNC_TD_REF_TSK) {
            try check.CHECK_TSKID_SELF(tskid);

            var tcb = task.get_tcb_self(tskid);

            tstd.knl_memset(pk_rtsk, 0, @sizeOf(*pk_rtsk));

            cpu_status.BEGIN_DISABLE_INTERRUPT();
            defer cpu_status.END_DISABLE_INTERRUPT();
            switch (tcb.state) {
                .NONEXIST => return TkError.ObjectNotExist,
                .READY => {
                    if (tcb == knlink.knl_ctxtsk) {
                        pk_rtsk.tskstat = syscall.TTSTAT.RUN;
                    } else {
                        pk_rtsk.tskstat = @intFromEnum(tcb.state) << 1;
                    }
                },
                .WAIT, .WAITSUS => {
                    pk_rtsk.tskwait = tcb.wspec.tskwait;
                    pk_rtsk.wid = tcb.wid;
                },
                else => {},
            }
            pk_rtsk.exinf = tcb.exinf;
            pk_rtsk.tskpri = task.ext_tskpri(tcb.priority);
            pk_rtsk.tskbpri = task.ext_tskpri(tcb.bpriority);
            pk_rtsk.wupcnt = tcb.wupcnt;
            pk_rtsk.suscnt = tcb.suscnt;
            pk_rtsk.task = tcb.task;
            pk_rtsk.stksz = tcb.sstksz;
            pk_rtsk.istack = tcb.isstack;
        }
    }
}

// Get task statistic information
pub fn td_inf_tsk(tskid: ID, pk_itsk: *libtk.dbgspt.TD_ITSK, clr: bool) TkError!void {
    if (comptime config.USE_DBGSPT) {
        if (comptime config.func.USE_FUNC_TD_INF_TSK) {
            try check.CHECK_TSKID_SELF(tskid);

            var tcb = task.get_tcb_self(tskid);

            {
                cpu_status.BEGIN_DISABLE_INTERRUPT();
                defer cpu_status.END_DISABLE_INTERRUPT();
                switch (tcb.state) {
                    .NONEXIST => return TkError.ObjectNotExist,
                    else => {
                        pk_itsk.stime = tcb.stime;
                        pk_itsk.utime = tcb.utime;
                        if (clr) {
                            tcb.stime = 0;
                            tcb.utime = 0;
                        }
                    },
                }
            }
        }
    }
}
