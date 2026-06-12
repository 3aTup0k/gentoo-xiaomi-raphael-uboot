# Gentoo for Xiaomi Redmi K20 Pro (raphael)

Gentoo (OpenRC) образ для Redmi K20 Pro с mainline ядром.

## Использование

1. **GitHub Actions**: `Actions` → `Build Gentoo (OpenRC) for Raphael` → `Run workflow`
2. Скачать артефакт `gentoo-raphael-openrc`
3. Прошить:

```
fastboot flash cache xiaomi-k20pro-boot.img
fastboot flash boot u-boot.img
fastboot flash userdata rootfs.img
```

## Включено

- stage3 arm64 OpenRC
- systemd-utils (отключен systemd USE)
- SSH, dhcpcd, dnsmasq
- USB NCM gadget
- ZRAM (zstd, 10G)
- KBD (keymaps)
- dracut initramfs

## Параметры

По умолчанию: user/user, root/1234. IP: 172.16.42.1.
