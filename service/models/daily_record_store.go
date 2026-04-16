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

	// ถ้า RepeatType == 0 ให้ข้ามการ insert days ทั้งหมด
	if r.RepeatType != 0 {
		for _, d := range days {
			_, err := tx.Exec(`
				INSERT INTO daily_record_days (record_id, record_date, created_at)
				VALUES ($1,$2,$3)
			`, recordID, d.RecordDate, d.CreatedAt)
			if err != nil {
				return 0, fmt.Errorf("insert daily record day: %w", err)
			}
		}
	}

	if err := tx.Commit(); err != nil {
		return 0, fmt.Errorf("commit transaction: %w", err)
	}

	return recordID, nil
}

func (s *DailyRecordStore) GetDailyRecordsByUserID(userID uint, filter DailyRecordFilter) ([]*DailyRecordResponse, error) {
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

	whereClause := strings.Join(conditions, " AND ")

	// paginate ที่ระดับ record ก่อน แล้วค่อย join dates
	query := fmt.Sprintf(`
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
		FROM (
			SELECT DISTINCT r.id
			FROM daily_records r
			LEFT JOIN daily_record_days d ON r.id = d.record_id
			WHERE %s
			ORDER BY r.id ASC
			LIMIT $%d OFFSET $%d
		) paged
		JOIN daily_records r ON r.id = paged.id
		LEFT JOIN daily_record_days d ON r.id = d.record_id
		ORDER BY r.id, d.record_date ASC
	`, whereClause, i, i+1)

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

// ดึงค่าStatus ของกิจกรรมในแต่ละวัน
func (s *DailyRecordStore) GetStatusDailyRecordsByUserID(userID uint, filter DailyRecordStatusFilter) ([]*DailyRecordStatusResponse, error) {
	base := `
		SELECT
			d.record_date,
			BOOL_OR(r.important) AS important
		FROM daily_records r
		INNER JOIN daily_record_days d ON r.id = d.record_id
	`

	args := []any{userID}
	conditions := []string{"r.user_id = $1", "d.record_date IS NOT NULL"}
	i := 2

	if filter.Year > 0 && filter.Month > 0 && filter.Day > 0 {
		// ค้นหาวันที่ตรงๆ
		t := time.Date(filter.Year, time.Month(filter.Month), filter.Day, 0, 0, 0, 0, time.UTC)
		conditions = append(conditions, fmt.Sprintf("d.record_date = $%d", i))
		args = append(args, t)
		i++
	} else if filter.Year > 0 && filter.Month > 0 {
		// ค้นหาทั้งเดือน → ใช้ range แทน EXTRACT เพื่อให้ใช้ index ได้
		from := time.Date(filter.Year, time.Month(filter.Month), 1, 0, 0, 0, 0, time.UTC)
		to := from.AddDate(0, 1, 0) // ต้นเดือนถัดไป
		conditions = append(conditions, fmt.Sprintf("d.record_date >= $%d AND d.record_date < $%d", i, i+1))
		args = append(args, from, to)
		i += 2
	} else if filter.Year > 0 {
		// ค้นหาทั้งปี
		from := time.Date(filter.Year, 1, 1, 0, 0, 0, 0, time.UTC)
		to := time.Date(filter.Year+1, 1, 1, 0, 0, 0, 0, time.UTC)
		conditions = append(conditions, fmt.Sprintf("d.record_date >= $%d AND d.record_date < $%d", i, i+1))
		args = append(args, from, to)
		i += 2
	} else if filter.Month > 0 {
		// ค้นหาทุกปีในเดือนนั้น (จำเป็นต้องใช้ EXTRACT กรณีนี้)
		conditions = append(conditions, fmt.Sprintf("EXTRACT(MONTH FROM d.record_date) = $%d", i))
		args = append(args, filter.Month)
		i++
		if filter.Day > 0 {
			conditions = append(conditions, fmt.Sprintf("EXTRACT(DAY FROM d.record_date) = $%d", i))
			args = append(args, filter.Day)
			i++
		}
	} else if filter.Day > 0 {
		conditions = append(conditions, fmt.Sprintf("EXTRACT(DAY FROM d.record_date) = $%d", i))
		args = append(args, filter.Day)
		i++
	}

	query := base + " WHERE " + strings.Join(conditions, " AND ")
	query += " GROUP BY d.record_date"
	query += " ORDER BY d.record_date ASC"

	rows, err := s.db.Query(query, args...)
	if err != nil {
		return nil, fmt.Errorf("query daily records: %w", err)
	}
	defer rows.Close()

	var results []*DailyRecordStatusResponse

	for rows.Next() {
		var (
			recordDate time.Time
			important  bool
		)

		if err := rows.Scan(&recordDate, &important); err != nil {
			return nil, fmt.Errorf("scan daily record: %w", err)
		}

		results = append(results, &DailyRecordStatusResponse{
			HasRecord: true,
			Important: important,
			Day:       recordDate.Day(),
			Month:     int(recordDate.Month()),
			Year:      recordDate.Year(),
		})
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate daily records: %w", err)
	}

	return results, nil
}

// แก้ไข
func (s *DailyRecordStore) UpdateDailyRecord(r *DailyRecord, dates []time.Time, userID uint) error {
	tx, err := s.db.Begin()
	if err != nil {
		return fmt.Errorf("begin transaction: %w", err)
	}
	defer tx.Rollback()

	const updateQuery = `
		UPDATE daily_records
		SET
			icon_id         = $1,
			start_time      = $2,
			end_time        = $3,
			repeat_type     = $4,
			important       = $5,
			activity_header = $6,
			activity_detail = $7,
			updated_at      = NOW()
		WHERE id = $8 AND user_id = $9
	`

	result, err := tx.Exec(updateQuery,
		r.IconID, r.StartTime, r.EndTime, r.RepeatType, r.Important, r.ActivityHeader, r.ActivityDetail,
		r.ID, userID,
	)
	if err != nil {
		return fmt.Errorf("update daily record: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("rows affected daily record: %w", err)
	}
	if rowsAffected == 0 {
		return sql.ErrNoRows
	}

	// ลบ record_days ทั้งหมดเสมอ
	_, err = tx.Exec(`DELETE FROM daily_record_days WHERE record_id = $1`, r.ID)
	if err != nil {
		return fmt.Errorf("delete daily record days: %w", err)
	}

	// ถ้า RepeatType != 0 ค่อย insert dates ใหม่
	if r.RepeatType != 0 {
		for _, date := range dates {
			_, err = tx.Exec(
				`INSERT INTO daily_record_days (record_id, record_date) VALUES ($1, $2)`,
				r.ID, date,
			)
			if err != nil {
				return fmt.Errorf("insert daily record day: %w", err)
			}
		}
	}

	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit transaction: %w", err)
	}

	return nil
}

// ลบ
func (s *DailyRecordStore) DeleteDailyRecord(id, userID uint) error {
	const query = `DELETE FROM daily_records WHERE id = $1 AND user_id = $2`

	result, err := s.db.Exec(query, id, userID)
	if err != nil {
		return fmt.Errorf("delete daily record: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("rows affected daily record: %w", err)
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

// create checklist
func (s *DailyRecordStore) CreateDailyCheckList(r *DailyCheckList, userID uint) error {
	query := `
		INSERT INTO daily_check_lists (
			main_record_id,
			day_check,
			check_status,
			created_at
		)
		SELECT $1, $2, $3, $4
		WHERE EXISTS (
			SELECT 1 FROM daily_records
			WHERE id = $1 AND user_id = $5
		)
		RETURNING id
	`

	err := s.db.QueryRow(
		query,
		r.MainRecordID,
		r.DayCheck,
		r.CheckStatus,
		r.CreatedAt,
		userID,
	).Scan(&r.ID)

	if err != nil {
		if err == sql.ErrNoRows {
			return fmt.Errorf("forbidden: record not found or not owned by user")
		}

		// 🔥 handle unique constraint
		if strings.Contains(err.Error(), "unique_record_day") {
			return fmt.Errorf("checklist already exists for this day")
		}

		return fmt.Errorf("insert daily checklist: %w", err)
	}

	return nil
}
