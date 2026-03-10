package routes

import (
	"daily-record/config"
	"daily-record/handlers"
	"daily-record/middleware"
	"daily-record/models"
	"daily-record/utils"

	"github.com/gofiber/fiber/v3"
)

// Setup ลงทะเบียน routes ทั้งหมด
func Setup(app *fiber.App, store *models.Store, cfg *config.Config) {
	authHandler := handlers.NewAuthHandler(store, cfg)
	loginLimiter := middleware.NewLoginRateLimiter(cfg.RateLimitMax, cfg.RateLimitWindow)

	api := app.Group("/api/v1")

	// ── Public Routes ─────────────────────────────────────────────────────────
	auth := api.Group("/auth")
	auth.Post("/register", authHandler.Register)
	auth.Post("/login", loginLimiter.Middleware(), authHandler.Login)
	auth.Post("/refresh", authHandler.Refresh)
	auth.Post("/logout", authHandler.Logout)

	// ── Protected Routes (ต้องมี Access Token) ────────────────────────────────
	protected := api.Group("/", middleware.Protected(cfg))
	protected.Get("/auth/me", authHandler.Me)
	protected.Post("/auth/logout-all", authHandler.LogoutAll)

	// ── Admin Routes ──────────────────────────────────────────────────────────
	admin := api.Group("/admin",
		middleware.Protected(cfg),
		middleware.RequireRole(models.RoleAdmin),
	)
	admin.Get("/dashboard", func(c fiber.Ctx) error {
		claims := c.Locals("claims").(*handlers.AccessClaims)
		return c.JSON(utils.SuccessResponse("Admin dashboard", fiber.Map{
			"admin_id":   claims.UserID,
			"admin_name": claims.Username,
		}))
	})
}
