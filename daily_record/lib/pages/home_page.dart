import 'package:daily_record/components/activity_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _BackGroundLayer(
        Color(0xFFEB00B1),
        0,
        _BackGroundLayer(
          Color(0xFFFFAAEA),
          10,
          _BackGroundLayer(
            Colors.white,
            10,
            _BackGroundLayer(
              Colors.transparent,
              10,
              Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(width: double.infinity, child: _Header()),
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
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                child: Column(
                                  children: [
                                    ActivityCard(
                                      icon: Icons.description,
                                      title: 'ทำงาน',
                                      time: '09:00',
                                      titleColor: Colors.red,
                                      trailing: 'สำคัญ',
                                      trailingColor: Colors.red,
                                    ),
                                    ActivityCard(
                                      icon: Icons.restaurant,
                                      title: 'ทานอาหาร',
                                      time: '09:00',
                                      titleColor: Colors.green,
                                      trailing: 'ทุกวัน',
                                      trailingColor: Colors.green,
                                    ),
                                    ActivityCard(
                                      icon: Icons.local_cafe,
                                      title: 'พักผ่อน',
                                      time: '09:00',
                                    ),
                                    ActivityCard(
                                      icon: Icons.restaurant,
                                      title: 'ทานอาหาร',
                                      time: '09:00',
                                      titleColor: Colors.green,
                                      trailing: 'ทุกวัน',
                                      trailingColor: Colors.green,
                                    ),
                                    ActivityCard(
                                      icon: Icons.local_cafe,
                                      title: 'พักผ่อน',
                                      time: '09:00',
                                    ),
                                    ActivityCard(
                                      icon: Icons.restaurant,
                                      title: 'ทานอาหาร',
                                      time: '09:00',
                                      titleColor: Colors.green,
                                      trailing: 'ทุกวัน',
                                      trailingColor: Colors.green,
                                    ),
                                    ActivityCard(
                                      icon: Icons.local_cafe,
                                      title: 'พักผ่อน',
                                      time: '09:00',
                                    ),
                                    ActivityCard(
                                      icon: Icons.restaurant,
                                      title: 'ทานอาหาร',
                                      time: '09:00',
                                      titleColor: Colors.green,
                                      trailing: 'ทุกวัน',
                                      trailingColor: Colors.green,
                                    ),
                                    ActivityCard(
                                      icon: Icons.local_cafe,
                                      title: 'พักผ่อน',
                                      time: '09:00',
                                    ),
                                    ActivityCard(
                                      icon: Icons.restaurant,
                                      title: 'ทานอาหาร',
                                      time: '09:00',
                                      titleColor: Colors.green,
                                      trailing: 'ทุกวัน',
                                      trailingColor: Colors.green,
                                    ),
                                    ActivityCard(
                                      icon: Icons.local_cafe,
                                      title: 'พักผ่อน',
                                      time: '09:00',
                                    ),
                                    ActivityCard(
                                      icon: Icons.restaurant,
                                      title: 'ทานอาหาร',
                                      time: '09:00',
                                      titleColor: Colors.green,
                                      trailing: 'ทุกวัน',
                                      trailingColor: Colors.green,
                                    ),
                                    ActivityCard(
                                      icon: Icons.local_cafe,
                                      title: 'พักผ่อน',
                                      time: '09:00',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _BackGroundLayer(Color color, double margin, Widget? child) {
  return Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(80),
    ),
    width: double.infinity,
    height: double.infinity,
    margin: EdgeInsets.symmetric(vertical: margin),
    child: child,
    clipBehavior: Clip.antiAlias,
  );
}

Widget _Header() {
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
      const Text(
        '04:00',
        style: TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 10),
      const Text(
        '1 กุมภาพันธ์ 2568',
        style: TextStyle(
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
          child: Container(
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
