package models

import (
	"sync"
	"time"
)

// Store คือ in-memory database thread-safe
type Store struct {
	mu sync.RWMutex

	users         map[uint]*User
	usersByName   map[string]uint // index: username → id
	usersByEmail  map[string]uint // index: email    → id
	refreshTokens map[string]*RefreshToken

	nextID uint
}

// NewStore สร้าง store ใหม่
func NewStore() *Store {
	return &Store{
		users:         make(map[uint]*User),
		usersByName:   make(map[string]uint),
		usersByEmail:  make(map[string]uint),
		refreshTokens: make(map[string]*RefreshToken),
		nextID:        1,
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// User Methods
// ─────────────────────────────────────────────────────────────────────────────

func (s *Store) CreateUser(u *User) *User {
	s.mu.Lock()
	defer s.mu.Unlock()

	u.ID = s.nextID
	u.CreatedAt = time.Now()
	u.UpdatedAt = time.Now()

	s.users[u.ID] = u
	s.usersByName[u.Username] = u.ID
	s.usersByEmail[u.Email] = u.ID
	s.nextID++

	return u
}

func (s *Store) FindUserByID(id uint) (*User, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	u, ok := s.users[id]
	return u, ok
}

func (s *Store) FindUserByUsername(username string) (*User, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	id, ok := s.usersByName[username]
	if !ok {
		return nil, false
	}
	return s.users[id], true
}

func (s *Store) FindUserByEmail(email string) (*User, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	id, ok := s.usersByEmail[email]
	if !ok {
		return nil, false
	}
	return s.users[id], true
}

func (s *Store) ExistsUsername(username string) bool {
	s.mu.RLock()
	defer s.mu.RUnlock()
	_, ok := s.usersByName[username]
	return ok
}

func (s *Store) ExistsEmail(email string) bool {
	s.mu.RLock()
	defer s.mu.RUnlock()
	_, ok := s.usersByEmail[email]
	return ok
}

// ─────────────────────────────────────────────────────────────────────────────
// RefreshToken Methods
// ─────────────────────────────────────────────────────────────────────────────

func (s *Store) SaveRefreshToken(rt *RefreshToken) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.refreshTokens[rt.Token] = rt
}

func (s *Store) FindRefreshToken(token string) (*RefreshToken, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	rt, ok := s.refreshTokens[token]
	return rt, ok
}

func (s *Store) RevokeRefreshToken(token string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if rt, ok := s.refreshTokens[token]; ok {
		rt.Revoked = true
	}
}

// RevokeAllUserTokens revoke ทุก session ของ user — ใช้เมื่อ logout-all หรือเปลี่ยน password
func (s *Store) RevokeAllUserTokens(userID uint) {
	s.mu.Lock()
	defer s.mu.Unlock()
	for _, rt := range s.refreshTokens {
		if rt.UserID == userID {
			rt.Revoked = true
		}
	}
}

// CleanExpiredTokens ลบ token ที่หมดอายุแล้ว — เรียกจาก background goroutine
func (s *Store) CleanExpiredTokens() {
	s.mu.Lock()
	defer s.mu.Unlock()
	for key, rt := range s.refreshTokens {
		if rt.IsExpired() {
			delete(s.refreshTokens, key)
		}
	}
}
