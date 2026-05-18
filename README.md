# rabbitizer

[![CI](https://github.com/k64ret/rabbitizer/actions/workflows/ci.yaml/badge.svg)](https://github.com/k64ret/rabbitizer/actions/workflows/ci.yaml)

_[rabbitizer](https://github.com/Decompollaborate/rabbitizer) ported to the Zig
build system_

## Consuming

```sh
zig fetch --save https://github.com/k64ret/rabbitizer/archive/refs/tags/1.3.0.tar.gz
```

Then, you can consume rabbitizer as a static or dynamic library in your
`build.zig`.

```zig
const rabbitizer_dep = b.dependency("rabbitizer", .{
    .target = target,
    .optimize = optimize,
    // These are the defaults if not provided...
    .linkage = .static, // or `.dynamic`
    .werror = false,
    .asan = false,
    .experimental = false,
    .sanity_checks = true,
});

// C artifact
const rabbitizer_artifact = rabbitizer_dep.artifact("rabbitizer");
// or, C++ artifact
const rabbitizer_artifact = rabbitizer_dep.artifact("rabbitizerpp");

some_lib_or_exe.root_module.addIncludePath(rabbitizer_artifact.getEmittedIncludeTree());
some_lib_or_exe.root_module.linkLibrary(rabbitizer_artifact);
```

## Building

```sh
zig build [OPTIONS] [--summary all]
```

### Options

#### `-Dlinkage=<static|dynamic>`

Whether to compile as a static or dynamic library.

#### `-Dwerror`

Treat warnings as errors.

#### `-Dasan`

Enable address and undefined behavior sanitizers.

#### `-Dexperimental`

Enable experimental code paths.

#### `-Dsanity-checks`

Enable sanity checks.
