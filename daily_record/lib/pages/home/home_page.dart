import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:daily_record/pages/home/activity_card.dart';
import 'package:daily_record/pages/home/activity_header.dart';
import 'package:daily_record/components/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    
    final List<Map<String, dynamic>> activities = [
      {
        'icon': Icons.description,
        'title': 'ทำงาน',
        'time': '09:00',
        'trailing': 2,
      },
      {
        'icon': Icons.restaurant,
        'title': 'ทานอาหาร',
        'time': '09:00',
        'trailing': 1,
      },
      {'icon': Icons.local_cafe, 'title': 'พักผ่อน', 'time': '09:00'},
    ];

    return Background(
      floatingActionButton: _floatingButton(context),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              child: const ActivityHeader(),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        _sectionHeader(context,'ขณะนี้'),
                        ActivityCard(
                          icon: Icons.directions_run,
                          title: 'ออกกำลังกาย',
                          time: '06:00',
                        ),
                        _sectionHeader(context,'รายการถัดไป'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ), // เผื่อที่ให้ปุ่ม Floating
                      itemCount: activities.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 0),
                      itemBuilder: (context, index) {
                        final item = activities[index];

                        return ActivityCard(
                          icon: item['icon'],
                          title: item['title'],
                          time: item['time'],
                          trailing: item['trailing'],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _sectionHeader(BuildContext context, String text) {
  final themeItem = context.watch<ThemeProvider>().currentThemeItem!;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: themeItem.textPrimary),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(thickness: 1.5,color: themeItem.textPrimary,)),
      ],
    ),
  );
}

Widget _floatingButton(BuildContext context) {
  final themeItem = context.watch<ThemeProvider>().currentThemeItem!;

  final double mainButtonSize = 75;
  final double childrenButtonSize = 65;
  return SpeedDial(
    icon: Icons.add,
    activeIcon: Icons.close,
    spaceBetweenChildren: 10, // <<< ระยะห่างจริง
    backgroundColor: themeItem.background1,
    overlayColor: Colors.black,
    elevation: 0,
    childPadding: const EdgeInsets.all(0),
    buttonSize: Size(mainButtonSize, mainButtonSize),
    childrenButtonSize: Size(childrenButtonSize, childrenButtonSize),
    iconTheme: IconThemeData(
      color: themeItem.primary,
    ),

    children: [
      _customDial(context,Icons.settings, childrenButtonSize,() => Navigator.pushNamed(context, '/setting')),
      _customDial(context,Icons.calendar_month, childrenButtonSize,() => Navigator.pushNamed(context, '/calendar')),
    ],

    child: _circleButton(context,Icons.add, mainButtonSize,null),
  );
}

SpeedDialChild _customDial(BuildContext context, IconData icon, double size,Function()? onTap) {
  return SpeedDialChild(
    backgroundColor: Colors.transparent,
    elevation: 0,
    onTap: onTap,
    child: _circleButton(context,icon, size,null),
  );
}

Widget _circleButton(BuildContext context, IconData icon, double size,Function()? onTap) {
  final themeItem = context.watch<ThemeProvider>().currentThemeItem!;

  const double outerBorder = 4;
  const double innerBorder = 4;

  return GestureDetector(
    onTap: onTap,
    child: SizedBox(
      width: size + outerBorder * 2,
      height: size + outerBorder * 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: themeItem.secondary, width: outerBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(outerBorder),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeItem.background2,
              border: Border.all(
                color: themeItem.primary,
                width: innerBorder,
              ),
            ),
            child: Center(
              child: Icon(icon, color: themeItem.text1, size: size * 0.45),
            ),
          ),
        ),
      ),
    ),
  );
}
