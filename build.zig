const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = std.zig.CrossTarget{
        // .cpu_arch = std.Target.Cpu.Arch.arm,
        // .os_tag = std.Target.Os.Tag.freestanding,
        // .abi = std.Target.Abi.none,
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabi,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 },
        .ofmt = .elf,
    };

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "utk3",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    // const tstd = b.createModule(.{ .source_file = .{ .path = "kernel/tstdlib/tstdlib.zig" } });
    const config = b.createModule(.{ .source_file = .{ .path = "src/config/config.zig" } });
    const utils = b.createModule(.{ .source_file = .{ .path = "src/lib/utils.zig" } });
    const devices = b.createModule(.{ .source_file = .{ .path = "src/devices/devices.zig" } });
    const knlink = b.createModule(.{ .source_file = .{ .path = "src/kernel/knlink.zig" } });
    // const inc_sys = b.createModule(.{ .source_file = .{ .path = "include/sys.zig" } });
    // const libtk = b.createModule(.{ .source_file = .{ .path = "lib/libtk.zig" } });
    // const inc_tk = b.createModule(.{ .source_file = .{ .path = "include/tk.zig" } });
    // const inc_tm = b.createModule(.{ .source_file = .{ .path = "include/tm.zig" } });
    // const knlink = b.createModule(.{ .source_file = .{ .path = "kernel/knlink.zig" } });
    //
    // try tstd.dependencies.put("tstd", tstd);
    // exe.addModule("tstd", tstd);
    //
    try config.dependencies.put("config", config);
    exe.addModule("config", config);

    try utils.dependencies.put("utils", utils);
    try utils.dependencies.put("config", config);
    exe.addModule("utils", utils);

    try devices.dependencies.put("devices", devices);
    try devices.dependencies.put("config", config);
    try devices.dependencies.put("utils", utils);
    exe.addModule("devices", devices);

    try knlink.dependencies.put("knlink", knlink);
    try knlink.dependencies.put("config", config);
    try knlink.dependencies.put("utils", utils);
    exe.addModule("knlink", knlink);
    //
    // try inc_sys.dependencies.put("inc_sys", inc_sys);
    // try inc_sys.dependencies.put("config", config);
    // try inc_sys.dependencies.put("inc_tk", inc_tk);
    // exe.addModule("inc_sys", inc_sys);
    //
    // try libtk.dependencies.put("libtk", libtk);
    // try libtk.dependencies.put("inc_sys", inc_sys);
    // exe.addModule("libtk", libtk);
    //
    // try inc_tk.dependencies.put("inc_tk", inc_tk);
    // try inc_tk.dependencies.put("libtk", libtk);
    // exe.addModule("inc_tk", inc_tk);
    //
    // try inc_tm.dependencies.put("inc_tm", inc_tm);
    // exe.addModule("inc_tm", inc_tm);
    //
    // try knlink.dependencies.put("knlink", knlink);
    // try knlink.dependencies.put("inc_sys", inc_sys);
    // try knlink.dependencies.put("inc_tk", inc_tk);
    // try knlink.dependencies.put("libtk", libtk);
    // exe.addModule("knlink", knlink);
    //
    exe.setLinkerScript(.{ .path = "./tkernel_map.ld" });

    // exe.addAssemblyFile(.{ .path = "kernel/sysdepend/cpu/core/armv7m/dispatch.S" });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
    const test_target = std.zig.CrossTarget{
        // .cpu_arch = std.Target.Cpu.Arch.arm,
        // .os_tag = std.Target.Os.Tag.freestanding,
        // .abi = std.Target.Abi.none,
        // .cpu_arch = .x86,
        // .os_tag = .linux,
        // .abi = .eabi,
        // .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 },
        .ofmt = .elf,
    };

    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = test_target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
