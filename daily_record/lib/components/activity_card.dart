import 'package:flutter/material.dart';

class ActivityCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String time;
  final Color titleColor;
  final String? trailing;
  final Color trailingColor;

  const ActivityCard({
    super.key,
    required this.icon,
    required this.title,
    required this.time,
    this.titleColor = Colors.black,
    this.trailing,
    this.trailingColor = Colors.black,
  });

  @override
  State<ActivityCard> createState() => ActivityCardState();
}

class ActivityCardState extends State<ActivityCard> {
  bool _showActions = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showActions = !_showActions;
        });
      },
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.pink, width: 4),
                  ),
                  child: Icon(widget.icon,size: 40),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'เวลา : ${widget.time}',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                if (widget.trailing != null)
                  Text(
                    widget.trailing!,
                    style: TextStyle(
                      color: widget.trailingColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),

          // 🔹 ปุ่มที่โผล่ออกมา
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Container(
              child: Column(
                children: [
                  if (_showActions) ...[
                    Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {
                                print('ไม่สำเร็จ');
                              },
                              child: const Text('ไม่สำเร็จ',style: TextStyle(color: Colors.white ,fontWeight: FontWeight.bold,fontSize: 16),),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {
                                print('สำเร็จ');
                              },
                              child: const Text('สำเร็จ',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
