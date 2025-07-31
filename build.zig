const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const linkage = b.option(
        std.builtin.LinkMode,
        "linkage",
        "Whether to compile as a static or dynamic library (default: static)",
    ) orelse .static;

    const werror = b.option(bool, "werror", "(default: false)") orelse false;
    _ = werror;

    const asan = b.option(bool, "asan", "(default: false)") orelse false;
    _ = asan;

    const experimental = b.option(bool, "experimental", "(default: false)") orelse false;
    _ = experimental;

    const sanity_checks = b.option(bool, "sanity-checks", "(default: true)") orelse true;
    _ = sanity_checks;

    const rabbitizer_dep = b.dependency("upstream", .{});

    const src_root = rabbitizer_dep.path(".");
    const src_root_xx = rabbitizer_dep.path("cplusplus");
    const tables_path = rabbitizer_dep.path("tables");
    const include_path = rabbitizer_dep.path("include");
    const cpp_include_path = rabbitizer_dep.path("cplusplus/include");

    const mod, const mod_xx = .{
        b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
        b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libcpp = true,
        }),
    };

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

    lib.addCSourceFiles(.{
        .root = src_root,
        .files = &c_src,
        .flags = &warnings ++ c_warnings ++ c_flags,
    });

    lib.installHeadersDirectory(include_path, "", .{});

    b.installArtifact(lib);

    lib_xx.addIncludePath(tables_path);
    lib_xx.addIncludePath(include_path);
    lib_xx.addIncludePath(cpp_include_path);

    lib_xx.addCSourceFiles(.{
        .root = src_root,
        .files = &c_src,
        .flags = &warnings ++ c_warnings ++ c_flags,
    });
    lib_xx.addCSourceFiles(.{
        .root = src_root_xx,
        .files = &cpp_src,
        .flags = &warnings ++ cpp_warnings ++ cpp_flags,
    });

    lib_xx.installHeadersDirectory(include_path, "", .{});
    lib_xx.installHeadersDirectory(
        cpp_include_path,
        "",
        .{ .include_extensions = &.{".hpp"} },
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
    "src/analysis/RabbitizerJrRegData.c",
    "src/analysis/RabbitizerLoPairingInfo.c",
    "src/analysis/RabbitizerRegistersTracker.c",
    "src/analysis/RabbitizerTrackedRegisterState.c",
    "src/common/RabbitizerConfig.c",
    "src/common/RabbitizerVersion.c",
    "src/common/Utils.c",
    "src/instructions/RabbitizerInstrCategory.c",
    "src/instructions/RabbitizerInstrDescriptor.c",
    "src/instructions/RabbitizerInstrId.c",
    "src/instructions/RabbitizerInstrIdType.c",
    "src/instructions/RabbitizerInstrSuffix.c",
    "src/instructions/RabbitizerInstruction/RabbitizerInstruction.c",
    "src/instructions/RabbitizerInstruction/RabbitizerInstruction_Disassemble.c",
    "src/instructions/RabbitizerInstruction/RabbitizerInstruction_Examination.c",
    "src/instructions/RabbitizerInstruction/RabbitizerInstruction_Operand.c",
    "src/instructions/RabbitizerInstruction/RabbitizerInstruction_ProcessUniqueId.c",
    "src/instructions/RabbitizerInstructionCpu/RabbitizerInstructionCpu_OperandType.c",
    "src/instructions/RabbitizerInstructionR3000GTE/RabbitizerInstructionR3000GTE.c",
    "src/instructions/RabbitizerInstructionR3000GTE/RabbitizerInstructionR3000GTE_OperandType.c",
    "src/instructions/RabbitizerInstructionR3000GTE/RabbitizerInstructionR3000GTE_ProcessUniqueId.c",
    "src/instructions/RabbitizerInstructionR4000Allegrex/RabbitizerInstructionR4000Allegrex.c",
    "src/instructions/RabbitizerInstructionR4000Allegrex/RabbitizerInstructionR4000Allegrex_OperandType.c",
    "src/instructions/RabbitizerInstructionR4000Allegrex/RabbitizerInstructionR4000Allegrex_ProcessUniqueId.c",
    "src/instructions/RabbitizerInstructionR5900/RabbitizerInstructionR5900.c",
    "src/instructions/RabbitizerInstructionR5900/RabbitizerInstructionR5900_OperandType.c",
    "src/instructions/RabbitizerInstructionR5900/RabbitizerInstructionR5900_ProcessUniqueId.c",
    "src/instructions/RabbitizerInstructionRsp/RabbitizerInstructionRsp.c",
    "src/instructions/RabbitizerInstructionRsp/RabbitizerInstructionRsp_OperandType.c",
    "src/instructions/RabbitizerInstructionRsp/RabbitizerInstructionRsp_ProcessUniqueId.c",
    "src/instructions/RabbitizerRegister.c",
    "src/instructions/RabbitizerRegisterDescriptor.c",
};

const c_flags = [_][]const u8{
    "-std=c11",
    "-fPIC",
    "-fno-common",
};

const c_warnings = [_][]const u8{
    "-Werror=implicit-function-declaration",
    "-Werror=incompatible-pointer-types",
};

const cpp_src = [_][]const u8{
    "src/analysis/JrRegData.cpp",
    "src/analysis/LoPairingInfo.cpp",
    "src/analysis/RegistersTracker.cpp",
    "src/instructions/InstrId.cpp",
    "src/instructions/InstrIdType.cpp",
    "src/instructions/InstructionBase.cpp",
    "src/instructions/InstructionCpu.cpp",
    "src/instructions/InstructionR3000GTE.cpp",
    "src/instructions/InstructionR4000Allegrex.cpp",
    "src/instructions/InstructionR5900.cpp",
    "src/instructions/InstructionRsp.cpp",
};

const cpp_flags = [_][]const u8{
    "-std=c++17",
    "-fPIC",
    "-fno-common",
};

const cpp_warnings = [_][]const u8{
    "",
};
