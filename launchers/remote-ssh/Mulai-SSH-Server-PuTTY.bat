@echo off
title Ubuntu SSD SSH Server (Port 2222)
echo ================================================================
echo   Menjalankan OpenSSH Server Ubuntu SSD di Port 2222...
echo   --------------------------------------------------------------
echo   Sekarang buka PuTTY di Windows:
echo     - Host Name: 127.0.0.1 (atau localhost)
echo     - Port: 2222
echo     - User: bakung
echo
echo   PENTING: Jangan tutup jendela ini selama memakai PuTTY!
echo   Tekan Ctrl+C untuk menghentikan server.
echo ================================================================
wsl -u root /mnt/host/wsl/PHYSICALDRIVE1p4/start_sshd.sh
pause
