

# SukiSU KernelPatch (KPM)

Prebuilt tools from [SukiSU-Ultra/SukiSU_KernelPatch_patch](https://github.com/SukiSU-Ultra/SukiSU_KernelPatch_patch) **v0.13.0**.

CI and local builds use this directory directly — no GitHub release download.

## Required files

| File | Purpose |
|------|---------|
| `patch_linux` | Patches the built kernel `Image` after compile (x86_64 host binary) |
| `kpimg` | KernelPatch payload embedded by `patch_linux` |

Optional (not used by CI):

| File | Purpose |
|------|---------|
| `patch_android` | ARM64 patch tool for on-device use |
| `kptools-android` | Android kptools |

Download the matching release assets and place `patch_linux` + `kpimg` here before building with `use_kpm: true`.
