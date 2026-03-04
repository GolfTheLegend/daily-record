import 'package:daily_record/pages/calendar_page.dart';
import 'package:daily_record/pages/create_active_page.dart';
import 'package:daily_record/pages/home_page.dart';
import 'package:daily_record/pages/setting_page.dart';
import 'package:daily_record/pages/theme_page.dart';
import 'package:daily_record/themes/theme.dart';
import 'package:daily_record/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/create': (context) => const CreateActivePage(),
        '/calendar': (context) => const CalendarPage(),
        '/setting': (context) => const SettingPage(),
        '/theme': (context) => const ThemePage(),
      },
    );
  }
}
