# 評估報告：讓 GKI 支援 SukiSU Ultra v4.2.0（俗稱 "v4.20"）

**日期：** 2026-09-23
**實作：** 分支 `sukisu-v4.2.0` 已按方案 A 改 pin。driver `b20dee702`、版本 ref `v4.2.0`（versionCode `40899`）、`android13-5.10` SUSFS `2c774fdb`（v2.3.0）。其他 GKI 版本沒有預設 SUSFS pin。
**範圍：** 版本相容與要改的 pin。不含漏洞利用。

## 結論

使用者說的「v4.20」是上游 tag **`v4.2.0`**（`85eb4a95`，2026-09-01，在 **`main`**）。沒有字面上的 `v4.20` tag。

目前 kernel 能配 Manager **v4.1.3**（versionCode `40796`），不能配 v4.2.0。原因是 driver 釘在 builtin `6c13a06`（2026-05-30），停在 UAPI v2 之前。Manager v4.2.0 的 `requireNewKernel()` 會因 `kernelUAPIVersion != 2` 把功能 UI 藏起來。數字版本門檻 `32513` 不是這次的阻礙：現在印的 `KSU_VERSION` 已是 `40796`。

**不要把 pin 改成 tag `v4.2.0`。** 那個 commit 在 `main`，`kernel/Kconfig` 沒有 `config KSU_SUSFS`，目錄也已改成 `Kbuild` + `core/`。本倉庫的 sukisu action 會直接失敗。

要改的目標是 **`builtin` HEAD `b20dee702`**（2026-09-13）。它比 `6c13a06` 只多 19 個 commit、16 個檔，樹狀結構不變，而且已經包含：

- `b8279c3`：`KERNEL_SU_UAPI_VERSION = 2`、新的 `KSU_IOCTL_GET_INFO`、`KSU_IOCTL_GET_INFO_LEGACY`
- `KSU_APP_PROFILE_VER` 3 → 4，`root_profile` 多了 `__u64 flags`（`FLAG_KSU_NO_NEW_PRIVS`）
- `e2912817`：bump version to 4.2.0
- `5a2bb7e`：`CONFIG_KSU_SUSFS` 誤進 safe mode 的修正
- `b20dee7`：補回 `kernel_umount_feature_set`

`kernel/kpm/*` 不在這 16 個檔裡。KPM release 仍只有 **0.13.0**，先不要換 `patch_linux` / `kpimg`。

## 必須一起動的 SUSFS

新 driver 的 `lsm_hook.c` / `sucompat.c` 會呼叫：

- `susfs_set_current_proc_no_su()`
- `susfs_set_current_proc_umounted_for_zygote_next()`
- `susfs_zygote_next_sid`

這些是 `susfs_def.h` 裡的 inline，定義在 susfs4ksu **v2.3.0**（2026-08-30 的 bump，`TIF_PROC_NO_SU` / `TIF_PROC_UMOUNTED_FOR_ZYGOTE_NEXT`）。目前 pin **`ee023e3`（2026-05-30，SUSFS v2.1.0）沒有這些符號**。只升 driver、SUSFS 不動，編譯會缺宣告。

`10_enable_susfs_for_ksu.patch` 是對 `main` 新目錄寫的，本 workflow 沒有套它。GKI 繼續走現有的 `50_add_susfs_in_gki-*.patch` + `fs/susfs.c` + `include/linux/susfs*.h`。各 `gki-*` 分支的 SHA 不同，不能假設一個 hash 在七條分支都存在。

## 版本數字

Manager 與 kernel 同一條公式：`4 * 10000 + commit_count - 2815`。

| ref | commit count | versionCode |
|---|---:|---:|
| `v4.1.3` | 3611 | 40796 |
| `v4.2.0` | 3714 | 40899 |

`REPO_BRANCH` 目前被 sukisu action 改成 `v4.1.3`，所以印出 40796。升 driver 時要把 `ksu_version_ref` 改成 **`v4.2.0`**，讓 `KSU_VERSION` 對上新 Manager。

## 本倉庫要改的檔

**Driver / 版本字串**

- `.github/actions/sukisu/action.yml` — `PINNED_SUKISU_SRC`：`6c13a06` → `b20dee702`；`ksu_version_ref` 預設：`v4.1.3` → `v4.2.0`
- `.github/workflows/main.yml` — 另有一份硬編碼 `SUKISU_SRC` / `SUKISU_VER`，以及 release 摘要
- `.github/workflows/build.yml` — 摘要表
- `.github/workflows/commit-status.yml`
- `.github/config/commits.json` — `sukisu.builtin`

**SUSFS pin（與 driver 同一代，不能留 `ee023e3`）**

- `.github/actions/susfs-setup/action.yml` — `PINNED_SUSFS`
- `.github/workflows/main.yml`、`.github/workflows/prepare.yml` — 各 `susfs_commit_*` 說明
- `.github/config/commits.json` — 各 `gki-*` SHA，須是該分支上含 `TIF_PROC_NO_SU` 的 commit

**文件**

- `README.md`、`README_zh-TW.md`、`.github/config/RELEASE_NOTES.md`

**維持不動**

- GKI 分支選擇、AnyKernel3、`CONFIG_KPM` / `KPROBES` / `KALLSYMS`
- `SukiSU_KernelPatch_patch/` 的 v0.13.0 二進位
- 不要 checkout `v4.2.0` / `main`

## 風險

| 項目 | 原因 |
|---|---|
| 只改 README / tag 字串 | UAPI 仍是舊的，Manager 繼續空白 |
| checkout `85eb4a9` | 沒有 `KSU_SUSFS`，action 失敗；目錄與現有整合不符 |
| driver 升了、SUSFS 留 `ee023e3` | 缺 `susfs_set_current_proc_no_su` 等 inline，編不過 |
| 七條 GKI 一起換 SUSFS tip | 2026-09 的 patch offset 有改，`50_add_susfs` 可能 reject |
| app profile | v4 的 `flags` 欄位；舊 Manager v4.1.3 寫 v3 profile，要實機確認能否當 fallback |
| KPM | kernel 端這段沒改，但仍要測 load/list/control |

建議先只編 **android13-5.10**（Pixel 6 Pro / 6a），SUSFS 用該分支上 v2.3.0 之後、且 patch 能套上的 commit。過了再鋪到其餘 GKI。
