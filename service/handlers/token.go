package handlers

import (
	"crypto/rand"
	"encoding/hex"
	"time"

	"daily-record/config"
	"daily-record/models"

	"github.com/golang-jwt/jwt/v5"
)

// TokenPair — คู่ token ที่ส่งกลับให้ client
type TokenPair struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	TokenType    string `json:"token_type"`
	ExpiresIn    int    `json:"expires_in"` // วินาที (ของ access token)
}

// AccessClaims — payload ของ JWT
type AccessClaims struct {
	UserID   uint   `json:"user_id"`
	Username string `json:"username"`
	Email    string `json:"email"`
	Role     string `json:"role"`
	jwt.RegisteredClaims
}

// generateAccessToken สร้าง JWT HS256 อายุสั้น
func generateAccessToken(user *models.User, cfg *config.Config) (string, error) {
	claims := AccessClaims{
		UserID:   user.ID,
		Username: user.Username,
		Email:    user.Email,
		Role:     user.Role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(cfg.AccessTokenExpiry)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
			Issuer:    "jwt-auth-service",
			Subject:   user.Username,
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(cfg.AccessTokenSecret))
}

// generateRefreshToken สร้าง opaque random string (ไม่ใช่ JWT)
// การใช้ opaque token แทน JWT สำหรับ refresh ทำให้ revoke ได้ทันที
func generateRefreshToken() (string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return hex.EncodeToString(b), nil
}

// IssueTokenPair ออก token คู่และบันทึก refresh token ลง store
func IssueTokenPair(user *models.User, store *models.Store, cfg *config.Config) (*TokenPair, error) {
	accessToken, err := generateAccessToken(user, cfg)
	if err != nil {
		return nil, err
	}

	refreshTokenStr, err := generateRefreshToken()
	if err != nil {
		return nil, err
	}

	store.SaveRefreshToken(&models.RefreshToken{
		Token:     refreshTokenStr,
		UserID:    user.ID,
		ExpiresAt: time.Now().Add(cfg.RefreshTokenExpiry),
		CreatedAt: time.Now(),
		Revoked:   false,
	})

	return &TokenPair{
		AccessToken:  accessToken,
		RefreshToken: refreshTokenStr,
		TokenType:    "Bearer",
		ExpiresIn:    int(cfg.AccessTokenExpiry.Seconds()),
	}, nil
}

// ParseAccessToken ตรวจสอบ JWT และ return claims
func ParseAccessToken(tokenStr string, cfg *config.Config) (*AccessClaims, error) {
	token, err := jwt.ParseWithClaims(
		tokenStr,
		&AccessClaims{},
		func(t *jwt.Token) (interface{}, error) {
			if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, jwt.ErrSignatureInvalid
			}
			return []byte(cfg.AccessTokenSecret), nil
		},
		jwt.WithExpirationRequired(),
		jwt.WithIssuedAt(),
	)
	if err != nil {
		return nil, err
	}

	claims, ok := token.Claims.(*AccessClaims)
	if !ok || !token.Valid {
		return nil, jwt.ErrTokenInvalidClaims
	}
	return claims, nil
}
