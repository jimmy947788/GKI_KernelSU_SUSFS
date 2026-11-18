# KPatch-Next (KPM)

Prebuilt tools from [KernelSU-Next/KPatch-Next](https://github.com/KernelSU-Next/KPatch-Next) release
[**0.13.5-2**](https://github.com/KernelSU-Next/KPatch-Next/releases/tag/0.13.5-2) (kpimg version `0xd05`, built 2026-01-20).

CI and local builds use this directory directly; nothing is downloaded at build time.

| File | Purpose | SHA-256 |
|------|---------|---------|
| `kptools-linux` | Patches the built kernel `Image` after compile (x86_64 host binary) | `cf1bbce43119ebf19eb1921ea5e0ed45fb5b143b19ab4b001eecc94b28b0fef7` |
| `kpimg-linux` | KPatch-Next payload embedded by `kptools-linux` | `943ce69cb00ed7aaff988da9a3fdda89004ba813b2c30aa4a843c642542d4cde` |

## Why KPatch-Next instead of SukiSU_KernelPatch_patch

Measured on a Pixel 6 Pro (`raven`, TQ3A.230901.001) with one-shot `fastboot boot` (nothing flashed):

| Payload on the r57.1 Nova GKI | Boots |
|---|---|
| SukiSU_KernelPatch_patch 0.14.0 (ABI v2, what Nova's KPM page needs) | 0/4, hangs before any Linux log (`0xcbea APC Watchdog Early`) |
| SukiSU_KernelPatch_patch 0.13.9 | 1/4 |
| SukiSU_KernelPatch_patch 0.13.0 | 4/4, but has no supercall and hooks `sukisu_kpm_*` symbols Nova no longer has, so KPM cannot be used at all |
| **KPatch-Next 0.13.5-2** | **5/5**, `KP KernelPatch Version: d05` in dmesg |

## Behaviour on the device

- KPatch-Next has **no superkey**. `kptools-linux` has no `-s` option; the kernel accepts supercalls
  from uid 0 only, so whoever has KernelSU root can manage KPM.
- The SukiSU Nova manager shows **KPM: Unsupported**. Its KPM page only talks to the SukiSU ABI v2
  bridge. This is expected; KernelPatch itself is running.
- Load and manage `.kpm` files with [KPatch-Next-Module](https://github.com/KernelSU-Next/KPatch-Next-Module)
  (WebUI, auto-loads `/data/adb/kp-next/kpm/*.kpm` at boot) or its `kpatch` CLI from a root shell.
  Do not use the module's boot-patch button: the kernel is already patched.
- Do not run KPatch-Next-Module under APatch; it aborts there.
