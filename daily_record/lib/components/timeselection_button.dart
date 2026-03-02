import 'dart:math';

import 'package:daily_record/components/border_button.dart';
import 'package:flutter/material.dart';

class TimeSelectionButton extends StatefulWidget {
  const TimeSelectionButton({super.key});

  @override
  State<TimeSelectionButton> createState() => _TimeSelectionButtonState();
}

class _TimeSelectionButtonState extends State<TimeSelectionButton> {
  int _hours = 12;
  int _minutes = 0;

  void _showTimePicker() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: _TimePickerModal(
          initialHour: _hours,
          initialMinute: _minutes,
          onSave: (h, m) => setState(() {
            _hours = h;
            _minutes = m;
          }),
        ),
      ),
    );
  }

  Widget _timeBox(String value) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String hh = _hours.toString().padLeft(2, '0');
    final String mm = _minutes.toString().padLeft(2, '0');

    return GestureDetector(
      onTap: _showTimePicker,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _timeBox(hh),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
          ),
          _timeBox(mm),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Modal
// ─────────────────────────────────────────────

class _TimePickerModal extends StatefulWidget {
  final int initialHour;
  final int initialMinute;
  final void Function(int hour, int minute) onSave;

  const _TimePickerModal({
    required this.initialHour,
    required this.initialMinute,
    required this.onSave,
  });

  @override
  State<_TimePickerModal> createState() => _TimePickerModalState();
}

class _TimePickerModalState extends State<_TimePickerModal> {
  late int _selectedHour;
  late int _selectedMinute;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  static const double _itemHeight = 64;
  static const Color _highlightColor = Color(0xFFE91E8C); // pink

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialHour;
    _selectedMinute = widget.initialMinute;
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  Widget _buildPicker({
    required FixedExtentScrollController controller,
    required int itemCount,
    required int selectedValue,
    required void Function(int) onChanged,
  }) {
    return SizedBox(
      width: 90,
      height: _itemHeight * 3,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: _itemHeight,
        physics: const FixedExtentScrollPhysics(),
        perspective: 0.003,
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            final bool isSelected = index == selectedValue;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: isSelected
                    ? Border.all(color: _highlightColor, width: 2.5)
                    : Border.all(color: Colors.transparent, width: 2.5),
              ),
              alignment: Alignment.center,
              child: Text(
                index.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.black87 : Colors.grey.shade400,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Pickers row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildPicker(
                controller: _hourController,
                itemCount: 24,
                selectedValue: _selectedHour,
                onChanged: (v) => setState(() => _selectedHour = v),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              _buildPicker(
                controller: _minuteController,
                itemCount: 60,
                selectedValue: _selectedMinute,
                onChanged: (v) => setState(() => _selectedMinute = v),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Buttons row ──
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
              const SizedBox(width: 12),
              Expanded(
                child: BorderButton(
                  onPressed: () {
                    widget.onSave(_selectedHour, _selectedMinute);
                    Navigator.pop(context);
                  },
                  borderColor1: Colors.black,
                  borderColor2: Colors.white,
                  backgroundColor: const Color(0xFF84FF8D),
                  text: 'บันทึก',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
