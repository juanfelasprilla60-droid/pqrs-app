# Parche para MySQL Workbench contra MariaDB
# ------------------------------------------------------------
# MySQL Workbench 26.x ejecuta al conectar:
#     SET SESSION explain_json_format_version=2
# MariaDB 10.4 no conoce esa variable y devuelve:
#     Error 1193: Unknown system variable 'explain_json_format_version'
#
# Este script agrega una comprobacion para saltar esa sentencia cuando el
# servidor es MariaDB. Es idempotente: se puede ejecutar varias veces.
#
# Uso:
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\fix-workbench-mariadb.ps1
#
# Nota: si Workbench se actualiza, vuelve a ejecutarlo.

$ErrorActionPreference = 'Stop'

$candidates = @(
    (Join-Path $env:LOCALAPPDATA 'Programs\MySQL\MySQL Workbench'),
    'C:\Program Files\MySQL\MySQL Workbench 8.0',
    'C:\Program Files\MySQL\MySQL Workbench'
)

$wb = $candidates | Where-Object { Test-Path (Join-Path $_ 'resources\app\shell\lib\mysqlsh\plugins') } | Select-Object -First 1

if (-not $wb) {
    Write-Host 'No se encontro la instalacion de MySQL Workbench.' -ForegroundColor Red
    exit 1
}

Write-Host "Workbench: $wb"

$patches = @(
    @{
        File   = 'resources\app\shell\lib\mysqlsh\plugins\gui_plugin\core\dbms\DbMySQLSessionSetupTasks.py'
        Marker = 'if "mariadb" in version.lower():'
        Old    = @'
        version = self.get_data(common.MySQLData.VERSION_INFO)
        major, minor, _ = version.split(".", 2)
'@
        New    = @'
        version = self.get_data(common.MySQLData.VERSION_INFO)
        # MariaDB no soporta explain_json_format_version (Error 1193).
        if "mariadb" in version.lower():
            return
        major, minor, _ = version.split(".", 2)
'@
    },
    @{
        File   = 'resources\app\shell\lib\mysqlsh\plugins\util_plugin\visual\exported.py'
        Marker = 'if "mariadb" in version.lower():'
        Old    = @'
    version = active_session.run_sql("select @@version").fetch_one()[0]
    major, minor, _ = version.split(".", 2)
'@
        New    = @'
    version = active_session.run_sql("select @@version").fetch_one()[0]
    # MariaDB no soporta explain_json_format_version (Error 1193).
    if "mariadb" in version.lower():
        raise RuntimeError(
            "Visual Explain requires MySQL 8.3 or newer; MariaDB is not supported."
        )
    major, minor, _ = version.split(".", 2)
'@
    }
)

foreach ($p in $patches) {
    $path = Join-Path $wb $p.File

    if (-not (Test-Path $path)) {
        Write-Host "  [omitido] no existe: $($p.File)" -ForegroundColor Yellow
        continue
    }

    $content = [System.IO.File]::ReadAllText($path)

    if ($content.Contains($p.Marker)) {
        Write-Host "  [ok] ya parcheado: $(Split-Path $p.File -Leaf)" -ForegroundColor Green
        continue
    }

    if (-not $content.Contains($p.Old)) {
        Write-Host "  [aviso] patron no encontrado en $(Split-Path $p.File -Leaf); puede ser otra version" -ForegroundColor Yellow
        continue
    }

    $backup = "$path.bak"
    if (-not (Test-Path $backup)) {
        Copy-Item $path $backup -Force
    }

    Set-ItemProperty -Path $path -Name IsReadOnly -Value $false -ErrorAction SilentlyContinue
    $content = $content.Replace($p.Old, $p.New)
    [System.IO.File]::WriteAllText($path, $content, (New-Object System.Text.UTF8Encoding($false)))

    $pycDir = Join-Path (Split-Path $path -Parent) '__pycache__'
    $pycName = [System.IO.Path]::GetFileNameWithoutExtension($path) + '.cpython-*.pyc'
    Get-ChildItem $pycDir -Filter $pycName -ErrorAction SilentlyContinue | ForEach-Object {
        Set-ItemProperty -Path $_.FullName -Name IsReadOnly -Value $false -ErrorAction SilentlyContinue
        Remove-Item $_.FullName -Force
    }

    Write-Host "  [parcheado] $(Split-Path $p.File -Leaf)" -ForegroundColor Green
}

Write-Host ''
Write-Host 'Listo. Reinicia MySQL Workbench para que el cambio surta efecto.' -ForegroundColor Cyan
