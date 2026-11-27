# Postman — PQRS API

## Importar la colección

1. Abre Postman.
2. **Import** → selecciona el archivo:
   `C:\xampp\htdocs\pqrs-app\postman\PQRS-API.postman_collection.json`
3. La colección trae variables propias (`baseUrl`, `token`, `permissionId`, `moduleId`, `userId`),
   no necesitas crear un environment.

## Uso

1. Ejecuta **`0. Autenticación → 0.1 Login`**.
   - El script de la pestaña **Tests** guarda el token automáticamente en `{{token}}`.
2. A partir de ahí todas las peticiones ya envían `Authorization: Bearer {{token}}`.
3. Al crear un permiso, un módulo o un usuario, su `id` se guarda en
   `{{permissionId}}` / `{{moduleId}}` / `{{userId}}`, así los `PUT` y `DELETE`
   apuntan al registro recién creado.
4. La carpeta **`6. Pruebas de seguridad`** valida 401/409/404 con tests automáticos.

> En la carpeta **4. Usuarios**, ejecuta primero `4.3 Crear usuario + perfil`
> (guarda `{{userId}}`); si ejecutas `4.4`/`4.5` sin crear antes, apuntarán al
> usuario `9` (admin). **No desactives al admin** si quieres seguir usando el token.

> En la carpeta **5. Asignación de permisos**, el orden es `5.1 Asignar` →
> `5.2 Ver permisos del usuario` → `5.3 Revocar`. Usa `user_id = 2`, `role_id = 2`,
> `module_id = 2` (Usuarios) y `permission_ids = [1, 2, 3]`. La tabla puente
> `module_role_user` debe existir (ver `PRUEBA-ASIGNACION.md`).

## Credenciales

| Campo | Valor |
|---|---|
| Usuario | `admin` |
| Contraseña | `Admin123` |

> El documento del taller usa `admin123` en minúsculas, pero el hash instalado
> corresponde a **`Admin123`**. El login distingue mayúsculas.

## Contenido (29 peticiones)

| Carpeta | Peticiones |
|---|---|
| 0. Autenticación | Login, Mi usuario |
| 1. Roles | Listar, ver, crear, actualizar, desactivar |
| 2. Permisos | Listar, ver, crear, actualizar, eliminar (físico) |
| 3. Módulos | Listar, ver, crear, actualizar, desactivar |
| 4. Usuarios | Listar, ver, crear (con perfil y roles), actualizar, desactivar |
| 5. Asignación de permisos | Asignar, ver permisos del usuario, revocar |
| 6. Pruebas de seguridad | Sin token, token inválido, duplicado, ID inexistente |

## Notas

- Los IDs `4` (rol) y `6` (módulo) del documento original son datos de ejemplo.
  En esta colección los `PUT`/`DELETE` usan las variables que se rellenan al crear,
  para no modificar los datos semilla (`admin`, `user`, `manager`, `Documentos`, etc.).
- La asignación de permisos escribe en la tabla puente `module_role_user`
  (`user_id`, `role_id`, `module_id`, `permission_id`). El borrado de esa tabla es
  **físico**, no lógico.
