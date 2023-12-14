const print = @import("devices").serial.print;

pub fn usermain() i32 {
    print("usermain started!");
    return 0;
}
