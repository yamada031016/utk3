const print = @import("devices").serial.print;
const knlink = @import("knlink");
const tskmng = knlink.task_manage;
const libtk = @import("libtk");
const syscall = libtk.syscall;
const libtm = @import("libtm");

fn dummy_task() void {
    print("dummy_task()!");
    while (true) {
        asm volatile ("nop");
    }
    // knlink.task_manage.tk_ext_tsk();
}

fn test_task() void {
    print("test_task()!");

    const test_ctsk = syscall.T_CTSK{
        .exinf = null,
        .tskatr = syscall.TA_HLNG | syscall.TA_RNG0,
        .task = @ptrCast(@alignCast(@constCast(&dummy_task))),
        .itskpri = 1,
        .stksz = 1 * 256,
        .bufptr = @constCast(&hoge),
    };

    if (tskmng.tk_cre_tsk(&test_ctsk)) |tskid| {
        if (tskmng.tk_sta_tsk(tskid, 0)) {
            print("success.");
            knlink.sysdepend.core.cpu_cntl.knl_dispatch();
        } else |err| {
            print(@errorName(err));
        }
    } else |err| {
        print(@errorName(err));
    }
}

var hoge: [256]isize = [_]isize{1} ** 256;
extern const __data_start: usize;
extern const __rom_end: usize;
extern const __end: usize;

pub fn usermain() i32 {
    // while (true) {
    //     asm volatile ("nop");
    // }
    const rom_usage = (@intFromPtr(&__rom_end) - 0x0800_0000) / 8;
    const ram_usage = (@intFromPtr(&__end) - @intFromPtr(&__data_start)) / 8;
    libtm.intPrint("total\t(byte)", ram_usage + rom_usage);
    libtm.intPrint("rom\t(byte)", rom_usage);
    libtm.intPrint("ram\t(byte)", ram_usage);
    libtm.intPrint("usermain time:", @import("libtk").syslib.cpu.read(@intFromEnum(@import("libsys").sysdepend.sysdef.TIM16.CNT)));
    // const test_ctsk = syscall.T_CTSK{
    //     .exinf = null,
    //     .tskatr = syscall.TA_HLNG | syscall.TA_RNG0,
    //     .task = @ptrCast(@alignCast(@constCast(&test_task))),
    //     .itskpri = 1,
    //     .stksz = 1 * 256,
    //     .bufptr = @constCast(&hoge),
    // };
    //
    // if (tskmng.tk_cre_tsk(&test_ctsk)) |tskid| {
    //     if (tskmng.tk_sta_tsk(tskid, 0)) {
    //         print("success.");
    //         knlink.sysdepend.core.cpu_cntl.knl_dispatch();
    //     } else |err| {
    //         print(@errorName(err));
    //     }
    // } else |err| {
    //     print(@errorName(err));
    // }

    // while (true) {
    //     asm volatile ("nop");
    // }
    return 0;
}
