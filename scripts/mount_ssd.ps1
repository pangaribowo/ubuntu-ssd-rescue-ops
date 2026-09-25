Write-Host "=== PROSES PENYAMBUNGAN (MOUNT) UBUNTU SSD ===" -ForegroundColor Yellow

# 1. Deteksi disk fisik SSD secara dinamis
$disk = Get-Disk | Where-Object { $_.FriendlyName -like '*ADATA*' -and $_.BusType -eq 'USB' }
if (-not $disk) {
    Write-Host "`n[ERROR] SSD ADATA tidak ditemukan!" -ForegroundColor Red
    Write-Host "Pastikan kabel USB SSD sudah tercolok ke laptop.`n" -ForegroundColor Yellow
    exit 1
}

$diskNum = $disk.Number
Write-Host "`n1. Terdeteksi SSD: $($disk.FriendlyName) pada PhysicalDrive$diskNum" -ForegroundColor Cyan

# 2. Cek apakah sudah ter-mount di WSL
$mountPath = "/mnt/host/wsl/PHYSICALDRIVE${diskNum}p4"
$alreadyMounted = $false
try {
    $check = wsl sh -c "test -d $mountPath/bin && echo 'yes'" 2>$null
    if ($check -match 'yes') {
        $alreadyMounted = $true
    }
} catch {}

if ($alreadyMounted) {
    Write-Host "2. SSD sudah dalam status ter-mount di $mountPath." -ForegroundColor Green
} else {
    Write-Host "2. Menghubungkan SSD ke WSL2 (Partition 4)..." -ForegroundColor Cyan
    $mountOutput = wsl --mount "\\.\PHYSICALDRIVE$diskNum" --partition 4 2>&1
    Write-Host "   $mountOutput"
}

# 3. Verifikasi mount berhasil
$verify = wsl sh -c "test -d $mountPath/bin && echo 'SUCCESS'" 2>$null
if ($verify -match 'SUCCESS') {
    Write-Host "`n============================================================" -ForegroundColor Green
    Write-Host "  [BERHASIL] SSD SIAP DIGUNAKAN!" -ForegroundColor Green
    Write-Host "  Path WSL: $mountPath" -ForegroundColor Green
    Write-Host "  Membuka terminal Ubuntu sekarang..." -ForegroundColor Green
    Write-Host "============================================================`n" -ForegroundColor Green
    
    # Langsung jalankan enter.sh
    wsl -u root "$mountPath/enter.sh"
} else {
    Write-Host "`n[GAGAL] Tidak dapat me-mount partisi 4. Pastikan partisi tidak sedang corrupt." -ForegroundColor Red
}
