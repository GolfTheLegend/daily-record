package config

import (
	"database/sql"
	"log"
	"net/http"
	"os"

	_ "github.com/lib/pq"
)

// สำหรับเก็บ config การเชื่อมต่อ Supaqbase
type SupabaseClient struct {
	URL    string
	APIKey string
	HTTP   *http.Client
	DB     *sql.DB
}

// สร้าง client ใหม่จาก env
func NewSupabaseClient() *SupabaseClient {
	dbURL := os.Getenv("DATABASE_URL")
	db, err := sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Test connection
	if err := db.Ping(); err != nil {
		log.Fatal("Failed to ping database:", err)
	}

	return &SupabaseClient{
		URL:    os.Getenv("SUPABASE_URL"),
		APIKey: os.Getenv("SUPABASE_API_KEY"),
		HTTP:   &http.Client{},
		DB:     db,
	}
}
