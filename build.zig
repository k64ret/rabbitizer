const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const linkage = b.option(
        std.builtin.LinkMode,
        "linkage",
        "Whether to compile as a static or dynamic library (default: static)",
    ) orelse .static;
    const werror = b.option(
        bool,
        "werror",
        "Treat warnings as errors (default: false)",
    ) orelse false;
    const asan = b.option(
        bool,
        "asan",
        "Enable address and undefined behavior sanitizers (default: false)",
    ) orelse false;
    const experimental = b.option(
        bool,
        "experimental",
        "Enable experimental code paths (default: false)",
    ) orelse false;
    const sanity_checks = b.option(
        bool,
        "sanity-checks",
        "Enable sanity checks (default: true)",
    ) orelse true;

    const rabbitizer_dep = b.dependency("upstream", .{});

    const src_root = rabbitizer_dep.path(".");
    const src_root_xx = rabbitizer_dep.path("cplusplus");
    const tables_path = rabbitizer_dep.path("tables");
    const include_path = rabbitizer_dep.path("include");
    const include_path_xx = rabbitizer_dep.path("cplusplus/include");

    var extra_flags: std.BoundedArray([]const u8, 8) = .{};

    const mod, const mod_xx = .{
        b.createModule(.{
            .target = target,
            .optimize = optimize,
            .pic = true,
            .link_libc = true,
        }),
        b.createModule(.{
            .target = target,
            .optimize = optimize,
            .pic = true,
            .link_libcpp = true,
        }),
    };

    if (optimize != .Debug) {
        extra_flags.appendSliceAssumeCapacity(&.{ "-Os", "-g" });
    } else {
        extra_flags.appendSliceAssumeCapacity(&.{ "-O0", "-g3" });
        mod.addCMacro("DEVELOPMENT", "1");
        mod_xx.addCMacro("DEVELOPMENT", "1");
    }

    if (werror) {
        extra_flags.appendAssumeCapacity("-Werror");
    }

    if (asan) {
        extra_flags.appendSliceAssumeCapacity(&.{
            "-fsanitize=address",
            "-fsanitize=pointer-compare",
            "-fsanitize=pointer-subtract",
            "-fsanitize=undefined",
        });
    }

    if (experimental) {
        mod.addCMacro("EXPERIMENTAL", "");
        mod_xx.addCMacro("EXPERIMENTAL", "");
    }

    if (sanity_checks) {
        mod.addCMacro("RAB_SANITY_CHECKS", "1");
        mod_xx.addCMacro("RAB_SANITY_CHECKS", "1");
    }

    const lib, const lib_xx = .{
        b.addLibrary(.{
            .name = "rabbitizer",
            .linkage = linkage,
            .root_module = mod,
        }),
        b.addLibrary(.{
            .name = "rabbitizerpp",
            .linkage = linkage,
            .root_module = mod_xx,
        }),
    };

    lib.addIncludePath(tables_path);
    lib.addIncludePath(include_path);
    lib.addIncludePath(include_path.path(b, "common"));

    lib.addCSourceFiles(.{
        .root = src_root,
        .files = &c_src,
        .flags = &(warnings ++ c_warnings ++ c_flags ++ extra_flags.buffer),
    });

    lib.installHeadersDirectory(
        include_path,
        "",
        .{ .include_extensions = &.{ ".h", ".inc" } },
    );

    b.installArtifact(lib);

    lib_xx.addIncludePath(tables_path);
    lib_xx.addIncludePath(include_path);
    lib_xx.addIncludePath(include_path.path(b, "common"));
    lib_xx.addIncludePath(include_path_xx);

    lib_xx.addCSourceFiles(.{
        .root = src_root,
        .files = &c_src,
        .flags = &(warnings ++ c_warnings ++ c_flags ++ extra_flags.buffer),
    });
    lib_xx.addCSourceFiles(.{
        .root = src_root_xx,
        .files = &cpp_src,
        .flags = &(warnings ++ cpp_warnings ++ cpp_flags ++ extra_flags.buffer),
    });

    lib_xx.installHeadersDirectory(
        include_path,
        "",
        .{ .include_extensions = &.{ ".h", ".inc" } },
    );
    lib_xx.installHeadersDirectory(
        include_path_xx,
        "",
        .{ .include_extensions = &.{ ".hpp", ".inc" } },
    );

    b.installArtifact(lib_xx);
}

const warnings = [_][]const u8{
    "-Wall",
    "-Wextra",
    "-Wpedantic",
    "-Wunused-value",
    "-Wformat=2",
    "-Wundef",
    "-Werror=vla",
    "-Werror=switch",
    "-Werror=implicit-fallthrough",
    "-Werror=unused-function",
    "-Werror=unused-parameter",
    "-Werror=shadow",
    "-Werror=double-promotion",
    "-Werror=type-limits",
};

const c_src = [_][]const u8{
    "src/analysis/RabbitizerLoPairingInfo.c",
    "src/analysis/RabbitizerRegistersTracker.c",
    "src/analysis/RabbitizerTrackedRegisterState.c",
    "src/common/RabbitizerConfig.c",
    "src/common/RabbitizerVersion.c",
    "src/common/Utils.c",
    "src/instructions/RabbitizerInstrCategory.c",
    "src/instructions/RabbitizerInstrDescriptor.c",
    "src/instructions/RabbitizerInstrId.c",
    "src/instructions/RabbitizerInstrSuffix.c",
    "src/instructions/RabbitizerRegister.c",
    "src/instructions/RabbitizerInstructionRsp/RabbitizerInstructionRsp.c",
    "src/instructions/RabbitizerInstructionRsp/RabbitizerInstructionRsp_OperandType.c",
    "src/instructions/RabbitizerInstructionRsp/RabbitizerInstructionRsp_ProcessUniqueId.c",
    "src/instructions/RabbitizerInstructionR5900/RabbitizerInstructionR5900.c",
    "src/instructions/RabbitizerInstructionR5900/RabbitizerInstructionR5900_OperandType.c",
    "src/instructions/RabbitizerInstructionR5900/RabbitizerInstructionR5900_ProcessUniqueId.c",
    "src/instructions/RabbitizerInstructionCpu/RabbitizerInstructionCpu_OperandType.c",
    "src/instructions/RabbitizerInstruction/RabbitizerInstruction.c",
    "src/instructions/RabbitizerInstruction/RabbitizerInstruction_Disassemble.c",
    "src/instructions/RabbitizerInstruction/RabbitizerInstruction_Examination.c",
    "src/instructions/RabbitizerInstruction/RabbitizerInstruction_ProcessUniqueId.c",
};

const c_flags = [_][]const u8{
    "-std=c11",
    "-fno-common",
};

const c_warnings = [_][]const u8{
    "-Werror=implicit-function-declaration",
    "-Werror=incompatible-pointer-types",
};

const cpp_src = [_][]const u8{
    "src/analysis/LoPairingInfo.cpp",
    "src/analysis/RegistersTracker.cpp",
    "src/instructions/InstrId.cpp",
    "src/instructions/InstructionBase.cpp",
    "src/instructions/InstructionCpu.cpp",
    "src/instructions/InstructionR5900.cpp",
    "src/instructions/InstructionRsp.cpp",
};

const cpp_flags = [_][]const u8{
    "-std=c++17",
    "-fno-common",
};

const cpp_warnings = [_][]const u8{
    "",
};
