import 'dart:async';
import 'package:flutter/material.dart';

class ActivityHeader extends StatefulWidget {
  const ActivityHeader({super.key});

  @override
  State<ActivityHeader> createState() => _ActivityHeaderState();
}

class _ActivityHeaderState extends State<ActivityHeader> {
  String _currentTime = '';
  Timer? _timer;

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
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'รายการวันนี้',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _currentTime, // ← ใช้ตัวแปรนี้แทน string คงที่
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          // ถ้าต้องการแสดงวันที่แบบไทยด้วย (ตัวอย่างง่าย ๆ)
          '${DateTime.now().day} ${['มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'][DateTime.now().month - 1]} ${DateTime.now().year + 543}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
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
                _DateBox('วันนี้'),
                const SizedBox(width: 10),
                ...List.generate(
                  30,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _DateBox('${index + 1}'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _DateBox(String text) {
    return Container(
      width: 80,
      height: 50,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFAAEA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 224, 97, 193),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
