#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [15] Cleanup"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [15]   Cleaning portage cache"
chroot rootdir emerge --clean 2>/dev/null || true
rm -rf rootdir/var/cache/distfiles/* 2>/dev/null || true
rm -rf rootdir/var/tmp/portage/* 2>/dev/null || true

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [15]   Renaming kernel files"
if [ -f rootdir/boot/initramfs ]; then
    :
elif ls rootdir/boot/initramfs-* 2>/dev/null > /dev/null; then
    mv rootdir/boot/initramfs-* rootdir/boot/initramfs 2>/dev/null || true
fi
if [ ! -f rootdir/boot/linux.efi ]; then
    mv rootdir/boot/vmlinuz-* rootdir/boot/linux.efi 2>/dev/null || true
fi

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [15]   Cleaning firmware"
rm -f rootdir/lib/firmware/reg* 2>/dev/null || true

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [15] OK"
