const print = @import("devices").serial.print;
const knlink = @import("knlink");
const tskmng = knlink.task_manage;
const libtk = @import("libtk");
const syscall = libtk.syscall;
const libtm = @import("libtm");

const STKSZ = 1024;
fn dummy_task() !void {
    libtm.log.TkLog(.info, .user, "{}()", .{@src().fn_name});
    try knlink.task_manage.tk_exd_tsk();
}

var hoge2: [STKSZ]usize = [_]usize{0} ** STKSZ;
fn test_task() !void {
    libtm.log.TkLog(.info, .user, "{}()", .{@src().fn_name});

    const test_ctsk2 = syscall.T_CTSK{
        .exinf = null,
        .tskatr = syscall.TA_HLNG | syscall.TA_RNG0,
        .task = @ptrCast(@alignCast(@constCast(&dummy_task))),
        .itskpri = 7,
        .stksz = 1 * STKSZ,
        .bufptr = @constCast(&hoge2),
    };
    if (tskmng.tk_cre_tsk(&test_ctsk2)) |tskid| {
        if (tskmng.tk_sta_tsk(tskid, 0)) {
            print("success.");
            knlink.sysdepend.core.cpu_cntl.knl_dispatch();
        } else |err| {
            print(@errorName(err));
        }
    } else |err| {
        print(@errorName(err));
    }

    knlink.task_manage.tk_exd_tsk() catch |err| {
        libtm.log.TkLog(.err, .user, "{}", .{@errorName(err)});
        libtm.log.TkLog(.debug, .user, "{}() failed ({} {},{})", .{ @src().fn_name, @src().file, @src().line, @src().column });
    };
    unreachable;
}

var hoge: [STKSZ]usize = [_]usize{0} ** STKSZ;

pub fn usermain() i32 {
    libtm.log.TkLog(.info, .user, "{}()", .{@src().fn_name});

    const test_ctsk = syscall.T_CTSK{
        .exinf = null,
        .tskatr = syscall.TA_HLNG | syscall.TA_RNG0,
        .task = @ptrCast(@alignCast(@constCast(&test_task))),
        .itskpri = 9,
        .stksz = STKSZ,
        .bufptr = @constCast(&hoge),
    };

    if (tskmng.tk_cre_tsk(&test_ctsk)) |tskid| {
        if (tskmng.tk_sta_tsk(tskid, 0)) {
            const tsk = knlink.task.get_tcb(tskid);
            const Alive = knlink.task.knl_task_alive(tsk.state);
            libtm.log.TkLog(.debug, .user, "task alive is {}", .{Alive});
        } else |err| {
            print(@errorName(err));
        }
    } else |err| {
        print(@errorName(err));
    }

    libtm.log.TkLog(.info, .user, "Finish!!!!!!!!!", .{});
    return 0;
}
