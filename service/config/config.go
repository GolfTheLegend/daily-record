package config

import (
	"os"
	"strings"
	"time"
)

type Config struct {
	Environment        string
	AccessTokenSecret  string
	RefreshTokenSecret string
	AccessTokenExpiry  time.Duration
	RefreshTokenExpiry time.Duration
	RateLimitMax       int
	RateLimitWindow    time.Duration
	Port               string
}

func Load() *Config {
	cfg := &Config{
		Environment:        strings.ToLower(getEnv("ENV", "dev")),
		AccessTokenSecret:  mustGetEnv("ACCESS_TOKEN_SECRET"),
		RefreshTokenSecret: mustGetEnv("REFRESH_TOKEN_SECRET"),
		AccessTokenExpiry:  15 * time.Minute,
		RefreshTokenExpiry: 30 * 24 * time.Hour,
		RateLimitMax:       100,
		RateLimitWindow:    1 * time.Minute,
		Port:               getEnv("PORT", "8080"),
	}

	if len(cfg.AccessTokenSecret) < 32 {
		panic("ACCESS_TOKEN_SECRET must be at least 32 characters")
	}
	if len(cfg.RefreshTokenSecret) < 32 {
		panic("REFRESH_TOKEN_SECRET must be at least 32 characters")
	}

	if cfg.IsProd() {
		if os.Getenv("PORT") == "" {
			panic("PORT must be set in production")
		}
	}

	return cfg
}

func (c *Config) IsProd() bool {
	return c.Environment == "prod"
}

func (c *Config) IsDev() bool {
	return c.Environment == "dev"
}

func mustGetEnv(key string) string {
	v := os.Getenv(key)
	if v == "" {
		panic("Missing required environment variable: " + key)
	}
	return v
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
