<div align="center">

# 🔥 Wild Kernels for Android

[![KernelSU](https://img.shields.io/badge/KernelSU-Supported-green)](https://kernelsu.org/)
[![SUSFS](https://img.shields.io/badge/SUSFS-Integrated-orange)](https://gitlab.com/simonpunk/susfs4ksu)

</div>

## 🌐 Language

- English: [README.md](README.md)
- 繁體中文: [README_zh-TW.md](README_zh-TW.md)

## ⚠️ Your warranty is no longer valid!

I am **not responsible** for bricked devices, damaged hardware, or any issues that arise from using this kernel.

**Please** do thorough research and fully understand the features included in this kernel before flashing it!

By flashing this kernel, **YOU** are choosing to make these modifications. If something goes wrong, **do not blame me**!

---

### 🚨 Proceed at your own risk!

---

## 🔧 Available Kernels

| Kernel | Repository | Status |
|--------|------------|--------|
| 🏗️ **GKI** | [GKI_KernelSU_SUSFS](https://github.com/WildKernels/GKI_KernelSU_SUSFS) | ✅ Active |
| 👑 **Sultan** | [Sultan_KernelSU_SUSFS](https://github.com/WildKernels/Sultan_KernelSU_SUSFS) | ✅ Active |
| 📱 **OnePlus** | [OnePlus_KernelSU_SUSFS](https://github.com/WildKernels/OnePlus_KernelSU_SUSFS) | ✅ Active |

---

## 🔗 Additional Resources

- 🩹 [Kernel Patches](https://github.com/WildKernels/kernel_patches)
- 📜 [Old Build Scripts](https://github.com/TheWildJames/kernel_build_scripts)
- ⚡ [Kernel Flasher](https://github.com/fatalcoder524/KernelFlasher)

---

## 📋 Installation Instructions

For GKI installation, please follow the official guide:

📖 **[KernelSU Installation Guide](https://kernelsu.org/guide/installation.html)**

---

## 🧭 OS Patch Level Mapping (Important)

The `date` field in each build matrix config (for example, `.github/config/android13-5.10.json`) is not only a label.
It is passed into the kernel source fetch step as `os_patch_level` and used to select the upstream branch:

- `common-android13-5.10-2023-09`
- `common-android13-5.10-2025-07`

This is why you can see multiple builds with the same sublevel (such as `5.10.107`) but different dates.
Each date points to a different monthly kernel branch.

### Why this matters

If your device firmware/vendor stack is from one patch level, flashing a kernel built from a much newer or older patch level can cause boot failure.

### Practical guidance

- Match build date to your ROM patch level first.
- For Pixel 6 Pro on Android 13 `raven-tq3a.230901.001`, start with `android13-5.10` + `2023-09`.
- Test normal build first, then try bypass/KPM only after a known-good boot.

### Build artifacts: `Flashable-Zips` vs `AnyKernel3`

After a successful workflow run, you will usually see two artifact groups with the same kernel prefix:

- `...-AnyKernel3`
- `...-Flashable-Zips`

What each one means:

- `AnyKernel3`
	- Raw AnyKernel3 working directory contents.
	- Intended for advanced users who want to inspect or modify packaging files before flashing.
	- May include both `Image` and `Bypass-Image` files depending on build steps.

- `Flashable-Zips`
	- Pre-packed, ready-to-flash zip outputs.
	- Contains two final packages:
		- `...-AnyKernel3-normal.zip` (standard kernel image)
		- `...-AnyKernel3-bypass.zip` (bypass kernel image)
	- Recommended for normal usage when you just want to download and flash.

Quick recommendation:

- Start with `...-AnyKernel3-normal.zip` first.
- Only move to bypass zip if normal boot fails due to version checks or compatibility restrictions.

### Important note for SukiSU / KPM mode

If you change the workflow to enable or adjust SukiSU / KPM integration, previously built kernel zip files do not gain those features automatically.

- You must rebuild the kernel after changing SukiSU / KPM workflow logic.
- You must re-download the newly generated artifact.
- You must re-flash the newly generated zip.

Old zip files built before the SukiSU / KPM integration change will still behave like the old build and may boot successfully while the SukiSU app still reports that root is unavailable.

### GitHub Actions `feature_set` options

In the `Build Kernels` workflow, `feature_set` controls optional patch groups.

Token meaning:

- `KSUN`: Enable KernelSU-Next setup
- `SUSFS`: Enable SUSFS setup/patches
- `BBG`: Enable Baseband Guard patches
- `NET`: Enable networking patch set
- `DS`: Enable DroidSpaces-OSS patches

What BBG / NET / DS actually do:

- `BBG` (Baseband Guard)
	- Installs and enables the Baseband Guard security module (`CONFIG_BBG=y`).
	- Adds `baseband_guard` to the active LSM chain in kernel security config.
	- Intended for security hardening, not for performance tuning.

- `NET` (Networking patch set)
	- Enables extended networking features such as ipset/netfilter options, WireGuard, CIFS, and advanced qdisc settings.
	- Applies BBRv3-related patches on supported versions.
	- Intended for networking capability/performance use cases.

- `DS` (DroidSpaces-OSS)
	- Applies DroidSpaces-OSS compatibility patches.
	- Enables namespace/IPC-related configs (for example PID/IPC/USER namespaces and SYSVIPC-related options).
	- Intended for DroidSpaces-style isolation/container workflows.

Recommended usage order (stability-first):

- Start with `KSUN+SUSFS` only.
- Add `BBG`/`NET`/`DS` one by one after confirming boot stability.

Available options in the action menu:

- `KSUN+SUSFS+BBG+NET+DS`: Enable all five optional groups
- `KSUN+SUSFS+BBG`: Enable KernelSU + SUSFS + Baseband Guard
- `KSUN+SUSFS+NET`: Enable KernelSU + SUSFS + networking
- `KSUN+SUSFS+DS`: Enable KernelSU + SUSFS + DroidSpaces
- `KSUN+SUSFS`: Enable KernelSU + SUSFS
- `KSUN+BBG`: Enable KernelSU + Baseband Guard
- `KSUN+NET`: Enable KernelSU + networking
- `KSUN+DS`: Enable KernelSU + DroidSpaces
- `KSUN`: Enable KernelSU only
- `NONE`: Disable all five optional groups above
- `FULL`: Alias for enabling all optional groups (same effective behavior as `KSUN+SUSFS+BBG+NET+DS`)

Notes:

- `feature_set` does not control all steps in the pipeline.
- Core compatibility/build steps still run (for example: kernel fixes, ntsync, ptrace, unicode fix, btf, packaging).

---

## ✨ Features

- 🔐 **KernelSU**: A root solution for Android GKI devices that works in kernel mode and grants root permission to userspace applications directly in kernel space
- 🛡️ **SUSFS**: An addon root hiding kernel patches and userspace module for KernelSU

---

## 🏆 Credits

- 🔐 **KernelSU**: Developed by [tiann](https://github.com/tiann/KernelSU)
- 🚀 **KernelSU-Next**: Developed by [rifsxd](https://github.com/KernelSU-Next/KernelSU-Next)
- ✨ **Magic-KSU**: Developed by [5ec1cff](https://github.com/5ec1cff/KernelSU)
- 🛡️ **SUSFS**: Developed by [simonpunk](https://gitlab.com/simonpunk/susfs4ksu.git)
- 🛡️ **Baseband-guard (BBG)**: Developed by [vc-teahouse](https://github.com/vc-teahouse/Baseband-guard)
- 📦 **SUSFS Module**: Developed by [sidex15](https://github.com/sidex15)
- 👑 **Sultan Kernels**: Developed by [kerneltoast](https://github.com/kerneltoast)
- 🔧 **Device Boot Fix**: [Boot fix commit](https://github.com/Anything-at-25-00/android_kernel_common_android12-5.10/commit/2476d262b597fe8af82cfb7aaf96676f51c6b4ed) for fixing some devices not booting

🙏 Special thanks to the open-source community for their contributions!

---

## 💬 Support

If you encounter any issues or need help, feel free to:
- 🐛 Open an issue in this repository
- 💬 Reach out to me directly

---

## ⚠️ Disclaimer

Flashing this kernel will void your warranty, and there is always a risk of bricking your device. Please make sure to:
- 💾 Back up your data
- 🧠 Understand the risks before proceeding

**🚨 Proceed at your own risk!**

---

<div align="center">

## 📱 Connect With Us

[![Telegram](https://img.shields.io/badge/Telegram-TheWildJames-blue?logo=telegram)](https://t.me/TheWildJames)
[![Telegram Group](https://img.shields.io/badge/Telegram-WildKernelsTG-blue?logo=telegram)](https://t.me/WildKernelsTG)

</div>

---

## 🌟 Special Thanks

**These amazing people help make this project possible! ❤️**

| Contributor | Contribution |
|-------------|-------------|
| 🛡️ [simonpunk](https://gitlab.com/simonpunk/susfs4ksu.git) | Created SUSFS! |
| 📦 [sidex15](https://github.com/sidex15) | Created module! |
| 🩹 [backslashxx](https://github.com/backslashxx) | Helped with patches! |
| 🔧 [Teemo](https://github.com/liqideqq) | Helped with patches! |
| 💝 [幕落](https://github.com/MuLuo688) | Donation! |
| 🛡️ [vc-teahouse](https://github.com/vc-teahouse) | Created Baseband-guard (BBG)! |

*If you have contributed and are not listed here, please remind me!* 🙏

---

## 💝 Donations

Any and all donations are appreciated!

- PayPal: [bauhd@outlook.com](mailto:bauhd@outlook.com)
- Card: <https://buy.stripe.com/5kQ28sdi08Nr0Xc2fU5os00>
- LTC: MVaN1ToSuks2cdK9mB3M8EHCfzQSyEMf6h
- BTC: 3BBXAMS4ZuCZwfbTXxWGczxHF4isymeyxG
- ETH: 0x2b9C846c84d58717e784458406235C09a834274e
- Patreon: <https://patreon.com/WildKernels>
