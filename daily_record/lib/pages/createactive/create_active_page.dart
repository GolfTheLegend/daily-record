import 'dart:math';

import 'package:daily_record/components/app_alert.dart';
import 'package:daily_record/components/background.dart';
import 'package:daily_record/components/border_button.dart';
import 'package:daily_record/components/calendar_modal.dart';
import 'package:daily_record/components/checkbox_button.dart';
import 'package:daily_record/components/dropdown_button.dart';
import 'package:daily_record/components/press_scale.dart';
import 'package:daily_record/core/models/create_daily_record_request.dart';
import 'package:daily_record/core/services/create_daily_record_service.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:daily_record/pages/createactive/iconselection.dart';
import 'package:daily_record/components/input.dart';
import 'package:daily_record/pages/createactive/timeselection_button.dart';
import 'package:daily_record/core/constants/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class CreateActivePage extends StatefulWidget {
  const CreateActivePage({super.key});

  @override
  State<CreateActivePage> createState() => _CreateActivePageState();
}

enum RepeatType {
  everyday('ทุกวัน', 0),
  selectDay('เลือกวัน', 1);

  const RepeatType(this.label, this.value);

  final String label;
  final int value;

  static final List<DropdownMenuEntry<RepeatType>> entries = [
    DropdownMenuEntry(
      value: RepeatType.everyday,
      label: RepeatType.everyday.label,
    ),
    DropdownMenuEntry(
      value: RepeatType.selectDay,
      label: RepeatType.selectDay.label,
    ),
  ];
}

class _CreateActivePageState extends State<CreateActivePage> {
  final _service = CreateDailyRecordService();
  bool _isLoading = false;
  int? _iconSelect = 0; //icons
  String? _startTime; //start time
  String? _endTime; //end time
  RepeatType _repeatType = RepeatType.everyday; //0
  bool _isImportant = false; //important
  String? _header; //header
  String? _detail; //detail
  List<String> _dates = []; //dates

  bool get _hasChanges =>
      _iconSelect != 0 ||
      _startTime != null ||
      _endTime != null ||
      _repeatType != RepeatType.everyday ||
      _isImportant != false ||
      (_header != null && _header!.isNotEmpty) ||
      (_detail != null && _detail!.isNotEmpty) ||
      _dates.isNotEmpty;

  @override
  void initState() {
    super.initState();
  }

  void _iconPicker() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: IconSelection(
          onSelect: (value) {
            setState(() {
              _iconSelect = value;
            });
          },
        ),
      ),
    );
  }

  Future<void> _createRecords() async {
    setState(() => _isLoading = true);
    try {
      final request = CreateDailyRecordsRequest(
        iconId: _iconSelect!,
        startTime: _startTime ?? '00:00',
        endTime: _endTime ?? '00:00',
        repeatType: _repeatType.value,
        important: _isImportant,
        activityHeader: _header ?? '',
        activityDetail: _detail ?? '',
        dates: _dates,
      );
      await _service.createDailyRecords(request);
      if (!mounted) return;
      AppAlert.show(
        context,
        title: 'สำเร็จ',
        message: 'บันทึกสำเร็จ',
        type: AlertType.success,
        onConfirm: () => Navigator.pop(context),
      );
    } catch (e) {
      if (!mounted) return;
      AppAlert.show(
        context,
        title: 'เกิดข้อผิดพลาด',
        message: e.toString(),
        type: AlertType.error,
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // Future<void> _createRecords() async {
  //   print(
  //     'Creating record with: \n'
  //     'Icon: $_iconSelect\n'
  //     'Start Time: $_startTime\n'
  //     'End Time: $_endTime\n'
  //     'Repeat Type: ${_repeatType.value}\n'
  //     'Important: $_isImportant\n'
  //     'Header: $_header\n'
  //     'Detail: $_detail\n'
  //     'Dates: $_dates',
  //   );
  // }

  void _onSelectDate() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: CalendarModal(
          initialDates: _dates,
          onTimeSelected: (v) => setState(() => _dates = v),
        ),
      ),
    );
  }

  void _onChangeRepeatType(RepeatType value) {
    AppAlert.show(
      context,
      title: 'สำเร็จ',
      message:
          'เปลี่ยนเป็น "${value.label}" จะลบวันที่ที่เลือกไว้ทั้งหมด คุณต้องการดำเนินการต่อหรือไม่?',
      type: AlertType.warning,
      cancelText: 'ยกเลิก',
      onConfirm: () {
        setState(() {
          _repeatType = value;
          _dates = [];
        });
      },
    );
  }

  void _onBack(BuildContext context) {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }
    AppAlert.show(
      context,
      title: 'ยกเลิกการสร้างกิจกรรม',
      message: 'ต้องการยกเลิกการสร้างกิจกรรมหรือไม่?',
      type: AlertType.warning,
      cancelText: 'ยกเลิก',
      onConfirm: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;
    final screenWidth = MediaQuery.of(context).size.width;
    return Background(
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "19",
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: themeItem.textPrimary,
                  ),
                ),
                Text(
                  "กุมภาพันธ์ 2568",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: themeItem.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: _iconPicker,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: themeItem.primary,
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(7, 12),
                        ),
                      ],
                    ),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: themeItem.background2,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: _buildSelectedIcon(themeItem.textPrimary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TimeSelectionButton(
                    onTimeSelected: (v) => setState(() => _startTime = v),
                  ),
                  Text(
                    'ถึง',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: themeItem.textPrimary,
                    ),
                  ),
                  TimeSelectionButton(
                    onTimeSelected: (v) => setState(() => _endTime = v),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'หัวข้อ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: themeItem.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          width: screenWidth * 0.75,
                          height: 45,
                          child: Input(
                            isMultiline: false,
                            maxLength: 50,
                            onChanged: (value) =>
                                setState(() => _header = value),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 20,
                    ),
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CheckboxButton(
                                  onChanged: (value) =>
                                      setState(() => _isImportant = value),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'สำคัญ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: themeItem.status2,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: DesignDropdown<RepeatType>(
                                  initialValue: _repeatType,
                                  entries: RepeatType.entries,
                                  onChanged: (value) {
                                    if (value == null) return;
                                    if (value == RepeatType.everyday &&
                                        _dates.isNotEmpty) {
                                      _onChangeRepeatType(value);
                                    } else {
                                      setState(() => _repeatType = value);
                                    }
                                  },
                                ),
                              ),
                            ),
                            PressScale(
                              onTap: () => _onSelectDate(),
                              disabled: _repeatType != RepeatType.selectDay,
                              child: Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: themeItem.background2,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _repeatType != RepeatType.selectDay
                                        ? themeItem.primary.withValues(
                                            alpha: 0.2,
                                          )
                                        : themeItem.primary,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    _dates.isNotEmpty
                                        ? Icons.edit_calendar_rounded
                                        : Icons.calendar_month_rounded,
                                    size: 35,
                                    color: _repeatType != RepeatType.selectDay
                                        ? themeItem.textPrimary.withValues(
                                            alpha: 0.2,
                                          )
                                        : _dates.isNotEmpty
                                        ? themeItem.status1
                                        : themeItem.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'รายละเอียด',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: themeItem.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                child: Input(
                                  isMultiline: true,
                                  height: 130,
                                  maxLength: 150,
                                  onChanged: (value) =>
                                      setState(() => _detail = value),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BorderButton(
                          width: min(screenWidth * 0.4, 500),
                          borderColor1: themeItem.secondary,
                          borderColor2: themeItem.primary,
                          backgroundColor: themeItem.background2,
                          text: 'กลับ',
                          onPressed: () => _onBack(context),
                        ),
                        BorderButton(
                          width: min(screenWidth * 0.4, 500),
                          borderColor1: themeItem.background1,
                          borderColor2: themeItem.background2,
                          backgroundColor: themeItem.addButton,
                          text: 'บันทึก',
                          onPressed: () => _createRecords(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedIcon(Color color) {
    if (_iconSelect == null) {
      return Icon(Icons.add, size: 60, color: color);
    }

    final selected = iconsData.firstWhere(
      (i) => i.keyId == _iconSelect,
      orElse: () => iconsData.first,
    );

    if (selected.icon != null) {
      return Icon(selected.icon, size: 60, color: color);
    }

    return SvgPicture.asset(selected.iconPath!, width: 60);
  }
}
