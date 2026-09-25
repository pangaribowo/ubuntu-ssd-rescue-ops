#!/bin/sh
# enter_ubuntu.sh — Chroot entry point with auto-mount pseudo-filesystems
# Usage: wsl -u root /mnt/host/wsl/PHYSICALDRIVE1p4/enter.sh
#
# This script safely bind-mounts /proc, /sys, /dev, /dev/pts, and /run
# into the Ubuntu SSD root, then drops into an interactive login shell
# as user bakung. Supports multiple concurrent sessions.

ROOT="/mnt/host/wsl/PHYSICALDRIVE1p4"

# Verify SSD is mounted
if [ ! -d "$ROOT/bin" ]; then
    echo "Error: SSD partition belum ter-mount di $ROOT"
    echo "Jalankan dulu: wsl --mount \\\\.\\PHYSICALDRIVE1 --partition 4"
    exit 1
fi

# Bind-mount essential pseudo-filesystems (idempotent guards)
mountpoint -q "$ROOT/proc"    || mount -t proc proc "$ROOT/proc"
mountpoint -q "$ROOT/sys"     || mount -t sysfs sys "$ROOT/sys"
mountpoint -q "$ROOT/dev"     || mount --bind /dev "$ROOT/dev"
mountpoint -q "$ROOT/dev/pts" || mount --bind /dev/pts "$ROOT/dev/pts"
mountpoint -q "$ROOT/run"     || mount --bind /run "$ROOT/run"

# Ensure DNS resolution works inside chroot via temporary bind-mount
# (DO NOT use cp, to preserve the native Ubuntu systemd-resolved symlink on disk)
if [ -f /etc/resolv.conf ]; then
    mountpoint -q "$ROOT/etc/resolv.conf" || mount --bind /etc/resolv.conf "$ROOT/etc/resolv.conf" 2>/dev/null
fi

# Set terminal type for color and Oh My Posh support
export TERM="${TERM:-xterm-256color}"

# Enter interactive login shell as user bakung
exec chroot "$ROOT" su -l bakung "$@"
