import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CalendarTable extends StatefulWidget {
  const CalendarTable();

  @override
  State<CalendarTable> createState() => CalendarTableState();
}

class CalendarTableState extends State<CalendarTable> {
  DateTime selectedDate = DateTime.now(); // เดือนปจุบัน
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
  List<int> waitingDates = [15, 16, 18, 23, 28]; // วันที่สำคัญ
  List<int> hasDayRecord = [2, 20, 25, 28]; // วันที่มีบันทึกกิจกรรม

  // ฟังก์ชันสำหรับดึงจำนวนวันในเดือน
  int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  // ฟังก์ชันสำหรับดึงวันแรกของเดือน (0 = อาทิตย์, 1 = จันทร์, ...)
  int getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday % 7;
  }

  void previousMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month - 1, 1);
    });
  }

  void nextMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;
    int daysInMonth = getDaysInMonth(selectedDate);
    int firstDayOfWeek = getFirstDayOfMonth(selectedDate);
    int totalItems = firstDayOfWeek + daysInMonth;
    int rowCount = (totalItems / 7).ceil();
    int itemCount = rowCount * 7;
    String monthText = monthNameTH[selectedDate.month - 1]; //แสดงชื่อเดือน
    int buddhistYear = selectedDate.year + 543; //แสดงเลขปี

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

              return Container(
                decoration: BoxDecoration(
                  color: themeItem.background2,
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
                          color: themeItem.textPrimary,
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
