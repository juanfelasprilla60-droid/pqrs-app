@echo off
REM ============================================================
REM  PQRS System - Servidor de desarrollo CodeIgniter 4
REM  http://localhost:8080
REM ============================================================
cd /d "%~dp0"
echo Iniciando servidor CodeIgniter 4 en http://localhost:8080 ...
C:\xampp\php\php.exe spark serve --host=127.0.0.1 --port=8080
