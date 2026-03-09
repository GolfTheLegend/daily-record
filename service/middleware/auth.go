package middleware

import (
    "strings"

    "daily-record/config"

    "github.com/gofiber/fiber/v3"
    "github.com/golang-jwt/jwt/v5"
)

func Protected() fiber.Handler {
    return func(c fiber.Ctx) error {
        authHeader := c.Get("Authorization")
        if authHeader == "" {
            return c.Status(401).JSON(fiber.Map{"error": "Missing Authorization header"})
        }

        parts := strings.SplitN(authHeader, " ", 2)
        if len(parts) != 2 || parts[0] != "Bearer" {
            return c.Status(401).JSON(fiber.Map{"error": "Invalid token format"})
        }

        tokenStr := parts[1]
        token, err := jwt.Parse(tokenStr, func(t *jwt.Token) (interface{}, error) {
            // ตรวจว่าใช้ HMAC
            if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
                return nil, fiber.ErrUnauthorized
            }
            return []byte(config.GetJWTSecret()), nil
        })

        if err != nil || !token.Valid {
            return c.Status(401).JSON(fiber.Map{"error": "Invalid or expired token"})
        }

        c.Locals("user", token)
        return c.Next()
    }
}

// Middleware ตรวจ Role
func RequireRole(role string) fiber.Handler {
    return func(c fiber.Ctx) error {
        user := c.Locals("user").(*jwt.Token)
        claims := user.Claims.(jwt.MapClaims)

        if claims["role"] != role {
            return c.Status(403).JSON(fiber.Map{"error": "Forbidden: insufficient permissions"})
        }

        return c.Next()
    }
}