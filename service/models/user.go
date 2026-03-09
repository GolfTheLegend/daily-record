package models

type User struct {
    ID       uint   `json:"id"`
    Username string `json:"username"`
    Password string `json:"-"` // ไม่ส่ง password ออก JSON
    Role     string `json:"role"`
}

// จำลอง in-memory DB
var Users = []User{}
var NextID uint = 1