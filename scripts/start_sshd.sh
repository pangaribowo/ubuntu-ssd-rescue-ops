#!/bin/sh
# start_sshd.sh — Launch OpenSSH server inside Ubuntu SSD chroot
# Usage: wsl -u root /mnt/host/wsl/PHYSICALDRIVE1p4/start_sshd.sh
#
# Starts sshd in foreground (-D) on port 2222, accessible from Windows
# via: ssh -p 2222 bakung@127.0.0.1 (or PuTTY to 127.0.0.1:2222)
#
# WSL2 automatically forwards localhost ports to Windows host.

ROOT="/mnt/host/wsl/PHYSICALDRIVE1p4"

# Verify SSD is mounted
if [ ! -d "$ROOT/bin" ]; then
    echo "Error: SSD partition belum ter-mount di $ROOT"
    echo "Jalankan dulu: wsl --mount \\\\.\\PHYSICALDRIVE1 --partition 4"
    exit 1
fi

# Bind-mount pseudo-filesystems (required for sshd PAM + PTY)
mountpoint -q "$ROOT/proc"    || mount -t proc proc "$ROOT/proc"
mountpoint -q "$ROOT/sys"     || mount -t sysfs sys "$ROOT/sys"
mountpoint -q "$ROOT/dev"     || mount --bind /dev "$ROOT/dev"
mountpoint -q "$ROOT/dev/pts" || mount --bind /dev/pts "$ROOT/dev/pts"
mountpoint -q "$ROOT/run"     || mount --bind /run "$ROOT/run"

# Ensure sshd runtime directory exists
mkdir -p "$ROOT/run/sshd"

echo "=========================================="
echo "  OpenSSH Server aktif di port 2222"
echo "  Hubungkan dari Windows:"
echo "    PuTTY  → Host: 127.0.0.1, Port: 2222"
echo "    CLI    → ssh -p 2222 bakung@127.0.0.1"
echo "  Tekan Ctrl+C untuk menghentikan server."
echo "=========================================="

# Run sshd in foreground (blocks until Ctrl+C)
exec chroot "$ROOT" /usr/sbin/sshd -D -p 2222
