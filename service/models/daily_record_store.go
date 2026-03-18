package models

import (
	"database/sql"
	"log"
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

func (s *DailyRecordStore) CreateDailyRecord(r *DailyRecord) (uint, error) {
	query := `
		INSERT INTO daily_records 
		(user_id, icon_id, start_time, end_time, repeat_type, important, activity_header, activity_detail, created_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
		RETURNING id
	`

	var id uint
	err := s.db.QueryRow(
		query,
		r.UserID,
		r.IconID,
		r.StartTime,
		r.EndTime,
		r.RepeatType,
		r.Important,
		r.ActivityHeader,
		r.ActivityDetail,
		r.CreatedAt,
	).Scan(&id)

	if err != nil {
		log.Printf("Error creating daily record: %v", err)
		return 0, err
	}
	return id, nil
}

func (s *DailyRecordStore) CreateDailyRecordDay(d *DailyRecordDay) error {
	query := `
		INSERT INTO daily_record_days 
		(record_id, record_date, created_at)
		VALUES ($1,$2,$3)
	`

	_, err := s.db.Exec(query, d.RecordID, d.RecordDate, d.CreatedAt)
	if err != nil {
		log.Printf("Error creating daily record day: %v", err)
		return err
	}
	return nil
}

// CreateWithDays creates a daily record with its days in a single transaction
// ✅ ensures data consistency: if day insertion fails, entire operation rolls back
func (s *DailyRecordStore) CreateWithDays(r *DailyRecord, days []*DailyRecordDay) (uint, error) {
	tx, err := s.db.Begin()
	if err != nil {
		log.Printf("Error beginning transaction: %v", err)
		return 0, err
	}

	defer tx.Rollback()

	var recordID uint

	err = tx.QueryRow(`
		INSERT INTO daily_records 
		(user_id, icon_id, start_time, end_time, repeat_type, important, activity_header, activity_detail, created_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
		RETURNING id
	`,
		r.UserID, r.IconID, r.StartTime, r.EndTime,
		r.RepeatType, r.Important, r.ActivityHeader,
		r.ActivityDetail, r.CreatedAt,
	).Scan(&recordID)

	if err != nil {
		log.Printf("Error creating daily record in transaction: %v", err)
		return 0, err
	}

	// Insert all associated days
	for _, d := range days {
		_, err := tx.Exec(`
			INSERT INTO daily_record_days (record_id, record_date, created_at)
			VALUES ($1,$2,$3)
		`, recordID, d.RecordDate, d.CreatedAt)

		if err != nil {
			log.Printf("Error creating daily record day in transaction: %v", err)
			return 0, err
		}
	}

	if err := tx.Commit(); err != nil {
		log.Printf("Error committing transaction: %v", err)
		return 0, err
	}

	return recordID, nil
}

func (s *DailyRecordStore) GetDailyRecordByID(id uint) (*DailyRecord, bool) {
	query := `
		SELECT id, user_id, icon_id, start_time, end_time, repeat_type, important, activity_header, activity_detail, created_at, updated_at
		FROM daily_records
		WHERE id = $1
	`

	record := &DailyRecord{}
	err := s.db.QueryRow(query, id).Scan(
		&record.ID, &record.UserID, &record.IconID, &record.StartTime, &record.EndTime,
		&record.RepeatType, &record.Important, &record.ActivityHeader, &record.ActivityDetail,
		&record.CreatedAt, &record.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, false
	}
	if err != nil {
		log.Printf("Error finding daily record by ID: %v", err)
		return nil, false
	}
	return record, true
}

func (s *DailyRecordStore) GetDailyRecordsByUserID(userID uint) ([]*DailyRecord, error) {
	query := `
		SELECT id, user_id, icon_id, start_time, end_time, repeat_type, important, activity_header, activity_detail, created_at, updated_at
		FROM daily_records
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := s.db.Query(query, userID)
	if err != nil {
		log.Printf("Error fetching daily records: %v", err)
		return nil, err
	}
	defer rows.Close()

	var records []*DailyRecord
	for rows.Next() {
		record := &DailyRecord{}
		err := rows.Scan(
			&record.ID, &record.UserID, &record.IconID, &record.StartTime, &record.EndTime,
			&record.RepeatType, &record.Important, &record.ActivityHeader, &record.ActivityDetail,
			&record.CreatedAt, &record.UpdatedAt,
		)
		if err != nil {
			log.Printf("Error scanning daily record: %v", err)
			continue
		}
		records = append(records, record)
	}

	// Check if there was an error during iteration
	if err := rows.Err(); err != nil {
		log.Printf("Error iterating daily records: %v", err)
		return nil, err
	}

	return records, nil
}

// DeleteDailyRecord deletes a daily record (only owner can delete)
// includes user_id in WHERE clause to prevent users from deleting others' records
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

// UpdateDailyRecord updates a daily record (only owner can update)
// includes user_id in WHERE clause to prevent users from updating others' records
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
