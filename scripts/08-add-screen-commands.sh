#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [08] Screen commands"

cat >> rootdir/etc/bash.bashrc << 'EOF'
leijun() {
    if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_TTY" ]; then
        sudo sh -c 'TERM=linux setterm --blank force </dev/tty1'
    else
        setterm --blank force --term linux </dev/tty1
    fi
    echo "screen off"
}

jinfan() {
    if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_TTY" ]; then
        sudo sh -c 'TERM=linux setterm --blank poke </dev/tty1'
    else
        setterm --blank poke --term linux </dev/tty1
    fi
    echo "screen on"
}
EOF

cat > rootdir/etc/init.d/blank-screen << 'EOF'
#!/sbin/openrc-run
description="Blank screen after 15s"
depend() {
    after bootmisc
}
start() {
    ebegin "Starting screen blank timer"
    sleep 15
    TERM=linux setterm --blank force </dev/tty1 &
    eend $?
}
EOF
chmod +x rootdir/etc/init.d/blank-screen
chroot rootdir rc-update add blank-screen default

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [08] OK"
