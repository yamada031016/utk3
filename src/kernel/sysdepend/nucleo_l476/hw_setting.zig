const knlink = @import("knlink");
const cpu_clock = knlink.sysdepend.cpu_clock;
const utils = @import("utils");
const write = utils.write;
const sysdef = @import("libsys").sysdepend.sysdef;

pub fn knl_startup_hw() void {
    const dummy_clkatr = 0;
    cpu_clock.startup_clock(dummy_clkatr);

    comptime var RCC = sysdef.RCC{};
    // utils.setReg(config.RCC_AHB2ENR, 1 << 0 | 1 << 1); // GPIOA, GPIOB enable
    utils.setReg(RCC.AHB2ENR, 0x0000_0007); // GPIOA, GPIOB enable
    // utils.setReg(config.RCC_APB1ENR1, 1 << 17); //usart2 clock enable
    utils.setReg(RCC.APB1ENR1, 0x0002_000F); //usart2 clock enable
    utils.setReg(RCC.APB2ENR, 0x0000_0001); //usart2 clock enable

    write(sysdef.GPIO_MODER('A'), 0xABFF_F7AF); // set PA2,3(USART2) PA5(LED1) enable
    write(sysdef.GPIO_OTYPER('A'), 0x0000_0000);
    write(sysdef.GPIO_OSPEEDR('A'), 0x0C00_0050);
    write(sysdef.GPIO_PUPDR('A'), 0x6400_0050);
    write(sysdef.GPIO_AFRL('A'), 0x0000_7700);
    write(sysdef.GPIO_ASCR('A'), 0x0000_0013);

    write(sysdef.GPIO_MODER('B'), 0xFFFA_FFBF); // set PA2,3(USART2) PA5(LED1) enable
    write(sysdef.GPIO_OTYPER('B'), 0x0000_0300);
    write(sysdef.GPIO_OSPEEDR('B'), 0x000F_0000);
    write(sysdef.GPIO_PUPDR('B'), 0x0005_0100);
    write(sysdef.GPIO_AFRL('B'), 0x0000_0000);
    write(sysdef.GPIO_AFRH('B'), 0x0000_0044);
    write(sysdef.GPIO_ASCR('B'), 0x0000_0001);
}
