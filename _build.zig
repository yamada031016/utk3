const std = @import("std");

pub fn build(b: *std.Build) !void {
    const _target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabi, // noneでも動いた
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 },
        // .ofmt = .elf,
    });

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "utk3",
        .root_source_file = .{ .path = "src/kernel/sysdepend/cpu/core/armv7m/reset_hdl.zig" },
        .target = _target,
        .optimize = optimize,
    });

    const config = b.createModule(.{ .root_source_file = .{ .path = "src/config/config.zig" } });
    const devices = b.createModule(.{ .root_source_file = .{ .path = "src/devices/devices.zig" } });
    const knlink = b.createModule(.{ .root_source_file = .{ .path = "src/kernel/knlink.zig" } });
    const libsys = b.createModule(.{ .root_source_file = .{ .path = "src/lib/libsys/libsys.zig" } });
    const libtk = b.createModule(.{ .root_source_file = .{ .path = "src/lib/libtk/libtk.zig" } });
    const libtm = b.createModule(.{ .root_source_file = .{ .path = "src/lib/libtm/libtm.zig" } });

    config.addImport("config", config);
    exe.root_module.addImport("config", config);

    devices.addImport("devices", devices);
    devices.addImport("libtk", libtk);
    devices.addImport("config", config);
    exe.root_module.addImport("devices", devices);

    libsys.addImport("libsys", libsys);
    libsys.addImport("libtk", libtk);
    libsys.addImport("config", config);
    libsys.addImport("knlink", knlink);
    libsys.addImport("devices", devices);
    exe.root_module.addImport("libsys", libsys);

    libtk.addImport("libtk", libtk);
    libtk.addImport("libsys", libsys);
    libtk.addImport("devices", devices);
    exe.root_module.addImport("libtk", libtk);

    libtm.addImport("libtm", libtm);
    libtm.addImport("libtk", libtk);
    libtm.addImport("devices", devices);
    exe.root_module.addImport("libtm", libtm);

    knlink.addImport("knlink", knlink);
    knlink.addImport("config", config);
    knlink.addImport("devices", devices);
    knlink.addImport("libsys", libsys);
    knlink.addImport("libtk", libtk);
    knlink.addImport("libtm", libtm);
    exe.root_module.addImport("knlink", knlink);

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

    // const run_cmd = b.addRunArtifact(exe);
    //
    // run_cmd.step.dependOn(b.getInstallStep());
    //
    // if (b.args) |args| {
    //     run_cmd.addArgs(args);
    // }
    //
    // const run_step = b.step("run", "Run the app");
    // run_step.dependOn(&run_cmd.step);
    // const test_target = std.zig.CrossTarget{
    //     // .cpu_arch = std.Target.Cpu.Arch.arm,
    //     // .os_tag = std.Target.Os.Tag.freestanding,
    //     // .abi = std.Target.Abi.none,
    //     // .cpu_arch = .x86,
    //     // .os_tag = .linux,
    //     // .abi = .eabi,
    //     // .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 },
    //     .ofmt = .elf,
    // };
    // _ = test_target;
    //
    // const unit_tests = b.addTest(.{
    //     .root_source_file = .{ .path = "src/main.zig" },
    //     .target = b.standardTargetOptions(std.Build.StandardTargetOptionsArgs{ .default_target = _target }),
    //     .optimize = optimize,
    // });
    //
    // const run_unit_tests = b.addRunArtifact(unit_tests);
    //
    // const test_step = b.step("test", "Run unit tests");
    // test_step.dependOn(&run_unit_tests.step);
}
