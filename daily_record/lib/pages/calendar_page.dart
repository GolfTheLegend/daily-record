import 'dart:math';

import 'package:daily_record/components/background.dart';
import 'package:daily_record/components/border_button.dart';
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
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color.fromARGB(255, 201, 201, 201),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 5),
                          Row(
                            children: [
                              _dot(Color(0xFF84FF8D)),
                              const SizedBox(width: 5),
                              const Text(
                                'มีรายการ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10),
                              _dot(Colors.redAccent),
                              const SizedBox(width: 5),
                              const Text(
                                'วันสำคัญ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 5),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFFFAAEA),
                                width: 4,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'รายละเอียด',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color.fromARGB(255, 201, 201, 201),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(10),
                        child: Text('x'),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      BorderButton(
                        width: min(
                          MediaQuery.of(context).size.width * 0.3,
                          500,
                        ),
                        borderColor1: const Color(0xFFEB00B1),
                        borderColor2: const Color(0xFFFFAAEA),
                        backgroundColor: Colors.white,
                        text: 'กลับ',
                      ),
                      BorderButton(
                        width: min(
                          MediaQuery.of(context).size.width * 0.3,
                          500,
                        ),
                        borderColor1: Colors.black,
                        borderColor2: Colors.white,
                        backgroundColor: Color(0xFF84FF8D),
                        text: '+ เพิ่ม',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color dotColor) {
    return Container(
      decoration: BoxDecoration(
        color: dotColor,
        borderRadius: BorderRadius.circular(10),
      ),
      width: 20,
      height: 20,
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
  List<int> waitingDates = [
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
                    backgroundColor: Colors.black,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_outlined),
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
            children: weekNameTH
                .map((element) => _BoxHeader(text: element))
                .toList(),
          ),
        ),
        _Line(),
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

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFAAEA), width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
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
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
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
                            color: isWaiting ? Colors.red : Colors.green,
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
