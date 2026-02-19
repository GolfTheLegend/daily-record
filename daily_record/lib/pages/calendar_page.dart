import 'package:daily_record/components/background.dart';
import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Background(
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 40,
                    color: Colors.black,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'ปฏิทิน',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(flex: 5, child: _CalendarTable()),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(color: Colors.purpleAccent[100]),
            ),
          ),
        ],
      ),
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
    return Container(
      width: MediaQuery.of(context).size.width / 9,
      height: 40,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.text,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarTable extends StatefulWidget {
  const _CalendarTable();

  @override
  State<_CalendarTable> createState() => __CalendarTableState();
}

class __CalendarTableState extends State<_CalendarTable> {
  DateTime selectedDate = DateTime(2025, 2, 1); // กุมภาพันธ์ 2568
  List<int> markedDates = [
    1,
    3,
    4,
    6,
    8,
    9,
    15,
    16,
    18,
    23,
    28,
  ]; // วันที่มีเครื่องหมาย
  List<int> waitingDates = []; // วันที่รอดำเนินการ (สีแดง)

  // ฟังก์ชันสำหรับดึงจำนวนวันในเดือน
  int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  // ฟังก์ชันสำหรับดึงวันแรกของเดือน (0 = อาทิตย์, 1 = จันทร์, ...)
  int getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday % 7;
  }

  @override
  Widget build(BuildContext context) {
    int daysInMonth = getDaysInMonth(selectedDate);
    int firstDayOfWeek = getFirstDayOfMonth(selectedDate);
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.tealAccent,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: Colors.black,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_outlined),
                ),
                Text(
                  'กุมภาพันธ์ 2568',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: Colors.black,
                  ),
                  child: const Icon(Icons.arrow_forward_ios_outlined),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BoxHeader(text: 'อา.'),
              _BoxHeader(text: 'จ.'),
              _BoxHeader(text: 'อ.'),
              _BoxHeader(text: 'พ.'),
              _BoxHeader(text: 'พฤ.'),
              _BoxHeader(text: 'ศ.'),
              _BoxHeader(text: 'ส.'),
            ],
          ),
        ),
        _Line(),
        Expanded(
          flex: 6,
          child: GridView.builder(
            padding: const EdgeInsets.all(0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 42, // 6 แถว x 7 วัน
            itemBuilder: (context, index) {
              int dayNumber = index - firstDayOfWeek + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return Container(); // ช่องว่าง
              }
              bool isWaiting = waitingDates.contains(dayNumber);
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFAAEA), width: 4),
                ),
                child: Stack(
                  children: [
                    // Center(
                    //   child: Text(
                    //     '$dayNumber',
                    //     style: const TextStyle(
                    //       fontSize: 18,
                    //       fontWeight: FontWeight.w500,
                    //     ),
                    //   ),
                    // ),
                    // if (isWaiting)
                    //   Positioned(
                    //     top: 4,
                    //     right: 4,
                    //     child: Container(
                    //       width: 8,
                    //       height: 8,
                    //       decoration: BoxDecoration(
                    //         color: isWaiting ? Colors.red : Colors.green,
                    //         shape: BoxShape.circle,
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
              );
            },
          ),
        ),
        _Line(),
      ],
    );
  }
}

Widget _Line() {
  return Container(
    height: 5,
    margin: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: Colors.black,
    ),
  );
}
