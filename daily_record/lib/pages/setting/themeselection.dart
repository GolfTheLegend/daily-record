import 'package:daily_record/components/border_button.dart';
import 'package:daily_record/components/press_scale.dart';
import 'package:daily_record/core/constants/theme.dart';
import 'package:flutter/material.dart';

class Themeselection extends StatelessWidget {
  final ValueChanged<int> onSelect;

  const Themeselection({super.key, required this.onSelect});

  void _onPressed(BuildContext context, int key) {
    print({'Return'});
    onSelect(key);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.4,
            child: SingleChildScrollView(
              child: Column(
                children: themeDataList.map((item) {
                  return PressScale(
                    onTap: () => _onPressed(context, item.key),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ThemeColor(item.background2),
                          const SizedBox(width: 10),
                          ThemeColor(item.primary),
                          const SizedBox(width: 10),
                          ThemeColor(item.secondary),
                          const SizedBox(width: 10),
                          ThemeColor(Colors.black),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: BorderButton(
                  onPressed: () => Navigator.pop(context),
                  borderColor1: const Color(0xFFEB00B1),
                  borderColor2: const Color(0xFFFFAAEA),
                  backgroundColor: Colors.white,
                  text: 'กลับ',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ThemeColor extends StatelessWidget {
  final Color color;
  final Widget? child;

  const ThemeColor(this.color, {super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey),
      ),
      child: child,
    );
  }
}
