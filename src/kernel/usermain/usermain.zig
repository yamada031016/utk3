const print = @import("devices").serial.print;
const knlink = @import("knlink");
const tskmng = knlink.task_manage;
const libtk = @import("libtk");
const syscall = libtk.syscall;
const libtm = @import("libtm");

const STKSZ = 1024;
fn dummy_task() void {
    print("\x1b[35m");
    print("dummy_task()!");
    print("\x1b[0m");
    knlink.task_manage.tk_exd_tsk();
    print("end");
}

var hoge2: [STKSZ]usize = [_]usize{0} ** STKSZ;
fn test_task() void {
    print("\x1b[35m");
    print("test_task()!");
    print("\x1b[0m");

    const test_ctsk2 = syscall.T_CTSK{
        .exinf = null,
        .tskatr = syscall.TA_HLNG | syscall.TA_RNG0,
        .task = @ptrCast(@alignCast(@constCast(&dummy_task))),
        .itskpri = 7,
        .stksz = 1 * STKSZ,
        .bufptr = @constCast(&hoge2),
    };
    _ = test_ctsk2;
    //
    // if (tskmng.tk_cre_tsk(&test_ctsk2)) |tskid| {
    //     if (tskmng.tk_sta_tsk(tskid, 0)) {
    //         print("success.");
    //         knlink.sysdepend.core.cpu_cntl.knl_dispatch();
    //     } else |err| {
    //         print(@errorName(err));
    //     }
    // } else |err| {
    //     print(@errorName(err));
    // }

    knlink.task_manage.tk_exd_tsk();
    unreachable;
}

var hoge: [STKSZ]usize = [_]usize{0} ** STKSZ;

pub fn usermain() i32 {
    print("\x1b[35m");
    print("usermain!");
    print("\x1b[0m");

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
            print("success.");
        } else |err| {
            print(@errorName(err));
        }
    } else |err| {
        print(@errorName(err));
    }

    print("hogehoge~~");
    return 0;
}
