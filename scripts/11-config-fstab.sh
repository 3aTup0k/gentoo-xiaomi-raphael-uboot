#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [11] fstab"

echo "PARTLABEL=userdata / ext4 errors=remount-ro 0 1
PARTLABEL=cache /boot vfat umask=0077 0 1" > rootdir/etc/fstab

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [11] OK"
