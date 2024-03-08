// bit operation
// if (comptime BIGENDIAN) {
//     pub fn _BIT_SET_N(n: i32) i32 {
//         return 0x80 >> ((n)&7);
//     }
//     pub fn _BIT_SHIFT(n: u8) i32 {
//      return n >> 1;
//     }
// }
// else{
pub inline fn _BIT_SET_N(n: i32) i32 {
    return 0x01 << ((n) & 7);
}
pub inline fn _BIT_SHIFT(n: u8) i32 {
    return n << 1;
}
// }

// if (comptime USE_FUNC_TSTDLIB_BITCLR) {
// tstdlib_bitclr : clear specified bit
pub fn knl_bitclr(base: *void, offset: i32) void {
    _ = offset;
    _ = base;
    // if (offset < 0)
    //     return;
    //
    // var cp = @as(*u8, base);
    // cp += offset / 8;
    //
    // var mask = _BIT_SET_N(offset);
    //
    // cp.* &= ~mask;
}
// }

// if (comptime USE_FUNC_TSTDLIB_BITSET) {
// tstdlib_bitset : set specified bit
pub fn knl_bitset(base: *void, offset: i32) void {
    // NOTE: 下記の変数はレジスタ変数として宣言されていた.
    // var cp: *u8;
    // var mask: u8;

    if (offset < 0)
        return;

    var cp = @as(*u8, base);
    cp += offset / 8;

    const mask = _BIT_SET_N(offset);

    cp.* |= mask;
}
// }

//TODO: 返り値が-1なのでエラーとして実装するか!i32でお茶を濁すか
// if (comptime USE_FUNC_TSTDLIB_BITSEARCH1) {
// tstdlib_bitsearch1 : perform 1 search on bit string
pub fn knl_bitsearch1(base: *void, offset: i32, width: i32) i32 {
    // NOTE: 下記の変数はレジスタ変数として宣言されていた.
    //       Zigではよくわからんので放置.
    // var cp: *u8;
    // var mask: u8;
    // var position: i32;

    if ((offset < 0) || (width < 0)) {
        return -1;
    }

    var cp = @as(*u8, base);
    cp += offset / 8;

    var position = 0;
    var mask = _BIT_SET_N(offset);

    while (position < width) {
        if (cp.*) { // includes 1 --> search bit of 1
            while (true) : (position += 1) {
                if (cp.* & mask) {
                    if (position < width) {
                        return position;
                    } else {
                        return -1;
                    }
                }
                mask = _BIT_SHIFT(mask);
            }
        } else { // all bits are 0 --> 1 Byte skip
            if (position) {
                position += 8;
            } else {
                position = 8 - (offset & 7);
                mask = _BIT_SET_N(0);
            }
            cp += 1;
        }
    }
    return -1;
}
// }

///	T-Kernel standard library

// #include "kernel.h"
// #include <tk/tkernel.h>

// binary operation
// memset : fill memory area
pub fn knl_memset(s: *void, c: i32, n: i32) *void {
    _ = n;
    @memset(c, s);
}

// memcpy : copy memory
pub fn knl_memcpy(dst: *void, src: *const void, n: i32) *void {
    _ = n;
    @memcpy(dst, src);
    return dst;
}

// strlen : get text string length
pub fn knl_strlen(s: [*]const u8) u8 {
    var count: u8 = 0;
    while (s[count] != 0) : (count += 1) {}
    return count;
}

// strcpy : copy text string
pub fn knl_strcpy(dst: [*]const u8, src: [*]const u8) [*]const u8 {
    for (src, 0..) |data, i| {
        dst[i] = data;
        if (data == 0) {
            dst[i] = 0;
        }
    }
    return dst;
}

pub fn knl_strncpy(dst: []const u8, src: []const u8, n: i32) []const u8 {
    for (src, 0..n) |data, i| {
        if (data == 0) {
            for (i..n) |j|
                dst[j] = 0;
            break;
        }
        dst[i] = data;
    }
    return dst;
}

// strcmp : perform text string comparison
pub fn knl_strcmp(s1: []const u8, s2: []const u8) bool {
    // std.mem.eqlの実装を持ってきた。
    // https://ziglang.org/documentation/master/std/src/std/mem.zig.html#L644
    if (s1.len != s1.len) return false;
    if (s1.ptr == s2.ptr) return true;
    for (s1, s2) |s1_elem, s2_elem| {
        if (s1_elem != s2_elem) return false;
    }
    return true;
}

// strcat : perform text string concatenation
pub fn knl_strcat(dst: [*]const u8, src: [*]const u8) [*]const u8 {
    return dst ++ src;
}
