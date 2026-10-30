

# SukiSU KernelPatch (KPM)

Prebuilt tools from [SukiSU-Ultra/SukiSU_KernelPatch_patch](https://github.com/SukiSU-Ultra/SukiSU_KernelPatch_patch) **v0.14.0**.

CI and local builds use this directory directly — no GitHub release download.

## Required files

| File | Purpose |
|------|---------|
| `kptools-linux` | Patches the built kernel `Image` after compile (x86_64 host binary) |
| `kpimg` | KernelPatch payload embedded by `kptools-linux` |

Optional (not used by CI):

| File | Purpose |
|------|---------|
| `kptools-android` | Android kptools |

Download the matching release assets and place `kptools-linux` + `kpimg` here before building with `use_kpm: true`.

Do not use the 0.14.0 `patch_linux` or `patch_android` assets. `patch_linux` embeds a one-byte `kpimg`, ignores the `kpimg` file, and always exits 0. `patch_android` comes from the same source and was removed with it.
