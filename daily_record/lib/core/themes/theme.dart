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
  //dark theme
  ThemeItem(
    key: 1,
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
  ThemeItem(
    key: 2,
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
  //blue
  ThemeItem(
    key: 2,
    primary: const Color(0xFF6EC6FF),
    secondary: const Color(0xFFB3E5FC),
    shadowPrimary: const Color(0x334A90E2),
    background1: const Color(0xFFEAF6FF),
    background2: const Color(0xFFF7FBFF),
    textPrimary: const Color(0xFF1A2A33),
    text1: const Color(0xFF2C3E50),
    text2: const Color(0xFF6B7C93),
    status1: const Color(0xFF4CAF50),
    status2: const Color(0xFFE53935),
    addButton: const Color(0xFF6EC6FF),
    backButton: const Color(0xFFFFFFFF),
    succress: const Color(0xFF4CAF50),
    fail: const Color(0xFFE53935),
  ),
];
