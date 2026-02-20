import 'package:flutter/material.dart';

class BorderButton extends StatefulWidget {
  final double width;
  final Color borderColor1;
  final Color borderColor2;
  final Color backgroundColor;
  const BorderButton({
    super.key,
    required this.width,
    required this.borderColor1,
    required this.borderColor2,
    required this.backgroundColor,
  });

  @override
  State<BorderButton> createState() => _BorderButtonState();
}

class _BorderButtonState extends State<BorderButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: widget.width,
        height: 55,
        child: Container(
          padding: const EdgeInsets.all(5), // ความหนาขอบนอก
          decoration: BoxDecoration(
            color: widget.borderColor1, // ชั้นนอกสุด
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: const EdgeInsets.all(5), // ความหนาขอบใน
            decoration: BoxDecoration(
              color: widget.borderColor2, // ชั้นใน
              borderRadius: BorderRadius.circular(15),
            ),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: widget.backgroundColor,
                foregroundColor: Colors.black,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                print('Back');
              },
              child: const Text(
                'กลับ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
