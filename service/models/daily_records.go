package models

import (
	"time"
)

type DailyRecord struct {
	ID             uint      `json:"id"`              // รหัสของกิจกรรม (Primary Key)
	UserID         uint      `json:"user_id"`         // รหัสผู้ใช้ที่เป็นเจ้าของกิจกรรม (Foreign Key -> users.id)
	IconID         uint      `json:"icon_id"`         // รหัสไอคอนที่เลือกใช้แสดงกิจกรรม (Foreign Key -> icons.id)
	StartTime      time.Time `json:"start_time"`      // เวลาเริ่มต้นของกิจกรรม (เช่น 08:00)
	EndTime        time.Time `json:"end_time"`        // เวลาสิ้นสุดของกิจกรรม (เช่น 09:00)
	RepeatType     uint      `json:"repeat_type"`     // ประเภทการทำซ้ำของกิจกรรม // 0 = ทำทุกวัน (Everyday) // 1 = เลือกวันเอง (Custom Days)
	Important      bool      `json:"important"`       // ใช้ระบุว่ากิจกรรมนี้สำคัญหรือไม่
	ActivityHeader string    `json:"activity_header"` // ชื่อกิจกรรม เช่น "ออกกำลังกาย"
	ActivityDetail string    `json:"activity_detail"` // รายละเอียดเพิ่มเติมของกิจกรรม
	CreatedAt      time.Time `json:"created_at"`      // วันที่สร้างข้อมูล
	UpdatedAt      time.Time `json:"updated_at"`      // วันที่แก้ไขล่าสุด
}

type DailyRecordDay struct {
	ID         uint      `json:"id"`          // Primary Key
	RecordID   uint      `json:"record_id"`   // Foreign Key -> daily_records.id
	RecordDate time.Time `json:"record_date"` // วันที่ที่กิจกรรมนี้ต้องทำ เช่น 2026-03-15
	CreatedAt  time.Time `json:"created_at"`  // วันที่สร้างข้อมูล
}

type DailyRecordFilter struct {
	DateFrom       *time.Time
	DateTo         *time.Time
	RepeatType     *uint
	Important      *bool
	ActivityHeader *string
	Limit          int
	Offset         int
}

type UpdateDailyRecordRequest struct {
	IconID         uint     `json:"icon_id"`
	StartTime      string   `json:"start_time"` // "HH:MM"
	EndTime        string   `json:"end_time"`   // "HH:MM"
	RepeatType     uint     `json:"repeat_type"`
	Important      bool     `json:"important"`
	ActivityHeader string   `json:"activity_header"`
	ActivityDetail string   `json:"activity_detail"`
	Dates          []string `json:"dates"` // "YYYY-MM-DD"
}

type DailyRecordResponse struct {
	ID             uint     `json:"id"`
	IconID         uint     `json:"icon_id"`
	StartTime      string   `json:"start_time"`
	EndTime        string   `json:"end_time"`
	RepeatType     uint     `json:"repeat_type"`
	Important      bool     `json:"important"`
	ActivityHeader string   `json:"activity_header"`
	ActivityDetail string   `json:"activity_detail"`
	Dates          []string `json:"dates"`
}

type DailyRecordStatusFilter struct {
	Day   int
	Month int
	Year  int
}

type DailyRecordStatusResponse struct {
	HasRecord bool `json:"has_record"`
	Important bool `json:"important"`
	Day       int  `json:"day"`
	Month     int  `json:"month"`
	Year      int  `json:"year"`
}

type DailyRecordListResponse struct {
	Success bool                   `json:"success"`
	Data    []*DailyRecordResponse `json:"data"`
}

type ErrorResponse struct {
	Success bool   `json:"success"`
	Error   string `json:"error"`
}

type DailyRecordDetailResponse struct {
	Success bool                 `json:"success"`
	Data    *DailyRecordResponse `json:"data"`
}
