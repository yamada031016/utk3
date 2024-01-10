const knlink = @import("knlink");
const cpu_clock = knlink.sysdepend.cpu_clock;
const libtk = @import("libtk");
const syslib = libtk.syslib;
const TkError = libtk.errno.TkError;
const int = libtk.sysdepend.int;
const write = syslib.cpu.write;
const sysdef = @import("libsys").sysdepend.sysdef;
const RCC = sysdef.cpu.RCC;
const config = @import("config");
const print = @import("devices").serial.print;

pub fn knl_startup_hw() void {
    const dummy_clkatr = 0;
    cpu_clock.startup_clock(dummy_clkatr);

    // syslib.cpu.setReg(config.RCC_AHB2ENR, 1 << 0 | 1 << 1); // GPIOA, GPIOB enable
    syslib.cpu.setReg(@intFromEnum(RCC.AHB2ENR), 0x0000_0007); // GPIOA, GPIOB enable
    // syslib.cpu.setReg(config.RCC_APB1ENR1, 1 << 17); //usart2 clock enable
    syslib.cpu.setReg(@intFromEnum(RCC.APB1ENR1), 0x0002_000F); //usart2 clock enable
    syslib.cpu.setReg(@intFromEnum(RCC.APB2ENR), 1 << 17); //TIM16 clock enable

    write(sysdef.cpu.GPIO_MODER('A'), 0xABFF_F7AF); // set PA2,3(USART2) PA5(LED1) enable
    write(sysdef.cpu.GPIO_OTYPER('A'), 0x0000_0000);
    write(sysdef.cpu.GPIO_OSPEEDR('A'), 0x0C00_0050);
    write(sysdef.cpu.GPIO_PUPDR('A'), 0x6400_0050);
    write(sysdef.cpu.GPIO_AFRL('A'), 0x0000_7700);
    write(sysdef.cpu.GPIO_ASCR('A'), 0x0000_0013);

    write(sysdef.cpu.GPIO_MODER('B'), 0xFFFA_FFBF); // set PA2,3(USART2) PA5(LED1) enable
    write(sysdef.cpu.GPIO_OTYPER('B'), 0x0000_0300);
    write(sysdef.cpu.GPIO_OSPEEDR('B'), 0x000F_0000);
    write(sysdef.cpu.GPIO_PUPDR('B'), 0x0005_0100);
    write(sysdef.cpu.GPIO_AFRL('B'), 0x0000_0000);
    write(sysdef.cpu.GPIO_AFRH('B'), 0x0000_0044);
    write(sysdef.cpu.GPIO_ASCR('B'), 0x0000_0001);

    write(sysdef.cpu.GPIO_BSRR('A'), (1 << 5));

    write(@intFromEnum(sysdef.TIM16.CR1), 1); //usart2,TIM16 clock enable
    write(@intFromEnum(sysdef.TIM16.OR1), 0); //usart2,TIM16 clock enable
    write(@intFromEnum(sysdef.TIM16.PSC), 79); // 80 -1
}

pub fn knl_shutdown_hw() void {
    if (comptime config.USE_SHUTDOWN) {
        _ = int.core.disint();
        while (true) {}
    }
}

// * Re-start device
// *	mode = -1		reset and re-start	(Reset -> Boot -> Start)
// *	mode = -2		fast re-start		(Start)
// *	mode = -3		Normal re-start		(Boot -> Start)

pub fn knl_restart_hw(mode: i32) TkError!void {
    switch (mode) {
        -1 => {
            print("\r\n<< SYSTEM RESET & RESTART >>");
            return TkError.UnsupportedFunction;
        },
        -2 => {
            //  fast re-start
            print("\r\n<< SYSTEM FAST RESTART >>");
            return TkError.UnsupportedFunction;
        },
        -3 => {
            //  Normal re-start
            print("\r\n<< SYSTEM RESTART >>");
            return TkError.UnsupportedFunction;
        },
        else => return TkError.ParameterError,
    }
}
