#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [05] Portage setup"

cat > rootdir/etc/portage/make.conf << 'MAKECONF'
CHOST="aarch64-unknown-linux-gnu"
CFLAGS="-O2 -pipe -march=armv8.2-a+crypto+rcpc+dotprod -mtune=cortex-a76"
CXXFLAGS="${CFLAGS}"
MAKEOPTS="-j$(nproc)"
EMERGE_DEFAULT_OPTS="--jobs=2 --load-average=$(nproc) --quiet-build=y"
ACCEPT_LICENSE="*"
ACCEPT_KEYWORDS="arm64"
USE="-systemd -X -gtk -qt -kde -gnome -wayland"
MAKECONF

cat > rootdir/etc/portage/repos.conf/gentoo.conf << 'EOF'
[DEFAULT]
main-repo = gentoo
[gentoo]
location = /var/db/repos/gentoo
sync-type = rsync
sync-uri = rsync://rsync.gentoo.org/gentoo-portage
auto-sync = yes
EOF

cat > rootdir/etc/portage/binrepos.conf << 'EOF'
[gentoobinhost]
priority = 9999
sync-uri = https://distfiles.gentoo.org/releases/arm64/binpackages/23.0/arm64
EOF

echo 'EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --getbinpkg --binpkg-respect-use=n"' >> rootdir/etc/portage/make.conf

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [05]   emerge-webrsync..."
chroot rootdir emerge-webrsync --quiet 2>&1 || {
    chroot rootdir emerge --sync --quiet 2>&1 || true
}

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [05]   @world update..."
chroot rootdir emerge --update --deep --newuse @world --quiet 2>&1 || true

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [05] OK"
