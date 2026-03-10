# daily-record — JWT Auth Service (Fiber v3)

## Stack
| Package | Version |
|---------|---------|
| `github.com/gofiber/fiber/v3` | v3.1.0 |
| `github.com/golang-jwt/jwt/v5` | v5.3.1 |
| `golang.org/x/crypto` | v0.48.0 |
| Go | 1.26.1 |

---

## Run

```bash
go mod tidy
go run main.go
```

---

## โครงสร้าง Folder

```
daily-record/
├── main.go
├── go.mod
├── README.md
├── config/
│   └── config.go          # secrets, expiry, rate limit
├── models/
│   ├── user.go            # User / RefreshToken struct
│   └── store.go           # in-memory DB (thread-safe)
├── handlers/
│   ├── token.go           # JWT generate / parse / IssueTokenPair
│   └── auth.go            # Register, Login, Refresh, Logout, Me, LogoutAll
├── middleware/
│   ├── auth.go            # Protected(), RequireRole()
│   └── ratelimit.go       # brute force protection
├── routes/
│   └── routes.go          # ลงทะเบียน route ทั้งหมด
└── utils/
    └── response.go        # ErrorResponse / SuccessResponse
```

---


## API Endpoints

| Method | Path | Auth | คำอธิบาย |
|--------|------|------|----------|
| `GET`  | `/health` | - | Health check |
| `POST` | `/api/v1/auth/register` | - | สมัครสมาชิก |
| `POST` | `/api/v1/auth/login` | - | Login → token pair |
| `POST` | `/api/v1/auth/refresh` | - | ต่ออายุ token |
| `POST` | `/api/v1/auth/logout` | - | Logout |
| `GET`  | `/api/v1/auth/me` | ✅ Bearer | ดูข้อมูลตัวเอง |
| `POST` | `/api/v1/auth/logout-all` | ✅ Bearer | kick ทุกอุปกรณ์ |
| `GET`  | `/api/v1/admin/dashboard` | ✅ Admin | Admin เท่านั้น |
