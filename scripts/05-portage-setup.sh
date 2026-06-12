#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [05] Portage setup"

# Make.conf без $(...) и ${...} чтобы portage не спотыкался
cat > rootdir/etc/portage/make.conf << 'MAKECONF'
CHOST="aarch64-unknown-linux-gnu"
CFLAGS="-O2 -pipe -march=armv8.2-a+crypto+rcpc+dotprod -mtune=cortex-a76"
CXXFLAGS="${CFLAGS}"
MAKEOPTS="-j4"
EMERGE_DEFAULT_OPTS="--jobs=2 --quiet-build=y"
ACCEPT_LICENSE="*"
ACCEPT_KEYWORDS="arm64"
USE="-systemd -X -gtk -qt -kde -gnome -wayland"
MAKECONF

echo 'EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --getbinpkg --binpkg-respect-use=n"' >> rootdir/etc/portage/make.conf

mkdir -p rootdir/etc/portage/repos.conf
cat > rootdir/etc/portage/repos.conf/gentoo.conf << 'EOF'
[DEFAULT]
main-repo = gentoo
[gentoo]
location = /var/db/repos/gentoo
auto-sync = no
EOF

mkdir -p rootdir/etc/portage/binrepos.conf
cat > rootdir/etc/portage/binrepos.conf/gentoobinhost.conf << 'EOF'
[gentoobinhost]
priority = 9999
sync-uri = https://distfiles.gentoo.org/releases/arm64/binpackages/23.0/arm64
EOF

# Используем дерево portage из stage3, НЕ делаем emerge-webrsync
# (он жрёт ~1.5G лишнего места)
echo "[$(date +'%Y-%m-%d %H:%M:%S')] [05]   Using stage3 portage tree (no sync)"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [05] OK"
