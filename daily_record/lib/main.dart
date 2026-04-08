import 'package:daily_record/pages/auth/auth_page.dart';
import 'package:daily_record/pages/calendar/calendar_page.dart';
import 'package:daily_record/pages/create_active/create_active_page.dart';
import 'package:daily_record/pages/detail/detail_page.dart';
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

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      navigatorObservers: [routeObserver],
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthPage(),
        '/Home': (context) => const HomePage(),
        '/create': (context) => const CreateActivePage(mode: PageMode.create),
        '/calendar': (context) => const CalendarPage(),
        '/detail': (context) => const DetailPage(selectionDate: '',recordData: []),
        '/setting': (context) => const SettingPage(),
      },
    );
  }
}
