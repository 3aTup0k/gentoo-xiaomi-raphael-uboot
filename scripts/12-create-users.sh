#!/bin/bash
set -e

ROOT_PASS="${ROOT_PASS:-1234}"
USER_NAME="${USER_NAME:-user}"
USER_PASS="${USER_PASS:-1234}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [12] Users + SSH"

echo "root:${ROOT_PASS}" | chroot rootdir chpasswd
chroot rootdir useradd -m -G wheel -s /bin/bash ${USER_NAME}
echo "${USER_NAME}:${USER_PASS}" | chroot rootdir chpasswd

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' rootdir/etc/sudoers

echo "PermitRootLogin yes" >> rootdir/etc/ssh/sshd_config
echo "PasswordAuthentication yes" >> rootdir/etc/ssh/sshd_config

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [12] OK"
