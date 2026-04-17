CREATE TABLE daily_check_lists (
    id BIGSERIAL PRIMARY KEY,
    main_record_id BIGINT NOT NULL,

    day_check DATE NOT NULL,
    check_status BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_daily_check_lists_record
        FOREIGN KEY (main_record_id)
        REFERENCES daily_records(id)
        ON DELETE CASCADE
        
);

-- index
CREATE INDEX idx_main_record_id ON daily_check_lists(main_record_id);
CREATE INDEX idx_day_check ON daily_check_lists(day_check);