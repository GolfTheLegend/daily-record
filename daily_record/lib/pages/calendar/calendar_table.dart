import 'package:daily_record/components/app_alert.dart';
import 'package:daily_record/components/loading.dart';
import 'package:daily_record/components/press_scale.dart';
import 'package:daily_record/core/di/injection.dart';
import 'package:daily_record/core/models/get_status_daily_record_request.dart';
import 'package:daily_record/core/repositories/repositories.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CalendarTable extends StatefulWidget {
  final Function(String)? onDateSelected;
  const CalendarTable({super.key, this.onDateSelected});

  @override
  State<CalendarTable> createState() => CalendarTableState();
}

class CalendarTableState extends State<CalendarTable> {
  DateTime _selectedMonth = DateTime.now(); // เดือนปจุบัน
  DateTime? _selectedDate; // วันที่เลือก
  final IDailyRecordRepository _dailyRecordRepository =
      getIt<IDailyRecordRepository>();
  bool _isLoading = false;
  int _slideDirection = 1;

  Future<void> refresh() async {
    await _fetchStatus(_selectedMonth.month, _selectedMonth.year);
  }

  List<String> monthNameTH = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];
  List<String> weekNameTH = ['อา.', 'จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.'];
  List<int> waitingDates = []; // วันที่สำคัญ
  List<int> hasDayRecord = []; // วันที่มีบันทึกกิจกรรม

  @override
  void initState() {
    super.initState();

    _selectedDate = DateTime.now();

    _initLoad();
  }

  Future<void> _initLoad() async {
    await _fetchStatus(_selectedMonth.month, _selectedMonth.year);
  }

  // ฟังก์ชันสำหรับดึงจำนวนวันในเดือน
  int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  // ฟังก์ชันสำหรับดึงวันแรกของเดือน (0 = อาทิตย์, 1 = จันทร์, ...)
  int getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday % 7;
  }

  void previousMonth() async {
    final lastMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month - 1,
      1,
    );
    setState(() {
      _slideDirection = -1;
      _selectedMonth = lastMonth;
    });
    await _fetchStatus(lastMonth.month, lastMonth.year);
  }

  void nextMonth() async {
    final nextMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      1,
    );
    setState(() {
      _slideDirection = 1;
      _selectedMonth = nextMonth;
    });
    await _fetchStatus(nextMonth.month, nextMonth.year);
  }

  Future<void> _fetchStatus(int month, int year) async {
    setState(() {
      _isLoading = true;
    });

    setState(() {
      waitingDates = [];
      hasDayRecord = [];
    });

    try {
      final request = GetStatusDailyRecordsRequest(month: month, year: year);
      print(request.toMap());

      final response = await _dailyRecordRepository.getStatusDailyRecords(request);

      final waiting = <int>[];
      final record = <int>[];

      for (final i in response.data) {
        if (i.hasRecord) record.add(i.day);
        if (i.important) waiting.add(i.day);
      }

      if (!mounted) return;

      setState(() {
        waitingDates = waiting;
        hasDayRecord = record;
      });
    } catch (e) {
      if (mounted) {
        AppAlert.show(
          context,
          title: 'เกิดข้อผิดพลาด',
          message: e.toString(),
          type: AlertType.error,
        );
      }
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;
    int daysInMonth = getDaysInMonth(_selectedMonth);
    int firstDayOfWeek = getFirstDayOfMonth(_selectedMonth);
    int totalItems = firstDayOfWeek + daysInMonth;
    int rowCount = (totalItems / 7).ceil();
    int itemCount = rowCount * 7;
    String monthText = monthNameTH[_selectedMonth.month - 1]; //แสดงชื่อเดือน
    int buddhistYear = _selectedMonth.year + 543; //แสดงเลขปี

    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PressScale(
                  onTap: () => previousMonth(),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                    decoration: BoxDecoration(
                      color: themeItem.secondary,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: themeItem.background2,
                      size: 18,
                    ),
                  ),
                ),
                Text(
                  '$monthText $buddhistYear',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                PressScale(
                  onTap: () => nextMonth(),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                    decoration: BoxDecoration(
                      color: themeItem.secondary,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: themeItem.background2,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekNameTH
                .map((element) => _BoxHeader(text: element))
                .toList(),
          ),
        ),
        _Line(themeItem.textPrimary),
        Expanded(
          flex: 6,
          child: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) {
                  final isEntering = child.key == ValueKey(_selectedMonth);
                  final offsetX = isEntering
                      ? _slideDirection * 1.0
                      : _slideDirection * -1.0;

                  final slideAnim =
                      Tween<Offset>(
                        begin: Offset(offsetX, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );

                  return ClipRect(
                    child: SlideTransition(
                      position: slideAnim,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_selectedMonth),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(5),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      int dayNumber = index - firstDayOfWeek + 1;
                      if (dayNumber < 1 || dayNumber > daysInMonth) {
                        return const SizedBox();
                      }
                      bool isWaiting = waitingDates.contains(dayNumber);
                      bool hasRecord = hasDayRecord.contains(dayNumber);

                      String dateText =
                          '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}-${dayNumber.toString().padLeft(2, '0')}';

                      bool isSelected =
                          _selectedDate != null &&
                          _selectedDate!.day == dayNumber &&
                          _selectedDate!.month == _selectedMonth.month &&
                          _selectedDate!.year == _selectedMonth.year;

                      return PressScale(
                        onTap: () {
                          setState(
                            () => _selectedDate = DateTime(
                              _selectedMonth.year,
                              _selectedMonth.month,
                              dayNumber,
                            ),
                          );
                          widget.onDateSelected?.call(dateText);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? themeItem.secondary
                                : themeItem.background2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: themeItem.primary,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  '$dayNumber',
                                  style: TextStyle(
                                    fontSize: (MediaQuery.of(context).size.width * 0.040).clamp(0.0, 30.0),
                                    color: isSelected
                                        ? themeItem.background2
                                        : themeItem.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isWaiting)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                     final dotSize = (MediaQuery.of(context).size.width * 0.022).clamp(0.0, 20.0);
                                      return Container(
                                        width: dotSize,
                                        height: dotSize,
                                        decoration: BoxDecoration(
                                          color: themeItem.status2,
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              if (hasRecord)
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final dotSize = (MediaQuery.of(context).size.width * 0.022).clamp(0.0, 20.0);
                                      return Container(
                                        width: dotSize,
                                        height: dotSize,
                                        decoration: BoxDecoration(
                                          color: themeItem.status1,
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              AnimatedOpacity(
                opacity: _isLoading ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_isLoading,
                  child: Container(
                    color: themeItem.background2.withValues(alpha: 0.6),
                    child: const Center(
                      child: LoadingAnimation(width: 50, height: 50),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _Line(themeItem.textPrimary),
      ],
    );
  }
}

class _BoxHeader extends StatefulWidget {
  final String text;
  const _BoxHeader({required this.text});

  @override
  State<_BoxHeader> createState() => __BoxHeaderState();
}

class __BoxHeaderState extends State<_BoxHeader> {
  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;

    return Container(
      width: MediaQuery.of(context).size.width / 9,
      height: 40,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: themeItem.primary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: themeItem.background2,
            ),
          ),
        ),
      ),
    );
  }
}

Widget _Line(Color color) {
  return Container(
    height: 5,
    margin: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: color,
    ),
  );
}
