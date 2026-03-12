package config

import (
	"net/http"
	"os"
)

// สำหรับเก็บ config การเชื่อมต่อ Supaqbase
type SupabaseClient struct {
	URL    string
	APIKey string
	HTTP   *http.Client
}

// สร้าง client ใหม่จาก env
func NewSupabaseClient() *SupabaseClient {
	return &SupabaseClient{
		URL:    os.Getenv("SUPABASE_URL"),
		APIKey: os.Getenv("SUPABASE_API_KEY"),
		HTTP:   &http.Client{},
	}
}
