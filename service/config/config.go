package config

import "os"

func GetJWTSecret() string {
    secret := os.Getenv("JWT_SECRET")
    if secret == "" {
        return "my-super-secret-key" // fallback (ควรใช้ .env จริงๆ)
    }
    return secret
}