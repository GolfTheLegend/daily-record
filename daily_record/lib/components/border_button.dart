import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BorderButton extends StatefulWidget {
  final double? width;
  final Color borderColor1;
  final Color borderColor2;
  final Color backgroundColor;
  final String text;
  final Function()? onPressed;
  const BorderButton({
    super.key,
    this.width,
    required this.borderColor1,
    required this.borderColor2,
    required this.backgroundColor,
    required this.text,
    this.onPressed,
  });

  @override
  State<BorderButton> createState() => _BorderButtonState();
}

class _BorderButtonState extends State<BorderButton> {
  @override
  Widget build(BuildContext context) {
    final themeItem = Provider.of<ThemeProvider>(context).currentThemeItem;
    
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: widget.width ?? null,
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
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                widget.onPressed?.call();
              },
              child: Text(
                widget.text,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,color: themeItem!.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
