CREATE TABLE daily_records (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    icon_id BIGINT NOT NULL,

    start_time TIME NOT NULL,
    end_time TIME NOT NULL,

    repeat_type SMALLINT NOT NULL DEFAULT 0, -- 0 = everyday, 1 = custom
    important BOOLEAN NOT NULL DEFAULT FALSE,

    activity_header TEXT NOT NULL,
    activity_detail TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_daily_records_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- index
CREATE INDEX idx_daily_records_user_id ON daily_records(user_id);
CREATE INDEX idx_daily_records_created_at ON daily_records(created_at);