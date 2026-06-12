#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [06] Emerge packages"

PACKAGES="
    net-misc/dhcpcd
    net-dns/dnsmasq
    net-firewall/nftables
    app-admin/sudo
    app-editors/nano
    app-misc/screen
    sys-process/htop
    net-misc/curl
    net-misc/wget
    sys-apps/kbd
    sys-apps/util-linux
    app-arch/tar
    app-arch/xz-utils
    app-arch/gzip
    app-arch/bzip2
    sys-apps/iproute2
    sys-process/zram-init
    sys-kernel/dracut
    net-misc/openssh
    net-dns/libidn2
"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [06]   Packages: $(echo "$PACKAGES" | tr '\n' ' ')"

chroot rootdir emerge --getbinpkg --usepkgonly --binpkg-respect-use=n $PACKAGES 2>&1 || {
    chroot rootdir emerge --getbinpkg --binpkg-respect-use=n $PACKAGES 2>&1
}

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [06]   Cleaning portage temp..."
chroot rootdir rm -rf /var/tmp/portage/* /var/cache/distfiles/* 2>/dev/null || true

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [06]   Enabling services..."
chroot rootdir rc-update add sshd default
chroot rootdir rc-update add dhcpcd default
chroot rootdir rc-update add keymaps default

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [06] OK"
