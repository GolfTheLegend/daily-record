import 'dart:async';

import 'package:daily_record/core/models/get_daily_record_request.dart';
import 'package:daily_record/core/models/get_daily_record_response.dart';
import 'package:daily_record/core/services/get_daily_record_service.dart';
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
  final _service = GetDailyRecordService();
  List<DailyRecordItem> _records = [];
  List<DailyRecordItem> _currentRecords = [];
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchRecords(_selectedDate, true);
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      _fetchRecords(_selectedDate, false);
    });
  }

  int _toMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  Future<void> _fetchRecords(DateTime date, bool onRefresh) async {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final nowMin = now.hour * 60 + now.minute;

    if (onRefresh) {
      setState(() {
        _isLoading = true;
        _records = [];
        _currentRecords = [];
      });
    }

    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    try {
      final request = GetDailyRecordsRequest(
        dateFrom: dateStr,
        dateTo: dateStr,
      );

      final response = await _service.getDailyRecords(request);

      final isToday =
          now.year == date.year &&
          now.month == date.month &&
          now.day == date.day;

      final current = response.data.where((i) {
        if (!isToday) return false;
        if (i.startTime == null || i.endTime == null) return false;

        final start = _toMinutes(i.startTime!);
        final end = _toMinutes(i.endTime!);

        return nowMin >= start && nowMin <= end;
      }).toList();

      final currentIds = current.map((i) => i.id).toSet();
      final record = response.data
          .where((i) => !currentIds.contains(i.id))
          .toList();

      if (!mounted) return;

      setState(() {
        _currentRecords = current;
        _records = record;
      });
    } catch (e) {
      debugPrint('Fetch error: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;
    final upcoming = _records.sublist(0);

    return Background(
      floatingActionButton: _floatingButton(context),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              child: ActivityHeader(
                onDateSelected: (DateTime date) {
                  setState(() => _selectedDate = date);
                  _fetchRecords(date, true);
                },
              ),
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
                        _sectionHeader(context, 'ขณะนี้'),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 240,
                          ), // ความสูง ~2 cards
                          child: SingleChildScrollView(
                            child: Column(
                              children: _currentRecords.isNotEmpty
                                  ? _currentRecords
                                        .map(
                                          (item) => ActivityCard(
                                            icon: Icons.directions_run,
                                            title: item.activityHeader ?? '-',
                                            time:
                                                '${item.startTime} - ${item.endTime}',
                                          ),
                                        )
                                        .toList()
                                  : [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Text(
                                          'ไม่มีรายการ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: themeItem.textPrimary
                                                .withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ),
                                    ],
                            ),
                          ),
                        ),
                        _sectionHeader(context, 'รายการถัดไป'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      itemCount: upcoming.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 0),
                      itemBuilder: (context, index) {
                        final item = upcoming[index];
                        return ActivityCard(
                          icon: Icons.description,
                          title: item.activityHeader ?? '-',
                          time: '${item.startTime} - ${item.endTime}',
                          trailing: item.repeatType,
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
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: themeItem.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(thickness: 1.5, color: themeItem.textPrimary)),
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
    iconTheme: IconThemeData(color: themeItem.primary),

    children: [
      _customDial(
        context,
        Icons.settings,
        childrenButtonSize,
        () => Navigator.pushNamed(context, '/setting'),
      ),
      _customDial(
        context,
        Icons.calendar_month,
        childrenButtonSize,
        () => Navigator.pushNamed(context, '/calendar'),
      ),
    ],

    child: _circleButton(context, Icons.add, mainButtonSize, null),
  );
}

SpeedDialChild _customDial(
  BuildContext context,
  IconData icon,
  double size,
  Function()? onTap,
) {
  return SpeedDialChild(
    backgroundColor: Colors.transparent,
    elevation: 0,
    onTap: onTap,
    child: _circleButton(context, icon, size, null),
  );
}

Widget _circleButton(
  BuildContext context,
  IconData icon,
  double size,
  Function()? onTap,
) {
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
              border: Border.all(color: themeItem.primary, width: innerBorder),
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
