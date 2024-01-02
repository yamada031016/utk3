const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = std.zig.CrossTarget{
        // .cpu_arch = std.Target.Cpu.Arch.arm,
        // .os_tag = std.Target.Os.Tag.freestanding,
        // .abi = std.Target.Abi.none,
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabi, // noneでも動いた
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
    const devices = b.createModule(.{ .source_file = .{ .path = "src/devices/devices.zig" } });
    const knlink = b.createModule(.{ .source_file = .{ .path = "src/kernel/knlink.zig" } });
    const libsys = b.createModule(.{ .source_file = .{ .path = "src/lib/libsys/libsys.zig" } });
    const libtk = b.createModule(.{ .source_file = .{ .path = "src/lib/libtk/libtk.zig" } });
    const libtm = b.createModule(.{ .source_file = .{ .path = "src/lib/libtm/libtm.zig" } });

    try config.dependencies.put("config", config);
    exe.addModule("config", config);

    try devices.dependencies.put("devices", devices);
    try devices.dependencies.put("config", config);
    try devices.dependencies.put("libtk", libtk);
    exe.addModule("devices", devices);

    try libsys.dependencies.put("libsys", libsys);
    try libsys.dependencies.put("libtk", libtk);
    try libsys.dependencies.put("config", config);
    try libsys.dependencies.put("knlink", knlink);
    try libsys.dependencies.put("devices", devices);
    exe.addModule("libsys", libsys);

    try libtk.dependencies.put("libtk", libtk);
    try libtk.dependencies.put("libsys", libsys);
    try libtk.dependencies.put("devices", devices);
    exe.addModule("libtk", libtk);

    try libtm.dependencies.put("libtm", libtm);
    try libtm.dependencies.put("libtk", libtk);
    try libtm.dependencies.put("devices", devices);
    exe.addModule("libtm", libtm);

    try knlink.dependencies.put("knlink", knlink);
    try knlink.dependencies.put("config", config);
    try knlink.dependencies.put("devices", devices);
    try knlink.dependencies.put("libsys", libsys);
    try knlink.dependencies.put("libtk", libtk);
    try knlink.dependencies.put("libtm", libtm);
    exe.addModule("knlink", knlink);

    exe.setLinkerScript(.{ .path = "./tkernel_map.ld" });

    // exe.addAssemblyFile(.{ .path = "kernel/sysdepend/cpu/core/armv7m/dispatch.S" });
    const bin = b.addObjCopy(exe.getEmittedBin(), .{
        .format = .bin,
    });
    bin.step.dependOn(&exe.step);

    // Copy the bin to the output directory
    const copy_bin = b.addInstallBinFile(bin.getOutput(), "utk3.bin");
    b.default_step.dependOn(&copy_bin.step);

    const stlink = b.step("stlink", "Write binary file to stm32l4");
    const stlink_path = &[_][]const u8{ "st-flash", "write", "zig-out/bin/utk3.bin", "0x08000000" };
    const run_stlink = b.addSystemCommand(stlink_path);
    run_stlink.step.dependOn(b.getInstallStep());
    stlink.dependOn(&run_stlink.step);

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
