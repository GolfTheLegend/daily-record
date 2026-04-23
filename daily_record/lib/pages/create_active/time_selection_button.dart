import 'package:daily_record/components/border_button.dart';
import 'package:daily_record/core/themes/theme.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimeSelectionButton extends StatefulWidget {
  final String? initialTime;
  final Function(String)? onTimeSelected;
  const TimeSelectionButton({super.key, this.onTimeSelected, this.initialTime});

  @override
  State<TimeSelectionButton> createState() => _TimeSelectionButtonState();
}

class _TimeSelectionButtonState extends State<TimeSelectionButton> {
  int _hours = 0;
  int _minutes = 0;

  @override
  void initState() {
    super.initState();

    if (widget.initialTime != null && widget.initialTime!.isNotEmpty) {
      final parts = widget.initialTime!.split(':');

      if (parts.length == 2) {
        _hours = int.tryParse(parts[0]) ?? 0;
        _minutes = int.tryParse(parts[1]) ?? 0;
      }
    }
  }

  @override
  void didUpdateWidget(covariant TimeSelectionButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialTime != oldWidget.initialTime &&
        widget.initialTime != null) {
      final parts = widget.initialTime!.split(':');

      if (parts.length == 2) {
        setState(() {
          _hours = int.tryParse(parts[0]) ?? 0;
          _minutes = int.tryParse(parts[1]) ?? 0;
        });
      }
    }
  }

  void _showTimePicker() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: _TimePickerModal(
          initialHour: _hours,
          initialMinute: _minutes,
          onTimeSelected: widget.onTimeSelected,
          onSave: (h, m) => setState(() {
            _hours = h;
            _minutes = m;
          }),
        ),
      ),
    );
  }

  Widget _timeBox(ThemeItem themeItem, String value) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: themeItem.background2,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: themeItem.primary, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: themeItem.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;
    final String hh = _hours.toString().padLeft(2, '0');
    final String mm = _minutes.toString().padLeft(2, '0');

    return GestureDetector(
      onTap: _showTimePicker,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _timeBox(themeItem, hh),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: themeItem.textPrimary,
              ),
            ),
          ),
          _timeBox(themeItem, mm),
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
  final Function(String)? onTimeSelected;
  final void Function(int hour, int minute) onSave;

  const _TimePickerModal({
    required this.initialHour,
    required this.initialMinute,
    required this.onTimeSelected,
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
    required BuildContext context,
    required FixedExtentScrollController controller,
    required int itemCount,
    required int selectedValue,
    required void Function(int) onChanged,
  }) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;

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
                color: themeItem.background2,
                borderRadius: BorderRadius.circular(14),
                border: isSelected
                    ? Border.all(color: themeItem.secondary, width: 2.5)
                    : Border.all(color: Colors.transparent, width: 2.5),
              ),
              alignment: Alignment.center,
              child: Text(
                index.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? themeItem.textPrimary
                      : themeItem.textPrimary.withValues(alpha: 0.3),
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
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      decoration: BoxDecoration(
        color: themeItem.background2,
        borderRadius: BorderRadius.circular(28),
      ),
      constraints: BoxConstraints(
        maxWidth: 500,
        maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                context: context,
                controller: _hourController,
                itemCount: 24,
                selectedValue: _selectedHour,
                onChanged: (v) => setState(() => _selectedHour = v),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: themeItem.textPrimary,
                  ),
                ),
              ),
              _buildPicker(
                context: context,
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
                  borderColor1: themeItem.secondary,
                  borderColor2: themeItem.primary,
                  backgroundColor: themeItem.background2,
                  text: 'กลับ',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BorderButton(
                  onPressed: () {
                    widget.onSave(_selectedHour, _selectedMinute);
                    widget.onTimeSelected?.call(
                      '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
                    );
                    Navigator.pop(context);
                  },
                  borderColor1: themeItem.background1,
                  borderColor2: themeItem.background2,
                  backgroundColor: themeItem.addButton,
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
