import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  final int maxLength;
  final String? hintText;
  final TextEditingController? controller;
  final bool isMultiline;

  const Input({
    super.key,
    this.maxLength = 50,
    this.hintText,
    this.controller,
    this.isMultiline = false,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade500),
      ),
      child: widget.isMultiline
          ? _buildMultiline()
          : _buildSingleLine(),
    );
  }

  Widget _buildSingleLine() {
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
          ),
        ),
        const SizedBox(width: 8),
        _buildCounter(),
      ],
    );
  }

  Widget _buildMultiline() {
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
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: _buildCounter(),
        ),
      ],
    );
  }

  Widget _buildCounter() {
    return Text(
      "${_controller.text.length}/${widget.maxLength}",
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade700,
      ),
    );
  }
}