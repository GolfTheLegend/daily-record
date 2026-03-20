package models

import (
	"database/sql"
	"fmt"
	"log"
	"strings"
	"time"
)

// DailyRecordStore แบ่ง responsibility สำหรับ daily record operations
type DailyRecordStore struct {
	db *sql.DB
}

// NewDailyRecordStore สร้าง DailyRecordStore ที่เชื่อมต่อกับ database
func NewDailyRecordStore(db *sql.DB) *DailyRecordStore {
	return &DailyRecordStore{
		db: db,
	}
}

func (s *DailyRecordStore) CreateDailyRecord(r *DailyRecord, days []*DailyRecordDay) (uint, error) {
	tx, err := s.db.Begin()
	if err != nil {
		return 0, fmt.Errorf("begin transaction: %w", err)
	}
	defer tx.Rollback()

	var recordID uint
	err = tx.QueryRow(`
		INSERT INTO daily_records 
		(user_id, icon_id, start_time, end_time, repeat_type, important, activity_header, activity_detail, created_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
		RETURNING id
	`, r.UserID, r.IconID, r.StartTime, r.EndTime,
		r.RepeatType, r.Important, r.ActivityHeader,
		r.ActivityDetail, r.CreatedAt,
	).Scan(&recordID)
	if err != nil {
		return 0, fmt.Errorf("insert daily record: %w", err)
	}

	for _, d := range days {
		_, err := tx.Exec(`
			INSERT INTO daily_record_days (record_id, record_date, created_at)
			VALUES ($1,$2,$3)
		`, recordID, d.RecordDate, d.CreatedAt)
		if err != nil {
			return 0, fmt.Errorf("insert daily record day: %w", err)
		}
	}

	if err := tx.Commit(); err != nil {
		return 0, fmt.Errorf("commit transaction: %w", err)
	}

	return recordID, nil
}

func (s *DailyRecordStore) GetDailyRecordsByUserID(userID uint, filter DailyRecordFilter) ([]*DailyRecordResponse, error) {
	base := `
		SELECT
			r.id,
			r.icon_id,
			r.start_time,
			r.end_time,
			r.repeat_type,
			r.important,
			r.activity_header,
			r.activity_detail,
			d.record_date
		FROM daily_records r
		LEFT JOIN daily_record_days d ON r.id = d.record_id
	`

	args := []any{userID}
	conditions := []string{"r.user_id = $1"}
	i := 2

	if filter.DateFrom != nil {
		conditions = append(conditions, fmt.Sprintf("(d.record_date IS NULL OR d.record_date >= $%d)", i))
		args = append(args, *filter.DateFrom)
		i++
	}
	if filter.DateTo != nil {
		conditions = append(conditions, fmt.Sprintf("(d.record_date IS NULL OR d.record_date <= $%d)", i))
		args = append(args, *filter.DateTo)
		i++
	}
	if filter.RepeatType != nil {
		conditions = append(conditions, fmt.Sprintf("r.repeat_type = $%d", i))
		args = append(args, *filter.RepeatType)
		i++
	}
	if filter.Important != nil {
		conditions = append(conditions, fmt.Sprintf("r.important = $%d", i))
		args = append(args, *filter.Important)
		i++
	}
	if filter.ActivityHeader != nil {
		conditions = append(conditions, fmt.Sprintf("r.activity_header ILIKE $%d", i))
		args = append(args, "%"+*filter.ActivityHeader+"%")
		i++
	}

	query := base + " WHERE " + strings.Join(conditions, " AND ")
	query += " ORDER BY r.id, d.record_date ASC"
	query += fmt.Sprintf(" LIMIT $%d OFFSET $%d", i, i+1)
	args = append(args, filter.Limit, filter.Offset)

	rows, err := s.db.Query(query, args...)
	if err != nil {
		return nil, fmt.Errorf("query daily records: %w", err)
	}
	defer rows.Close()

	var (
		order     []uint
		recordMap = make(map[uint]*DailyRecordResponse)
	)

	for rows.Next() {
		var (
			id, iconID uint
			startTime  time.Time
			endTime    time.Time
			repeatType uint
			important  bool
			header     string
			detail     string
			recordDate *time.Time
		)

		if err := rows.Scan(&id, &iconID, &startTime, &endTime, &repeatType, &important, &header, &detail, &recordDate); err != nil {
			return nil, fmt.Errorf("scan daily record: %w", err)
		}

		if _, exists := recordMap[id]; !exists {
			order = append(order, id)
			recordMap[id] = &DailyRecordResponse{
				ID:             id,
				IconID:         iconID,
				StartTime:      startTime.Format("15:04"),
				EndTime:        endTime.Format("15:04"),
				RepeatType:     repeatType,
				Important:      important,
				ActivityHeader: header,
				ActivityDetail: detail,
				Dates:          []string{},
			}
		}

		if recordDate != nil {
			recordMap[id].Dates = append(recordMap[id].Dates, recordDate.Format("2006-01-02"))
		}
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate daily records: %w", err)
	}

	results := make([]*DailyRecordResponse, 0, len(order))
	for _, id := range order {
		results = append(results, recordMap[id])
	}

	return results, nil
}

// ดูรายละเอียดทีละอัน
func (s *DailyRecordStore) GetDailyRecordByID(userID, recordID uint) (*DailyRecordResponse, error) {
	const query = `
		SELECT
			r.id,
			r.icon_id,
			r.start_time,
			r.end_time,
			r.repeat_type,
			r.important,
			r.activity_header,
			r.activity_detail,
			d.record_date
		FROM daily_records r
		LEFT JOIN daily_record_days d ON r.id = d.record_id
		WHERE r.user_id = $1 AND r.id = $2
		ORDER BY d.record_date ASC
	`

	rows, err := s.db.Query(query, userID, recordID)
	if err != nil {
		return nil, fmt.Errorf("query daily record by id: %w", err)
	}
	defer rows.Close()

	var result *DailyRecordResponse

	for rows.Next() {
		var (
			id, iconID uint
			startTime  time.Time
			endTime    time.Time
			repeatType uint
			important  bool
			header     string
			detail     string
			recordDate *time.Time
		)

		if err := rows.Scan(&id, &iconID, &startTime, &endTime, &repeatType, &important, &header, &detail, &recordDate); err != nil {
			return nil, fmt.Errorf("scan daily record by id: %w", err)
		}

		if result == nil {
			result = &DailyRecordResponse{
				ID:             id,
				IconID:         iconID,
				StartTime:      startTime.Format("15:04"),
				EndTime:        endTime.Format("15:04"),
				RepeatType:     repeatType,
				Important:      important,
				ActivityHeader: header,
				ActivityDetail: detail,
				Dates:          []string{},
			}
		}

		if recordDate != nil {
			result.Dates = append(result.Dates, recordDate.Format("2006-01-02"))
		}
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate daily record by id: %w", err)
	}

	if result == nil {
		return nil, sql.ErrNoRows
	}

	return result, nil
}

// ลบ
func (s *DailyRecordStore) DeleteDailyRecord(id uint, userID uint) error {
	query := `DELETE FROM daily_records WHERE id = $1 AND user_id = $2`
	result, err := s.db.Exec(query, id, userID)
	if err != nil {
		log.Printf("Error deleting daily record: %v", err)
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		log.Printf("Error getting rows affected: %v", err)
		return err
	}

	if rowsAffected == 0 {
		return sql.ErrNoRows
	}

	return nil
}

// แก้ไข
func (s *DailyRecordStore) UpdateDailyRecord(r *DailyRecord, userID uint) error {
	query := `
		UPDATE daily_records
		SET icon_id = $1, start_time = $2, end_time = $3, repeat_type = $4, important = $5, activity_header = $6, activity_detail = $7, updated_at = NOW()
		WHERE id = $8 AND user_id = $9
	`

	result, err := s.db.Exec(
		query,
		r.IconID, r.StartTime, r.EndTime, r.RepeatType, r.Important, r.ActivityHeader, r.ActivityDetail, r.ID, userID,
	)
	if err != nil {
		log.Printf("Error updating daily record: %v", err)
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		log.Printf("Error getting rows affected: %v", err)
		return err
	}

	if rowsAffected == 0 {
		return sql.ErrNoRows
	}

	return nil
}

// GetDaysByRecordID retrieves all days associated with a daily record
func (s *DailyRecordStore) GetDaysByRecordID(recordID uint) ([]*DailyRecordDay, error) {
	query := `
		SELECT id, record_id, record_date, created_at
		FROM daily_record_days
		WHERE record_id = $1
		ORDER BY record_date ASC
	`

	rows, err := s.db.Query(query, recordID)
	if err != nil {
		log.Printf("Error fetching record days: %v", err)
		return nil, err
	}
	defer rows.Close()

	var days []*DailyRecordDay
	for rows.Next() {
		day := &DailyRecordDay{}
		err := rows.Scan(&day.ID, &day.RecordID, &day.RecordDate, &day.CreatedAt)
		if err != nil {
			log.Printf("Error scanning record day: %v", err)
			continue
		}
		days = append(days, day)
	}

	if err := rows.Err(); err != nil {
		log.Printf("Error iterating record days: %v", err)
		return nil, err
	}

	return days, nil
}
