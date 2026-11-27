$ErrorActionPreference = 'Stop'

$body = '{"username":"admin","password":"Admin123"}'

try {
    $r = Invoke-RestMethod -Uri 'http://localhost:8080/api/auth/login' `
        -Method POST -ContentType 'application/json' -Body $body -TimeoutSec 15

    Write-Host "OK - Login exitoso para '$($r.user.username)' (id $($r.user.id))" -ForegroundColor Green
    Write-Host "Token: $($r.token.Substring(0, 30))..." -ForegroundColor DarkGray
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
