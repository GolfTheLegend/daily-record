import 'package:daily_record/core/themes/theme.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Input extends StatefulWidget {
  final int maxLength; //จำนวนข้อความสูงสุดที่กรอกได้
  final String? hintText; //ตัวอักษรเมื่อไม่ได้กรอก
  final TextEditingController? controller;
  final bool isMultiline; //เปลี่ยนเป็นแบบหลายบรรทัดได้
  final double? height;

  const Input({
    super.key,
    this.maxLength = 50,
    this.hintText,
    this.controller,
    this.isMultiline = false,
    this.height,
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  late TextEditingController _controller;
  late bool _isExternalController;

  @override
  void initState() {
    super.initState();
    _isExternalController = widget.controller != null;
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);

    // dispose เฉพาะกรณีที่เราสร้างเอง
    if (!_isExternalController) {
      _controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeItem = Provider.of<ThemeProvider>(context).currentThemeItem;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: widget.height ?? null,
      decoration: BoxDecoration(
        color: themeItem!.background2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeItem.secondary),
      ),
      child: widget.isMultiline
          ? _buildMultiline(themeItem.text1,themeItem)
          : _buildSingleLine(themeItem.text1,themeItem),
    );
  }

  Widget _buildSingleLine(Color textColor,ThemeItem themeItem) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            maxLength: widget.maxLength,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: widget.hintText ?? '',
              border: InputBorder.none,
              counterText: '',
              isDense: true,
            ),
            style: TextStyle(color: textColor),
          ),
        ),
        const SizedBox(width: 8),
        _buildCounter(themeItem),
      ],
    );
  }

  Widget _buildMultiline(Color textColor,ThemeItem themeItem) {
    return Stack(
      children: [
        TextField(
          controller: _controller,
          maxLength: widget.maxLength,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: widget.hintText ?? '',
            border: InputBorder.none,
            counterText: '',
            isDense: true,
          ),
          style: TextStyle(color: textColor),
        ),
        Positioned(right: 0, bottom: 0, child: _buildCounter(themeItem)),
      ],
    );
  }

  Widget _buildCounter(ThemeItem themeItem) {
    return Text(
      "${_controller.text.length}/${widget.maxLength}",
      style: TextStyle(fontSize: 12, color: themeItem.primary.withOpacity(0.8)),
    );
  }
}
