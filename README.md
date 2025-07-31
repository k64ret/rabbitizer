# Rabbitizer

_[rabbitizer](https://github.com/Decompollaborate/rabbitizer) ported to the Zig
build system_

## Consuming

Since this repo doesn't currently have tags or releases, it makes the most sense
to pull the latest commit from `main`.

```sh
zig fetch --save git+https://github.com/k64ret/rabbitizer?ref=main
```

Then, you can consume rabbitizer as a static or dynamic library in your
`build.zig`.

```zig
const rabbitizer_dep = b.dependency("rabbitizer", .{
    .target = target,
    .optimize = optimize,
    // These are the defaults if not provided...
    .linkage = .static, // or `.dynamic`
    .experimental = false,
    .sanity_checks = true,
});
// C artifact
const rabbitizer_artifact = rabbitizer_dep.artifact("rabbitizer");
// or, C++ artifact
const rabbitizer_artifact = rabbitizer_dep.artifact("rabbitizerpp");
// Then link against it
some_lib_or_exe.linkLibrary(rabbitizer_artifact);
```
