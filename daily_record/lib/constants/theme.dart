import 'package:flutter/material.dart';

class ThemeItem {
  final int key;
  final Color primary; // สีหลักของแอป
  final Color secondary; // สีรอง
  final Color background1; // สีพื้นหลังขอบหลังสุด
  final Color background2; // สีพื้นหลังหลักของหน้าจอ
  final Color textPrimary; // สีตัวอักษรหลัก
  final Color text1; // สีตัวอักษรรอง
  final Color text2; // สีตัวอักษรรอง
  final Color addButton;
  final Color backButton;

  const ThemeItem({
    required this.key,
    required this.primary,
    required this.secondary,
    required this.background1,
    required this.background2,
    required this.textPrimary,
    required this.text1,
    required this.text2,
    required this.addButton,
    required this.backButton,
  });
}

const List<ThemeItem> themeDataList = [
  ThemeItem(
    key: 1,
    primary: Color(0xFFFFAAEA),
    secondary: Color(0xFFEB00B1),
    background1: Colors.black,
    background2: Colors.white,
    textPrimary: Colors.black,
    text1: Colors.black,
    text2: Colors.black,
    addButton: Color(0xFF84FF8D),
    backButton: Colors.white,
  ),
];
