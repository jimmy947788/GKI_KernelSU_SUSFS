<div align="center">

# 🔥 Wild Kernels for Android（繁體中文說明）

[![KernelSU](https://img.shields.io/badge/KernelSU-Supported-green)](https://kernelsu.org/)
[![SUSFS](https://img.shields.io/badge/SUSFS-Integrated-orange)](https://gitlab.com/simonpunk/susfs4ksu)

</div>

## 🌐 語系

- English: [README.md](README.md)
- 繁體中文: [README_zh-TW.md](README_zh-TW.md)

## ⚠️ 風險聲明

我**不對**刷入此核心後造成的裝置損壞、資料遺失、硬體異常或任何問題負責。

請先充分了解此核心功能與風險，再進行刷機。

一旦刷入，代表你已自行承擔所有後果。

---

### 🚨 請自行承擔風險

---

## 🔧 可用核心專案

| 核心 | 倉庫 | 狀態 |
|--------|------------|--------|
| 🏗️ **GKI** | [GKI_KernelSU_SUSFS](https://github.com/WildKernels/GKI_KernelSU_SUSFS) | ✅ Active |
| 👑 **Sultan** | [Sultan_KernelSU_SUSFS](https://github.com/WildKernels/Sultan_KernelSU_SUSFS) | ✅ Active |
| 📱 **OnePlus** | [OnePlus_KernelSU_SUSFS](https://github.com/WildKernels/OnePlus_KernelSU_SUSFS) | ✅ Active |

---

## 🔗 其他資源

- 🩹 [Kernel Patches](https://github.com/WildKernels/kernel_patches)
- 📜 [Old Build Scripts](https://github.com/TheWildJames/kernel_build_scripts)
- ⚡ [Kernel Flasher](https://github.com/fatalcoder524/KernelFlasher)

---

## 📋 安裝說明

GKI 安裝方式請參考官方文件：

📖 **[KernelSU 安裝指南](https://kernelsu.org/guide/installation.html)**

---

## 🧭 OS Patch Level 對應說明（重要）

各版本設定檔中的 `date`（例如 `.github/config/android13-5.10.json`）**不只是標籤**。

它會在下載核心原始碼時，被當成 `os_patch_level` 使用，並拼成上游分支名稱，例如：

- `common-android13-5.10-2023-09`
- `common-android13-5.10-2025-07`

這也是為什麼你會看到同一個 sublevel（例如 `5.10.107`）但有多個不同日期。
每個日期都代表不同月份的核心分支。

### 為什麼這很重要

若你的裝置 firmware/vendor stack 屬於某個 patch level，卻刷入差距很大的月份核心，可能導致無法開機。

### 實務建議

- 先讓 build 日期對齊你目前 ROM 的 patch level。
- Pixel 6 Pro（Android 13，`raven-tq3a.230901.001`）建議先從 `android13-5.10` + `2023-09` 開始。
- 先測 normal 版可開機，再逐步嘗試 bypass/KPM。

### 編譯產物：`Flashable-Zips` 與 `AnyKernel3` 差異

每次 workflow 成功後，通常會看到兩組同前綴產物：

- `...-AnyKernel3`
- `...-Flashable-Zips`

用途差異：

- `AnyKernel3`
  - 原始 AnyKernel3 工作目錄內容。
  - 適合進階使用者自行檢查或修改封裝內容後再刷。
  - 可能同時包含 `Image` 與 `Bypass-Image`。

- `Flashable-Zips`
  - 已預先封裝好的可刷 zip。
  - 內含兩個最終檔案：
    - `...-AnyKernel3-normal.zip`（標準核心映像）
    - `...-AnyKernel3-bypass.zip`（bypass 核心映像）
  - 一般使用者建議直接下載這組刷入。

快速建議：

- 先刷 `...-AnyKernel3-normal.zip`。
- 若 normal 因版本檢查或相容限制無法啟動，再試 bypass 版。

### GitHub Actions `feature_set` 選項說明

`Build Kernels` workflow 的 `feature_set` 用來控制「可選功能群組」。

代碼含義：

- `KSUN`：啟用 KernelSU-Next
- `SUSFS`：啟用 SUSFS patch 流程
- `BBG`：啟用 Baseband Guard
- `NET`：啟用 Networking patch 集
- `DS`：啟用 DroidSpaces-OSS patches

Actions 選單中各選項意義：

- `KSUN+SUSFS+BBG+NET+DS`：啟用上述五個功能群組
- `KSUN+SUSFS+BBG`：啟用 KernelSU + SUSFS + BBG
- `KSUN+SUSFS+NET`：啟用 KernelSU + SUSFS + NET
- `KSUN+SUSFS+DS`：啟用 KernelSU + SUSFS + DS
- `KSUN+SUSFS`：啟用 KernelSU + SUSFS
- `KSUN+BBG`：啟用 KernelSU + BBG
- `KSUN+NET`：啟用 KernelSU + NET
- `KSUN+DS`：啟用 KernelSU + DS
- `KSUN`：只啟用 KernelSU
- `NONE`：停用上述五個可選群組
- `FULL`：等同全開（效果同 `KSUN+SUSFS+BBG+NET+DS`）

注意：

- `feature_set` 不會控制所有 build 步驟。
- 某些核心相容與打包步驟仍會執行（例如：kernel fixes、ntsync、ptrace、unicode fix、btf、封裝流程）。

### GitHub Actions `quick_mode`（快速編譯）

`Build Kernels` workflow 新增 `quick_mode` 輸入，用於縮短單次驗證 build 的時間。

當 `quick_mode=true`：

- 跳過磁碟清理步驟（Free Disk Space）。
- 跳過 swap 建立步驟（Setup more Swap）。
- 跳過 bypass 核心編譯（只編 normal 核心）。
- `Flashable-Zips` 產物只會包含 `...-AnyKernel3-normal.zip`。

當 `quick_mode=false`（預設）：

- 走完整流程，包含 normal + bypass 兩次編譯與兩個 flashable zip。

建議使用方式：

- 平常驗證或除錯先用 `quick_mode=true`。
- 正式發版再改回 `quick_mode=false`。

### 完整輸入範例（快速路徑）

以下是 `Build Kernels` workflow 的完整輸入範例，適合單一版本快速驗證：

```yaml
release_type: Action
kernel_build_version: android13-5.10
os_patch_level_filter: "2023-09"
feature_set: KSUN+SUSFS
use_kpm: "false"
quick_mode: "true"
ksu_branch: ""
susfs_commit_android12-5-10: ""
susfs_commit_android13-5-10: ""
susfs_commit_android13-5-15: ""
susfs_commit_android14-5-15: ""
susfs_commit_android14-6-1: ""
susfs_commit_android15-6-6: ""
susfs_commit_android16-6-12: ""
```

此範例補充：

- `ksu_branch` 留空代表使用預設最新分支。
- `susfs_commit_*` 留空代表使用各分支最新 commit。
- 只會編譯 `android13-5.10` + `2023-09` 這一組。

---

## ✨ 主要功能

- 🔐 **KernelSU**：運作於核心層的 root 方案，可直接在 kernel 空間管理 userspace 應用程式授權。
- 🛡️ **SUSFS**：KernelSU 的隱藏與偽裝相關補丁與使用者空間模組。

---

## 🏆 鳴謝

- 🔐 **KernelSU**：由 [tiann](https://github.com/tiann/KernelSU) 開發
- 🚀 **KernelSU-Next**：由 [rifsxd](https://github.com/KernelSU-Next/KernelSU-Next) 開發
- ✨ **Magic-KSU**：由 [5ec1cff](https://github.com/5ec1cff/KernelSU) 開發
- 🛡️ **SUSFS**：由 [simonpunk](https://gitlab.com/simonpunk/susfs4ksu.git) 開發
- 🛡️ **Baseband-guard (BBG)**：由 [vc-teahouse](https://github.com/vc-teahouse/Baseband-guard) 開發
- 📦 **SUSFS Module**：由 [sidex15](https://github.com/sidex15) 開發
- 👑 **Sultan Kernels**：由 [kerneltoast](https://github.com/kerneltoast) 開發
- 🔧 **Device Boot Fix**：參考 [Boot fix commit](https://github.com/Anything-at-25-00/android_kernel_common_android12-5.10/commit/2476d262b597fe8af82cfb7aaf96676f51c6b4ed)

感謝所有開源貢獻者。

---

## 💬 支援

如遇問題，歡迎：

- 🐛 在此倉庫開 issue
- 💬 直接聯絡維護者

---

## ⚠️ 免責聲明

刷入此核心可能使保固失效，且存在變磚風險。請務必：

- 💾 先備份資料
- 🧠 充分理解風險

**🚨 請自行承擔風險**

---

<div align="center">

## 📱 聯絡我們

[![Telegram](https://img.shields.io/badge/Telegram-TheWildJames-blue?logo=telegram)](https://t.me/TheWildJames)
[![Telegram Group](https://img.shields.io/badge/Telegram-WildKernelsTG-blue?logo=telegram)](https://t.me/WildKernelsTG)

</div>

---

## 🌟 特別感謝

**以下夥伴讓此專案成為可能 ❤️**

| 貢獻者 | 貢獻 |
|-------------|-------------|
| 🛡️ [simonpunk](https://gitlab.com/simonpunk/susfs4ksu.git) | 建立 SUSFS |
| 📦 [sidex15](https://github.com/sidex15) | 製作模組 |
| 🩹 [backslashxx](https://github.com/backslashxx) | 協助 patches |
| 🔧 [Teemo](https://github.com/liqideqq) | 協助 patches |
| 💝 [幕落](https://github.com/MuLuo688) | 捐助 |
| 🛡️ [vc-teahouse](https://github.com/vc-teahouse) | 建立 BBG |

若你有貢獻但尚未列名，請提醒維護者。

---

## 💝 捐助

任何形式的支持都非常感謝：

- PayPal: [bauhd@outlook.com](mailto:bauhd@outlook.com)
- Card: <https://buy.stripe.com/5kQ28sdi08Nr0Xc2fU5os00>
- LTC: MVaN1ToSuks2cdK9mB3M8EHCfzQSyEMf6h
- BTC: 3BBXAMS4ZuCZwfbTXxWGczxHF4isymeyxG
- ETH: 0x2b9C846c84d58717e784458406235C09a834274e
- Patreon: <https://patreon.com/WildKernels>
