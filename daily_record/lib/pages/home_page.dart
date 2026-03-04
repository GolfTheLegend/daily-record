import 'package:daily_record/components/activity_card.dart';
import 'package:daily_record/components/activity_header.dart';
import 'package:daily_record/components/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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
        'titleColor': Colors.red,
        'trailing': 'สำคัญ',
        'trailingColor': Colors.red,
      },
      {
        'icon': Icons.restaurant,
        'title': 'ทานอาหาร',
        'time': '09:00',
        'titleColor': Colors.green,
        'trailing': 'ทุกวัน',
        'trailingColor': Colors.green,
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
                        _sectionHeader('ขณะนี้'),
                        ActivityCard(
                          icon: Icons.directions_run,
                          title: 'ออกกำลังกาย',
                          time: '06:00',
                        ),
                        _sectionHeader('รายการถัดไป'),
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
                          titleColor: item['titleColor'] ?? Colors.black,
                          trailing: item['trailing'],
                          trailingColor: item['trailingColor'] ?? Colors.black,
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

Widget _sectionHeader(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider(thickness: 1.5)),
      ],
    ),
  );
}

Widget _floatingButton(BuildContext context) {
  final double mainButtonSize = 75;
  final double childrenButtonSize = 65;
  return SpeedDial(
    icon: Icons.add,
    activeIcon: Icons.close,
    spaceBetweenChildren: 10, // <<< ระยะห่างจริง
    backgroundColor: Colors.black,
    overlayColor: Colors.black,
    elevation: 0,
    childPadding: const EdgeInsets.all(0),
    buttonSize: Size(mainButtonSize, mainButtonSize),
    childrenButtonSize: Size(childrenButtonSize, childrenButtonSize),

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
          border: Border.all(color: Colors.pink, width: outerBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(outerBorder),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFFFFAAEA),
                width: innerBorder,
              ),
            ),
            child: Center(
              child: Icon(icon, color: Colors.black, size: size * 0.45),
            ),
          ),
        ),
      ),
    ),
  );
}
