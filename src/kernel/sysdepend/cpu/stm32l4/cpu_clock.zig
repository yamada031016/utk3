const config = @import("config");
const utils = @import("utils");
const write = utils.write;

inline fn FLASH_ACR_LATENCY(f: u32) u32 {
    return f & 0x7; //FLASH_ACR_LATENCY_MASK = 0x7;
}

// Startup System Clock */
pub fn startup_clock(clkatr: u32) void {
    _ = clkatr;
    // Enable clock source */
    // Use HSI clock */
    const RCC_CR_HSION = 0x100;
    const RCC_CR_HSIRDY = 0x400;
    const addr: *u32 = @as(*u32, @ptrFromInt(config.RCC_CR));
    addr.* |= @as(u32, RCC_CR_HSION); // HSI enable
    // @atomicStore(u32, addr, addr.* | @as(u32, RCC_CR_HSION), .Unordered);
    while ((addr.* & RCC_CR_HSIRDY) == 0) {} // Wait HSI ready
    // Use HSE clock */
    // if (clkatr & sysdepend.CLKATR_HSE != 0) {
    //     addr.* |= sysdef.RCC_CR_HSEON; // HSE enable
    //     while ((addr.* & sysdef.RCC_CR_HSERDY) == 0) {} // Wait HSE ready */
    // }
    // Use MSI clock */
    // if (clkatr & sysdepend.CLKATR_MSI != 0) {
    //     addr.* |= sysdef.RCC_CR_MSION; // MSI enable
    //     while ((addr.* & sysdef.RCC_CR_MSIRDY) == 0) {} // Wait MSI ready
    // }

    // if (clkatr & sysdepend.CLKATR_USE_PLL != 0) { // PLL Configuration */
    const RCC_CR_PLLON = 0x0100_0000;
    const RCC_CR_PLLRDY = 0x0200_0000;
    const RCC_PLLCFGR_INIT = 0xA00;
    const RCC_PLLCFGR_PLLSRC = 0x3;
    const RCC_PLLCFGR_PLLSRC_INIT = 0x2;
    const RCC_PLLCFGR_PLLREN = 0x0100_0000;
    addr.* &= ~@as(u32, RCC_CR_PLLON); // Disable PLL
    while ((addr.* & RCC_CR_PLLRDY) != 0) {} // Wait PLL ready

    write(config.RCC_PLLCFGR, (RCC_PLLCFGR_INIT & ~@as(u32, RCC_PLLCFGR_PLLSRC)) | RCC_PLLCFGR_PLLSRC_INIT); // Set PLL

    addr.* |= RCC_CR_PLLON; // Enable PLL
    @as(*volatile u32, @ptrFromInt(config.RCC_PLLCFGR)).* |= RCC_PLLCFGR_PLLREN; // Enable PLL System Clock output
    while ((addr.* & RCC_CR_PLLRDY) == 0) {} // Wait PLL ready
    // }

    // if (clkatr & sysdepend.CLKATR_USE_PLLSAI1 != 0) { // PLLSAI1 Configuration */
    const RCC_CR_PLLSAI1ON = 0x0400_0000;
    const RCC_CR_PLLSAI1RDY = 0x0800_0000;
    const RCC_PLLSAI1CFGR_INIT = 0x800;
    addr.* &= ~@as(u32, RCC_CR_PLLSAI1ON); // Disable PLLSAT1
    while ((addr.* & RCC_CR_PLLSAI1RDY) != 0) {} // Wait PLLSAT1 disable

    write(config.RCC_PLLSAI1CFGR, RCC_PLLSAI1CFGR_INIT); // Set PLLSAI1

    addr.* |= RCC_CR_PLLSAI1ON; // Enable PLLSAI1
    while ((addr.* & RCC_CR_PLLSAI1RDY) == 0) {} // Wait PLLSAI1 ready
    // }

    // if (clkatr & sysdepend.CLKATR_USE_PLLSAI2 != 0) { // PLLSAI2 Configuration */
    const RCC_CR_PLLSAI2ON = 0x1000_0000;
    const RCC_CR_PLLSAI2RDY = 0x2000_0000;
    const RCC_PLLSAI2CFGR_INIT = 0x800;
    addr.* |= RCC_CR_PLLSAI2ON; // Disable PLLSAT2
    while ((addr.* & RCC_CR_PLLSAI2RDY) != 0) {} // Wait PLLSAT2 disable

    write(config.RCC_PLLSAI1CFGR, RCC_PLLSAI2CFGR_INIT); // Set PLLSAI2

    addr.* |= RCC_CR_PLLSAI2ON; // Enable PLLSAI2
    while ((addr.* & RCC_CR_PLLSAI2RDY) == 0) {} // Wait PLLSAI2 ready
    // }

    // Set Flash Memory Access latency  */
    var f_ratency: u32 = 0x400 >> 8; // 1024
    const FLASH_ACR_LATENCY_MASK = 0x7;
    @as(*volatile u32, @ptrFromInt(config.FLASH_ACR)).* = (@as(*volatile u32, @ptrFromInt(config.FLASH_ACR)).* & ~@as(usize, FLASH_ACR_LATENCY_MASK)) | FLASH_ACR_LATENCY(f_ratency);
    while ((@as(*volatile u32, @ptrFromInt(config.FLASH_ACR)).* & FLASH_ACR_LATENCY_MASK) != FLASH_ACR_LATENCY(f_ratency)) {}

    // Clock setting */
    const RCC_CFGR_INIT = 0x0;
    const RCC_CFGR_SW = 0x3;
    const RCC_CFGR_SW_INIT = 0x3;
    write(config.RCC_CFGR, (RCC_CFGR_INIT & ~@as(u32, RCC_CFGR_SW)) | RCC_CFGR_SW_INIT);
    while ((@as(*volatile u32, @ptrFromInt(config.RCC_CFGR)).* & RCC_CFGR_SW) != RCC_CFGR_SW_INIT) {}

    // Disable all interrupts */
    write(config.RCC_CIER, 0);
}
