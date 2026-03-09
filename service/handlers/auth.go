package handlers

import (
	"time"

	"daily-record/config"
	"daily-record/models"

	"github.com/gofiber/fiber/v3"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

// ── REGISTER ──────────────────────────────────────────
func Register(c fiber.Ctx) error {
	type Request struct {
		Username string `json:"username"`
		Password string `json:"password"`
	}

	var body Request
	if err := c.Bind().Body(&body); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "Invalid request body"})
	}

	if body.Username == "" || body.Password == "" {
		return c.Status(400).JSON(fiber.Map{"error": "Username and password required"})
	}

	// เช็คซ้ำ
	for _, u := range models.Users {
		if u.Username == body.Username {
			return c.Status(409).JSON(fiber.Map{"error": "Username already exists"})
		}
	}

	// Hash password
	hashed, err := bcrypt.GenerateFromPassword([]byte(body.Password), bcrypt.DefaultCost)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Failed to hash password"})
	}

	user := models.User{
		ID:       models.NextID,
		Username: body.Username,
		Password: string(hashed),
		Role:     "user",
	}
	models.Users = append(models.Users, user)
	models.NextID++

	return c.Status(201).JSON(fiber.Map{
		"message": "User registered successfully",
		"user": fiber.Map{
			"id":       user.ID,
			"username": user.Username,
			"role":     user.Role,
		},
	})
}

// ── LOGIN ──────────────────────────────────────────────
func Login(c fiber.Ctx) error {
	type Request struct {
		Username string `json:"username"`
		Password string `json:"password"`
	}

	var body Request
	if err := c.Bind().Body(&body); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "Invalid request body"})
	}

	// หา user
	var found *models.User
	for i := range models.Users {
		if models.Users[i].Username == body.Username {
			found = &models.Users[i]
			break
		}
	}

	if found == nil {
		return c.Status(401).JSON(fiber.Map{"error": "Invalid credentials"})
	}

	// ตรวจ password
	if err := bcrypt.CompareHashAndPassword([]byte(found.Password), []byte(body.Password)); err != nil {
		return c.Status(401).JSON(fiber.Map{"error": "Invalid credentials"})
	}

	// สร้าง JWT
	claims := jwt.MapClaims{
		"user_id":  found.ID,
		"username": found.Username,
		"role":     found.Role,
		"exp":      time.Now().Add(24 * time.Hour).Unix(), // หมดอายุ 24 ชม.
		"iat":      time.Now().Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, err := token.SignedString([]byte(config.GetJWTSecret()))
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Failed to generate token"})
	}

	return c.JSON(fiber.Map{
		"message":      "Login successful",
		"access_token": signed,
		"token_type":   "Bearer",
		"expires_in":   86400,
	})
}

// ── GET PROFILE (Protected) ────────────────────────────
func GetProfile(c fiber.Ctx) error {
	user := c.Locals("user").(*jwt.Token)
	claims := user.Claims.(jwt.MapClaims)

	return c.JSON(fiber.Map{
		"user_id":  claims["user_id"],
		"username": claims["username"],
		"role":     claims["role"],
	})
}

// ── REFRESH TOKEN ──────────────────────────────────────
func RefreshToken(c fiber.Ctx) error {
	user := c.Locals("user").(*jwt.Token)
	claims := user.Claims.(jwt.MapClaims)

	// ออก token ใหม่
	newClaims := jwt.MapClaims{
		"user_id":  claims["user_id"],
		"username": claims["username"],
		"role":     claims["role"],
		"exp":      time.Now().Add(24 * time.Hour).Unix(),
		"iat":      time.Now().Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, newClaims)
	signed, err := token.SignedString([]byte(config.GetJWTSecret()))
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Failed to refresh token"})
	}

	return c.JSON(fiber.Map{
		"access_token": signed,
		"token_type":   "Bearer",
		"expires_in":   86400,
	})
}
