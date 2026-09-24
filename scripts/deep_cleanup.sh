#!/bin/sh
# deep_cleanup.sh — Automated disk cleanup for Ubuntu SSD
# Usage: Run inside the Ubuntu chroot terminal
#
# Targets only REGENERABLE artifacts (caches, node_modules, AI model caches,
# old installers). Never deletes source code, documents, or credentials.
#
# Estimated savings: ~10 GB on a typical development workstation.

set -e

echo "=== DISK BEFORE CLEANUP ==="
df -h /

echo ""
echo "=== 1. Removing AI IDE caches ==="
# Windsurf AI indexing cache (typically 1-3 GB per project)
find ~/Documents -maxdepth 3 -type d -name ".windsurf" -exec rm -rf {} + 2>/dev/null || true
# Codeium local model cache (typically 2+ GB)
rm -rf ~/.codeium 2>/dev/null || true
# Cursor cache
rm -rf ~/.cursor/Cache ~/.cursor/CachedData 2>/dev/null || true
echo "Done: AI caches removed"

echo ""
echo "=== 2. Removing all node_modules directories ==="
find ~/Documents -maxdepth 4 -type d -name "node_modules" -exec rm -rf {} + 2>/dev/null || true
echo "Done: node_modules purged"

echo ""
echo "=== 3. Removing build artifacts ==="
find ~/Documents -maxdepth 4 -type d \( -name "build" -o -name "dist" -o -name ".angular" -o -name ".next" \) -exec rm -rf {} + 2>/dev/null || true
echo "Done: build artifacts removed"

echo ""
echo "=== 4. Clearing user caches ==="
rm -rf ~/.cache/* 2>/dev/null || true
rm -rf ~/.npm 2>/dev/null || true
echo "Done: user caches cleared"

echo ""
echo "=== 5. Clearing system caches (requires root) ==="
if [ "$(id -u)" = "0" ]; then
    apt-get clean 2>/dev/null || true
    journalctl --vacuum-size=100M 2>/dev/null || true
    echo "Done: system caches cleared"
else
    echo "Skipped: run as root for system cache cleanup"
fi

echo ""
echo "=== DISK AFTER CLEANUP ==="
df -h /
sync
echo ""
echo "Cleanup complete. Run 'sync' to flush all writes."
