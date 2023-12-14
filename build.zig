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
        .root_source_file = .{ .path = "src/kernel/sysdepend/cpu/core/armv7m/reset_hdl.zig" },
        .target = target,
        .optimize = optimize,
    });
    const config = b.createModule(.{ .source_file = .{ .path = "src/config/config.zig" } });
    const utils = b.createModule(.{ .source_file = .{ .path = "src/lib/utils.zig" } });
    const devices = b.createModule(.{ .source_file = .{ .path = "src/devices/devices.zig" } });
    const knlink = b.createModule(.{ .source_file = .{ .path = "src/kernel/knlink.zig" } });
    const libsys = b.createModule(.{ .source_file = .{ .path = "src/lib/libsys/libsys.zig" } });
    const libtk = b.createModule(.{ .source_file = .{ .path = "src/lib/libtk/libtk.zig" } });

    try config.dependencies.put("config", config);
    exe.addModule("config", config);

    try utils.dependencies.put("utils", utils);
    try utils.dependencies.put("config", config);
    exe.addModule("utils", utils);

    try devices.dependencies.put("devices", devices);
    try devices.dependencies.put("config", config);
    try devices.dependencies.put("utils", utils);
    try devices.dependencies.put("libtk", libtk);
    exe.addModule("devices", devices);

    try libsys.dependencies.put("libsys", libsys);
    try libsys.dependencies.put("config", config);
    try libsys.dependencies.put("knlink", knlink);
    exe.addModule("libsys", libsys);

    try libtk.dependencies.put("libtk", libtk);
    exe.addModule("libtk", libtk);

    try knlink.dependencies.put("knlink", knlink);
    try knlink.dependencies.put("config", config);
    try knlink.dependencies.put("devices", devices);
    try knlink.dependencies.put("utils", utils);
    try knlink.dependencies.put("libsys", libsys);
    try knlink.dependencies.put("libtk", libtk);
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
