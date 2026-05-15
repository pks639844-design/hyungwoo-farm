@echo off
chcp 65001 > nul
pwsh -ExecutionPolicy Bypass -NoProfile -File "%~dp0upload.ps1"
