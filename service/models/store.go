package models

import (
	"database/sql"
	"log"
)

// Store ใช้ Supabase/PostgreSQL database
type Store struct {
	db *sql.DB
}

// NewStore สร้าง store ที่เชื่อมต่อกับ database
func NewStore(db *sql.DB) *Store {
	return &Store{
		db: db,
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// User Methods
// ─────────────────────────────────────────────────────────────────────────────

func (s *Store) CreateUser(u *User) *User {
	query := `
		INSERT INTO users (username, email, password, role, created_at, updated_at)
		VALUES ($1, $2, $3, $4, NOW(), NOW())
		RETURNING id, created_at, updated_at
	`
	err := s.db.QueryRow(query, u.Username, u.Email, u.Password, u.Role).
		Scan(&u.ID, &u.CreatedAt, &u.UpdatedAt)
	if err != nil {
		log.Printf("Error creating user: %v", err)
		return nil
	}
	return u
}

func (s *Store) FindUserByID(id uint) (*User, bool) {
	query := `
		SELECT id, username, email, password, role, created_at, updated_at
		FROM users
		WHERE id = $1
	`
	user := &User{}
	err := s.db.QueryRow(query, id).Scan(
		&user.ID, &user.Username, &user.Email, &user.Password, &user.Role,
		&user.CreatedAt, &user.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, false
	}
	if err != nil {
		log.Printf("Error finding user by ID: %v", err)
		return nil, false
	}
	return user, true
}

func (s *Store) FindUserByUsername(username string) (*User, bool) {
	query := `
		SELECT id, username, email, password, role, created_at, updated_at
		FROM users
		WHERE username = $1
	`
	user := &User{}
	err := s.db.QueryRow(query, username).Scan(
		&user.ID, &user.Username, &user.Email, &user.Password, &user.Role,
		&user.CreatedAt, &user.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, false
	}
	if err != nil {
		log.Printf("Error finding user by username: %v", err)
		return nil, false
	}
	return user, true
}

func (s *Store) FindUserByEmail(email string) (*User, bool) {
	query := `
		SELECT id, username, email, password, role, created_at, updated_at
		FROM users
		WHERE email = $1
	`
	user := &User{}
	err := s.db.QueryRow(query, email).Scan(
		&user.ID, &user.Username, &user.Email, &user.Password, &user.Role,
		&user.CreatedAt, &user.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, false
	}
	if err != nil {
		log.Printf("Error finding user by email: %v", err)
		return nil, false
	}
	return user, true
}

func (s *Store) ExistsUsername(username string) bool {
	query := `SELECT EXISTS(SELECT 1 FROM users WHERE username = $1)`
	var exists bool
	err := s.db.QueryRow(query, username).Scan(&exists)
	if err != nil {
		log.Printf("Error checking username exists: %v", err)
		return false
	}
	return exists
}

func (s *Store) ExistsEmail(email string) bool {
	query := `SELECT EXISTS(SELECT 1 FROM users WHERE email = $1)`
	var exists bool
	err := s.db.QueryRow(query, email).Scan(&exists)
	if err != nil {
		log.Printf("Error checking email exists: %v", err)
		return false
	}
	return exists
}

// ─────────────────────────────────────────────────────────────────────────────
// RefreshToken Methods
// ─────────────────────────────────────────────────────────────────────────────

func (s *Store) SaveRefreshToken(rt *RefreshToken) {
	query := `
		INSERT INTO refresh_tokens (token, user_id, expires_at, created_at, revoked)
		VALUES ($1, $2, $3, $4, $5)
	`
	_, err := s.db.Exec(query, rt.Token, rt.UserID, rt.ExpiresAt, rt.CreatedAt, rt.Revoked)
	if err != nil {
		log.Printf("Error saving refresh token: %v", err)
	}
}

func (s *Store) FindRefreshToken(token string) (*RefreshToken, bool) {
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

func (s *Store) RevokeRefreshToken(token string) {
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
func (s *Store) RevokeAllUserTokens(userID uint) {
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
func (s *Store) CleanExpiredTokens() {
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
