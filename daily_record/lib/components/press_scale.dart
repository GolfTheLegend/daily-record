import 'package:flutter/material.dart';

class PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const PressScale({required this.child, required this.onTap});

  @override
  State<PressScale> createState() => PressScaleState();
}

class PressScaleState extends State<PressScale> {
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