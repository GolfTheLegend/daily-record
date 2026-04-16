import 'package:daily_record/components/app_alert.dart';
import 'package:daily_record/components/press_scale.dart';
import 'package:daily_record/core/constants/constants.dart';
import 'package:daily_record/core/models/check_list_request.dart';
import 'package:daily_record/core/services/create_check_list_service.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActivityCard extends StatefulWidget {
  final int id;
  final IconData icon;
  final String title;
  final String time;
  final int? repeatType;
  final bool important;
  final bool isDisable;
  final Function(bool) loading;

  const ActivityCard({
    super.key,
    required this.id,
    required this.icon,
    required this.title,
    required this.time,
    required this.important,
    this.repeatType,
    this.isDisable = false,
    required this.loading,
  });

  @override
  State<ActivityCard> createState() => ActivityCardState();
}

class ActivityCardState extends State<ActivityCard> {
  final _service = UpdateCheckListService();
  bool _showActions = false;

  Future<void> _saveCheckList(bool onCheck) async {
    widget.loading(true);

    try {
      final request = CheckListRequest(
        checkStatus: onCheck,
        dayCheck: DateTime.now().toIso8601String(),
      );

      await _service.updateCheckLists(widget.id, request);
      if (!mounted) return;
      AppAlert.show(
        context,
        title: 'สำเร็จ',
        message: 'บันทึกสำเร็จ',
        type: AlertType.success,
        onConfirm: () => Navigator.pop(context, true),
      );
    } catch (e) {
      if (!mounted) return;
      AppAlert.show(
        context,
        title: 'เกิดข้อผิดพลาด',
        message: e.toString(),
        type: AlertType.error,
        onConfirm: () {},
      );
    } finally {
      if (!mounted) return;
      widget.loading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? trailingTitle;
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;

    final Color textColor = widget.important == true
        ? themeItem.status2
        : (widget.repeatType! < statusList.length &&
              statusList[widget.repeatType!].key == 0)
        ? themeItem.status1
        : themeItem.textPrimary;

    if (widget.repeatType != null) {
      final result = widget.important == true
          ? 'สำคัญ'
          : statusList[widget.repeatType!].key == 0
          ? 'ทุกวัน'
          : '';

      if (result.isNotEmpty) {
        trailingTitle = result;
      }
    }

    return GestureDetector(
      onTap: widget.isDisable
          ? null
          : () {
              setState(() {
                _showActions = !_showActions;
              });
            },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: themeItem.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
              decoration: BoxDecoration(
                color: themeItem.shadowPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeItem.background2,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: themeItem.background1,
                        border: Border.all(
                          color: themeItem.secondary,
                          width: 4,
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 40,
                        color: themeItem.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'เวลา : ${widget.time}',
                            style: TextStyle(
                              fontSize: 15,
                              color: themeItem.text1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (trailingTitle != null)
                      Text(
                        trailingTitle,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // 🔹 ปุ่มที่โผล่ออกมา
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Container(
              child: Column(
                children: [
                  if (_showActions) ...[
                    Container(
                      child: Row(
                        children: [
                          ButtonBox(
                            title: 'สำเร็จ',
                            onPressed: () => _saveCheckList(true),
                            textColor: const Color.fromARGB(255, 7, 68, 9),
                            color1: Colors.green,
                            color2: const Color.fromARGB(255, 7, 68, 9),
                          ),
                          const SizedBox(width: 8),
                          ButtonBox(
                            title: 'ไม่สำเร็จ',
                            onPressed: () => _saveCheckList(false),
                            textColor: const Color.fromARGB(255, 102, 12, 6),
                            color1: const Color.fromARGB(255, 252, 95, 83),
                            color2: const Color.fromARGB(255, 102, 12, 6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ButtonBox extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color textColor;
  final Color color1;
  final Color color2;

  const ButtonBox({
    super.key,
    required this.title,
    required this.onPressed,
    required this.textColor,
    required this.color1,
    required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        decoration: BoxDecoration(
          color: color1,
          borderRadius: BorderRadius.circular(12),
        ),
        child: PressScale(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
            decoration: BoxDecoration(
              color: color2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
