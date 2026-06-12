#!/bin/bash
set -e

KERNEL_DEBS_DIR="${KERNEL_DEBS_DIR:-.}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [09] Kernel (extract .deb + dracut)"

DEB_DIR="/tmp/kernel-extract"
mkdir -p "$DEB_DIR"
BUILD_DIR="$(pwd)"

for deb in "${KERNEL_DEBS_DIR}"/*-xiaomi-raphael.deb; do
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [09]   Extracting: $(basename "$deb")"
    deb_dir="$DEB_DIR/$(basename "$deb" .deb)"
    mkdir -p "$deb_dir"
    cd "$deb_dir"
    ar x "$BUILD_DIR/$deb"
    cd "$BUILD_DIR"
done

for deb_dir in "$DEB_DIR"/*; do
    data_archive=$(ls "$deb_dir"/data.tar.* 2>/dev/null | head -1)
    if [ -n "$data_archive" ]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] [09]   Extracting data → rootdir/"
        tar xf "$data_archive" -C rootdir/
    fi
done

rm -rf "$DEB_DIR"

KERNEL_VER=$(ls rootdir/lib/modules/ 2>/dev/null | head -1)
if [ -z "$KERNEL_VER" ]; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [09]   ERROR: no modules in rootdir/lib/modules/"
    exit 1
fi
echo "[$(date +'%Y-%m-%d %H:%M:%S')] [09]   Kernel version: $KERNEL_VER"

if [ -f "rootdir/boot/vmlinuz-$KERNEL_VER" ]; then
    cp "rootdir/boot/vmlinuz-$KERNEL_VER" rootdir/boot/linux.efi
fi

mkdir -p rootdir/etc/dracut.conf.d
cat > rootdir/etc/dracut.conf.d/99-raphael.conf << 'EOF'
hostonly=no
add_dracutmodules+=" bash dash base fs-lib "
add_drivers+=" ext4 sdhci ufs qcom_wdt "
force_drivers+=" ext4 "
kernel_cmdline="root=PARTLABEL=userdata rootwait console=tty0 console=ttyMSM0,115200n8"
EOF

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [09]   dracut..."
chroot rootdir dracut --force --no-hostonly --kver "$KERNEL_VER" /boot/initramfs 2>&1 || {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [09]   dracut failed, trying genkernel..."
    chroot rootdir genkernel initramfs --kernel-config=/dev/null 2>&1 || true
}

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [09] OK"
