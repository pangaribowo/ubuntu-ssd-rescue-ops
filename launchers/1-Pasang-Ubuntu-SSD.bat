@echo off
title Pasang & Buka Ubuntu SSD
echo ============================================================
echo   Mendeteksi dan Memasang Ubuntu SSD ke Windows/WSL...
echo ============================================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\mount_ssd.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Ada masalah saat mendeteksi atau me-mount SSD.
    pause
)
