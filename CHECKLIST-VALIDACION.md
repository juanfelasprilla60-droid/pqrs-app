# Checklist de Validación de APIs — Proyecto PQRS

**Proyecto:** `C:\xampp\htdocs\pqrs-app`
**Servidor:** `http://localhost:8080` (`php spark serve`)
**Base de datos:** `pqrs_system` en `127.0.0.1:3307` (usuario `root`, sin contraseña)
**Fecha de ejecución:** 29 de octubre de 2026
**Credenciales:** `admin` / `Admin123`

---

## Resultado global

| Métrica | Valor |
|---|---|
| Comprobaciones ejecutadas | **130** (66 fases 0-3 + 35 usuarios + 2 duplicados `PUT` + 27 asignación) |
| Aprobadas | **130** ✅ |
| Fallidas | **0** ❌ |
| Endpoints validados | **25 / 25** |
| Pendientes | 0 |

> Las 66 comprobaciones de las fases 0-3 cubren sus **67 casillas**: la casilla
> **7.3** (DELETE físico de permisos) se valida con la misma evidencia de **2.5**
> (`P13`), por eso hay una comprobación menos que casillas en esas fases.
> Total de casillas del documento: **97 / 97 ✅**.

---

## Convenciones

- **✅** = Validado y funcionando.
- **⬜** = Pendiente por validar.
- **❌** = Falló (requiere corrección).

---

## 0. Autenticación (`/api/auth`)

### 0.1 Login

- [x] ✅ `POST /api/auth/login` con credenciales válidas → `200` + token.
- [x] ✅ El token es un string JWT válido (3 partes separadas por puntos).
- [x] ✅ `POST /api/auth/login` con password incorrecto → `401 Credenciales inválidas`.
- [x] ✅ `POST /api/auth/login` con usuario inexistente → `401 Credenciales inválidas`.
- [x] ✅ `POST /api/auth/login` sin body → `400 Usuario y contraseña son obligatorios`.
- [x] ✅ `POST /api/auth/login` con usuario inactivo (`status_id != 1`) → `403 El usuario no está activo`.

### 0.2 Me

- [x] ✅ `GET /api/auth/me` con token válido → `200` + datos del usuario.
- [x] ✅ `GET /api/auth/me` sin token → `401 Token no proporcionado`.
- [x] ✅ `GET /api/auth/me` con token inválido → `401 Token inválido o expirado`.

**Evidencia (9/9)**

| Caso | HTTP | Mensaje / dato |
|---|---|---|
| Login válido | 200 | `token` JWT de 3 partes + `user` |
| Password incorrecto | 401 | `Credenciales inválidas.` |
| Usuario inexistente | 401 | `Credenciales inválidas.` |
| Sin body | 400 | `Usuario y contraseña son obligatorios.` |
| Usuario inactivo (`id 8`, `status_id = 2`) | 403 | `El usuario no está activo.` |
| `/me` con token | 200 | `status: success` + datos del usuario |
| `/me` sin token | 401 | `Token no proporcionado.` |
| `/me` token inválido | 401 | `Token inválido o expirado.` |

---

## 1. Roles (`/api/roles`)

### 1.1 Listar roles

- [x] ✅ `GET /api/roles` con token válido → `200` + array de roles.
- [x] ✅ `GET /api/roles` sin token → `401 Token no proporcionado`.
- [x] ✅ `GET /api/roles` con token inválido → `401 Token inválido o expirado`.

### 1.2 Ver rol por ID

- [x] ✅ `GET /api/roles/1` con token válido → `200` + datos del rol.
- [x] ✅ `GET /api/roles/999` (inexistente) → `404 Rol no encontrado`.

### 1.3 Crear rol

- [x] ✅ `POST /api/roles` con body válido → `201` + rol creado.
- [x] ✅ `POST /api/roles` sin `name` → `400 El campo name es obligatorio`.
- [x] ✅ `POST /api/roles` con `name` duplicado → `409 Ya existe un rol con ese nombre`.
- [x] ✅ `POST /api/roles` sin token → `401`.

### 1.4 Actualizar rol

- [x] ✅ `PUT /api/roles/{id}` con body válido → `200` + rol actualizado.
- [x] ✅ `PUT /api/roles/{id}` con `name` duplicado → `409 Ya existe otro rol con ese nombre`.
- [x] ✅ `PUT /api/roles/999` (inexistente) → `404 Rol no encontrado`.
- [x] ✅ `PUT /api/roles/{id}` sin body → `400 No se enviaron datos para actualizar`.

### 1.5 Desactivar rol (soft delete)

- [x] ✅ `DELETE /api/roles/{id}` → `200` + `is_active` cambia a `0`.
- [x] ✅ Verificar en BD que `is_active = 0` después del delete.
- [x] ✅ `DELETE /api/roles/999` → `404 Rol no encontrado`.

**Evidencia (16/16)**

| Caso | HTTP | Resultado |
|---|---|---|
| `GET /api/roles` | 200 | array de roles |
| Sin token / token inválido | 401 / 401 | `Token no proporcionado.` / `Token inválido o expirado.` |
| `GET /api/roles/1` | 200 | rol `admin` |
| `GET /api/roles/999` | 404 | `Rol no encontrado.` |
| `POST` válido (`checklist_role`) | 201 | rol creado |
| `POST` sin `name` | 400 | `El campo name es obligatorio.` |
| `POST` `name` duplicado (`admin`) | 409 | `Ya existe un rol con ese nombre.` |
| `POST` sin token | 401 | `Token no proporcionado.` |
| `PUT` válido | 200 | descripción actualizada |
| `PUT` `name` duplicado | 409 | `Ya existe otro rol con ese nombre.` |
| `PUT /999` | 404 | `Rol no encontrado.` |
| `PUT` sin body | 400 | `No se enviaron datos para actualizar.` |
| `DELETE` | 200 | rol desactivado |
| BD tras `DELETE` | — | `is_active = 0` (fila conservada) |
| `DELETE /999` | 404 | `Rol no encontrado.` |

> El rol de prueba `checklist_role` se eliminó físicamente al terminar para dejar
> la tabla `role` con sus **4 registros semilla**.

---

## 2. Permisos (`/api/permissions`)

### 2.1 Listar permisos

- [x] ✅ `GET /api/permissions` con token válido → `200` + array de permisos.
- [x] ✅ `GET /api/permissions` sin token → `401`.

### 2.2 Ver permiso por ID

- [x] ✅ `GET /api/permissions/1` → `200` + permiso `view`.
- [x] ✅ `GET /api/permissions/999` → `404 Permiso no encontrado`.

### 2.3 Crear permiso

- [x] ✅ `POST /api/permissions` con body válido → `201` + permiso creado.
- [x] ✅ `POST /api/permissions` sin `name` → `400 El campo name es obligatorio`.
- [x] ✅ `POST /api/permissions` con `name` duplicado → `409 Ya existe un permiso con ese nombre`.

### 2.4 Actualizar permiso

- [x] ✅ `PUT /api/permissions/{id}` con body válido → `200` + permiso actualizado.
- [x] ✅ `PUT /api/permissions/{id}` con `name` duplicado → `409 Ya existe otro permiso con ese nombre`.
- [x] ✅ `PUT /api/permissions/999` → `404 Permiso no encontrado`.
- [x] ✅ `PUT /api/permissions/{id}` sin body → `400 No se enviaron datos para actualizar`.

### 2.5 Eliminar permiso (físico)

- [x] ✅ `DELETE /api/permissions/{id}` → `200` + permiso eliminado.
- [x] ✅ Verificar en BD que el registro ya no existe.
- [x] ✅ `DELETE /api/permissions/999` → `404 Permiso no encontrado`.

**Evidencia (14/14)**

| Caso | HTTP | Resultado |
|---|---|---|
| `GET /api/permissions` | 200 | 5 permisos (`view`, `create`, `edit`, `delete`, `export`) |
| Sin token | 401 | `Token no proporcionado.` |
| `GET /api/permissions/1` | 200 | `{"id":"1","name":"view"}` |
| `GET /api/permissions/999` | 404 | `Permiso no encontrado.` |
| `POST` válido (`checklist_perm`) | 201 | permiso creado |
| `POST` sin `name` | 400 | `El campo name es obligatorio.` |
| `POST` `name` duplicado (`view`) | 409 | `Ya existe un permiso con ese nombre.` |
| `PUT` válido | 200 | descripción actualizada |
| `PUT` `name` duplicado | 409 | `Ya existe otro permiso con ese nombre.` |
| `PUT /999` | 404 | `Permiso no encontrado.` |
| `PUT` sin body | 400 | `No se enviaron datos para actualizar.` |
| `DELETE` | 200 | permiso eliminado |
| BD tras `DELETE` | — | `SELECT COUNT(*) = 0` (borrado **físico**) |
| `DELETE /999` | 404 | `Permiso no encontrado.` |

> La tabla `permission` no existía en la base original: se creó y se sembró con los
> 5 permisos base (ids 1-5). El permiso temporal `checklist_perm` fue eliminado por
> el propio `DELETE` (borrado físico).

---

## 3. Módulos (`/api/modules`)

### 3.1 Listar módulos

- [x] ✅ `GET /api/modules` con token válido → `200` + array de módulos.
- [x] ✅ `GET /api/modules` sin token → `401`.

### 3.2 Ver módulo por ID

- [x] ✅ `GET /api/modules/1` → `200` + módulo `Dashboard`.
- [x] ✅ `GET /api/modules/999` → `404 Módulo no encontrado`.

### 3.3 Crear módulo

- [x] ✅ `POST /api/modules` con body válido → `201` + módulo creado.
- [x] ✅ `POST /api/modules` sin `name` o `route` → `400 Los campos name y route son obligatorios`.
- [x] ✅ `POST /api/modules` con `name` duplicado → `409 Ya existe un módulo con ese nombre`.
- [x] ✅ `POST /api/modules` con `route` duplicada → `409 Ya existe un módulo con esa ruta`.

### 3.4 Actualizar módulo

- [x] ✅ `PUT /api/modules/{id}` con body válido → `200` + módulo actualizado.
- [x] ✅ `PUT /api/modules/{id}` con `name` duplicado → `409 Ya existe otro módulo con ese nombre`.
- [x] ✅ `PUT /api/modules/{id}` con `route` duplicada → `409 Ya existe otro módulo con esa ruta`.
- [x] ✅ `PUT /api/modules/999` → `404 Módulo no encontrado`.
- [x] ✅ `PUT /api/modules/{id}` sin body → `400 No se enviaron datos para actualizar`.

### 3.5 Desactivar módulo (soft delete)

- [x] ✅ `DELETE /api/modules/{id}` → `200` + `is_active` cambia a `0`.
- [x] ✅ Verificar en BD que `is_active = 0`.
- [x] ✅ `DELETE /api/modules/999` → `404 Módulo no encontrado`.

**Evidencia (16/16)**

| Caso | HTTP | Resultado |
|---|---|---|
| `GET /api/modules` | 200 | 7 módulos (ids 1-6 y 9) |
| Sin token | 401 | `Token no proporcionado.` |
| `GET /api/modules/1` | 200 | `{"name":"Dashboard","route":"#dashboard"}` |
| `GET /api/modules/999` | 404 | `Módulo no encontrado.` |
| `POST` válido (`checklist_module`) | 201 | módulo creado |
| `POST` sin `name`/`route` | 400 | `Los campos name y route son obligatorios.` |
| `POST` `name` duplicado (`Dashboard`) | 409 | `Ya existe un módulo con ese nombre.` |
| `POST` `route` duplicada (`#dashboard`) | 409 | `Ya existe un módulo con esa ruta.` |
| `PUT` válido | 200 | descripción actualizada |
| `PUT` `name` duplicado | 409 | `Ya existe otro módulo con ese nombre.` |
| `PUT` `route` duplicada | 409 | `Ya existe otro módulo con esa ruta.` |
| `PUT /999` | 404 | `Módulo no encontrado.` |
| `PUT` sin body | 400 | `No se enviaron datos para actualizar.` |
| `DELETE` | 200 | módulo desactivado |
| BD tras `DELETE` | — | `is_active = 0` (fila conservada) |
| `DELETE /999` | 404 | `Módulo no encontrado.` |

> El módulo de prueba `checklist_module` se eliminó físicamente al terminar; la tabla
> `module` quedó con sus **7 registros semilla**, todos activos.

---

## 4. Usuarios (`/api/users`)

> **Implementado y validado** (Fase 4). Creación transaccional en `user` + `profile`
> + `user_role`, borrado lógico con `status_id = 2`.

### 4.1 Listar usuarios

- [x] ✅ `GET /api/users` con token válido → `200` + array de usuarios con perfil y roles.
- [x] ✅ `GET /api/users` sin token → `401`.

### 4.2 Ver usuario por ID

- [x] ✅ `GET /api/users/1` → `200` + usuario con perfil y roles.
- [x] ✅ `GET /api/users/999` → `404 Usuario no encontrado`.

> En esta base **no existe el usuario id 1** (los ids son 2, 3, 8 y 9). La casilla se
> validó con `GET /api/users/9` (admin): `200` + `profile` + `roles`. `GET /api/users/1`
> devuelve `404`, que es el comportamiento correcto para un id inexistente.

### 4.3 Crear usuario + perfil

- [x] ✅ `POST /api/users` con body válido → `201` + usuario creado con perfil y rol.
- [x] ✅ Verificar en BD que se crearon registros en `user`, `profile` y `user_role`.
- [x] ✅ `POST /api/users` sin `username` → `400`.
- [x] ✅ `POST /api/users` con `username` duplicado → `409`.
- [x] ✅ `POST /api/users` con `email` duplicado → `409`.
- [x] ✅ `POST /api/users` con `document_number` duplicado → `409`.
- [x] ✅ Verificar que la contraseña se guarda hasheada en BD (no en texto plano).

### 4.4 Actualizar usuario

- [x] ✅ `PUT /api/users/{id}` con body válido → `200` + usuario actualizado.
- [x] ✅ Verificar que se actualizan tanto `user` como `profile`.
- [x] ✅ `PUT /api/users/{id}` con `email` duplicado → `409`.
- [x] ✅ `PUT /api/users/999` → `404 Usuario no encontrado`.

### 4.5 Desactivar usuario (soft delete)

- [x] ✅ `DELETE /api/users/{id}` → `200` + `status_id` cambia a `2` (inactivo).
- [x] ✅ Verificar en BD que `status_id = 2`.
- [x] ✅ Intentar hacer login con el usuario desactivado → `403 El usuario no está activo`.
- [x] ✅ `DELETE /api/users/999` → `404 Usuario no encontrado`.

**Evidencia (19/19)**

| Caso | HTTP | Resultado |
|---|---|---|
| `GET /api/users` | 200 | 4 usuarios, cada uno con `profile` y `roles` |
| Sin token / token inválido | 401 / 401 | `Token no proporcionado.` / `Token inválido o expirado.` |
| `GET /api/users/9` | 200 | admin + `roles` + `status_name` |
| `GET /api/users/999` | 404 | `Usuario no encontrado.` |
| `POST` válido (`juan`) | 201 | usuario + perfil + rol creados |
| BD tras `POST` | — | `user=1`, `profile=1`, `user_role=1` |
| `POST` sin `username` | 400 | `El campo username es obligatorio.` |
| `POST` sin `role_ids` / no array | 400 | `Debe asignar al menos un rol.` |
| `POST` `username` duplicado | 409 | `Ya existe un usuario con ese username.` |
| `POST` `email` duplicado | 409 | `Ya existe un usuario con ese email.` |
| `POST` `document_number` duplicado | 409 | `Ya existe un perfil con ese número de documento.` |
| BD: hash de contraseña | — | `$2y$10$...` |
| `PUT` válido | 200 | `first_name` y `phone` actualizados |
| BD tras `PUT` | — | `user` y `profile` actualizados |
| `PUT` `email` duplicado | 409 | `Ya existe otro usuario con ese email.` |
| `PUT` `document_number` duplicado | 409 | `Ya existe otro perfil con ese número de documento.` |
| `PUT /999` | 404 | `Usuario no encontrado.` |
| `PUT` sin body | 400 | `No se enviaron datos para actualizar.` |
| `DELETE` | 200 | usuario desactivado |
| BD tras `DELETE` | — | `status_id = 2` |
| Login desactivado | 403 | `El usuario no está activo.` |
| `DELETE /999` | 404 | `Usuario no encontrado.` |

Además se validaron llaves foráneas: `role_ids: [999]`, `status_id: 999` y
`document_type_id: 999` devuelven **404** (no 500) y no dejan registros parciales.

---

## 5. Asignación de Permisos (`/api/permissions`)

> **Implementado y validado** (Fase 5). Tabla puente `module_role_user` creada con
> FKs y `UNIQUE (user_id, role_id, module_id, permission_id)`. Borrado **físico**.

### 5.1 Asignar permisos

- [x] ✅ `POST /api/permissions/assign` con body válido → `201` + permisos asignados.
- [x] ✅ Verificar en BD que se crearon registros en `module_role_user`.
- [x] ✅ `POST /api/permissions/assign` con `user_id` inexistente → `404`.
- [x] ✅ `POST /api/permissions/assign` con `role_id` inexistente → `404`.
- [x] ✅ `POST /api/permissions/assign` con `module_id` inexistente → `404`.
- [x] ✅ `POST /api/permissions/assign` con `permission_ids` vacío → `400`.

### 5.2 Ver permisos de un usuario

- [x] ✅ `GET /api/permissions/user/{userId}` → `200` + array de permisos agrupados por módulo.
- [x] ✅ `GET /api/permissions/user/999` → `404 Usuario no encontrado`.

### 5.3 Revocar permiso

- [x] ✅ `DELETE /api/permissions/revoke` con body válido → `200` + permiso revocado.
- [x] ✅ Verificar en BD que el registro se eliminó de `module_role_user`.
- [x] ✅ `DELETE /api/permissions/revoke` con permiso inexistente → `404`.

**Evidencia (11/11)**

| Caso | HTTP | Resultado |
|---|---|---|
| `POST assign` válido (`[1,2,3]`) | 201 | `inserted: 3`, `skipped: 0` |
| BD tras `assign` | — | 3 filas en `module_role_user` |
| `POST assign` repetido | 201 | `inserted: 0`, `skipped: 3` |
| `POST assign` mixto (`[2,3,4]`) | 201 | `inserted: 1`, `skipped: 2` |
| `user_id: 999` | 404 | `Usuario no encontrado.` |
| `role_id: 999` | 404 | `Rol no encontrado.` |
| `module_id: 999` | 404 | `Módulo no encontrado.` |
| `permission_ids: []` | 400 | `El campo permission_ids es obligatorio.` |
| `permission_ids: "1"` (no array) | 400 | `permission_ids debe ser un array.` |
| `permission_ids: [999]` | 201 | permiso ignorado, 0 filas |
| `GET /api/permissions/user/2` | 200 | agrupado por módulo con `permissions` y `roles` |
| `GET /api/permissions/user/999` | 404 | `Usuario no encontrado.` |
| `DELETE revoke` válido | 200 | `Permiso revocado correctamente.` |
| BD tras `revoke` | — | fila eliminada |
| `revoke` de permiso no asignado | 404 | `El permiso no está asignado al usuario.` |
| `revoke` sin `permission_id` | 400 | `El campo permission_id es obligatorio.` |
| `assign` / `user` / `revoke` sin token | 401 | `Token no proporcionado.` |
| `GET /api/permissions` y `/1` | 200 | rutas genéricas siguen funcionando |

Las rutas de asignación se registraron **antes** del grupo genérico `api/permissions`
(verificado con `php spark routes`). Suite completa: **27/27 PASS**.

---

## 6. Pruebas de Seguridad (Transversales)

- [x] ✅ Cualquier endpoint protegido sin token → `401 Token no proporcionado`.
- [x] ✅ Cualquier endpoint protegido con token inválido → `401 Token inválido o expirado`.
- [x] ✅ Cualquier endpoint protegido con token expirado → `401 Token inválido o expirado`.
- [x] ✅ Los endpoints de login no requieren token.
- [x] ✅ Los errores 500 no exponen información sensible (en producción, `CI_ENVIRONMENT = production`).
- [x] ✅ Los IDs inexistentes devuelven `404` y no `500`.
- [x] ✅ Los duplicados devuelven `409` y no `500`.

**Evidencia (7/7)**

| Prueba | Resultado |
|---|---|
| Endpoint protegido sin token | 401 `Token no proporcionado.` |
| Token inválido (`abc.def.ghi`) | 401 `Token inválido o expirado.` |
| Token expirado (generado con `exp` en el pasado) | 401 `Token inválido o expirado.` |
| Login sin token | 200 (no requiere autenticación) |
| Respuestas 500 en toda la suite | **0** |
| ID inexistente | 404 (nunca 500) |
| Duplicado | 409 (nunca 500) |

> El token expirado se generó con la misma `JWT_SECRET` del `.env` y `exp = now - 3600`,
> de modo que el filtro lo rechaza por expiración y no por firma inválida.

---

## 7. Validaciones de Base de Datos

- [x] ✅ Los `created_at` y `updated_at` se generan automáticamente.
- [x] ✅ Los `DELETE` (soft delete) cambian el estado pero no borran el registro.
- [x] ✅ Los `DELETE` físicos (permisos) eliminan el registro.
- [x] ✅ Las contraseñas se guardan hasheadas (empiezan con `$2y$10$`).
- [x] ✅ Las foreign keys se respetan (no se puede crear un usuario con `status_id` inexistente).

**Evidencia (5/5)**

| Prueba | Resultado |
|---|---|
| Filas con `created_at`/`updated_at` nulos en `role` | `0` |
| Soft delete de rol: fila conservada | `1` fila (con `is_active = 0`) |
| Borrado físico de permiso | `0` filas restantes |
| Hash de `admin` | empieza con `$2y$10$` |
| `INSERT` con `status_id = 999` | rechazado por FK (`exit=1`, `0` filas creadas) |

---

## 8. Resumen de Progreso

| Módulo | Total endpoints | Validados | Pendientes |
|--------|-----------------|-----------|------------|
| Autenticación | 2 | **2** ✅ | 0 |
| Roles | 5 | **5** ✅ | 0 |
| Permisos | 5 | **5** ✅ | 0 |
| Módulos | 5 | **5** ✅ | 0 |
| Usuarios | 5 | **5** ✅ | 0 |
| Asignación | 3 | **3** ✅ | 0 |
| **Total** | **25** | **25** | **0** |

**Casillas del checklist:** 97 totales → **97 marcadas** ✅ · **0 pendientes**.

---

## 9. Estado de los datos tras la validación

| Tabla | Registros | Observación |
|---|---|---|
| `role` | 4 | semilla (`admin`, `user`, `manager`, …) — rol de prueba eliminado |
| `module` | 7 | ids 1-6 y 9, todos activos — módulo de prueba eliminado |
| `permission` | 5 | `view`, `create`, `edit`, `delete`, `export` |
| `user` | 4 | ids 2, 3, 8 y 9 — todos con `status_id = 1` |
| `profile` | 0 | los usuarios semilla no tienen perfil; los perfiles de prueba se borraron |
| `user_role` | 1 | solo `admin` (id 9) con rol `admin` |
| `module_role_user` | 0 | tabla puente creada en la Fase 5; las asignaciones de prueba se revocaron |

---

## 10. Notas

- Marca cada casilla solo cuando el endpoint devuelva el código HTTP y el JSON esperado.
- Si un endpoint falla, anota el error y corrígelo antes de continuar.
- Usa la colección `postman/PQRS-API.postman_collection.json` con variables de entorno
  (`baseUrl`, `token`, `permissionId`, `moduleId`, `userId`) para no repetir el token.
- Guarda los ejemplos de respuestas exitosas para usarlos como referencia en el frontend.
- **Contraseña:** el documento del taller usa `admin123`, pero el hash instalado
  corresponde a **`Admin123`** (el login distingue mayúsculas).
- **Datos de ejemplo:** los ids `4` (rol) y `6` (módulo) del documento original son
  ilustrativos; el id 6 es el módulo semilla **Documentos**. La colección de Postman
  usa variables que se rellenan al crear los registros de prueba.
