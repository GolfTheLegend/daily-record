package models

import (
	"database/sql"
	"log"
)

// TokenStore แบ่ง responsibility สำหรับ refresh token operations
type TokenStore struct {
	db *sql.DB
}

// NewTokenStore สร้าง TokenStore ที่เชื่อมต่อกับ database
func NewTokenStore(db *sql.DB) *TokenStore {
	return &TokenStore{
		db: db,
	}
}

func (s *TokenStore) SaveRefreshToken(rt *RefreshToken) {
	query := `
		INSERT INTO refresh_tokens (token, user_id, expires_at, created_at, revoked)
		VALUES ($1, $2, $3, $4, $5)
	`
	_, err := s.db.Exec(query, rt.Token, rt.UserID, rt.ExpiresAt, rt.CreatedAt, rt.Revoked)
	if err != nil {
		log.Printf("Error saving refresh token: %v", err)
	}
}

func (s *TokenStore) FindRefreshToken(token string) (*RefreshToken, bool) {
	query := `
		SELECT token, user_id, expires_at, created_at, revoked
		FROM refresh_tokens
		WHERE token = $1
	`
	rt := &RefreshToken{}
	err := s.db.QueryRow(query, token).Scan(
		&rt.Token, &rt.UserID, &rt.ExpiresAt, &rt.CreatedAt, &rt.Revoked,
	)
	if err == sql.ErrNoRows {
		return nil, false
	}
	if err != nil {
		log.Printf("Error finding refresh token: %v", err)
		return nil, false
	}
	return rt, true
}

func (s *TokenStore) RevokeRefreshToken(token string) {
	query := `
		UPDATE refresh_tokens
		SET revoked = true
		WHERE token = $1
	`
	_, err := s.db.Exec(query, token)
	if err != nil {
		log.Printf("Error revoking refresh token: %v", err)
	}
}

// RevokeAllUserTokens revoke ทุก session ของ user — ใช้เมื่อ logout-all หรือเปลี่ยน password
func (s *TokenStore) RevokeAllUserTokens(userID uint) {
	query := `
		UPDATE refresh_tokens
		SET revoked = true
		WHERE user_id = $1
	`
	_, err := s.db.Exec(query, userID)
	if err != nil {
		log.Printf("Error revoking all user tokens: %v", err)
	}
}

// CleanExpiredTokens ลบ token ที่หมดอายุแล้ว — เรียกจาก background goroutine
func (s *TokenStore) CleanExpiredTokens() {
	query := `
		DELETE FROM refresh_tokens
		WHERE expires_at < NOW() OR revoked = true
	`
	result, err := s.db.Exec(query)
	if err != nil {
		log.Printf("Error cleaning expired tokens: %v", err)
		return
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		log.Printf("Error getting rows affected: %v", err)
	}
	if rowsAffected > 0 {
		log.Printf("[Cleanup] %d expired tokens removed", rowsAffected)
	}
}
