import 'package:flutter/material.dart';

class ThemeItem {
  final int key;
  final Color primary; // สีหลักของแอป
  final Color secondary; // สีรอง
  final Color shadowPrimary; //เงาสีหลัก
  final Color background1; // สีพื้นหลังขอบหลังสุด
  final Color background2; // สีพื้นหลังหลักของหน้าจอ
  final Color textPrimary; // สีตัวอักษรหลัก
  final Color text1; // สีตัวอักษรรอง
  final Color text2; // สีตัวอักษรรอง
  final Color status1; //สถานะ ทุกวัน
  final Color status2; //สถานะ สำคัญ
  final Color addButton; //สีปุ่มเพิ่ม
  final Color backButton; //สีปุ่มยกเลิก-ย้อนกลับ
  final Color succress; //สำร็จ หรือยืนยัน
  final Color fail; //ล้มเหลว หรือยกเลิก

  const ThemeItem({
    required this.key,
    required this.primary,
    required this.shadowPrimary,
    required this.secondary,
    required this.background1,
    required this.background2,
    required this.textPrimary,
    required this.text1,
    required this.text2,
    required this.status1,
    required this.status2,
    required this.addButton,
    required this.backButton,
    required this.succress,
    required this.fail,
  });
}

const List<ThemeItem> themeDataList = [
  // Brown Warm Theme
  ThemeItem(
    key: 1,
    primary: const Color(0xFFA0522D), // น้ำตาล Sienna — ขอบ card, icon
    secondary: const Color(0xFFD2A679), // น้ำตาลอ่อน — ขอบนอกปุ่ม
    shadowPrimary: const Color(0x66A0522D), // เงาน้ำตาล
    background1: const Color(0xFF2C1A0E), // น้ำตาลเกือบดำ — ขอบสุด
    background2: const Color(0xFFF8DECE), // ครีมอ่อน — พื้นหลักหน้าจอ
    textPrimary: const Color(0xFF3B1F0E), // น้ำตาลเข้มมาก — หัวข้อ/divider
    text1: const Color(0xFF5C3317), // น้ำตาลเข้ม — ตัวอักษรหลักใน card
    text2: const Color(0xFF8B5E3C), // น้ำตาลกลาง — ตัวอักษรรอง/เวลา
    status1: const Color(0xFFA0522D), // น้ำตาล — dot รายวัน
    status2: const Color(0xFFD32F2F), // แดงเข้ม — dot สำคัญ (เห็นชัดบนครีม)
    addButton: const Color(0xFFA0522D), // น้ำตาล — ปุ่ม + เพิ่ม
    backButton: const Color(0xFFD2A679), // น้ำตาลอ่อน — ปุ่มกลับ (ไม่ดำเกินไป)
    succress: const Color(0xFF388E3C), // เขียวเข้ม — เห็นชัดบนครีม
    fail: const Color(0xFFD32F2F), // แดงเข้ม
  ),
  //dark theme
  ThemeItem(
    key: 2,
    primary: const Color(0xFFD4AF37),
    secondary: const Color(0xFF8E8E8E),
    shadowPrimary: const Color(0x66000000),
    background1: const Color(0xFF0F0F10),
    background2: const Color(0xFF1A1A1C),
    textPrimary: const Color(0xFFFFFFFF),
    text1: const Color(0xFFEAEAEA),
    text2: const Color(0xFFB5B5B5),
    status1: const Color(0xFFD4AF37),
    status2: const Color(0xFFFF6B6B),
    addButton: const Color(0xFFD4AF37),
    backButton: const Color(0xFF2A2A2A),
    succress: Color.fromARGB(255, 50, 199, 99),
    fail: const Color(0xFFFF6B6B),
  ),
  //Minimal: Snow White
  ThemeItem(
    key: 3,
    primary: const Color(0xFF212121), // กราไฟต์ดำ
    secondary: const Color(0xFF9E9E9E), // เทากลาง
    shadowPrimary: const Color(0x22000000), // เงาอ่อนมาก
    background1: const Color(0xFFF2F2F2), // เทาอ่อนมาก
    background2: const Color(0xFFFAFAFA), // ขาวบริสุทธิ์
    textPrimary: const Color(0xFF212121), // ดำ
    text1: const Color(0xFF212121), // ดำ — หลัก
    text2: const Color(0xFF616161), // เทาเข้ม — รอง
    status1: const Color(0xFF616161), // เทา — dot รายวัน
    status2: const Color(0xFFD32F2F), // แดง — dot สำคัญ
    addButton: const Color(0xFFE0E0E0), // ดำ — ปุ่ม +
    backButton: const Color(0xFFE0E0E0), // เทาอ่อน — ปุ่มกลับ
    succress: const Color(0xFF388E3C),
    fail: const Color(0xFFD32F2F),
  ),
  //Deep Sea
  ThemeItem(
    key: 4,
    primary: const Color(0xFF1565C0), // น้ำเงินลึก
    secondary: const Color(0xFF29B6F6), // ฟ้าอควา
    shadowPrimary: const Color(0x661565C0), // เงาน้ำเงิน
    background1: const Color(0xFF0A1628), // navy เกือบดำ
    background2: const Color(0xFF0D2137), // navy เข้ม
    textPrimary: const Color(0xFF90CAF9), // ฟ้าอ่อน — หัวข้อ
    text1: const Color(0xFF90CAF9), // ฟ้าอ่อน — หลัก
    text2: const Color(0xFF64B5F6), // ฟ้ากลาง — รอง
    status1: const Color(0xFF29B6F6), // ฟ้า — dot รายวัน
    status2: const Color(0xFFEF5350), // แดง — dot สำคัญ
    addButton: const Color(0xFF1565C0), // น้ำเงิน — ปุ่ม +
    backButton: const Color(0xFF112944), // navy — ปุ่มกลับ
    succress: const Color(0xFF26C6DA),
    fail: const Color(0xFFEF5350),
  ),
  //Forest Sage
  ThemeItem(
    key: 5,
    primary: const Color(0xFF4A7A38), // เขียวป่า
    secondary: const Color(0xFFA8C896), // เขียวอ่อน
    shadowPrimary: const Color(0x664A7A38), // เงาเขียว
    background1: const Color(0xFFD4E8C8), // เขียวพาสเทล
    background2: const Color(0xFFEDF5E8), // เขียวอ่อนมาก
    textPrimary: const Color(0xFF2E4A22), // เขียวเข้มมาก
    text1: const Color(0xFF2E4A22), // เขียวเข้ม — หลัก
    text2: const Color(0xFF4A7A38), // เขียวกลาง — รอง
    status1: const Color(0xFF4A7A38), // เขียว — dot รายวัน
    status2: const Color(0xFFC0392B), // แดง — dot สำคัญ
    addButton: const Color(0xFF4A7A38), // เขียว — ปุ่ม +
    backButton: const Color(0xFFA8C896), // เขียวอ่อน — ปุ่มกลับ
    succress: const Color(0xFF388E3C),
    fail: const Color(0xFFC0392B),
  ),
  //Sunset Energy Theme
  ThemeItem(
    key: 6,
    primary: const Color(0xFFFF7A18),
    secondary: const Color(0xFFFFC48C),
    shadowPrimary: const Color(0x66FF7A18),
    background1: const Color(0xFF3A1F0F),
    background2: const Color(0xFFFFF1E6),
    textPrimary: const Color(0xFF4E2A14),
    text1: const Color(0xFF6E3B1F),
    text2: const Color(0xFFB06A3C),
    status1: const Color(0xFFFF7A18),
    status2: const Color(0xFFE53935),
    addButton: const Color(0xFFFF7A18),
    backButton: const Color(0xFFFFD8B5),
    succress: const Color(0xFF43A047),
    fail: const Color(0xFFE53935),
  ),
  //Luxury: Obsidian Gold
  ThemeItem(
    key: 7,
    primary: const Color(0xFFBFA14A), // ทองแชมเปญ — icon, ขอบ card
    secondary: const Color(0xFF8A7A5A), // ทองหม่น — ขอบนอกปุ่ม
    shadowPrimary: const Color(0x66BFA14A), // เงาทอง
    background1: const Color(0xFF0D0D0D), // ดำลึก — ขอบสุด
    background2: const Color(0xFF1A1710), // ดำอุ่น — พื้นหน้าจอ
    textPrimary: const Color(0xFFE8C96A), // ทองสว่าง — หัวข้อ
    text1: const Color(0xFFE8C96A), // ทองสว่าง — ตัวอักษรหลัก
    text2: const Color(0xFFC8A84B), // ทองกลาง — ตัวอักษรรอง
    status1: const Color(0xFFBFA14A), // ทอง — dot รายวัน
    status2: const Color(0xFFC0392B), // แดง — dot สำคัญ
    addButton: const Color(0xFFBFA14A), // ทอง — ปุ่ม +
    backButton: const Color(0xFF2A2318), // น้ำตาลเข้ม — ปุ่มกลับ
    succress: const Color(0xFF27AE60),
    fail: const Color(0xFFC0392B),
  ),
  //pink theme
  ThemeItem(
    key: 8,
    primary: const Color(0xFFFF6FD8),
    secondary: const Color(0xFFFFB3EC),
    shadowPrimary: Color.fromARGB(255, 255, 146, 228),
    background1: const Color(0xFFFFE6F6),
    background2: const Color(0xFFFFF5FB),
    textPrimary: const Color(0xFF2A2A2A),
    text1: const Color(0xFF3A3A3A),
    text2: const Color(0xFF8A8A8A),
    status1: const Color(0xFF43A047),
    status2: const Color(0xFFE53935),
    addButton: const Color(0xFFFF6FD8),
    backButton: const Color(0xFFFFFFFF),
    succress: const Color(0xFF43A047),
    fail: const Color(0xFFE53935),
  ),
  //Ocean Calm Theme
  ThemeItem(
    key: 9,
    primary: const Color(0xFF2D9CDB),
    secondary: const Color(0xFFBEE9F7),
    shadowPrimary: const Color(0x552D9CDB),
    background1: const Color(0xFF0F2A3D),
    background2: const Color(0xFFEAF6FB),
    textPrimary: const Color(0xFF0B3C5D),
    text1: const Color(0xFF145374),
    text2: const Color(0xFF5F9FBF),
    status1: const Color(0xFF2D9CDB),
    status2: const Color(0xFFE63946),
    addButton: const Color(0xFF2D9CDB),
    backButton: const Color(0xFFD6EEF8),
    succress: const Color(0xFF2ECC71),
    fail: const Color(0xFFE63946),
  ),
];
