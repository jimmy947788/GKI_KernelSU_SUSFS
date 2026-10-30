# 評估報告：讓 GKI 支援 SukiSU Ultra v4.3.0

**日期：** 2026-10-31
**實作：** 分支 `sukisu-v4.3.0`。driver `b16e899a5`、版本 ref `v4.3.0`、`KSU_VERSION` `41100`、KPM `0.14.0`、SUSFS 七條 `gki-*` 分支更新到 2026-10-29 的 tip。
**範圍：** 版本相容與要改的 pin。不含漏洞利用。

## 結論

Manager v4.3.0（`SukiSU_v4.3.0_41100`）要求 kernel 的 UAPI 版本與自己相同（`kernelUAPIVersion == managerUAPIVersion`），目前是 **6**。舊 driver `b20dee702` 是 UAPI 2，Manager 會把功能 UI 藏起來。

**不要把 pin 改成 tag `v4.3.0`。** 那個 commit 的 `kernel/Kconfig` 沒有 `config KSU_SUSFS`，本倉庫的 sukisu action 會直接失敗。

要改的目標是 **`builtin` HEAD `b16e899a5`**（2026-10-30）。它不是 tag `v4.3.0` 的後代，但 UAPI 同為 6，ioctl 編號、`ksu_extension_id` 與 app profile 版本都和 v4.3.0 相同，`KSU_IOCTL_EXTENSION` 與 `KSU_EXTENSION_ENUM` 也都在。

## 必須一起動的項目

| 項目 | 舊 | 新 | 原因 |
|---|---|---|---|
| SUSFS | `18fe1544` 等 | 各分支 2026-10-29 tip | driver 呼叫 `susfs_set_priority_uid_filter()`、`susfs_parse_priority_app_strings()`，舊 pin 沒有 |
| KPM | `0.13.0` | `0.14.0` | kernel 的 bridge 先 probe，回傳值必須是 ABI 2，否則回 `-EOPNOTSUPP` |

先前跳過 `ksu_handle_post_execveat_sucompat` 的理由已不成立：`b16e899a5` 有這個符號，所以 SUSFS 不必再停在這個 hook 之前。

### KPM 0.14.0 的陷阱

tag `0.14.0` 的原始碼是 `SUKISU_KPM_ABI_VERSION 1`，但 release 資產在 2026-10-27 重新上傳過。反組譯 `kpimg` 可看到 `cmp x4, #2`，也就是 ABI 2。判斷相容性要看 release 二進位，不要看 tag 原始碼。

## 版本數字

公式：`4 * 10000 + commit_count - 2815`。

| ref | commit count | versionCode |
|---|---:|---:|
| `v4.2.0` | 3714 | 40899（官方 APK 是 40900） |
| `v4.3.0` | 3915 | 41100（與官方 APK 相同） |

`KSU_VERSION` 繼續直接釘成 `41100`，因為 Makefile 建置時也會透過 GitHub API 數 commit。

## 已驗證

本機對 `deprecated/android13-5.10-2023-09`（5.10.186）測試：

- `50_add_susfs_in_gki-android13-5.10.patch`（`cfa82d53`）可套用，無 reject，一個 hunk 有 fuzz 1。
- 用 Ubuntu clang 21 編到 `Image`，build log 印出 `41100 [v4.3.0-b16e899a@HEAD]`。

## 不要用 KPM 0.14.0 的 `patch_linux`

0.14.0 的 `patch_linux` 內建的 `kpimg` 只有 1 byte。上游 CI artifact（`patch_linux` 雜湊與 release 相同）的 `patch/include/kpimg_enc.h` 內容是 `res_kpimg_enc[] = { 0 }`。

- 它會忽略旁邊的 `kpimg` 檔。CI log 顯示 `kpimg: 0x2c91000,0x10`、`kpimg version: 0`，但仍印出 `patch done`。
- 不論內部 `kptools` 是否成功都回傳 0。本機對非 LTO 的 `Image` 執行時印出 `double free or corruption (!prev)`，`oImage` 只多 1680 bytes。
- 最後由 `kpm-patch` action 的 `KernelPatch` 字串檢查擋下。

因此 action 改成直接跑同一個 release 的 `kptools-linux -p -s 123 -i Image -k kpimg -o oImage`，參數和 `patch_linux` 內部相同。0.13.0 不能當退路：它沒有 ABI 2 bridge，KPM 會被 kernel 的 probe 拒絕。

## 尚未驗證

- 本機編譯關閉了 LTO、CFI、BTF，也不是用 CI 的 Bazel 與 Android clang。
- 其他六條 GKI 分支只確認 SUSFS tip 含所需符號，沒有套 patch 或編譯。
- 尚未實機開機，Manager 握手、KPM load/list/control、SUSFS 都要刷機確認。

## 建議

先用 `Build Kernels` 只編 **android13-5.10**，刷到 Pixel 6 Pro 確認後，再鋪到其餘 GKI。
