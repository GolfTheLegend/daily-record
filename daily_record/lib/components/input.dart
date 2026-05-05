import 'package:daily_record/core/themes/theme.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Input extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final int maxLength; //จำนวนข้อความสูงสุดที่กรอกได้
  final String? hintText; //ตัวอักษรเมื่อไม่ได้กรอก
  final TextEditingController? controller;
  final bool isMultiline; //เปลี่ยนเป็นแบบหลายบรรทัดได้
  final double? height;
  final bool? hideMaxWord;
  final bool ispassword;
  final FocusNode? focusNode;

  const Input({
    super.key,
    this.onChanged,
    this.maxLength = 50,
    this.hintText,
    this.controller,
    this.isMultiline = false,
    this.height,
    this.hideMaxWord = false,
    this.ispassword = false,
    this.focusNode,
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  late TextEditingController _controller;
  late bool _isExternalController;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _isExternalController = widget.controller != null;
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _obscureText = widget.ispassword;
  }

  void _onTextChanged() {
    setState(() {});
    widget.onChanged?.call(_controller.text);
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
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: widget.height ?? null,
      decoration: BoxDecoration(
        color: themeItem.background2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeItem.primary, width: 2),
      ),
      child: widget.isMultiline
          ? _buildMultiline(themeItem.text1, themeItem)
          : _buildSingleLine(themeItem.text1, themeItem),
    );
  }

  Widget _buildSingleLine(Color textColor, ThemeItem themeItem) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            maxLength: widget.maxLength,
            focusNode: widget.focusNode,
            maxLines: 1,
            obscureText: _obscureText,
            decoration: InputDecoration(
              hintText: widget.hintText ?? '',
              border: InputBorder.none,
              counterText: '',
              isDense: true,
            ),
            style: TextStyle(color: textColor),
          ),
        ),
        // ปุ่ม toggle password
        if (widget.ispassword) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => _obscureText = !_obscureText),
            child: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              size: 20,
              color: themeItem.primary.withValues(alpha: 0.7),
            ),
          ),
        ],
        if (widget.hideMaxWord == false) ...[
          const SizedBox(width: 8),
          _buildCounter(themeItem),
        ],
      ],
    );
  }

  Widget _buildMultiline(Color textColor, ThemeItem themeItem) {
    return Stack(
      children: [
        TextField(
          controller: _controller,
          maxLength: widget.maxLength,
          focusNode: widget.focusNode,
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
        if (widget.hideMaxWord == false) ...[
          Positioned(right: 0, bottom: 0, child: _buildCounter(themeItem)),
        ],
      ],
    );
  }

  Widget _buildCounter(ThemeItem themeItem) {
    return Text(
      "${_controller.text.length}/${widget.maxLength}",
      style: TextStyle(
        fontSize: 12,
        color: themeItem.primary.withValues(alpha: 0.8),
      ),
    );
  }
}
