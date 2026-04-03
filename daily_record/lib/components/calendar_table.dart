import 'package:daily_record/components/press_scale.dart';
import 'package:daily_record/core/models/get_status_daily_record_request.dart';
import 'package:daily_record/core/services/get_daily_record_service.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CalendarTable extends StatefulWidget {
  final Function(String)? onDateSelected;
  const CalendarTable({this.onDateSelected});

  @override
  State<CalendarTable> createState() => CalendarTableState();
}

class CalendarTableState extends State<CalendarTable> {
  DateTime _selectedMonth = DateTime.now(); // เดือนปจุบัน
  DateTime? _selectedDate; // วันที่เลือก
  final _service = GetDailyRecordService();
  bool _isLoading = false;

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
    _fetchStatus(_selectedMonth.month, _selectedMonth.year);
  }

  // ฟังก์ชันสำหรับดึงจำนวนวันในเดือน
  int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  // ฟังก์ชันสำหรับดึงวันแรกของเดือน (0 = อาทิตย์, 1 = จันทร์, ...)
  int getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday % 7;
  }

  void previousMonth() {
    final lastMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month - 1,
      1,
    );
    setState(() {
      _selectedMonth = lastMonth;
    });
    _fetchStatus(lastMonth.month, lastMonth.year);
  }

  void nextMonth() {
    final nextMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      1,
    );
    setState(() {
      _selectedMonth = nextMonth;
    });
    _fetchStatus(nextMonth.month, nextMonth.year);
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

      final response = await _service.getStatusDailyRecords(request);

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
      debugPrint('Fetch error: $e');
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
                ElevatedButton(
                  onPressed: previousMonth,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: themeItem.secondary,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: themeItem.background2,
                  ),
                ),
                Text(
                  '$monthText $buddhistYear',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: nextMonth,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: themeItem.secondary,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: themeItem.background2,
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
          child: GridView.builder(
            // shrinkWrap: true,
            // physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(5),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: itemCount, // 6 แถว x 7 วัน
            itemBuilder: (context, index) {
              int dayNumber = index - firstDayOfWeek + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return SizedBox(); // ช่องว่าง
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
                    border: Border.all(color: themeItem.primary, width: 4),
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
                            fontSize: 16,
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
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: themeItem.status2,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      if (hasRecord)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: themeItem.status1,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
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
