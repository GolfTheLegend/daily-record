import 'package:daily_record/components/border_button.dart';
import 'package:daily_record/components/press_scale.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CalendarModal extends StatefulWidget {
  final List<String> initialDates;
  final Function(List<String>)? onTimeSelected;

  const CalendarModal({
    this.initialDates = const [],
    this.onTimeSelected,
    super.key,
  });

  @override
  State<CalendarModal> createState() => CalendarModalState();
}

class CalendarModalState extends State<CalendarModal> {
  DateTime _selectedMonth = DateTime.now();
  List<DateTime> _selectedDates = [];
  int _slideDirection = 1;

  @override
  void initState() {
    super.initState();
    // แปลง "yyyy-MM-dd" กลับเป็น DateTime
    _selectedDates = widget.initialDates.map((s) {
      final parts = s.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }).toList();

    // ถ้ามีวันที่เริ่มต้น ให้เปิดเดือนของวันแรก
    if (_selectedDates.isNotEmpty) {
      _selectedMonth = DateTime(
        _selectedDates.first.year,
        _selectedDates.first.month,
        1,
      );
    }
  }

  final DateTime _today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  final List<String> _monthNameTH = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];

  final List<String> _weekNameTH = ['อา.', 'จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.'];

  int _getDaysInMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0).day;

  int _getFirstDayOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1).weekday % 7;

  void _previousMonth() {
    setState(() {
      _slideDirection = -1;
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _slideDirection = 1;
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
    });
  }

  bool _isPastDate(int dayNumber) {
    final date = DateTime(_selectedMonth.year, _selectedMonth.month, dayNumber);
    return date.isBefore(_today);
  }

  bool _isSelected(int dayNumber) {
    return _selectedDates.any(
      (d) =>
          d.day == dayNumber &&
          d.month == _selectedMonth.month &&
          d.year == _selectedMonth.year,
    );
  }

  void _toggleDate(int dayNumber) {
    final date = DateTime(_selectedMonth.year, _selectedMonth.month, dayNumber);
    setState(() {
      final idx = _selectedDates.indexWhere(
        (d) =>
            d.day == date.day && d.month == date.month && d.year == date.year,
      );
      if (idx >= 0) {
        _selectedDates.removeAt(idx);
      } else {
        _selectedDates.add(date);
      }
      // เรียงลำดับวันที่
      _selectedDates.sort((a, b) => a.compareTo(b));
    });
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  List<String> get _selectedDateTexts =>
      _selectedDates.map(_formatDate).toList();

  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;
    final double maxHeight = MediaQuery.of(context).size.height * 0.85;

    final int daysInMonth = _getDaysInMonth(_selectedMonth);
    final int firstDayOfWeek = _getFirstDayOfMonth(_selectedMonth);
    final int totalItems = firstDayOfWeek + daysInMonth;
    final int rowCount = (totalItems / 7).ceil();
    final int itemCount = rowCount * 7;
    final String monthText = _monthNameTH[_selectedMonth.month - 1];
    final int buddhistYear = _selectedMonth.year + 543;
    final double fontSize = (MediaQuery.of(context).size.width * 0.040).clamp(
      0.0,
      30.0,
    );
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 10),
        decoration: BoxDecoration(
          color: themeItem.background2,
          borderRadius: BorderRadius.circular(28),
        ),
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PressScale(
                  onTap: () => _previousMonth(),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: themeItem.secondary,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: themeItem.background2,
                      size: 18,
                    ),
                  ),
                ),
                Text(
                  '$monthText $buddhistYear',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PressScale(
                  onTap: () => _nextMonth(),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: themeItem.secondary,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: themeItem.background2,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // วันในสัปดาห์
            Row(
              children: _weekNameTH
                  .map((day) => Expanded(child: _BoxHeader(text: day)))
                  .toList(),
            ),

            _Line(themeItem.textPrimary),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) {
                final isEntering = child.key == ValueKey(_selectedMonth);
                final offsetX = isEntering
                    ? _slideDirection * 1.0
                    : _slideDirection * -1.0;

                final slideAnim =
                    Tween<Offset>(
                      begin: Offset(offsetX, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    );

                return ClipRect(
                  child: SlideTransition(
                    position: slideAnim,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(_selectedMonth),
                child:
                    // Grid วันที่
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 4,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            childAspectRatio: 1,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        final int dayNumber = index - firstDayOfWeek + 1;
                        if (dayNumber < 1 || dayNumber > daysInMonth) {
                          return const SizedBox();
                        }

                        final bool isPast = _isPastDate(dayNumber);
                        final bool isSelected = _isSelected(dayNumber);

                        return Opacity(
                          opacity: isPast ? 0.4 : 1.0,
                          child: PressScale(
                            onTap: isPast
                                ? () {}
                                : () => _toggleDate(dayNumber),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? themeItem.secondary
                                    : themeItem.background2,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: themeItem.primary,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '$dayNumber',
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? themeItem.background2
                                        : themeItem.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ),

            _Line(themeItem.textPrimary),

            const SizedBox(height: 4),

            // แสดงวันที่เลือก
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: themeItem.background2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: themeItem.primary, width: 2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---- วันที่ที่เลือก ----
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: _selectedDates.isEmpty
                          ? Center(
                              child: Text(
                                'ยังไม่ได้เลือกวันที่',
                                style: TextStyle(
                                  color: themeItem.textPrimary.withValues(
                                    alpha: 0.4,
                                  ),
                                  fontSize: 13,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 3.5,
                                    ),
                                itemCount: _selectedDates.length,
                                itemBuilder: (context, i) {
                                  final date = _selectedDates[i];
                                  return GestureDetector(
                                    onLongPress: () => _toggleDate(date.day),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: themeItem.background2,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: themeItem.secondary,
                                          width: 4,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _formatDate(date),
                                          style: TextStyle(
                                            fontSize: fontSize * 0.8,
                                            fontWeight: FontWeight.w600,
                                            color: themeItem.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ),

                  // ---- ปุ่มถังขยะ ----
                  PressScale(
                    onTap: () => setState(() => _selectedDates.clear()),
                    child: Container(
                      width: 44,
                      decoration: BoxDecoration(
                        color: themeItem.status2,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: themeItem.background2,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ปุ่มกลับ / บันทึก
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
                      widget.onTimeSelected?.call(_selectedDateTexts);
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
      ),
    );
  }
}

// ---- Widget ย่อย ----

class _BoxHeader extends StatelessWidget {
  final String text;
  const _BoxHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;
    final double fontSize = (MediaQuery.of(context).size.width * 0.035).clamp(
      0.0,
      17.0,
    );

    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: themeItem.primary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: themeItem.background2,
          ),
        ),
      ),
    );
  }
}

Widget _Line(Color color) {
  return Container(
    height: 4,
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: color,
    ),
  );
}
