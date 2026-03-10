package middleware

import (
	"strings"

	"daily-record/config"
	"daily-record/handlers"
	"daily-record/utils"

	"github.com/gofiber/fiber/v3"
)

// Protected ตรวจสอบ JWT Access Token ใน Authorization header
func Protected(cfg *config.Config) fiber.Handler {
	return func(c fiber.Ctx) error {
		authHeader := c.Get("Authorization")
		if authHeader == "" {
			return c.Status(fiber.StatusUnauthorized).JSON(
				utils.ErrorResponse("Missing Authorization header"),
			)
		}

		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || parts[0] != "Bearer" {
			return c.Status(fiber.StatusUnauthorized).JSON(
				utils.ErrorResponse("Format: Authorization: Bearer <token>"),
			)
		}

		claims, err := handlers.ParseAccessToken(parts[1], cfg)
		if err != nil {
			return c.Status(fiber.StatusUnauthorized).JSON(
				utils.ErrorResponse("Invalid or expired access token"),
			)
		}

		// เก็บ claims ไว้ให้ handler ถัดไปใช้
		c.Locals("claims", claims)
		return c.Next()
	}
}

// RequireRole ตรวจสอบ role — ใช้หลัง Protected เสมอ
func RequireRole(roles ...string) fiber.Handler {
	return func(c fiber.Ctx) error {
		claims := c.Locals("claims").(*handlers.AccessClaims)
		for _, role := range roles {
			if claims.Role == role {
				return c.Next()
			}
		}
		return c.Status(fiber.StatusForbidden).JSON(
			utils.ErrorResponse("Forbidden: insufficient permissions"),
		)
	}
}
