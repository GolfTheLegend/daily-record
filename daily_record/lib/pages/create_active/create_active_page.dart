import 'dart:math';

import 'package:daily_record/components/app_alert.dart';
import 'package:daily_record/components/background.dart';
import 'package:daily_record/components/border_button.dart';
import 'package:daily_record/components/calendar_modal.dart';
import 'package:daily_record/components/checkbox_button.dart';
import 'package:daily_record/components/dropdown_button.dart';
import 'package:daily_record/components/press_scale.dart';
import 'package:daily_record/core/models/daily_record_request.dart';
import 'package:daily_record/core/models/get_daily_record_response.dart';
import 'package:daily_record/core/services/create_daily_record_service.dart';
import 'package:daily_record/core/services/edit_daily_record_service.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:daily_record/pages/create_active/icon_selection.dart';
import 'package:daily_record/components/input.dart';
import 'package:daily_record/pages/create_active/time_selection_button.dart';
import 'package:daily_record/core/constants/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const _kIconSize = 60.0;
const _kIconContainerSize = 80.0;
const _kIconBorderRadius = 60.0;
const _kButtonMaxWidth = 500.0;

// ─── Enums ────────────────────────────────────────────────────────────────────

enum PageMode { create, edit }

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

  static RepeatType fromValue(int value) =>
      value == 0 ? RepeatType.everyday : RepeatType.selectDay;
}

// ─── Widget ───────────────────────────────────────────────────────────────────

class CreateActivePage extends StatefulWidget {
  const CreateActivePage({super.key, required this.mode, this.recordData})
    : assert(
        mode == PageMode.create || recordData != null,
        'recordData must be provided in edit mode',
      );

  final PageMode mode;
  final DailyRecordItem? recordData;

  @override
  State<CreateActivePage> createState() => _CreateActivePageState();
}

// ─── State ────────────────────────────────────────────────────────────────────

class _CreateActivePageState extends State<CreateActivePage> {
  // Services
  final _createService = CreateDailyRecordService();
  final _updateService = UpdateDailyRecordService();

  // Controllers — ใช้ TextEditingController เพื่อโหลดค่าเดิมในโหมด edit
  late final TextEditingController _headerController;
  late final TextEditingController _detailController;

  // State
  bool _isLoading = false;
  int _iconSelect = 0;
  String? _startTime;
  String? _endTime;
  RepeatType _repeatType = RepeatType.everyday;
  bool _isImportant = false;
  List<String> _dates = [];

  // ─── Computed ──────────────────────────────────────────────────────────────

  bool get _isEditMode => widget.mode == PageMode.edit;

  /// ตรวจสอบการเปลี่ยนแปลงครบทุก field (ไม่ใช่แค่ 3 field เหมือนเดิม)
  bool get _hasChanges {
    final data = widget.recordData;
    if (data == null) {
      // create mode — ถือว่ามี changes ถ้ากรอกอะไรไปแล้ว
      return _headerController.text.isNotEmpty ||
          _detailController.text.isNotEmpty ||
          _startTime != null ||
          _endTime != null ||
          _dates.isNotEmpty ||
          _iconSelect != 0;
    }
    return _headerController.text != data.activityHeader ||
        _detailController.text != (data.activityDetail ?? '') ||
        _iconSelect != data.iconId ||
        _startTime != data.startTime ||
        _endTime != data.endTime ||
        _repeatType.value != data.repeatType ||
        _isImportant != (data.important ?? false) ||
        !_listsEqual(_dates, data.dates);
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  String? get _validationError {
    if (_headerController.text.trim().isEmpty) return 'กรุณาใส่หัวข้อกิจกรรม';
    if (_repeatType == RepeatType.selectDay && _dates.isEmpty) {
      return 'กรุณาเลือกวันที่อย่างน้อย 1 วัน';
    }
    return null;
  }

  String get _formattedDate {
    final now = DateTime.now();
    // แสดงวันที่จริงจาก device
    final buddhistYear = now.year + 543;
    final monthName = _thaiMonths[now.month - 1];
    return '${now.day}\n$monthName $buddhistYear';
  }

  static const _thaiMonths = [
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

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final data = widget.recordData;

    // สร้าง controller พร้อม initial value ทันที → edit mode เห็นข้อมูลเดิม
    _headerController = TextEditingController(text: data?.activityHeader ?? '');
    _detailController = TextEditingController(text: data?.activityDetail ?? '');

    if (_isEditMode && data != null) {
      _iconSelect = data.iconId!;
      _startTime = data.startTime;
      _endTime = data.endTime;
      _repeatType = RepeatType.fromValue(data.repeatType!);
      _isImportant = data.important ?? false;
      _dates = List.from(data.dates); // defensive copy
    }
  }

  @override
  void dispose() {
    // dispose controllers เสมอ เพื่อป้องกัน memory leak
    _headerController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  void _showIconPicker() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: IconSelection(
          onSelect: (value) => setState(() => _iconSelect = value),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    // Validate ก่อน submit เสมอ
    final error = _validationError;
    if (error != null) {
      AppAlert.show(
        context,
        title: 'ข้อมูลไม่ครบ',
        message: error,
        type: AlertType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = DailyRecordsRequest(
        iconId: _iconSelect,
        startTime: _startTime ?? '00:00',
        endTime: _endTime ?? '00:00',
        repeatType: _repeatType.value,
        important: _isImportant,
        activityHeader: _headerController.text.trim(),
        activityDetail: _detailController.text.trim(),
        dates: _dates,
      );

      if (_isEditMode) {
        await _updateService.updateDailyRecords(
          widget.recordData!.id!,
          request,
        );
      } else {
        await _createService.createDailyRecords(request);
      }

      if (!mounted) return;

      AppAlert.show(
        context,
        title: 'สำเร็จ',
        message: 'บันทึกสำเร็จ',
        type: AlertType.success,
        onConfirm: () => Navigator.pop(context,true),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDatePicker() {
    showDialog(
      context: context,
      barrierDismissible: false,
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

  void _onRepeatTypeChanged(RepeatType value) {
    if (value == _repeatType) return; // ไม่ทำอะไรถ้าค่าเดิม

    // แจ้งเตือนเฉพาะกรณีที่ selectDay → everyday และมี dates อยู่แล้ว
    if (value == RepeatType.everyday && _dates.isNotEmpty) {
      AppAlert.show(
        context,
        title: 'ยืนยันการเปลี่ยน', // แก้จาก "สำเร็จ" → ชื่อที่ถูกต้อง
        message:
            'เปลี่ยนเป็น "${value.label}" จะลบวันที่ที่เลือกไว้ทั้งหมด คุณต้องการดำเนินการต่อหรือไม่?',
        type: AlertType.warning,
        cancelText: 'ยกเลิก',
        onConfirm: () => setState(() {
          _repeatType = value;
          _dates = [];
        }),
      );
    } else {
      setState(() => _repeatType = value);
    }
  }

  void _onBack() {
    if (!_hasChanges) {
      Navigator.pop(context,false);
      return;
    }
    AppAlert.show(
      context,
      title: _isEditMode ? 'ยกเลิกการแก้ไข' : 'ยกเลิกการสร้างกิจกรรม',
      message: _isEditMode
          ? 'ต้องการยกเลิกการแก้ไขกิจกรรมหรือไม่?'
          : 'ต้องการยกเลิกการสร้างกิจกรรมหรือไม่?',
      type: AlertType.warning,
      cancelText: 'ยกเลิก',
      onConfirm: () => Navigator.pop(context,false),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;
    final screenWidth = MediaQuery.sizeOf(
      context,
    ).width; // ใช้ sizeOf แทน size.width (ไม่ rebuild ทั้งหน้า)

    return Background(
      child: Column(
        children: [
          _HeaderSection(
            themeItem: themeItem,
            formattedDate: _formattedDate,
            iconSelect: _iconSelect,
            onIconTap: _showIconPicker,
          ),
          _TimeSection(
            startTime: _startTime,
            endTime: _endTime,
            themeItem: themeItem,
            onStartTimeSelected: (v) => setState(() => _startTime = v),
            onEndTimeSelected: (v) => setState(() => _endTime = v),
          ),
          Expanded(
            flex: 4,
            child: _FormSection(
              themeItem: themeItem,
              screenWidth: screenWidth,
              headerController: _headerController,
              detailController: _detailController,
              isImportant: _isImportant,
              repeatType: _repeatType,
              dates: _dates,
              isLoading: _isLoading,
              isEditMode: _isEditMode,
              onImportantChanged: (v) => setState(() => _isImportant = v),
              onRepeatTypeChanged: _onRepeatTypeChanged,
              onSelectDate: _showDatePicker,
              onBack: _onBack,
              onSubmit: _submit,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets (แยกออกเพื่อลด rebuild scope) ───────────────────────────────

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.themeItem,
    required this.formattedDate,
    required this.iconSelect,
    required this.onIconTap,
  });

  final dynamic themeItem;
  final String formattedDate;
  final int iconSelect;
  final VoidCallback onIconTap;

  @override
  Widget build(BuildContext context) {
    final parts = formattedDate.split('\n');
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            parts[0],
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: themeItem.textPrimary,
            ),
          ),
          Text(
            parts.length > 1 ? parts[1] : '',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeItem.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: onIconTap,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: themeItem.primary,
                borderRadius: BorderRadius.circular(_kIconBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(7, 12),
                  ),
                ],
              ),
              child: Container(
                width: _kIconContainerSize,
                height: _kIconContainerSize,
                decoration: BoxDecoration(
                  color: themeItem.background2,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: _buildSelectedIcon(iconSelect, themeItem.textPrimary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedIcon(int? iconId, Color color) {
    final selected = iconsData.firstWhere(
      (i) => i.keyId == iconId,
      orElse: () => iconsData.first,
    );

    if (selected.icon != null) {
      return Icon(selected.icon, size: _kIconSize, color: color);
    }
    if (selected.iconPath != null) {
      return SvgPicture.asset(selected.iconPath!, width: _kIconSize);
    }
    return Icon(Icons.add, size: _kIconSize, color: color);
  }
}

class _TimeSection extends StatelessWidget {
  final String? startTime;
  final String? endTime;
  final dynamic themeItem;
  final ValueChanged<String> onStartTimeSelected;
  final ValueChanged<String> onEndTimeSelected;

  const _TimeSection({
    required this.startTime,
    required this.endTime,
    required this.themeItem,
    required this.onStartTimeSelected,
    required this.onEndTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TimeSelectionButton(
              initialTime: startTime,
              onTimeSelected: onStartTimeSelected,
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
              initialTime: endTime,
              onTimeSelected: onEndTimeSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.themeItem,
    required this.screenWidth,
    required this.headerController,
    required this.detailController,
    required this.isImportant,
    required this.repeatType,
    required this.dates,
    required this.isLoading,
    required this.isEditMode,
    required this.onImportantChanged,
    required this.onRepeatTypeChanged,
    required this.onSelectDate,
    required this.onBack,
    required this.onSubmit,
  });

  final dynamic themeItem;
  final double screenWidth;
  final TextEditingController headerController;
  final TextEditingController detailController;
  final bool isImportant;
  final RepeatType repeatType;
  final List<String> dates;
  final bool isLoading;
  final bool isEditMode;
  final ValueChanged<bool> onImportantChanged;
  final ValueChanged<RepeatType> onRepeatTypeChanged;
  final VoidCallback onSelectDate;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  bool get _isSelectDayMode => repeatType == RepeatType.selectDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ─── Header input
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
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
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: Input(
                      controller: headerController, // ส่ง controller เข้าไป
                      isMultiline: false,
                      maxLength: 50,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ─── Options + Detail
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Important + Repeat + Calendar row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CheckboxButton(
                          value: isImportant,
                          onChanged: onImportantChanged,
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
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DesignDropdown<RepeatType>(
                          initialValue: repeatType,
                          entries: RepeatType.entries,
                          onChanged: (value) {
                            if (value != null) onRepeatTypeChanged(value);
                          },
                        ),
                      ),
                    ),
                    _CalendarButton(
                      themeItem: themeItem,
                      isEnabled: _isSelectDayMode,
                      hasDates: dates.isNotEmpty,
                      onTap: onSelectDate,
                    ),
                  ],
                ),

                // Detail input
                Column(
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
                    Input(
                      controller: detailController, // ส่ง controller เข้าไป
                      isMultiline: true,
                      height: 130,
                      maxLength: 150,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ─── Action buttons
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BorderButton(
                  width: min(screenWidth * 0.4, _kButtonMaxWidth),
                  borderColor1: themeItem.secondary,
                  borderColor2: themeItem.primary,
                  backgroundColor: themeItem.background2,
                  text: 'กลับ',
                  onPressed: isLoading ? null : onBack, // disable ขณะ loading
                ),
                BorderButton(
                  width: min(screenWidth * 0.4, _kButtonMaxWidth),
                  borderColor1: themeItem.background1,
                  borderColor2: themeItem.background2,
                  backgroundColor: themeItem.addButton,
                  text: (isEditMode ? 'แก้ไข' : 'บันทึก'),
                  onPressed: isLoading ? null : onSubmit,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CalendarButton extends StatelessWidget {
  const _CalendarButton({
    required this.themeItem,
    required this.isEnabled,
    required this.hasDates,
    required this.onTap,
  });

  final dynamic themeItem;
  final bool isEnabled;
  final bool hasDates;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      disabled: !isEnabled,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: themeItem.background2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: !isEnabled
                ? themeItem.primary.withValues(alpha: 0.2)
                : themeItem.primary,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            hasDates
                ? Icons.edit_calendar_rounded
                : Icons.calendar_month_rounded,
            size: 35,
            color: !isEnabled
                ? themeItem.textPrimary.withValues(alpha: 0.2)
                : hasDates
                ? themeItem.status1
                : themeItem.textPrimary,
          ),
        ),
      ),
    );
  }
}
