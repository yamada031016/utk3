///	string.c
///	T-Kernel standard library

// #include "kernel.h"
// #include <tk/tkernel.h>

// binary operation
// memset : fill memory area
pub fn knl_memset(s: *void, c: i32, n: i32) *void {
    //NOTE: register変数やった
    //   var cp: *u8 = undefined;
    //   var cval: u8 = undefined;
    //   var lp: *u32 = undefined;
    //   var lval: u32 = undefined;
    //
    // cp = @ptrCast(s);
    // cval = @intCast(c);
    //
    // if (n < 8) {
    //   while (n > 0) : (n -= 1) {
    //   *cp+=1;
    //   *cp= cval;
    //   }
    //   return s;
    // }
    //
    //   var cp_casted: i32 = cp;
    // while (cp_casted % 4) {
    //   n-=1;
    //   *cp+=1;
    //   *cp = cval;
    // }
    //
    // lp = @ptrCast(cp);
    // lval = cval | cval << 8 | cval << 16 | cval << 24;
    // // lval = (unsigned long)cval | (unsigned long)cval << 8 |
    // //        (unsigned long)cval << 16 | (unsigned long)cval << 24;
    //
    // while (n >= 4) {
    //   *lp+=1;
    //   *lp = lval;
    //   n -= 4;
    // }
    //
    // cp = @ptrCast(lp);
    // while (n) {
    //   *cp+=1;
    //   *cp = cval;
    //   n-=1;
    // }
    //
    // return s;
    @memset(dst, src);
}

// memcpy : copy memory
pub fn knl_memcpy(dst: *void, src: *const void, n: i32) *void {
    _ = n;
    //NOTE: register変数
    // var cdst: *u32 = undefined;
    // var csrc: *u32 = undefined;
    //
    // cdst = @ptrCast(dst);
    // csrc = @ptrCast(src);
    // while (n > 0) : (n-=1) {
    //   *cdst+=1;
    //   *csrc+=1;
    //   *cdst=*csrc;
    // }
    //
    // return dst;
    @memcpy(dst, src);
    return dst;
}

// strlen : get text string length
pub fn knl_strlen(s: [*]const u8) u8 {
    //NOTE: register変数
    // var cp: *i8 = undefined;
    //
    // cp = (char *)s;
    // while (*cp) {
    //   ++cp;
    // }
    // return (SZ)(cp - s);
    var count: u8 = 0;
    while (s[count] != 0) : (count += 1) {}
    return count;
}

// strcpy : copy text string
pub fn knl_strcpy(dst: [*]const u8, src: [*]const u8) [*]const u8 {
    //NOTE: register変数
    // register char *cp;
    //
    // cp = dst;
    // do {
    //   *cp++ = *src;
    // } while (*src++);
    //
    // return dst;
    for (src, 0..) |data, i| {
        dst[i] = data;
        if (data == '\0') {
            dst[i] = '\0';
        }
    }
    return dst;
}

pub fn knl_strncpy(dst: []const u8, src: []const u8, n: i32) []const u8 {
    // register char *cp;
    //
    // cp = dst;
    // do {
    //   if (n-- <= 0) {
    //     return dst;
    //   }
    //   *cp++ = *src;
    // } while (*src++);
    //
    // while (n-- > 0) {
    //   *cp++ = 0;
    // }
    //
    // return dst;
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
    // register int result;
    //
    // while (*s1) {
    //   result = (unsigned char)*s1++ - (unsigned char)*s2++;
    //   if (result) {
    //     return result;
    //   }
    // }
    //
    // return (unsigned char)*s1 - (unsigned char)*s2;
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
    // register char *cp;
    //
    // cp = dst;
    // while (*cp) {
    //   ++cp;
    // }
    //
    // while (*src) {
    //   *cp++ = *src++;
    // }
    // *cp = '\0';
    //
    // return dst;
    return dst ++ src;
}
