# Auth Concept - Enterprise-Perfected Flow

## วัตถุประสงค์
ปรับระบบ authentication ให้เป็นระดับ enterprise โดยเพิ่มความปลอดภัยและความครบถ้วนของ flow:
- refresh token เป็น source of truth
- refresh token rotation
- revocation strategy
- expiry buffer
- secure transport
- request retry + refresh lock
- logout + session invalidation

## แนวทางหลัก

### 1. refresh token = auto login source of truth
- Mobile app ส่วนใหญ่ถือว่า `refreshToken` = auto login
- `remember me` / checkbox เป็นเพียง UX choice
- logic จริง: ถ้ามี refresh token ใช้งานได้ ให้ auto login
- ถ้าไม่มี refresh token ให้ไป login

### 2. secure storage
- access token และ refresh token ต้องเก็บใน `FlutterSecureStorage`
- session flags หรือ UI option เช่น `remember me` สามารถเก็บด้วย `SharedPreferences`

### 3. refresh token rotation
- เมื่อ refresh สำเร็จ ต้องได้รับ
  - access token ใหม่
  - refresh token ใหม่
- refresh token เก่า ต้องถูก invalidate/revoke โดย server
- client ต้องบันทึก refresh token ใหม่ทุกครั้ง
- flow นี้เรียกว่า `Refresh Token Rotation`

### 4. expiry buffer
- ต้อง refresh ก่อน token หมดอายุเล็กน้อย
- ตัวอย่าง: `now >= expiresAt - buffer`
- buffer ช่วยป้องกัน request ที่ส่งไปแล้ว token หมดกลางทาง
- ใน code ควรใช้ระยะเวลา 1–5 นาทีเป็น buffer

### 5. refresh lock + direct startup refresh
- startup flow ควรใช้ `DioClient.tryRefreshDirect()` เพื่อ reuse logic เดียวกับ interceptor
- ไม่ควรเรียก refresh service ตรง ๆ จาก UI layer
- ถ้ามี request พร้อมกันใน startup ให้รอ refresh เดียวกัน
- ควรมี `initAuthState()` ที่ preload access token จาก secure storage เพื่อให้ request แรกใช้ cache ได้ทันที
- ควรแยก network error กับ auth error: network issue ไม่ควร logout แต่ invalid refresh ต้อง logout
- ควรใช้ retry/backoff strategy เมื่อ refresh ล้มเหลวเพราะ network

### 6. revocation strategy
- server ต้องสามารถ revoke token ได้
- use cases:
  - user logout ทุก device
  - user เปลี่ยน password
  - admin revoke session
- client ต้อง handle refresh fail ด้วย logout + clear token
- server-side blacklist / invalidation เป็นส่วนสำคัญ

### 7. refresh lock + retry
- เมื่อ request หลายตัวเจอ 401 พร้อมกัน ให้ refresh ครั้งเดียว
- request อื่นรอการ refresh เดียวกัน
- เมื่อ refresh สำเร็จ ให้ retry request เดิมด้วย token ใหม่
- ห้าม trigger refresh ซ้ำสำหรับ endpoint refresh เอง

### 8. logout และ global invalidation
- logout ต้องเคลียร์ทั้ง access token, refresh token, expiry
- client ควร redirect ไปหน้า login หลัง logout
- server logout endpoint ควร revoke refresh token

### 9. secure transport / cookie option
- Mobile: Bearer token + secure storage เป็น pattern ปกติ
- Web: HttpOnly cookie เป็นอีกแนวทางที่ secure มากสำหรับ web flow
- หากระบบรองรับทั้ง mobile และ web ให้พิจารณาใช้ cookie สำหรับ web และ bearer token สำหรับ mobile

### 9. device binding / session control (optional)
- enterprise สามารถผูก session กับ device ID หรือ fingerprint
- refresh token อาจถูกจำกัดบน device เดียว
- วิธีนี้ช่วยป้องกัน token reuse ใน device อื่น

## สิ่งที่แก้ไขในโปรเจกต์นี้
- `lib/core/utils/token_storage.dart`
  - เก็บ access token + refresh token ใน `FlutterSecureStorage`
  - ทำให้ refresh token เป็น source of truth สำหรับ auto login
  - เพิ่มการตรวจสอบ expiry พร้อม buffer
- `lib/pages/auth/auth_page.dart`
  - เรียก startup auth session check โดยดูจาก refresh token
  - ถ้ามี refresh token และ access token ยัง valid ให้ไปหน้าหลัก
  - ถ้า access token หมดอายุ ให้ refresh token และ login ต่อ
  - ถ้า refresh ล้มเหลว ให้เคลียร์ token และแสดง login
- `lib/core/network/dio_client.dart`
  - ป้องกัน refresh-loop เมื่อ refresh endpoint ส่ง 401
  - ใช้ refresh lock + retry request
  - เพิ่ม in-memory access token cache ลด I/O
  - startup warm cache ด้วย `initAuthState()`
  - แยก logout event จาก UI navigation
  - timeout / backoff สำหรับ refresh
  - แยก network error กับ invalid token
- `lib/core/services/refresh_token_service.dart`
  - ทำหน้าที่เฉพาะ request / response ของ refresh endpoint
  - ไม่บันทึก token โดยตรงอีกต่อไป
- `lib/main.dart`
  - preload auth token cache ก่อน runApp

## Result
ระบบ auth ปัจจุบันทำงานแบบ:
1. login สำเร็จ -> เก็บ access token + refresh token ใน secure storage
2. app เปิดใหม่ -> ถ้ามี refresh token ให้ใช้เป็น source of truth
3. access token หมดอายุ -> refresh token rotation + retry
4. refresh fail / revoke -> logout และ clear token

## Enterprise notes
- Refresh token rotation เป็นหัวใจของ security flow
- revocation ต้องมีทั้ง client และ server support
- buffer ช่วยลดความเสี่ยง request ตกหล่นกลางทาง
- refresh token ใช้ได้บน device เดียวเมื่อใช้ device binding
- ถ้าต้องรองรับ web ให้พิจารณา HttpOnly cookie สำหรับเว็บส่วนตัว แต่ mobile ใช้ bearer token ได้
