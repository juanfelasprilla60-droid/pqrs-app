@echo off
REM ============================================================
REM  PQRS System - Inicia la instancia MariaDB del proyecto
REM  (puerto 3307, sin contrasena, datos en data_fresh4)
REM ============================================================
netstat -ano | findstr ":3307" | findstr "LISTENING" >nul
if %errorlevel%==0 (
    echo [OK] MariaDB ya esta corriendo en el puerto 3307.
    exit /b 0
)

echo Iniciando MariaDB en el puerto 3307...
start "MariaDB PQRS (3307)" "C:\xampp\mysql\bin\mysqld.exe" --no-defaults ^
  --basedir=C:/xampp/mysql ^
  --datadir=C:/xampp/mysql/data_fresh4 ^
  --port=3307 ^
  --bind-address=127.0.0.1 ^
  --socket=C:/xampp/mysql/data_fresh4/mysql.sock ^
  --pid-file=C:/xampp/mysql/data_fresh4/mysqld.pid ^
  --log-error=C:/xampp/mysql/data_fresh4/error.log

timeout /t 4 /nobreak >nul
echo [OK] MariaDB iniciada. Base de datos: pqrs_system (127.0.0.1:3307, usuario root, sin contrasena)
