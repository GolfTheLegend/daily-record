package models

import "time"

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
