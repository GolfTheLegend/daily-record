package models

import (
	"database/sql"
	"log"
)

// UserStore แบ่ง responsibility สำหรับ user operations
type UserStore struct {
	db *sql.DB
}

// NewUserStore สร้าง UserStore ที่เชื่อมต่อกับ database
func NewUserStore(db *sql.DB) *UserStore {
	return &UserStore{
		db: db,
	}
}

func (s *UserStore) CreateUser(u *User) *User {
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

func (s *UserStore) FindUserByID(id uint) (*User, bool) {
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

func (s *UserStore) FindUserByUsername(username string) (*User, bool) {
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

func (s *UserStore) FindUserByEmail(email string) (*User, bool) {
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

func (s *UserStore) ExistsUsername(username string) bool {
	query := `SELECT EXISTS(SELECT 1 FROM users WHERE username = $1)`
	var exists bool
	err := s.db.QueryRow(query, username).Scan(&exists)
	if err != nil {
		log.Printf("Error checking username exists: %v", err)
		return false
	}
	return exists
}

func (s *UserStore) ExistsEmail(email string) bool {
	query := `SELECT EXISTS(SELECT 1 FROM users WHERE email = $1)`
	var exists bool
	err := s.db.QueryRow(query, email).Scan(&exists)
	if err != nil {
		log.Printf("Error checking email exists: %v", err)
		return false
	}
	return exists
}
