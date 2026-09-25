@echo off
title Lepas Aman (Safe Eject) Ubuntu SSD
echo ============================================================
echo   Melepaskan Kuncian dan Sinkronisasi SSD...
echo ============================================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\eject_ssd.ps1"
pause
