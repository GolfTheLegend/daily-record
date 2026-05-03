# UAT / Environment Setup Guide

## เป้าหมาย
- แยก environment frontend ให้เป็น `dev`, `uat`, `prod`
- ใช้ `AppConfig` เพื่อกำหนด `baseUrl` และพฤติกรรมของ service
- รองรับการทดสอบหน้าเว็บ/หน้าบ้านด้วย UAT URL และถ้าอยากใช้ mock service ก็ทำได้ง่าย

## โครงสร้างที่เปลี่ยน
1. `lib/core/config/app_config.dart`
   - สร้าง `AppConfig` เพื่อเก็บค่า environment
   - รองรับ `AppEnvironment.dev`, `uat`, `prod`
   - รองรับ `useMockServices`

2. `lib/core/constants/api_constants.dart`
   - เปลี่ยน `baseUrl` จาก `const` เป็น `AppConfig.instance.baseUrl`
   - ทำให้ทุก service อ่าน base URL เดียวกัน

3. `lib/core/network/dio_client.dart`
   - ใช้ `AppConfig.instance.baseUrl` สำหรับ `Dio` ทั้ง API หลักและ refresh
   - ทำให้ `DioClient` เปลี่ยน URL ตาม environment ได้ทันที

4. `lib/core/services/refresh_token_service.dart`
   - เปลี่ยนค่า default `Dio` ให้ใช้ `AppConfig.instance.baseUrl`

5. `lib/main.dart`
   - เพิ่มการอ่านค่า `ENV`, `BASE_URL`, `USE_MOCK_SERVICES` จาก `--dart-define`
   - เรียก `AppConfig.init(...)` ก่อน `runApp`

## วิธีรัน UAT
### 1. รันสดด้วย UAT URL
```powershell
flutter run --dart-define=ENV=uat --dart-define=BASE_URL=https://uat-api.example.com/api/v1
```

### 2. สร้าง APK/Bundle สำหรับ UAT
```powershell
flutter build apk -t lib/main.dart --dart-define=ENV=uat --dart-define=BASE_URL=https://uat-api.example.com/api/v1
```

### 3. ถ้าต้องการใช้ Mock Service ใน UAT
```powershell
flutter run --dart-define=ENV=uat --dart-define=BASE_URL=https://uat-api.example.com/api/v1 --dart-define=USE_MOCK_SERVICES=true
```

## คำสั่งรันและ build version เต็ม
### รันแบบพัฒนา (DEV)
```powershell
flutter run -t lib/main.dart --dart-define=ENV=dev --dart-define=BASE_URL=https://dev-api.example.com/api/v1 --dart-define=USE_MOCK_SERVICES=false
```

### รัน UAT สด
```powershell
flutter run -t lib/main.dart --dart-define=ENV=uat --dart-define=BASE_URL=https://uat-api.example.com/api/v1 --dart-define=USE_MOCK_SERVICES=false
```

### รัน UAT แบบ mock frontend
```powershell
flutter run -t lib/main.dart --dart-define=ENV=uat --dart-define=BASE_URL=https://uat-api.example.com/api/v1 --dart-define=USE_MOCK_SERVICES=true
```

### สร้าง APK สำหรับ UAT version เต็ม
```powershell
flutter build apk -t lib/main.dart --dart-define=ENV=uat --dart-define=BASE_URL=https://uat-api.example.com/api/v1 --build-name=1.0.0 --build-number=100
```

### สร้าง App Bundle สำหรับ UAT version เต็ม
```powershell
flutter build appbundle -t lib/main.dart --dart-define=ENV=uat --dart-define=BASE_URL=https://uat-api.example.com/api/v1 --build-name=1.0.0 --build-number=100
```

### สร้าง iOS IPA สำหรับ UAT version เต็ม
```powershell
flutter build ipa -t lib/main.dart --dart-define=ENV=uat --dart-define=BASE_URL=https://uat-api.example.com/api/v1 --dart-define=USE_MOCK_SERVICES=false --build-name=1.0.0 --build-number=100
```

> แนะนำให้ปรับ `--build-name` และ `--build-number` ตาม version ของ release ที่ต้องการ

> ถ้าต้องการสรุป release เดียวสำหรับ production ให้เปลี่ยน `ENV=prod` และ `BASE_URL` เป็น production API

> ในทุกคำสั่งก่อน build ให้รัน `flutter pub get` ก่อนเสมอ

> ในอนาคต ถ้าจะเพิ่ม logic แยก service แบบเต็ม ให้เช็ค `AppConfig.instance.useMockServices` แล้วเลือกสร้าง `MockService` หรือ `ApiService` ได้ทันที

## ตัวอย่างการใช้งาน `AppConfig`
```dart
if (AppConfig.instance.isUat) {
  // ใช้ UAT URL
}

if (AppConfig.instance.useMockServices) {
  // เลือก mock service
}
```

## ข้อดีของแนวทางนี้
- ไม่ต้องแก้โค้ดหลายไฟล์เมื่อเปลี่ยน URL
- มี environment เดียวที่ควบคุมทุก service
- เหมาะกับ enterprise เพราะรองรับ build-time config และแยก UAT/Prod/Dev อย่างชัดเจน
- สามารถยืดออกเป็น `UAT service` หรือ `Mock service` ได้ง่าย

## ถัดไป ถ้าต้องการให้ชัดขึ้น
1. สร้าง abstract service interface เช่น `AuthService`, `RecordService`
2. สร้าง implementation สำหรับ:
   - API จริง (`ApiAuthService`, `ApiRecordService`)
   - UAT / mock (`MockAuthService`, `MockRecordService`)
3. ใช้ `AppConfig.instance.useMockServices` หรือ `AppConfig.instance.isUat` ใน factory เพื่อเลือก implementation

---

## สรุปคำสั่งสำคัญ
- `ENV=dev` → ใช้ development mode
- `ENV=uat` → ใช้ UAT mode
- `ENV=prod` → ใช้ production mode
- `BASE_URL` → กำหนด API URL ของแต่ละ environment
- `USE_MOCK_SERVICES` → เปิดระบบ mock service ถ้าต้องการทดสอบ frontend แยกจาก backend
