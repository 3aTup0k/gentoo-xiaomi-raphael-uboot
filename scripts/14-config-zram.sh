#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [14] ZRAM"

cat > rootdir/etc/conf.d/zram-init << 'EOF'
ZRAM_SIZE=10240
ZRAM_ALGO=zstd
ZRAM_COUNT=1
ZRAM_DEV=/dev/zram0
ZRAM_PRIORITY=100
EOF

chroot rootdir rc-update add zram-init default 2>/dev/null || true

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [14] OK"
