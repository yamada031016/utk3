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
    // libtm.intPrint("usermain tskid test()", knlink.rdy_que.knl_ready_queue.tskque[9].?.tskid);
    //
    // if (tskmng.tk_cre_tsk(&test_ctsk2)) |tskid| {
    //     libtm.intPrint("top pri test()", knlink.rdy_que.knl_ready_queue.top_priority);
    //     libtm.intPrint("tskid:", tskid);
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

// extern const __data_start: usize;
// extern const __rom_end: usize;
// extern const __end: usize;
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
        libtm.intPrint("tskid:", tskid);
        if (tskmng.tk_sta_tsk(tskid, 0)) {
            print("success.");
        } else |err| {
            print(@errorName(err));
        }
    } else |err| {
        print(@errorName(err));
    }

    print("hogehoge~~");
    // while (true) { asm volatile ("nop"); }
    return 0;
}
