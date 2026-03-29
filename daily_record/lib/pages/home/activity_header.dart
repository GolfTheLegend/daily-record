import 'dart:async';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActivityHeader extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  const ActivityHeader({super.key, this.onDateSelected});

  @override
  State<ActivityHeader> createState() => _ActivityHeaderState();
}

class _ActivityHeaderState extends State<ActivityHeader> {
  String _currentTime = '';
  Timer? _timer;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // อัปเดตเวลาทันทีครั้งแรก
    _updateTime();
    // ตั้งค่าให้อัปเดตทุก 10 วินาที (10000 ms)
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime =
          now.hour.toString().padLeft(2, '0') +
          ':' +
          now.minute.toString().padLeft(2, '0');
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // สำคัญมาก! ป้องกัน memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'รายการวันนี้',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: themeItem.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _currentTime, // ← ใช้ตัวแปรนี้แทน string คงที่
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: themeItem.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          // ถ้าต้องการแสดงวันที่แบบไทยด้วย (ตัวอย่างง่าย ๆ)
          '${DateTime.now().day} ${['มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'][DateTime.now().month - 1]} ${DateTime.now().year + 543}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: themeItem.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = today);
                    widget.onDateSelected?.call(today);
                  },
                  child: _DateBox(
                    context,
                    'วันนี้',
                    isToday: true,
                    isSelected: _selectedDate == null || _selectedDate == today,
                  ),
                ),
                const SizedBox(width: 10),
                ...List.generate(30, (index) {
                  final date = DateTime.now().add(Duration(days: index + 1));
                  final normalizedDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                  );
                  final shortMonths = [
                    'ม.ค.',
                    'ก.พ.',
                    'มี.ค.',
                    'เม.ย.',
                    'พ.ค.',
                    'มิ.ย.',
                    'ก.ค.',
                    'ส.ค.',
                    'ก.ย.',
                    'ต.ค.',
                    'พ.ย.',
                    'ธ.ค.',
                  ];
                  final dayText = '${date.day}';
                  final monthText = shortMonths[date.month - 1];

                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedDate = normalizedDate);
                        widget.onDateSelected?.call(normalizedDate);
                      },
                      child: _DateBox(
                        context,
                        dayText,
                        subtitle: monthText,
                        isSelected: _selectedDate == normalizedDate,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _DateBox(
    BuildContext context,
    String text, {
    String? subtitle,
    bool isToday = false,
    bool isSelected = false,
  }) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;

    return Container(
      width: 90,
      height: 50,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      decoration: BoxDecoration(
        color: isSelected
            ? themeItem.primary
            : themeItem.primary.withOpacity(0.4), // highlight ตรงนี้
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        decoration: BoxDecoration(
          color: themeItem.shadowPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: themeItem.background2,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: isToday
                ? Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeItem.textPrimary,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeItem.textPrimary,
                        ),
                      ),
                      if (subtitle != null) SizedBox(width: 5),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: themeItem.textPrimary,
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
