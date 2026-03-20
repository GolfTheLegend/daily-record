package handlers

import (
	"daily-record/config"
	"daily-record/models"
	"strconv"
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
// @Success 200 {object} object{success=bool,data=[]models.DailyRecordResponse}
// @Failure 400 {object} object{success=bool,error=string}
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

	var days []*models.DailyRecordDay

	if req.RepeatType == 1 {
		for _, d := range req.Dates {
			date, err := time.Parse("2006-01-02", d)
			if err != nil {
				return c.Status(400).JSON(fiber.Map{"error": "invalid date format"})
			}

			days = append(days, &models.DailyRecordDay{
				RecordDate: date,
				CreatedAt:  time.Now(),
			})
		}
	}

	// 🔥 ใช้ transaction ตัวเดียวจบ
	recordID, err := h.store.CreateDailyRecord(&record, days)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(201).JSON(fiber.Map{
		"message":   "created success",
		"record_id": recordID,
	})
}

// @Summary Get Daily Records
// @Description Get all daily records for a user with optional filters
// @Tags Daily Records
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param date_from       query string  false "Filter from date (YYYY-MM-DD)"
// @Param date_to         query string  false "Filter to date (YYYY-MM-DD)"
// @Param repeat_type     query integer false "Filter by repeat type"
// @Param important       query boolean false "Filter by important flag"
// @Param activity_header query string  false "Search by activity header (partial match)"
// @Param limit           query integer false "Number of records per page (default: 20, max: 100)"
// @Param offset          query integer false "Number of records to skip (default: 0)"
// @Success 200 {object} object{success=bool,data=[]models.DailyRecordResponse}
// @Failure 400 {object} object{success=bool,error=string}
// @Failure 500 {object} object{success=bool,error=string}
// @Router /daily-records [get]
func (h *DailyRecordHandler) GetDailyRecords(c fiber.Ctx) error {
	const (
		defaultLimit = 20
		maxLimit     = 100
	)
	claims := c.Locals("claims").(*AccessClaims)

	filter := models.DailyRecordFilter{
		Limit: defaultLimit,
	}

	if v := c.Query("date_from"); v != "" {
		t, err := time.Parse("2006-01-02", v)
		if err != nil {
			return c.Status(400).JSON(fiber.Map{"success": false, "error": "invalid date_from, expected YYYY-MM-DD"})
		}
		filter.DateFrom = &t
	}
	if v := c.Query("date_to"); v != "" {
		t, err := time.Parse("2006-01-02", v)
		if err != nil {
			return c.Status(400).JSON(fiber.Map{"success": false, "error": "invalid date_to, expected YYYY-MM-DD"})
		}
		filter.DateTo = &t
	}
	if v := c.Query("repeat_type"); v != "" {
		parsed, err := strconv.ParseUint(v, 10, 64)
		if err != nil {
			return c.Status(400).JSON(fiber.Map{"success": false, "error": "invalid repeat_type"})
		}
		u := uint(parsed)
		filter.RepeatType = &u
	}
	if v := c.Query("important"); v != "" {
		parsed, err := strconv.ParseBool(v)
		if err != nil {
			return c.Status(400).JSON(fiber.Map{"success": false, "error": "invalid important"})
		}
		filter.Important = &parsed
	}
	if v := c.Query("activity_header"); v != "" {
		filter.ActivityHeader = &v
	}
	if v := c.Query("limit"); v != "" {
		parsed, err := strconv.Atoi(v)
		if err != nil || parsed < 1 {
			return c.Status(400).JSON(fiber.Map{"success": false, "error": "invalid limit"})
		}
		if parsed > maxLimit {
			parsed = maxLimit
		}
		filter.Limit = parsed
	}
	if v := c.Query("offset"); v != "" {
		parsed, err := strconv.Atoi(v)
		if err != nil || parsed < 0 {
			return c.Status(400).JSON(fiber.Map{"success": false, "error": "invalid offset"})
		}
		filter.Offset = parsed
	}

	records, err := h.store.GetDailyRecordsByUserID(claims.UserID, filter)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"success": false, "error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "data": records})
}
