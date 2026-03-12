package main

import (
	"fmt"
	"log"
	"time"

	"daily-record/config"
	"daily-record/models"
	"daily-record/routes"
	"daily-record/utils"

	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/middleware/cors"
	"github.com/gofiber/fiber/v3/middleware/logger"
	"github.com/gofiber/fiber/v3/middleware/recover"
	"github.com/joho/godotenv"
)

func main() {
	//โหลด .env ก่อน เพื่อให้ config สามารถอ่านค่าได้
	if err := godotenv.Load(); err != nil {
		log.Fatal("ไม่พบไฟล์ .env")
	}

	// 1. Load config
	cfg := config.Load()

	// 2. ดึงฐานข้อมูล Supabase (ถ้ามี)
	db := config.NewSupabaseClient()
	fmt.Println("✅ เชื่อมต่อ Supabase สำเร็จ!")
	fmt.Println("URL:", db.URL)

	// 2. Init store
	store := models.NewStore()

	// 3. Background cleanup
	go func() {
		ticker := time.NewTicker(1 * time.Hour)
		defer ticker.Stop()
		for range ticker.C {
			store.CleanExpiredTokens()
			log.Println("[Cleanup] Expired refresh tokens removed")
		}
	}()

	// 4. Init Fiber v3
	// ข้อแตกต่างจาก v2: fiber.Config{} บางฟิลด์เปลี่ยนชื่อ
	app := fiber.New(fiber.Config{
		AppName: "daily-record",
		// Fiber v3: ErrorHandler signature เปลี่ยนเป็น func(fiber.Ctx, error) error
		ErrorHandler: func(c fiber.Ctx, err error) error {
			code := fiber.StatusInternalServerError
			if e, ok := err.(*fiber.Error); ok {
				code = e.Code
			}
			return c.Status(code).JSON(utils.ErrorResponse(err.Error()))
		},
	})

	// 5. Global Middleware
	// Fiber v3: import path เปลี่ยนเป็น fiber/v3/middleware/...
	app.Use(recover.New())
	app.Use(logger.New(logger.Config{
		Format: "[${time}] ${status} ${method} ${path} | IP:${ip} | ${latency}\n",
	}))
	app.Use(cors.New(cors.Config{
		AllowOrigins: []string{"*"}, // Fiber v3: AllowOrigins เป็น []string แทน string
		AllowHeaders: []string{"Origin", "Content-Type", "Authorization"},
		AllowMethods: []string{"GET", "POST", "PUT", "DELETE"},
	}))

	// 6. Health check
	app.Get("/health", func(c fiber.Ctx) error {
		return c.JSON(utils.SuccessResponse("Service is running", fiber.Map{
			"service": "daily-record",
			"version": "1.0.0",
		}))
	})

	// 7. Register routes
	routes.Setup(app, store, cfg)

	// 8. Start
	log.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	log.Println("  🚀  daily-record — JWT Auth Service")
	log.Printf("  📡  Port          : %s\n", cfg.Port)
	log.Printf("  🔑  Access Token  : %s\n", cfg.AccessTokenExpiry)
	log.Printf("  🔄  Refresh Token : %s\n", cfg.RefreshTokenExpiry)
	log.Printf("  🛡️   Rate Limit    : %d req / %s\n", cfg.RateLimitMax, cfg.RateLimitWindow)
	log.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	log.Fatal(app.Listen(fmt.Sprintf(":%s", cfg.Port)))
}
