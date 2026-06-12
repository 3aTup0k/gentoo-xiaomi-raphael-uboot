#!/bin/bash
set -e

BOOT_IMG="${BOOT_IMG:-xiaomi-k20pro-boot.img}"
GENTOO_STAGE3_URL="${GENTOO_STAGE3_URL:-}"
GENTOO_MIRROR="${GENTOO_MIRROR:-https://distfiles.gentoo.org}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [02] stage3 arm64 OpenRC"

if [ -z "$GENTOO_STAGE3_URL" ]; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [02]   Resolving latest stage3..."
    LATEST_TXT=$(curl -sL "$GENTOO_MIRROR/releases/arm64/autobuilds/latest-stage3-arm64-openrc.txt" 2>/dev/null || true)
    STAGE3_FILE=$(echo "$LATEST_TXT" | grep -E '\.tar\.(xz|bz2|gz)\s' | head -1 | awk '{print $1}')

    if [ -z "$STAGE3_FILE" ]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] [02]   openrc pointer failed, trying generic arm64..."
        LATEST_TXT=$(curl -sL "$GENTOO_MIRROR/releases/arm64/autobuilds/latest-stage3-arm64.txt" 2>/dev/null || true)
        STAGE3_FILE=$(echo "$LATEST_TXT" | grep -E '\.tar\.(xz|bz2|gz)\s' | head -1 | awk '{print $1}')
    fi

    if [ -z "$STAGE3_FILE" ]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] [02]   ERROR: could not resolve stage3 URL"
        exit 1
    fi

    GENTOO_STAGE3_URL="$GENTOO_MIRROR/releases/arm64/autobuilds/$STAGE3_FILE"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [02]   Resolved: $STAGE3_FILE"
fi

STAGE3_FILENAME=$(basename "$GENTOO_STAGE3_URL")
echo "[$(date +'%Y-%m-%d %H:%M:%S')] [02]   Downloading: $STAGE3_FILENAME"
curl -fL -o "$STAGE3_FILENAME" "$GENTOO_STAGE3_URL"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [02]   Extracting..."
tar xpf "$STAGE3_FILENAME" -C rootdir/
rm -f "$STAGE3_FILENAME"

mkdir -p rootdir/etc/portage/repos.conf
cat > rootdir/etc/portage/repos.conf/gentoo.conf << 'EOF'
[DEFAULT]
main-repo = gentoo

[gentoo]
location = /var/db/repos/gentoo
sync-type = rsync
sync-uri = rsync://rsync.gentoo.org/gentoo-portage
auto-sync = yes
EOF

if [ -f "${BOOT_IMG}" ]; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [02]   Mounting boot.img"
    mkdir -p rootdir/boot
    mount -o loop ${BOOT_IMG} rootdir/boot
else
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [02]   ERROR: ${BOOT_IMG} not found"
    exit 1
fi

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [02] OK"
