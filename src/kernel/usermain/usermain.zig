const print = @import("devices").serial.print;
const knlink = @import("knlink");
const tskmng = knlink.task_manage;
const libtk = @import("libtk");
const syscall = libtk.syscall;

fn test_task() void {
    print("test_task()!");
}

var hoge: [256]isize = [_]isize{1} ** 256;
pub fn usermain() i32 {
    print("usermain started!");
    const test_ctsk = syscall.T_CTSK{
        .exinf = null,
        .tskatr = syscall.TA_HLNG | syscall.TA_RNG0,
        .task = @ptrCast(@alignCast(@constCast(&test_task))),
        .itskpri = 1,
        .stksz = 1 * 256,
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

    return 0;
}
