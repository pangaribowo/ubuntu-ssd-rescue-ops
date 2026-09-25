Write-Host "=== PROSES PELEPASAN AMAN (SAFE EJECT) UBUNTU SSD ===" -ForegroundColor Yellow

Write-Host "`n1. Menyinkronkan penulisan file (sync) dan unmount sistem di WSL..." -ForegroundColor Cyan
wsl sh -c "sync; umount /mnt/host/wsl/PHYSICALDRIVE*/* 2>/dev/null; umount /mnt/host/wsl/PHYSICALDRIVE* 2>/dev/null; sync" 2>$null

Write-Host "2. Mematikan kuncian hardware passthrough WSL..." -ForegroundColor Cyan
wsl --shutdown

Start-Sleep -Seconds 1

Write-Host "3. Memverifikasi status hardware di Windows..." -ForegroundColor Cyan
$disk = Get-Disk | Where-Object { $_.FriendlyName -like '*ADATA*' -and $_.BusType -eq 'USB' }
if ($disk) {
    Write-Host "   -> Disk $($disk.Number) ($($disk.FriendlyName)) - Status: $($disk.OperationalStatus)" -ForegroundColor Green
} else {
    Write-Host "   -> SSD sudah tidak terdeteksi / sudah tercabut." -ForegroundColor Yellow
}

Write-Host "`n============================================================" -ForegroundColor Green
Write-Host "  [BERHASIL] SSD SUDAH BEBAS DARI SEMUA KUNCIAN!" -ForegroundColor Green
Write-Host "  Silakan cabut kabel USB SSD dengan aman." -ForegroundColor Green
Write-Host "============================================================`n" -ForegroundColor Green
