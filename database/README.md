# Base de datos PQRS — MySQL Workbench

## Conexión

MySQL Workbench ya tiene guardada la conexión:

| Campo | Valor |
|---|---|
| Nombre | `PQRS Local (MariaDB 3307)` |
| Host | `127.0.0.1` |
| Puerto | **`3307`** |
| Usuario | `root` |
| Contraseña | *(vacía)* |
| Esquema | `pqrs_system` |

> **Importante:** el proyecto usa el MariaDB de XAMPP en el puerto **3307**, no el
> MySQL Server 8.0 del puerto 3306. Si Workbench se conecta al 3306 verás otra base
> (u otra versión) y no los cambios de las fases 4 y 5.

## Ver la base en Workbench

1. Abre **MySQL Workbench**.
2. Doble clic en la conexión **`PQRS Local (MariaDB 3307)`**.
3. En el panel izquierdo (Navigator), clic derecho sobre `pqrs_system` →
   **Refresh All** (o `F5`). Workbench cachea el esquema; sin refrescar no aparecen
   las tablas nuevas.
4. Para ver el modelo con relaciones:
   **Database → Reverse Engineer…** → elige la conexión → esquema `pqrs_system`.

## Importar el dump completo

Archivo: `database/pqrs_system.sql` (copia en `C:\Users\vorte\Downloads\pqrs_system_actualizado.sql`).

**Opción A — Workbench**

1. `Server → Data Import`.
2. **Import from Self-Contained File** → selecciona `pqrs_system.sql`.
3. **Default Target Schema**: `pqrs_system` (o deja que el dump lo cree).
4. **Start Import**.

**Opción B — consola**

```bat
C:\xampp\mysql\bin\mysql.exe -h 127.0.0.1 -P 3307 -u root < database\pqrs_system.sql
```

> El dump hace `DROP TABLE` de cada tabla antes de crearla. Si tienes datos que
> quieres conservar, haz un backup antes.

## Contenido

14 tablas:

| Tabla | Registros | Descripción |
|---|---|---|
| `document_type` | 3 | CC, TI, CE |
| `module` | 7 | módulos del sistema |
| `module_role` | 0 | relación módulo ↔ rol (tabla heredada) |
| `module_role_user` | 0 | **tabla puente de asignación de permisos (Fase 5)** |
| `permission` | 5 | `view`, `create`, `edit`, `delete`, `export` |
| `pqrs` | 0 | solicitudes |
| `pqrs_response` | 0 | respuestas |
| `pqrs_status` | 5 | estados |
| `pqrs_type` | 4 | tipos |
| `profile` | 0 | perfiles de usuario |
| `role` | 4 | `admin`, `user`, `manager`, … |
| `user` | 4 | ids 2, 3, 8 y 9 (`admin`) |
| `user_role` | 1 | admin ↔ rol admin |
| `user_status` | 3 | estados de usuario |

Además incluye **5 procedimientos almacenados**
(`sp_module_role_user`, `sp_show_id_user_active`, `sp_show_profile`,
`sp_show_user_active`, `sp_user_role_id`).

## Relaciones principales (EER)

```
user_status ──< user ──< user_role >── role
                 │                      │
                 ├──< profile >── document_type
                 ├──< module_role_user >── module
                 │            │
                 │            └── permission
                 └──< pqrs >── pqrs_type / pqrs_status
                        └──< pqrs_response
```

`module_role_user` tiene 4 claves foráneas (`user_id`, `role_id`, `module_id`,
`permission_id`) y una restricción `UNIQUE` sobre las cuatro columnas.

## Verificación realizada

El dump se importó en una base temporal `pqrs_verify` y se comparó con la base real:

| Comprobación | Real | Importada |
|---|---|---|
| Tablas | 14 | 14 |
| Procedimientos | 5 | 5 |
| `permission` | 5 | 5 |
| `user` | 4 | 4 |
| `role` | 4 | 4 |
| `module` | 7 | 7 |
| `module_role_user` | 0 | 0 |

La base temporal se eliminó después de la prueba.
