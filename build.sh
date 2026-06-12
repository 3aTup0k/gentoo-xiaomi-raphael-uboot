#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

. "$SCRIPT_DIR/config/build-config.sh"

export SCRIPT_DIR
export SYSTEM_TYPE="${1:-gentoo-server}"
export KERNEL_VERSION="${2:-7.0}"
export IMAGE_NAME="rootfs.img"
export IMAGE_UUID="ee8d3593-59b1-480e-a3b6-4fefb17ee7d8"
export HOSTNAME="xiaomi-raphael"
export BOOT_IMG="xiaomi-k20pro-boot.img"
export KERNEL_DEBS_DIR="xiaomi-raphael-debs_$KERNEL_VERSION"

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

TMP_SYSTEM_CONFIG=$(mktemp)
system_config "$SYSTEM_TYPE" "" > "$TMP_SYSTEM_CONFIG"
while IFS= read -r line; do
    export "$line"
done < "$TMP_SYSTEM_CONFIG"
rm "$TMP_SYSTEM_CONFIG"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] =========================================="
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Gentoo image builder for Xiaomi Raphael"
echo "[$(date +'%Y-%m-%d %H:%M:%S')] =========================================="
echo "[$(date +'%Y-%m-%d %H:%M:%S')] System:      $SYSTEM_TYPE"
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Kernel:      $KERNEL_VERSION"
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Image size:  $IMAGE_SIZE"

if [ ! -f "$BOOT_IMG" ]; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Error: $BOOT_IMG not found"
    exit 1
fi
if [ ! -d "$KERNEL_DEBS_DIR" ]; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Error: $KERNEL_DEBS_DIR not found"
    exit 1
fi

chmod +x "$SCRIPT_DIR/scripts"/*.sh

echo ""
echo "[$(date +'%Y-%m-%d %H:%M:%S')] ==================== Build ===================="
"$SCRIPT_DIR/scripts/01-create-image.sh"
"$SCRIPT_DIR/scripts/02-bootstrap.sh"
"$SCRIPT_DIR/scripts/03-mount-dev.sh"
"$SCRIPT_DIR/scripts/04-config-network.sh"
"$SCRIPT_DIR/scripts/05-portage-setup.sh"
"$SCRIPT_DIR/scripts/06-install-all-packages.sh"
"$SCRIPT_DIR/scripts/07-config-locale.sh"
"$SCRIPT_DIR/scripts/08-add-screen-commands.sh"
"$SCRIPT_DIR/scripts/09-install-kernel.sh"
"$SCRIPT_DIR/scripts/10-config-ncm.sh"
"$SCRIPT_DIR/scripts/11-config-fstab.sh"
"$SCRIPT_DIR/scripts/12-create-users.sh"
"$SCRIPT_DIR/scripts/13-config-power.sh"
"$SCRIPT_DIR/scripts/14-config-zram.sh"
"$SCRIPT_DIR/scripts/15-cleanup.sh"
"$SCRIPT_DIR/scripts/16-finalize.sh"
echo "[$(date +'%Y-%m-%d %H:%M:%S')] ==================== Done ===================="

echo ""
ls -lh rootfs.img 2>/dev/null || true
echo ""
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Build successful!"
