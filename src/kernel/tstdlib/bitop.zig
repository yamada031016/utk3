// #include <tk/tkernel.h>

// bit operation
if (comptime BIGENDIAN) {
    pub fn _BIT_SET_N(n: i32) i32 {
        return 0x80 >> ((n)&7);
    }
    pub fn _BIT_SHIFT(n: u8) i32 {
     return n >> 1;
    }
}
else{
    pub fn _BIT_SET_N(n: i32) i32 {
        return 0x01 << ((n)&7);
    }
    pub fn _BIT_SHIFT(n: u8) i32 {
     return n << 1;
    }
}

// bit operation
if (comptime USE_FUNC_TSTDLIB_BITCLR) {
    // tstdlib_bitclr : clear specified bit
    pub fn knl_bitclr(base: *void, offset: i32) void {
    // NOTE: 下記の変数はレジスタ変数として宣言されていた.
    volatile var cp: *u8;
    volatile var mask: u8;

    if (offset < 0) {
        return;
    }

    cp = @as(*u8, base);
    cp += offset / 8;

    mask = _BIT_SET_N(offset);

    cp.* &= ~mask;
    }
}

if (comptime USE_FUNC_TSTDLIB_BITSET) {
    // tstdlib_bitset : set specified bit
    pub fn knl_bitset(base: *void, offset: i32) void {
    // NOTE: 下記の変数はレジスタ変数として宣言されていた.
    //       Zigではよくわからんので放置.
    volatile var cp: *u8;
    volatile var mask: u8;

    if (offset < 0) {
        return;
    }

    cp = @as(*u8, base);
    cp += offset / 8;

    mask = _BIT_SET_N(offset);

    cp.* |= mask;
    }
}

//TODO: 返り値が-1なのでエラーとして実装するか!i32でお茶を濁すか
if (comptime USE_FUNC_TSTDLIB_BITSEARCH1) {
    // tstdlib_bitsearch1 : perform 1 search on bit string
    pub fn knl_bitsearch1(base: *void, offset: i32, width: i32) i32 {
    // NOTE: 下記の変数はレジスタ変数として宣言されていた.
    //       Zigではよくわからんので放置.
    volatile var cp: *u8;
    volatile var mask: u8;
    volatile var position: i32;

    if ((offset < 0) || (width < 0)) {
        return -1;
    }

    cp = @as(*u8, base);
    cp += offset / 8;

    position = 0;
    mask = _BIT_SET_N(offset);

    while (position < width) {
        if (cp.*) { // includes 1 --> search bit of 1
        while (true) {
            if (cp.* & mask) {
                if (position < width) {
                    return position;
                } else {
                    return -1;
                }
            }
            mask = _BIT_SHIFT(mask);
            ++position;
        }
        } else { // all bits are 0 --> 1 Byte skip
        if (position) {
            position += 8;
        } else {
            position = 8 - (offset & 7);
            mask = _BIT_SET_N(0);
        }
        cp+=1;
        }
    }

    return -1;
    }
}
