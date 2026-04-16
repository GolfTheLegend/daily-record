package handlers

import (
	"daily-record/config"
	"daily-record/models"
	"database/sql"
	"errors"
	"fmt"
	"strconv"
	"strings"
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

// @Summary Get Status Daily Records
// @Description Get status of daily records for a user filtered by date, month, or year
// @Tags Daily Records
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param day   query integer false "Filter by day (1-31)"
// @Param month query integer false "Filter by month (1-12)"
// @Param year  query integer false "Filter by year (e.g. 2025)"
// @Success 200 {object} object{success=bool,data=[]models.DailyRecordStatusResponse}
// @Failure 400 {object} object{success=bool,error=string}
// @Failure 500 {object} object{success=bool,error=string}
// @Router /daily-records/status [get]
func (h *DailyRecordHandler) GetStatusDailyRecords(c fiber.Ctx) error {
	claims := c.Locals("claims").(*AccessClaims)

	filter := models.DailyRecordStatusFilter{}

	if v := c.Query("day"); v != "" {
		parsed, err := strconv.Atoi(v)
		if err != nil || parsed < 1 || parsed > 31 {
			return c.Status(400).JSON(fiber.Map{"success": false, "error": "invalid day, expected 1-31"})
		}
		filter.Day = parsed
	}
	if v := c.Query("month"); v != "" {
		parsed, err := strconv.Atoi(v)
		if err != nil || parsed < 1 || parsed > 12 {
			return c.Status(400).JSON(fiber.Map{"success": false, "error": "invalid month, expected 1-12"})
		}
		filter.Month = parsed
	}
	if v := c.Query("year"); v != "" {
		parsed, err := strconv.Atoi(v)
		if err != nil || parsed < 1 {
			return c.Status(400).JSON(fiber.Map{"success": false, "error": "invalid year"})
		}
		filter.Year = parsed
	}

	records, err := h.store.GetStatusDailyRecordsByUserID(claims.UserID, filter)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"success": false, "error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "data": records})
}

// @Summary Get Daily Record by ID
// @Description Get a single daily record by ID
// @Tags Daily Records
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param id path integer true "Record ID"
// @Success 200 {object} models.DailyRecordDetailResponse
// @Failure 404 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /daily-records/{id} [get]
func (h *DailyRecordHandler) GetDailyRecordByID(c fiber.Ctx) error {
	claims := c.Locals("claims").(*AccessClaims)

	recordID, err := strconv.ParseUint(c.Params("id"), 10, 64)
	if err != nil {
		return c.Status(400).JSON(models.ErrorResponse{Success: false, Error: "invalid record id"})
	}

	record, err := h.store.GetDailyRecordByID(claims.UserID, uint(recordID))
	if errors.Is(err, sql.ErrNoRows) {
		return c.Status(404).JSON(models.ErrorResponse{Success: false, Error: "record not found"})
	}
	if err != nil {
		return c.Status(500).JSON(models.ErrorResponse{Success: false, Error: err.Error()})
	}

	return c.JSON(models.DailyRecordDetailResponse{Success: true, Data: record})
}

// @Summary Update Daily Record
// @Description Update an existing daily record and its dates by ID
// @Tags Daily Records
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param id      path integer                        true "Record ID"
// @Param request body models.UpdateDailyRecordRequest true "Updated record details"
// @Success 200 {object} models.ErrorResponse
// @Failure 400 {object} models.ErrorResponse
// @Failure 404 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /daily-records/{id} [put]
func (h *DailyRecordHandler) UpdateDailyRecord(c fiber.Ctx) error {
	claims := c.Locals("claims").(*AccessClaims)

	recordID, err := strconv.ParseUint(c.Params("id"), 10, 64)
	if err != nil {
		return c.Status(400).JSON(models.ErrorResponse{Success: false, Error: "invalid record id"})
	}

	var req models.UpdateDailyRecordRequest
	if err := c.Bind().JSON(&req); err != nil {
		return c.Status(400).JSON(models.ErrorResponse{Success: false, Error: "invalid request body"})
	}

	startTime, err := time.Parse("15:04", req.StartTime)
	if err != nil {
		return c.Status(400).JSON(models.ErrorResponse{Success: false, Error: "invalid start_time, expected HH:MM"})
	}

	endTime, err := time.Parse("15:04", req.EndTime)
	if err != nil {
		return c.Status(400).JSON(models.ErrorResponse{Success: false, Error: "invalid end_time, expected HH:MM"})
	}

	dates := make([]time.Time, 0, len(req.Dates))
	for _, d := range req.Dates {
		parsed, err := time.Parse("2006-01-02", d)
		if err != nil {
			return c.Status(400).JSON(models.ErrorResponse{Success: false, Error: fmt.Sprintf("invalid date %q, expected YYYY-MM-DD", d)})
		}
		dates = append(dates, parsed)
	}

	record := &models.DailyRecord{
		ID:             uint(recordID),
		IconID:         req.IconID,
		StartTime:      startTime,
		EndTime:        endTime,
		RepeatType:     req.RepeatType,
		Important:      req.Important,
		ActivityHeader: req.ActivityHeader,
		ActivityDetail: req.ActivityDetail,
	}

	err = h.store.UpdateDailyRecord(record, dates, claims.UserID)
	if errors.Is(err, sql.ErrNoRows) {
		return c.Status(404).JSON(models.ErrorResponse{Success: false, Error: "record not found"})
	}
	if err != nil {
		return c.Status(500).JSON(models.ErrorResponse{Success: false, Error: err.Error()})
	}

	return c.JSON(models.ErrorResponse{Success: true})
}

// @Summary Delete Daily Record
// @Description Delete a daily record by ID (related days are removed automatically)
// @Tags Daily Records
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param id path integer true "Record ID"
// @Success 200 {object} models.ErrorResponse
// @Failure 400 {object} models.ErrorResponse
// @Failure 404 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /daily-records/{id} [delete]
func (h *DailyRecordHandler) DeleteDailyRecord(c fiber.Ctx) error {
	claims := c.Locals("claims").(*AccessClaims)

	recordID, err := strconv.ParseUint(c.Params("id"), 10, 64)
	if err != nil {
		return c.Status(400).JSON(models.ErrorResponse{Success: false, Error: "invalid record id"})
	}

	err = h.store.DeleteDailyRecord(uint(recordID), claims.UserID)
	if errors.Is(err, sql.ErrNoRows) {
		return c.Status(404).JSON(models.ErrorResponse{Success: false, Error: "record not found"})
	}
	if err != nil {
		return c.Status(500).JSON(models.ErrorResponse{Success: false, Error: err.Error()})
	}

	return c.JSON(models.ErrorResponse{Success: true})
}

// @Summary Create Daily Check List
// @Description Create a new daily check list
// @Tags Daily Check Lists
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param id path int true "Daily Record ID"
// @Param request body models.CreateDailyCheckListRequest true "Daily check list details"
// @Success 201 {object} object{success=bool,data=models.DailyCheckList}
// @Failure 400 {object} object{success=bool,error=string}
// @Failure 500 {object} object{success=bool,error=string}
// @Router /daily-records/check-list/{id} [post]
func (h *DailyRecordHandler) CreateDailyCheckList(c fiber.Ctx) error {
	var req models.CreateDailyCheckListRequest

	claims, ok := c.Locals("claims").(*AccessClaims)
	if !ok {
		return c.Status(401).JSON(models.ErrorResponse{
			Success: false,
			Error:   "unauthorized",
		})
	}

	recordID, err := strconv.ParseUint(c.Params("id"), 10, 64)
	if err != nil {
		return c.Status(400).JSON(models.ErrorResponse{
			Success: false,
			Error:   "invalid record id",
		})
	}

	if err := c.Bind().JSON(&req); err != nil {
		return c.Status(400).JSON(models.ErrorResponse{
			Success: false,
			Error:   "invalid request",
		})
	}

	dayCheck, err := time.Parse("2006-01-02", req.DayCheck)
	if err != nil {
		return c.Status(400).JSON(models.ErrorResponse{
			Success: false,
			Error:   "invalid day_check format, use YYYY-MM-DD",
		})
	}

	checkStatus := false
	if req.CheckStatus != nil {
		checkStatus = *req.CheckStatus
	}

	checkList := models.DailyCheckList{
		MainRecordID: uint(recordID),
		DayCheck:     dayCheck,
		CheckStatus:  checkStatus,
		CreatedAt:    time.Now(),
	}

	err = h.store.CreateDailyCheckList(&checkList, claims.UserID)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return c.Status(403).JSON(models.ErrorResponse{
				Success: false,
				Error:   err.Error(),
			})
		}

		return c.Status(500).JSON(models.ErrorResponse{
			Success: false,
			Error:   err.Error(),
		})
	}

	return c.Status(201).JSON(fiber.Map{
		"success": true,
		"data":    checkList,
	})
}
