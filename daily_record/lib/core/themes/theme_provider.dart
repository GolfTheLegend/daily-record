import 'package:daily_record/core/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeItem? _currentThemeItem;
  ThemeItem? get currentThemeItem => _currentThemeItem;

  // ดู key ที่ใช้อยู่
  int? get currentKey => _currentThemeItem?.key;

  ThemeData get themeData {
    if (_currentThemeItem == null) return ThemeData.light();
    final t = _currentThemeItem!;
    return ThemeData(
      primaryColor: t.primary,
      scaffoldBackgroundColor: t.background2,
      colorScheme: ColorScheme.light(
        primary: t.primary,
        secondary: t.secondary,
        surface: t.background1,
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: t.textPrimary),
        bodySmall: TextStyle(color: t.text1),
      ),
    );
  }

  // โหลด key ที่บันทึกไว้ — เรียกตอน app เริ่ม
  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getInt('theme_key');

    // ถ้าไม่มี savedKey ให้ใช้ theme แรกเป็น default
    setThemeByKey(savedKey ?? themeDataList.first.key);
  }

  // เลือก + บันทึก key
  Future<void> setThemeByKey(int key) async {
    _currentThemeItem = themeDataList.firstWhere(
      (t) => t.key == key,
      orElse: () => themeDataList.first,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_key', key); // บันทึก
    notifyListeners();
  }
}
