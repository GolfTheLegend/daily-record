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
// POST /auth/register
// ─────────────────────────────────────────────────────────────────────────────

type RegisterRequest struct {
	Username string `json:"username"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

// @Summary ลงทะเบียนผู้ใช้ใหม่
// @Description สร้างบัญชีผู้ใช้ใหม่ด้วยชื่อผู้ใช้ อีเมล และรหัสผ่าน
// @Tags Authentication
// @Accept json
// @Produce json
// @Param request body RegisterRequest true "ข้อมูลการลงทะเบียน"
// @Success 200 {object} map[string]interface{} "ลงทะเบียนสำเร็จ"
// @Failure 400 {object} map[string]interface{} "ข้อมูลไม่ถูกต้อง"
// @Router /auth/register [post]
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
// POST /auth/login
// ─────────────────────────────────────────────────────────────────────────────

type LoginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
	DeviceID string `json:"device_id"`
}

// @Summary Login user
// @Description Login ด้วย username และ password
// @Tags Authentication
// @Accept json
// @Produce json
// @Param request body LoginRequest true "Login credentials"
// @Success 200 {object} map[string]interface{}
// @Failure 401 {object} map[string]interface{}
// @Router /auth/login [post]
func (h *AuthHandler) Login(c fiber.Ctx) error {
	var req LoginRequest
	if err := c.Bind().Body(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(
			utils.ErrorResponse("Invalid request body"),
		)
	}

	if req.Username == "" || req.Password == "" || req.DeviceID == "" {
		return c.Status(fiber.StatusBadRequest).JSON(
			utils.ErrorResponse("username, password and device_id are required"),
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

	// ออก token คู่ พร้อม device binding
	pair, err := IssueTokenPair(user, h.store, h.cfg, req.DeviceID)
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
// POST /auth/refresh
// ─────────────────────────────────────────────────────────────────────────────

type RefreshRequest struct {
	RefreshToken string `json:"refresh_token"`
	DeviceID     string `json:"device_id"`
}

// @Summary Refresh access token
// @Description ใช้ refresh token เพื่อออก access token ใหม่
// @Tags Authentication
// @Accept json
// @Produce json
// @Param request body RefreshRequest true "Refresh token"
// @Success 200 {object} map[string]interface{}
// @Failure 401 {object} map[string]interface{}
// @Router /auth/refresh [post]
func (h *AuthHandler) Refresh(c fiber.Ctx) error {
	var req RefreshRequest
	if err := c.Bind().Body(&req); err != nil || req.RefreshToken == "" || req.DeviceID == "" {
		return c.Status(fiber.StatusBadRequest).JSON(
			utils.ErrorResponse("refresh_token and device_id are required"),
		)
	}

	tokenHash := hashRefreshToken(req.RefreshToken, h.cfg.RefreshTokenSecret)
	rt, exists, err := h.store.FindRefreshTokenByHash(tokenHash)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(
			utils.ErrorResponse("Internal server error"),
		)
	}
	if !exists {
		return c.Status(fiber.StatusUnauthorized).JSON(
			utils.ErrorResponse("Invalid or expired refresh token"),
		)
	}

	if rt.Revoked {
		_ = h.store.RevokeAllUserTokens(rt.UserID)
		return c.Status(fiber.StatusUnauthorized).JSON(
			utils.ErrorResponse("Refresh token reuse detected. All sessions revoked."),
		)
	}

	if rt.IsExpired() {
		return c.Status(fiber.StatusUnauthorized).JSON(
			utils.ErrorResponse("Invalid or expired refresh token"),
		)
	}

	if rt.DeviceID != req.DeviceID {
		_ = h.store.RevokeAllUserTokens(rt.UserID)
		return c.Status(fiber.StatusUnauthorized).JSON(
			utils.ErrorResponse("Invalid device for refresh token"),
		)
	}

	user, exists := h.store.FindUserByID(rt.UserID)
	if !exists {
		return c.Status(fiber.StatusUnauthorized).JSON(
			utils.ErrorResponse("User not found"),
		)
	}

	// Token Rotation — revoke เก่า แล้วออกใหม่
	if err := h.store.RevokeRefreshTokenByHash(tokenHash); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(
			utils.ErrorResponse("Internal server error"),
		)
	}

	pair, err := IssueTokenPair(user, h.store, h.cfg, req.DeviceID)
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
// POST /auth/logout
// ─────────────────────────────────────────────────────────────────────────────

type LogoutRequest struct {
	RefreshToken string `json:"refresh_token"`
	DeviceID     string `json:"device_id"`
}

// @Summary Logout user
// @Description Logout โดย revoke refresh token
// @Tags Authentication
// @Accept json
// @Produce json
// @Param request body LogoutRequest true "Refresh token"
// @Success 200 {object} map[string]interface{}
// @Router /auth/logout [post]
func (h *AuthHandler) Logout(c fiber.Ctx) error {
	var req LogoutRequest
	if err := c.Bind().Body(&req); err != nil || req.RefreshToken == "" {
		return c.Status(fiber.StatusBadRequest).JSON(
			utils.ErrorResponse("refresh_token is required"),
		)
	}

	if req.DeviceID == "" {
		return c.Status(fiber.StatusBadRequest).JSON(
			utils.ErrorResponse("device_id is required"),
		)
	}

	tokenHash := hashRefreshToken(req.RefreshToken, h.cfg.RefreshTokenSecret)
	if err := h.store.RevokeRefreshTokenByHash(tokenHash); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(
			utils.ErrorResponse("Internal server error"),
		)
	}

	return c.JSON(utils.SuccessResponse("Logged out successfully", nil))
}

// ─────────────────────────────────────────────────────────────────────────────
// POST /auth/logout-all   [Protected]
// kick ออกทุกอุปกรณ์พร้อมกัน
// ─────────────────────────────────────────────────────────────────────────────

// @Summary Logout all sessions
// @Description Logout จากทุกอุปกรณ์
// @Tags Authentication
// @Security BearerAuth
// @Success 200 {object} map[string]interface{}
// @Router /auth/logout-all [post]
func (h *AuthHandler) LogoutAll(c fiber.Ctx) error {
	claims := c.Locals("claims").(*AccessClaims)
	h.store.RevokeAllUserTokens(claims.UserID)
	return c.JSON(utils.SuccessResponse("All sessions have been terminated", nil))
}

// ─────────────────────────────────────────────────────────────────────────────
// GET /auth/me   [Protected]
// ─────────────────────────────────────────────────────────────────────────────

// @Summary Get current user
// @Description ดูข้อมูล user ปัจจุบัน
// @Tags Authentication
// @Security BearerAuth
// @Produce json
// @Success 200 {object} map[string]interface{}
// @Router /auth/me [get]
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
