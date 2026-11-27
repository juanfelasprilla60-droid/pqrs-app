<?php

namespace App\Controllers\Security;

use App\Controllers\BaseApiController;
use App\Models\ModuleModel;
use App\Models\ModuleRoleUserModel;
use App\Models\PermissionModel;
use App\Models\RoleModel;
use App\Models\UserModel;

class PermissionAssignmentController extends BaseApiController
{
    protected ModuleRoleUserModel $mruModel;
    protected UserModel $userModel;
    protected RoleModel $roleModel;
    protected ModuleModel $moduleModel;
    protected PermissionModel $permissionModel;

    public function __construct()
    {
        $this->mruModel        = new ModuleRoleUserModel();
        $this->userModel       = new UserModel();
        $this->roleModel       = new RoleModel();
        $this->moduleModel     = new ModuleModel();
        $this->permissionModel = new PermissionModel();
    }

    /**
     * POST /api/permissions/assign
     * Body: { "user_id": 1, "role_id": 1, "module_id": 2, "permission_ids": [1, 2, 3] }
     */
    public function assign()
    {
        $input = $this->request->getJSON(true);

        if (empty($input)) {
            return $this->respondError('No se enviaron datos para asignar permisos.', 400);
        }

        $required = ['user_id', 'role_id', 'module_id', 'permission_ids'];
        foreach ($required as $field) {
            if (empty($input[$field])) {
                return $this->respondError("El campo {$field} es obligatorio.", 400);
            }
        }

        if (! is_array($input['permission_ids'])) {
            return $this->respondError('permission_ids debe ser un array.', 400);
        }

        // Validar que existan las entidades
        if (! $this->userModel->find((int) $input['user_id'])) {
            return $this->respondError('Usuario no encontrado.', 404);
        }
        if (! $this->roleModel->find((int) $input['role_id'])) {
            return $this->respondError('Rol no encontrado.', 404);
        }
        if (! $this->moduleModel->find((int) $input['module_id'])) {
            return $this->respondError('Módulo no encontrado.', 404);
        }

        $db = \Config\Database::connect();
        $db->transBegin();

        try {
            $inserted = 0;
            $skipped  = 0;

            foreach (array_unique(array_map('intval', $input['permission_ids'])) as $permissionId) {
                if (! $this->permissionModel->find($permissionId)) {
                    continue; // Ignorar permisos inexistentes (igual que el taller)
                }

                // Verificar si ya existe
                $exists = $this->mruModel
                    ->where('user_id', (int) $input['user_id'])
                    ->where('role_id', (int) $input['role_id'])
                    ->where('module_id', (int) $input['module_id'])
                    ->where('permission_id', $permissionId)
                    ->first();

                if ($exists) {
                    $skipped++;
                    continue;
                }

                $ok = $this->mruModel->insert([
                    'user_id'       => (int) $input['user_id'],
                    'role_id'       => (int) $input['role_id'],
                    'module_id'     => (int) $input['module_id'],
                    'permission_id' => $permissionId,
                ]);

                if ($ok === false) {
                    throw new \RuntimeException('No se pudo asignar el permiso ' . $permissionId . '.');
                }

                $inserted++;
            }

            $db->transCommit();

            return $this->respondSuccess([
                'inserted' => $inserted,
                'skipped'  => $skipped,
            ], "Permisos asignados: {$inserted}, omitidos (ya existían): {$skipped}.", 201);
        } catch (\Throwable $e) {
            $db->transRollback();

            return $this->respondError('Error al asignar permisos: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/permissions/user/{userId}
     */
    public function getUserPermissions($userId = null)
    {
        if (! $this->userModel->find((int) $userId)) {
            return $this->respondError('Usuario no encontrado.', 404);
        }

        $permissions = $this->mruModel->getPermissionsByUser((int) $userId);

        return $this->respondSuccess($permissions, 'Permisos del usuario obtenidos correctamente.');
    }

    /**
     * DELETE /api/permissions/revoke
     * Body: { "user_id": 1, "role_id": 1, "module_id": 2, "permission_id": 3 }
     */
    public function revoke()
    {
        $input = $this->request->getJSON(true);

        if (empty($input)) {
            return $this->respondError('No se enviaron datos para revocar el permiso.', 400);
        }

        $required = ['user_id', 'role_id', 'module_id', 'permission_id'];
        foreach ($required as $field) {
            if (empty($input[$field])) {
                return $this->respondError("El campo {$field} es obligatorio.", 400);
            }
        }

        $exists = $this->mruModel
            ->where('user_id', (int) $input['user_id'])
            ->where('role_id', (int) $input['role_id'])
            ->where('module_id', (int) $input['module_id'])
            ->where('permission_id', (int) $input['permission_id'])
            ->first();

        if (! $exists) {
            return $this->respondError('El permiso no está asignado al usuario.', 404);
        }

        $this->mruModel->delete($exists['id']);

        return $this->respondSuccess(null, 'Permiso revocado correctamente.');
    }
}
