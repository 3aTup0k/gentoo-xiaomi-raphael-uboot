#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [07] Locale + keyboard"

chroot rootdir ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo "Asia/Shanghai" > rootdir/etc/timezone

cat > rootdir/etc/locale.gen << 'EOF'
en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8
EOF

chroot rootdir locale-gen
chroot rootdir localedef -i en_US -f UTF-8 en_US.UTF-8 2>/dev/null || true

cat > rootdir/etc/env.d/02locale << 'EOF'
LANG="en_US.UTF-8"
LC_COLLATE="C.UTF-8"
EOF

cat > rootdir/etc/vconsole.conf << 'EOF'
KEYMAP="us"
FONT="ter-132n"
EOF

cat > rootdir/etc/profile.d/99-locale-fix.sh << 'EOF'
if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_TTY" ]; then
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
fi
EOF
chmod +x rootdir/etc/profile.d/99-locale-fix.sh

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [07] OK"
