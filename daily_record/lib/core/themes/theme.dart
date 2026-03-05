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
  final Color addButton;
  final Color backButton;

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
  });
}

const List<ThemeItem> themeDataList = [
   //Default
  ThemeItem(
    key: 1,
    primary: Color(0xFFFFAAEA),
    secondary: Color(0xFFEB00B1),
    shadowPrimary: Color.fromARGB(255, 224, 97, 193),
    background1: Colors.black,
    background2: Colors.white,
    textPrimary: Colors.black,
    text1: Colors.black,
    text2: Colors.black,
    status1: Colors.green,
    status2: Colors.red,
    addButton: Color(0xFF84FF8D),
    backButton: Colors.white,
  ),
  //Luxury 
  ThemeItem(
    key: 2,
    primary: const Color(0xFFBFA046),
    secondary: const Color(0xFFD9D9D9),
    shadowPrimary: const Color(0x336B5E2E),
    background1: const Color(0x336B5E2E),
    background2: const Color(0xFFFFFFFF),
    textPrimary: const Color(0xFF1C1C1C),
    text1: const Color(0xFF2A2A2A),
    text2: const Color(0xFF8A8A8A),
    status1: const Color(0xFFBFA046),
    status2: const Color(0xFF9DA3A6),
    addButton: const Color(0xFFBFA046),
    backButton: const Color(0xFFFFFFFF),
  ),
];
