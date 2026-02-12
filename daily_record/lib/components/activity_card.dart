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
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFAAEA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 224, 97, 193),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                      child: Icon(widget.icon, size: 40),
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
                          ButtonBox(
                            title: 'ไม่สำเร็จ',
                            onPressed: () {
                              print('ไม่สำเร็จ');
                            },
                            textColor: const Color.fromARGB(255, 102, 12, 6),
                            color1: const Color.fromARGB(255, 252, 95, 83),
                            color2: const Color.fromARGB(255, 102, 12, 6),
                          ),
                          const SizedBox(width: 8),
                          ButtonBox(
                            title: 'สำเร็จ',
                            onPressed: () {
                              print('สำเร็จ');
                            },
                            textColor: const Color.fromARGB(255, 7, 68, 9),
                            color1: Colors.green,
                            color2: const Color.fromARGB(255, 7, 68, 9),
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

class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressScale({required this.child, required this.onTap});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0, // ยุบลง
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.85 : 1,
          duration: const Duration(milliseconds: 100),
          child: widget.child,
        ),
      ),
    );
  }
}

class ButtonBox extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color textColor;
  final Color color1;
  final Color color2;

  const ButtonBox({
    super.key,
    required this.title,
    required this.onPressed,
    required this.textColor,
    required this.color1,
    required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        decoration: BoxDecoration(
          color: color1,
          borderRadius: BorderRadius.circular(12),
        ),
        child: _PressScale(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
            decoration: BoxDecoration(
              color: color2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
