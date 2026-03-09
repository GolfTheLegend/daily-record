package main

import (
	"daily-record/handlers"
	"daily-record/middleware"
	"log"

	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/middleware/logger"
	"github.com/gofiber/fiber/v3/middleware/recover"
)

func main() {
	app := fiber.New(fiber.Config{
		AppName: "JWT Auth API v1.0",
	})

	// Global Middleware
	app.Use(logger.New())
	app.Use(recover.New())

	// ── Public Routes ──────────────────────────────────
	api := app.Group("/api/v1")

	auth := api.Group("/auth")
	auth.Post("/register", handlers.Register)
	auth.Post("/login", handlers.Login)

	// ── Protected Routes ───────────────────────────────
	protected := api.Group("/", middleware.Protected())
	protected.Get("/profile", handlers.GetProfile)
	protected.Post("/auth/refresh", handlers.RefreshToken)

	// Admin only
	admin := api.Group("/admin", middleware.Protected(), middleware.RequireRole("admin"))
	admin.Get("/dashboard", func(c fiber.Ctx) error {
		return c.JSON(fiber.Map{"message": "Welcome Admin!"})
	})

	log.Fatal(app.Listen(":8080"))
}
