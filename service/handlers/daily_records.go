package handlers

import (
	"daily-record/config"
	"daily-record/models"
	"time"

	"github.com/gofiber/fiber/v3"
)

type CreateDailyRecordRequest struct {
	IconID         uint     `json:"icon_id"`
	StartTime      string   `json:"start_time"`
	EndTime        string   `json:"end_time"`
	RepeatType     uint     `json:"repeat_type"`
	Important      bool     `json:"important"`
	ActivityHeader string   `json:"activity_header"`
	ActivityDetail string   `json:"activity_detail"`
	Dates          []string `json:"dates"` // ใช้ตอน repeat_type = 1
}
type DailyRecordHandler struct {
	store *models.Store
	cfg   *config.Config
}

func NewDailyRecordHandler(store *models.Store, cfg *config.Config) *DailyRecordHandler {
	return &DailyRecordHandler{store: store, cfg: cfg}
}

// @Summary Create Daily-Record
// @Description Create a new daily record
// @Tags Daily Records
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param request body CreateDailyRecordRequest true "Daily record details"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]interface{}
// @Router /daily-records [post]
func (h *DailyRecordHandler) CreateDailyRecord(c fiber.Ctx) error {
	var req CreateDailyRecordRequest

	if err := c.Bind().Body(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid request"})
	}

	// 🔥 เอา user จาก token
	claims := c.Locals("claims").(*AccessClaims)

	// parse time
	startTime, err := time.Parse("15:04", req.StartTime)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid start_time format, use HH:mm"})
	}
	endTime, err := time.Parse("15:04", req.EndTime)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid end_time format, use HH:mm"})
	}

	record := models.DailyRecord{
		UserID:         claims.UserID, // 🔥 ไม่ใช้จาก request
		IconID:         req.IconID,
		StartTime:      startTime,
		EndTime:        endTime,
		RepeatType:     req.RepeatType,
		Important:      req.Important,
		ActivityHeader: req.ActivityHeader,
		ActivityDetail: req.ActivityDetail,
		CreatedAt:      time.Now(),
	}

	// save main record
	recordID, err := h.store.CreateDailyRecord(&record)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}

	// 🔥 ถ้าเลือกวัน
	if req.RepeatType == 1 {
		for _, d := range req.Dates {
			date, err := time.Parse("2006-01-02", d)
			if err != nil {
				return c.Status(400).JSON(fiber.Map{"error": "invalid date format, use YYYY-MM-DD"})
			}

			err = h.store.CreateDailyRecordDay(&models.DailyRecordDay{
				RecordID:   recordID,
				RecordDate: date,
				CreatedAt:  time.Now(),
			})
			if err != nil {
				return c.Status(500).JSON(fiber.Map{"error": err.Error()})
			}
		}
	}

	return c.JSON(fiber.Map{
		"message": "created success",
	})
}
