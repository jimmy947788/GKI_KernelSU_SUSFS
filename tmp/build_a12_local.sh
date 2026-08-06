#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage:
  build_a12_local.sh --sublevel 236 --patch-level 2025-05 [options]

Required:
  --sublevel N             Kernel sublevel, for example 236
  --patch-level YYYY-MM    Android OS patch level, for example 2025-05

Optional:
  --revision R             GKI revision suffix, default: r1
  --dist-dir PATH          Kernel dist dir containing Image, default:
                           <repo>/android12-5.10-<sublevel>/out/android12-5.10/dist
  --workspace PATH         Output workspace, default: <repo>/tmp/output
  --fallback-patch-level   Explicit fallback patch level if the target GKI zip is unavailable
  --boot-size BYTES        Boot partition size, default: 67108864
  --os-version VER         OS version passed to mkbootimg, default: 12.0.0

Environment overrides:
  AVBTOOL MKBOOTIMG UNPACK_BOOTIMG GZIP AVB_KEY

This script repacks a certified Android 12 GKI boot image with a locally built
kernel Image/Image.lz4. It does not build the kernel itself.
EOF
}

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)

SUBLEVEL=""
PATCH_LEVEL=""
REVISION="r1"
DIST_DIR=""
WORKSPACE="$REPO_ROOT/tmp/output"
FALLBACK_PATCH_LEVEL=""
BOOT_SIZE=$((64 * 1024 * 1024))
OS_VERSION="12.0.0"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --sublevel)
            SUBLEVEL="$2"
            shift 2
            ;;
        --patch-level)
            PATCH_LEVEL="$2"
            shift 2
            ;;
        --revision)
            REVISION="$2"
            shift 2
            ;;
        --dist-dir)
            DIST_DIR="$2"
            shift 2
            ;;
        --workspace)
            WORKSPACE="$2"
            shift 2
            ;;
        --fallback-patch-level)
            FALLBACK_PATCH_LEVEL="$2"
            shift 2
            ;;
        --boot-size)
            BOOT_SIZE="$2"
            shift 2
            ;;
        --os-version)
            OS_VERSION="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

if [[ -z "$SUBLEVEL" || -z "$PATCH_LEVEL" ]]; then
    usage >&2
    exit 2
fi

if [[ -z "$DIST_DIR" ]]; then
    DIST_DIR="$REPO_ROOT/android12-5.10-$SUBLEVEL/out/android12-5.10/dist"
fi

find_tool() {
    local current_value="$1"
    shift
    if [[ -n "$current_value" ]]; then
        printf '%s\n' "$current_value"
        return 0
    fi

    local candidate
    for candidate in "$@"; do
        if [[ -n "$candidate" && -e "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    return 1
}

AVBTOOL=${AVBTOOL:-}
MKBOOTIMG=${MKBOOTIMG:-}
UNPACK_BOOTIMG=${UNPACK_BOOTIMG:-}
GZIP=${GZIP:-}
AVB_KEY=${AVB_KEY:-}

AVBTOOL=$(find_tool "$AVBTOOL" \
    "$REPO_ROOT/kernel-build-tools/linux-x86/bin/avbtool" \
    "$REPO_ROOT/kernel_patches/kernel-build-tools/linux-x86/bin/avbtool") || {
    echo "Could not find avbtool. Set AVBTOOL explicitly." >&2
    exit 1
}

MKBOOTIMG=$(find_tool "$MKBOOTIMG" \
    "$REPO_ROOT/mkbootimg/mkbootimg.py") || {
    echo "Could not find mkbootimg.py. Set MKBOOTIMG explicitly." >&2
    exit 1
}

UNPACK_BOOTIMG=$(find_tool "$UNPACK_BOOTIMG" \
    "$REPO_ROOT/mkbootimg/unpack_bootimg.py") || {
    echo "Could not find unpack_bootimg.py. Set UNPACK_BOOTIMG explicitly." >&2
    exit 1
}

GZIP=$(find_tool "$GZIP" \
    "$REPO_ROOT/build-tools/path/linux-x86/gzip" \
    "/usr/bin/gzip") || {
    echo "Could not find gzip. Set GZIP explicitly." >&2
    exit 1
}

AVB_KEY=$(find_tool "$AVB_KEY" \
    "$REPO_ROOT/kernel-build-tools/linux-x86/share/avb/testkey_rsa2048.pem" \
    "$REPO_ROOT/kernel_patches/kernel-build-tools/linux-x86/share/avb/testkey_rsa2048.pem") || {
    echo "Could not find AVB test key. Set AVB_KEY explicitly." >&2
    exit 1
}

if [[ ! -f "$DIST_DIR/Image" ]]; then
    echo "Missing kernel Image at $DIST_DIR/Image" >&2
    exit 1
fi

TARGET_NAME="android12-5.10.${SUBLEVEL}_${PATCH_LEVEL}_${REVISION}"
BUILD_DIR="$WORKSPACE/$TARGET_NAME"
ZIP_NAME="gki-certified-boot-android12-5.10-${PATCH_LEVEL}_${REVISION}.zip"
GKI_URL="https://dl.google.com/android/gki/${ZIP_NAME}"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
rm -rf out extracted
mkdir -p extracted

download_zip() {
    local patch_level="$1"
    local revision="$2"
    local zip_name="gki-certified-boot-android12-5.10-${patch_level}_${revision}.zip"
    local url="https://dl.google.com/android/gki/${zip_name}"

    echo "[+] Checking $url"
    local http_code
    http_code=$(curl -sL -w '%{http_code}' "$url" -o /dev/null)
    if [[ "$http_code" == "200" ]]; then
        echo "[+] Downloading $zip_name"
        curl -LfsS -o gki-kernel.zip "$url"
        return 0
    fi

    return 1
}

if ! download_zip "$PATCH_LEVEL" "$REVISION"; then
    if [[ -n "$FALLBACK_PATCH_LEVEL" ]]; then
        echo "[!] Primary GKI zip unavailable, trying fallback patch level $FALLBACK_PATCH_LEVEL"
        download_zip "$FALLBACK_PATCH_LEVEL" "$REVISION" || {
            echo "Failed to download both target and fallback GKI zips." >&2
            exit 1
        }
        PATCH_LEVEL="$FALLBACK_PATCH_LEVEL"
        TARGET_NAME="android12-5.10.${SUBLEVEL}_${PATCH_LEVEL}_${REVISION}"
    else
        echo "Target GKI zip not found: $GKI_URL" >&2
        echo "Refusing to silently fall back to a different patch level." >&2
        exit 1
    fi
fi

unzip -qo gki-kernel.zip -d extracted
rm -f gki-kernel.zip

BOOT_IMG=$(find extracted -maxdepth 1 -type f -name 'boot*.img' | head -n1)
if [[ -z "$BOOT_IMG" ]]; then
    echo "Could not find boot image inside downloaded GKI zip." >&2
    exit 1
fi

echo "[+] Unpacking $(basename "$BOOT_IMG")"
python3 "$UNPACK_BOOTIMG" --boot_img="$BOOT_IMG"

if [[ ! -d out/ramdisk ]]; then
    echo "unpack_bootimg did not produce out/ramdisk" >&2
    exit 1
fi

cp "$DIST_DIR/Image" ./Image
if [[ -f "$DIST_DIR/Image.lz4" ]]; then
    cp "$DIST_DIR/Image.lz4" ./Image.lz4
fi

echo "[+] Building Image.gz"
"$GZIP" -n -c -9 Image > Image.gz

build_boot_image() {
    local kernel_file="$1"
    local output_name="$2"

    echo "[+] Building $output_name from $kernel_file"
    python3 "$MKBOOTIMG" \
        --header_version 4 \
        --kernel "$kernel_file" \
        --output "$output_name" \
        --ramdisk out/ramdisk \
        --os_version "$OS_VERSION" \
        --os_patch_level "$PATCH_LEVEL"

    "$AVBTOOL" add_hash_footer \
        --partition_name boot \
        --partition_size "$BOOT_SIZE" \
        --image "$output_name" \
        --algorithm SHA256_RSA2048 \
        --key "$AVB_KEY"

    "$GZIP" -n -f -9 "$output_name"
    mv "$output_name.gz" "${TARGET_NAME}-${output_name}.gz"
}

build_boot_image Image boot.img
build_boot_image Image.gz boot-gz.img

if [[ -f Image.lz4 ]]; then
    build_boot_image Image.lz4 boot-lz4.img
else
    echo "[!] Image.lz4 not found in $DIST_DIR, skipping boot-lz4.img"
fi

echo "[+] Generated files:"
find . -maxdepth 1 -type f -name "${TARGET_NAME}-boot*.gz" | sort
