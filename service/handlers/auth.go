package handlers

import (
	"daily-record/config"
	"daily-record/models"
	"daily-record/utils"

	"github.com/gofiber/fiber/v3"
	"golang.org/x/crypto/bcrypt"
)

// AuthHandler รวม dependency ที่ใช้ใน handler
type AuthHandler struct {
	store *models.Store
	cfg   *config.Config
}

// NewAuthHandler constructor
func NewAuthHandler(store *models.Store, cfg *config.Config) *AuthHandler {
	return &AuthHandler{store: store, cfg: cfg}
}

// ─────────────────────────────────────────────────────────────────────────────
// POST /api/v1/auth/register
// ─────────────────────────────────────────────────────────────────────────────

type RegisterRequest struct {
	Username string `json:"username"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

func (h *AuthHandler) Register(c fiber.Ctx) error {
	var req RegisterRequest
	if err := c.Bind().Body(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(
			utils.ErrorResponse("Invalid request body"),
		)
	}

	// Validate input
	if req.Username == "" || req.Email == "" || req.Password == "" {
		return c.Status(fiber.StatusBadRequest).JSON(
			utils.ErrorResponse("username, email and password are required"),
		)
	}
	if len(req.Username) < 3 {
		return c.Status(fiber.StatusBadRequest).JSON(
			utils.ErrorResponse("Username must be at least 3 characters"),
		)
	}
	if len(req.Password) < 8 {
		return c.Status(fiber.StatusBadRequest).JSON(
			utils.ErrorResponse("Password must be at least 8 characters"),
		)
	}

	// ตรวจซ้ำ
	if h.store.ExistsUsername(req.Username) {
		return c.Status(fiber.StatusConflict).JSON(
			utils.ErrorResponse("Username already taken"),
		)
	}
	if h.store.ExistsEmail(req.Email) {
		return c.Status(fiber.StatusConflict).JSON(
			utils.ErrorResponse("Email already registered"),
		)
	}

	// Hash password ด้วย bcrypt
	hashed, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(
			utils.ErrorResponse("Internal server error"),
		)
	}

	user := h.store.CreateUser(&models.User{
		Username: req.Username,
		Email:    req.Email,
		Password: string(hashed),
		Role:     models.RoleUser,
	})

	return c.Status(fiber.StatusCreated).JSON(utils.SuccessResponse(
		"Registration successful",
		fiber.Map{
			"id":         user.ID,
			"username":   user.Username,
			"email":      user.Email,
			"role":       user.Role,
			"created_at": user.CreatedAt,
		},
	))
}

// ─────────────────────────────────────────────────────────────────────────────
// POST /api/v1/auth/login
// ─────────────────────────────────────────────────────────────────────────────

type LoginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

func (h *AuthHandler) Login(c fiber.Ctx) error {
	var req LoginRequest
	if err := c.Bind().Body(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(
			utils.ErrorResponse("Invalid request body"),
		)
	}

	if req.Username == "" || req.Password == "" {
		return c.Status(fiber.StatusBadRequest).JSON(
			utils.ErrorResponse("username and password are required"),
		)
	}

	// หา user — ใช้ข้อความเดียวกันเพื่อกัน username enumeration
	user, exists := h.store.FindUserByUsername(req.Username)
	if !exists {
		return c.Status(fiber.StatusUnauthorized).JSON(
			utils.ErrorResponse("Invalid username or password"),
		)
	}

	// ตรวจ password
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(
			utils.ErrorResponse("Invalid username or password"),
		)
	}

	// ออก token คู่
	pair, err := IssueTokenPair(user, h.store, h.cfg)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(
			utils.ErrorResponse("Failed to generate tokens"),
		)
	}

	return c.JSON(utils.SuccessResponse("Login successful", fiber.Map{
		"user": fiber.Map{
			"id":       user.ID,
			"username": user.Username,
			"email":    user.Email,
			"role":     user.Role,
		},
		"tokens": pair,
	}))
}

// ─────────────────────────────────────────────────────────────────────────────
// POST /api/v1/auth/refresh
// ─────────────────────────────────────────────────────────────────────────────

type RefreshRequest struct {
	RefreshToken string `json:"refresh_token"`
}

func (h *AuthHandler) Refresh(c fiber.Ctx) error {
	var req RefreshRequest
	if err := c.Bind().Body(&req); err != nil || req.RefreshToken == "" {
		return c.Status(fiber.StatusBadRequest).JSON(
			utils.ErrorResponse("refresh_token is required"),
		)
	}

	rt, exists := h.store.FindRefreshToken(req.RefreshToken)
	if !exists || !rt.IsValid() {
		return c.Status(fiber.StatusUnauthorized).JSON(
			utils.ErrorResponse("Invalid or expired refresh token"),
		)
	}

	user, exists := h.store.FindUserByID(rt.UserID)
	if !exists {
		return c.Status(fiber.StatusUnauthorized).JSON(
			utils.ErrorResponse("User not found"),
		)
	}

	// Token Rotation — revoke เก่า แล้วออกใหม่
	// ถ้า attacker ขโมย token ไปใช้ก่อน เจ้าของจะ refresh แล้วพบว่า token ถูก revoke แล้ว
	h.store.RevokeRefreshToken(req.RefreshToken)

	pair, err := IssueTokenPair(user, h.store, h.cfg)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(
			utils.ErrorResponse("Failed to generate tokens"),
		)
	}

	return c.JSON(utils.SuccessResponse("Token refreshed successfully", fiber.Map{
		"tokens": pair,
	}))
}

// ─────────────────────────────────────────────────────────────────────────────
// POST /api/v1/auth/logout
// ─────────────────────────────────────────────────────────────────────────────

type LogoutRequest struct {
	RefreshToken string `json:"refresh_token"`
}

func (h *AuthHandler) Logout(c fiber.Ctx) error {
	var req LogoutRequest
	if err := c.Bind().Body(&req); err != nil || req.RefreshToken == "" {
		return c.Status(fiber.StatusBadRequest).JSON(
			utils.ErrorResponse("refresh_token is required"),
		)
	}

	h.store.RevokeRefreshToken(req.RefreshToken)

	return c.JSON(utils.SuccessResponse("Logged out successfully", nil))
}

// ─────────────────────────────────────────────────────────────────────────────
// POST /api/v1/auth/logout-all   [Protected]
// kick ออกทุกอุปกรณ์พร้อมกัน
// ─────────────────────────────────────────────────────────────────────────────

func (h *AuthHandler) LogoutAll(c fiber.Ctx) error {
	claims := c.Locals("claims").(*AccessClaims)
	h.store.RevokeAllUserTokens(claims.UserID)
	return c.JSON(utils.SuccessResponse("All sessions have been terminated", nil))
}

// ─────────────────────────────────────────────────────────────────────────────
// GET /api/v1/auth/me   [Protected]
// ─────────────────────────────────────────────────────────────────────────────

func (h *AuthHandler) Me(c fiber.Ctx) error {
	claims := c.Locals("claims").(*AccessClaims)

	user, exists := h.store.FindUserByID(claims.UserID)
	if !exists {
		return c.Status(fiber.StatusNotFound).JSON(
			utils.ErrorResponse("User not found"),
		)
	}

	return c.JSON(utils.SuccessResponse("", fiber.Map{
		"id":         user.ID,
		"username":   user.Username,
		"email":      user.Email,
		"role":       user.Role,
		"created_at": user.CreatedAt,
	}))
}
