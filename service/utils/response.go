package utils

import "github.com/gofiber/fiber/v3"

// ErrorResponse สร้าง error response มาตรฐาน
func ErrorResponse(msg string) fiber.Map {
	return fiber.Map{
		"success": false,
		"error":   msg,
	}
}

// SuccessResponse สร้าง success response มาตรฐาน
func SuccessResponse(msg string, data interface{}) fiber.Map {
	return fiber.Map{
		"success": true,
		"message": msg,
		"data":    data,
	}
}
