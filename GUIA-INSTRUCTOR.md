# Guía para el instructor — `pqrs-app`

**Repositorio:** https://github.com/juanfelasprilla60-droid/pqrs-app  
**Tema:** API REST PQRS con CodeIgniter 4, JWT, roles y permisos.  
**Estado:** funcional; 25/25 endpoints validados (97/97 casillas del checklist).

## Requisitos

- PHP 8.2+, Composer.
- MySQL/MariaDB (XAMPP usa el puerto **3307** en este proyecto).

## Ejecución

```bash
git clone https://github.com/juanfelasprilla60-droid/pqrs-app.git
cd pqrs-app
composer install
Copy-Item env .env
# Editar .env: database.default.*, JWT_SECRET, encryption.key y app.baseURL
```

Importar la base de datos (el dump hace `DROP TABLE`, hacer backup si hay datos):

```bat
C:\xampp\mysql\bin\mysql.exe -h 127.0.0.1 -P 3307 -u root < database\pqrs_system.sql
```

Arrancar: `php spark serve` → `http://localhost:8080`.

## Credenciales de prueba

| Usuario | Contraseña |
|---|---|
| `admin` | `Admin123` (la documentación del taller usa `admin123`, el hash instalado es sensible a mayúsculas) |

## Verificación

1. Importar `postman/PQRS-API.postman_collection.json` (29 peticiones, variables propias).
2. Ejecutar primero `0. Autenticación → 0.1 Login`: guarda `{{token}}` automáticamente.
3. Seguir con roles/permisos/módulos/usuarios y, al final, `6. Pruebas de seguridad`.
4. `CHECKLIST-VALIDACION.md` contiene la evidencia de cada caso (errores 400/401/403/404/409, soft delete, hash de contraseñas, FKs).

También hay una prueba rápida de login en `tools/test-login.ps1`.

## Estructura relevante

| Ruta | Contenido |
|---|---|
| `app/Controllers/`, `app/Models/`, `app/Services/` | Lógica de negocio |
| `app/Filters/`, `app/Libraries/JwtService.php`, `app/Helpers/jwt_helper.php` | Seguridad JWT |
| `app/Config/Routes.php` | Rutas `/api/...` |
| `database/pqrs_system.sql` | Dump completo (14 tablas) |
| `postman/` | Colección y guía de uso |
| `system/` | Framework CodeIgniter 4 (se conserva para poder arrancar sin copiarlo aparte) |

## Seguridad

El `.env` real (JWT_SECRET, encryption.key y credenciales de BD) **no se publica**.
La plantilla `env` está incluida como ejemplo; cópiala y genera tus propias claves antes de ejecutar.
`vendor/`, logs y cachés tampoco se versionan: se obtienen con `composer install`.
