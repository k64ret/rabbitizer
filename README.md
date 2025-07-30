# Rabbitizer

_[rabbitizer](https://github.com/Decompollaborate/rabbitizer) ported to the Zig
build system_

## Consuming

Since [rabbitizer](https://github.com/k64ret/rabbitizer) doesn't have tags or
releases yet, it makes the most sense to pull the latest commit from `main` like
so.

```sh
zig fetch --save git+https://github.com/k64ret/rabbitizer?ref=main
```

You can then consume rabbitizer as a static or dynamic library in your
`build.zig`.

```zig
// Static library
const rabbitizer_dep = b.dependency("rabbitizer", .{
    .target = target,
    .optimize = optimize,
    .linkage = .static
});
// Dynamic library
const rabbitizer_dep = b.dependency("rabbitizer", .{
    .target = target,
    .optimize = optimize,
    .linkage = .dynamic
});
// C library artifact
const rabbitizer_artifact = rabbitizer_dep.artifact("rabbitizer");
// or, C++ library artifact
const rabbitizer_artifact = rabbitizer_dep.artifact("rabbitizerpp");
// Then link against it
some_lib_or_exe.linkLibrary(rabbitizer_artifact);
```
