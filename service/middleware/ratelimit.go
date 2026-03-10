package middleware

import (
	"fmt"
	"sync"
	"time"

	"daily-record/utils"

	"github.com/gofiber/fiber/v3"
)

// bucket เก็บสถานะการ request ของแต่ละ IP
type bucket struct {
	count   int
	resetAt time.Time
}

// RateLimiter ป้องกัน brute force ด้วยการจำกัดจำนวน request ต่อ IP
type RateLimiter struct {
	mu      sync.Mutex
	buckets map[string]*bucket
	max     int
	window  time.Duration
}

// NewLoginRateLimiter สร้าง rate limiter สำหรับ login endpoint
func NewLoginRateLimiter(max int, window time.Duration) *RateLimiter {
	rl := &RateLimiter{
		buckets: make(map[string]*bucket),
		max:     max,
		window:  window,
	}

	// background cleanup ทุก 5 นาที เพื่อไม่ให้ memory leak
	go func() {
		ticker := time.NewTicker(5 * time.Minute)
		defer ticker.Stop()
		for range ticker.C {
			rl.cleanup()
		}
	}()

	return rl
}

// Middleware return fiber.Handler ที่ใช้เป็น middleware ได้
func (rl *RateLimiter) Middleware() fiber.Handler {
	return func(c fiber.Ctx) error {
		ip := c.IP()

		rl.mu.Lock()
		b, exists := rl.buckets[ip]
		if !exists || time.Now().After(b.resetAt) {
			// สร้าง bucket ใหม่หรือ reset ถ้าหมด window
			b = &bucket{resetAt: time.Now().Add(rl.window)}
			rl.buckets[ip] = b
		}
		b.count++
		count := b.count
		resetAt := b.resetAt
		remaining := rl.max - count
		rl.mu.Unlock()

		// ตั้ง rate limit headers (มาตรฐาน RFC 6585)
		c.Set("X-RateLimit-Limit", fmt.Sprintf("%d", rl.max))
		c.Set("X-RateLimit-Remaining", fmt.Sprintf("%d", max(remaining, 0)))
		c.Set("X-RateLimit-Reset", fmt.Sprintf("%d", resetAt.Unix()))

		if count > rl.max {
			retryAfter := int(time.Until(resetAt).Seconds())
			c.Set("Retry-After", fmt.Sprintf("%d", retryAfter))
			return c.Status(fiber.StatusTooManyRequests).JSON(
				utils.ErrorResponse(
					fmt.Sprintf("Too many login attempts. Try again in %d seconds.", retryAfter),
				),
			)
		}

		return c.Next()
	}
}

func (rl *RateLimiter) cleanup() {
	rl.mu.Lock()
	defer rl.mu.Unlock()
	for ip, b := range rl.buckets {
		if time.Now().After(b.resetAt) {
			delete(rl.buckets, ip)
		}
	}
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}
