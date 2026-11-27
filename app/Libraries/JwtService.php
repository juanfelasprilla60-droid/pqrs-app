<?php

namespace App\Libraries;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

/**
 * Servicio de JWT usado por AuthController.
 * Envuelve la librería firebase/php-jwt con la configuración del .env.
 */
class JwtService
{
    private string $secret;
    private int $expire;

    public function __construct()
    {
        $this->secret = (string) env('JWT_SECRET', 'pqrs-dev-secret');
        $this->expire = (int) env('JWT_EXPIRE', 3600);
    }

    /**
     * Genera un token JWT con los datos del usuario.
     */
    public function generate(array $payload): string
    {
        $time = time();

        return JWT::encode([
            'iat'  => $time,
            'exp'  => $time + $this->expire,
            'data' => $payload,
        ], $this->secret, 'HS256');
    }

    /**
     * Valida el token y retorna el payload, o false si es inválido/expirado.
     *
     * @return array|false
     */
    public function validate(string $token)
    {
        try {
            $decoded = JWT::decode($token, new Key($this->secret, 'HS256'));

            return (array) $decoded->data;
        } catch (\Throwable $e) {
            return false;
        }
    }

    /**
     * Extrae el token del header Authorization: Bearer <token>.
     */
    public function getBearerToken(): ?string
    {
        $request    = \Config\Services::request();
        $authHeader = $request->getHeaderLine('Authorization');

        if (preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
            return $matches[1];
        }

        return null;
    }
}
