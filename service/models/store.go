package models

import (
	"database/sql"
)

// Store เป็น composite store ที่รวม UserStore, TokenStore, DailyRecordStore
// ใช้ได้เพื่อ backward compatibility และ convenience
type Store struct {
	*UserStore
	*TokenStore
	*DailyRecordStore
}

// NewStore สร้าง Store ที่เชื่อมต่อกับ database
// ส่วนประกอบ: UserStore, TokenStore, DailyRecordStore
func NewStore(db *sql.DB) *Store {
	return &Store{
		UserStore:        NewUserStore(db),
		TokenStore:       NewTokenStore(db),
		DailyRecordStore: NewDailyRecordStore(db),
	}
}
