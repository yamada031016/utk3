const config = @import("config.zig");

pub fn addGPIOX(port_id: usize, offset: usize) usize {
    return switch (port_id) {
        'A' => config.GPIOA_BASE + offset,
        'B' => config.GPIOB_BASE + offset,
        'C' => config.GPIOC_BASE + offset,
        'D' => config.GPIOD_BASE + offset,
        'E' => config.GPIOE_BASE + offset,
        'F' => config.GPIOF_BASE + offset,
        'G' => config.GPIOG_BASE + offset,
        'H' => config.GPIOH_BASE + offset,
        'I' => config.GPIOI_BASE + offset,
        else => unreachable,
    };
}

pub fn GPIO_MODER(port_id: usize) *volatile usize {
    return @as(*volatile usize, @ptrFromInt(addGPIOX(port_id, 0x00)));
} // GPIO port mode register */
pub fn GPIO_OTYPER(port_id: usize) *volatile usize {
    return @as(*volatile usize, @ptrFromInt(addGPIOX(port_id, 0x04)));
} // GPIO port output type register */
pub fn GPIO_OSPEEDR(port_id: usize) *volatile usize {
    return @as(*volatile usize, @ptrFromInt(addGPIOX(port_id, 0x08)));
} // GPIO port output speed register */
pub fn GPIO_PUPDR(port_id: usize) *volatile usize {
    return @as(*volatile usize, @ptrFromInt(addGPIOX(port_id, 0x0C)));
} // GPIO port pull-up/pull-down register */
pub fn GPIO_IDR(port_id: usize) *volatile usize {
    return @as(*volatile usize, @ptrFromInt(addGPIOX(port_id, 0x10)));
} // GPIO port input data register */
pub fn GPIO_ODR(port_id: usize) *volatile usize {
    return @as(*volatile usize, @ptrFromInt(addGPIOX(port_id, 0x14)));
} // GPIO port output data register */
pub fn GPIO_BSRR(port_id: usize) *volatile usize {
    return @as(*volatile usize, @ptrFromInt(addGPIOX(port_id, 0x18)));
} // GPIO port bit set/reset register */
pub fn GPIO_LCKR(port_id: usize) *volatile usize {
    return @as(*volatile usize, @ptrFromInt(addGPIOX(port_id, 0x1C)));
} // GPIO port configuration lock register */
pub fn GPIO_AFRL(port_id: usize) *volatile usize {
    return @as(*volatile usize, @ptrFromInt(addGPIOX(port_id, 0x20)));
} // GPIO alternate function low register */
pub fn GPIO_AFRH(port_id: usize) *volatile usize {
    return @as(*volatile usize, @ptrFromInt(addGPIOX(port_id, 0x24)));
} // GPIO alternate function high register */
pub fn GPIO_BRR(port_id: usize) *volatile usize {
    return @as(*volatile usize, @ptrFromInt(addGPIOX(port_id, 0x28)));
} // GPIO port bit reset register */
pub fn GPIO_ASCR(port_id: usize) *volatile usize {
    return @as(*volatile usize, @ptrFromInt(addGPIOX(port_id, 0x2C)));
} // GPIO port analog switch control register */
//

pub fn read(port_addr: *volatile usize) usize {
    return port_addr.*;
}

pub fn write(port_addr: *volatile usize, data: usize) void {
    port_addr.* = data;
}
