import 'package:daily_record/pages/auth/auth_page.dart';
import 'package:daily_record/pages/calendar/calendar_page.dart';
import 'package:daily_record/pages/createactive/create_active_page.dart';
import 'package:daily_record/pages/home/home_page.dart';
import 'package:daily_record/pages/setting/setting_page.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ต้องมีก่อน SharedPreferences

  final themeProvider = ThemeProvider();
  await themeProvider.loadSavedTheme(); // โหลด key ที่บันทึกไว้

  runApp(
    ChangeNotifierProvider.value(value: themeProvider, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      initialRoute: '/create',
      routes: {
        // '/': (context) => const AuthPage(),
        // '/Home': (context) => const HomePage(),
        '/create': (context) => const CreateActivePage(),
        // '/calendar': (context) => const CalendarPage(),
        // '/setting': (context) => const SettingPage(),
      },
    );
  }
}
