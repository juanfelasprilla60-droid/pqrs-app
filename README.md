# PQRS App — API REST con CodeIgniter 4

Backend del sistema PQRS (Peticiones, Quejas, Reclamos y Sugerencias) construido con
**PHP 8.2 + CodeIgniter 4.7**, autenticación **JWT**, roles/permisos y MySQL/MariaDB.

## Documentación incluida

| Archivo | Contenido |
|---|---|
| `GUIA-INSTRUCTOR.md` | Instalación, ejecución, verificación y estructura del repositorio |
| `CHECKLIST-VALIDACION.md` | 97 casillas y 130 comprobaciones ejecutadas (25/25 endpoints) |
| `database/README.md` | Conexión e importación del dump `database/pqrs_system.sql` |
| `postman/README.md` | Uso de la colección Postman (29 peticiones) |
| `postman/PQRS-API.postman_collection.json` | Colección con variables y tests automáticos |
| `tools/` | Scripts auxiliares (`test-login.ps1`, `fix-workbench-mariadb.ps1`) |

## Módulos implementados

- Autenticación JWT (`/api/auth/login`, `/me`).
- Usuarios, roles, permisos y módulos con soft delete.
- Asignación y revocación de permisos por usuario/rol/módulo.
- Validaciones 400/401/403/404/409 y contraseñas hasheadas (`$2y$10$`).

## Ejecución rápida

```bash
composer install
Copy-Item env .env          # configurar base de datos y JWT_SECRET
# importar database/pqrs_system.sql en MySQL/MariaDB (puerto 3307 en XAMPP)
php spark serve             # http://localhost:8080
```

Ver `GUIA-INSTRUCTOR.md` para el detalle completo.
