package config

import (
	"os"
	"time"
)

type Config struct {
	AccessTokenSecret  string
	RefreshTokenSecret string
	AccessTokenExpiry  time.Duration
	RefreshTokenExpiry time.Duration
	RateLimitMax       int
	RateLimitWindow    time.Duration
	Port               string
}

func Load() *Config {
	return &Config{
		AccessTokenSecret:  getEnv("ACCESS_TOKEN_SECRET", "access-secret-change-in-production-min-32-chars"),
		RefreshTokenSecret: getEnv("REFRESH_TOKEN_SECRET", "refresh-secret-change-in-production-min-32-chars"),
		AccessTokenExpiry:  15 * time.Minute,
		RefreshTokenExpiry: 30 * 24 * time.Hour,
		RateLimitMax:       5,
		RateLimitWindow:    15 * time.Minute,
		Port:               getEnv("PORT", "8080"),
	}
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
