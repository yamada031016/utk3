//! logging functios
const libtm = @import("libtm");
const serial = @import("devices").serial;
const builtin = @import("builtin");

pub const Level = enum {
    err,
    warn,
    info,
    debug,

    pub fn asText(comptime self: Level) []const u8 {
        return switch (self) {
            .err => "error",
            .warn => "warning",
            .info => "info",
            .debug => "debug",
        };
    }
};

pub const Scope = enum {
    kernel,
    handler,
    api,
    user,

    pub fn asText(comptime self: Scope) []const u8 {
        return switch (self) {
            .kernel => "kernel",
            .handler => "handler",
            .api => "api",
            .user => "user",
        };
    }
};

pub const default_level: Level = switch (builtin.mode) {
    .Debug => .debug,
    .ReleaseSafe => .warn,
    .ReleaseSmall, .ReleaseFast => .err,
};

pub fn TkLog(comptime level: Level, comptime scope: Scope, comptime format: []const u8, args: anytype) void {
    if (@intFromEnum(level) > @intFromEnum(default_level)) {
        return;
    } else {
        defer serial.puts("\x1b[0m");
        const scope_prefix = scope.asText();
        const prefix = level.asText();

        switch (level) {
            .err => libtm.tm_putstring("\x1b[1;31m"), //Red, Bold
            .warn => libtm.tm_putstring("\x1b[33m"), //Yellow
            .info => libtm.tm_putstring("\x1b[35m"), //Purple
            .debug => libtm.tm_putstring("\x1b[37m"), //White
        }

        libtm.tm_vprintf("{}({}): ", .{ prefix, scope_prefix });
        if (args.len != 0) {
            libtm.tm_printf(format, args);
        } else {
            serial.print(format);
        }
    }
}
