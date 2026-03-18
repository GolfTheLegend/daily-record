CREATE TABLE daily_record_days (
    id BIGSERIAL PRIMARY KEY,
    record_id BIGINT NOT NULL,

    record_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_record
        FOREIGN KEY (record_id)
        REFERENCES daily_records(id)
        ON DELETE CASCADE
);

-- index
CREATE INDEX idx_record_id ON daily_record_days(record_id);
CREATE INDEX idx_record_date ON daily_record_days(record_date);