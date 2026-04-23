import 'package:daily_record/components/border_button.dart';
import 'package:daily_record/components/press_scale.dart';
import 'package:daily_record/core/themes/theme.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimeSelectionButton extends StatefulWidget {
  final String? initialTime;
  final String? minTime;
  final bool disabled;
  final Function(String)? onTimeSelected;
  const TimeSelectionButton({
    super.key,
    this.onTimeSelected,
    this.initialTime,
    this.minTime,
    this.disabled = false,
  });

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
    if (widget.initialTime != oldWidget.initialTime) {
      if (widget.initialTime == null || widget.initialTime!.isEmpty) {
        setState(() {
          _hours = 0;
          _minutes = 0;
        });
      } else {
        final parts = widget.initialTime!.split(':');
        if (parts.length == 2) {
          setState(() {
            _hours = int.tryParse(parts[0]) ?? 0;
            _minutes = int.tryParse(parts[1]) ?? 0;
          });
        }
      }
    }
  }

  static (int, int)? _parseTime(String? t) {
    if (t == null || t.isEmpty) return null;
    final parts = t.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return (h, m);
  }

  void _showTimePicker() {
    if (widget.disabled) return; // 🆕 ถ้า disabled ไม่เปิด modal

    final minParsed = _parseTime(widget.minTime); // 🆕 parse minTime

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: _TimePickerModal(
          initialHour: _hours,
          initialMinute: _minutes,
          minHour: minParsed?.$1,
          minMinute: minParsed?.$2,
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
    final Color borderColor = widget.disabled
        ? themeItem.primary.withValues(alpha: 0.2)
        : themeItem.primary;
    final Color textColor = widget.disabled
        ? themeItem.textPrimary.withValues(alpha: 0.3)
        : themeItem.textPrimary;

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
        border: Border.all(color: borderColor, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;
    final String hh = _hours.toString().padLeft(2, '0');
    final String mm = _minutes.toString().padLeft(2, '0');

    return PressScale(
      onTap: _showTimePicker,
      disabled: widget.disabled,
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
                color: widget.disabled
                    ? themeItem.textPrimary.withValues(alpha: 0.3)
                    : themeItem.textPrimary,
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
  final int? minHour;
  final int? minMinute;
  final Function(String)? onTimeSelected;
  final void Function(int hour, int minute) onSave;

  const _TimePickerModal({
    required this.initialHour,
    required this.initialMinute,
    required this.onTimeSelected,
    required this.onSave,
    this.minHour,
    this.minMinute,
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

  bool get _hasMin => widget.minHour != null;

  int get _effectiveMinMinute {
    if (!_hasMin) return 0;
    if (_selectedHour > widget.minHour!) return 0;
    return widget.minMinute ?? 0;
  }

  int _clampHour(int h) {
    if (!_hasMin) return h;
    return h < widget.minHour! ? widget.minHour! : h;
  }

  int _clampMinute(int h, int m) {
    if (!_hasMin) return m;
    final minM = (h > widget.minHour!) ? 0 : (widget.minMinute ?? 0);
    return m < minM ? minM : m;
  }

  @override
  void initState() {
    super.initState();
    _selectedHour = _clampHour(widget.initialHour);
    _selectedMinute = _clampMinute(_selectedHour, widget.initialMinute);
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

  void _onHourChanged(int h) {
    final clampedMinute = _clampMinute(h, _selectedMinute);

    setState(() {
      _selectedHour = h;
      _selectedMinute = clampedMinute;
    });

    if (clampedMinute != _selectedMinute) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_minuteController.hasClients) {
          _minuteController.animateToItem(
            clampedMinute,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Widget _buildPicker({
    required BuildContext context,
    required FixedExtentScrollController controller,
    required int itemCount,
    required int selectedValue,
    required int minValue,
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
            final bool isDisabled = index < minValue;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: themeItem.background2,
                borderRadius: BorderRadius.circular(14),
                border: isSelected && !isDisabled
                    ? Border.all(color: themeItem.secondary, width: 2.5)
                    : Border.all(color: Colors.transparent, width: 2.5),
              ),
              alignment: Alignment.center,
              child: Text(
                index.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDisabled
                      ? themeItem.textPrimary.withValues(alpha: 0.15)
                      : isSelected
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
                minValue: widget.minHour ?? 0, // 🆕
                onChanged: _onHourChanged,
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
                minValue: _effectiveMinMinute,
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
