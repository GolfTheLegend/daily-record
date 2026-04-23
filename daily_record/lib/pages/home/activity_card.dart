import 'package:daily_record/components/app_alert.dart';
import 'package:daily_record/components/press_scale.dart';
import 'package:daily_record/core/constants/constants.dart';
import 'package:daily_record/core/models/check_list_request.dart';
import 'package:daily_record/core/models/edit_check_list_request.dart';
import 'package:daily_record/core/services/create_check_list_service.dart';
import 'package:daily_record/core/services/edit_check_list_service.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:daily_record/pages/home/activity_detail_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class ActivityCard extends StatefulWidget {
  final int id;
  final IconData icon;
  final String title;
  final String time;
  final int? repeatType;
  final bool important;
  final bool isDisable;
  final bool? checkStatus;
  final int? checkListId;
  final String detail;
  final Function(bool) loading;
  final Function() onSuccress;

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
    this.checkStatus,
    this.checkListId,
    required this.onSuccress,
    required this.detail,
  });

  @override
  State<ActivityCard> createState() => ActivityCardState();
}

class ActivityCardState extends State<ActivityCard>
    with SingleTickerProviderStateMixin {
  final _createService = CreateCheckListService();
  final _updateService = UpdateCheckListService();
  bool _showActions = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // ช่วงแรก 0.0→0.35 = scale up, ช่วงหลัง 0.35→1.0 = scale กลับปกติ
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.22,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.22,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 65,
      ),
    ]).animate(_controller);

    // flip เริ่มหลังจาก scale ขึ้นแล้ว (เริ่มที่ 35%)
    _flipAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(0.0), // รอให้ scale ขึ้นก่อน
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 65,
      ),
    ]).animate(_controller);

    if (widget.checkStatus != null) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ActivityCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.checkStatus != oldWidget.checkStatus) {
      if (widget.checkStatus != null) {
        _controller.forward(from: 0);
      } else {
        _controller.reverse();
      }
    }
  }

  Future<void> _saveCheckList(bool onCheck) async {
    final now = DateTime.now();
    final formattedDate = now.toIso8601String().split('T').first;
    widget.loading(true);

    try {
      final createRequest = CheckListRequest(
        checkStatus: onCheck,
        dayCheck: formattedDate,
      );

      final updateRequest = EditCheckListRequest(checkStatus: onCheck);

      if (widget.checkListId != null) {
        await _updateService.updateCheckLists(
          widget.checkListId!,
          updateRequest,
        );
      } else {
        await _createService.createCheckLists(widget.id, createRequest);
      }
      if (!mounted) return;
      AppAlert.show(
        context,
        title: 'สำเร็จ',
        message: 'บันทึกสำเร็จ',
        type: AlertType.success,
        onConfirm: () {
          widget.onSuccress();
          setState(() => _showActions = false);
        },
      );
    } catch (e) {
      if (!mounted) return;
      AppAlert.show(
        context,
        title: 'เกิดข้อผิดพลาด',
        message: e.toString(),
        type: AlertType.error,
        onConfirm: () => {},
      );
    } finally {
      if (!mounted) return;
      widget.loading(false);
    }
  }

  void _openDetailModal(
    int id,
    IconData icon,
    String title,
    String time,
    int repeatType,
    bool important,
    bool? checkStatus,
    String detail,
  ) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ActivityDetailModal(
          id: id,
          icon: icon,
          title: title,
          time: time,
          repeatType: repeatType,
          important: important,
          checkStatus: checkStatus,
          detail: detail,
        ),
      ),
    );
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
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        final isBack = _flipAnim.value >= 0.5;
                        final angle = isBack
                            ? (1.0 - _flipAnim.value) * pi
                            : _flipAnim.value * pi;

                        final borderColor = isBack
                            ? (widget.checkStatus == true
                                  ? themeItem.succress
                                  : themeItem.fail)
                            : themeItem.secondary;
                        final bgColor = isBack
                            ? (widget.checkStatus == true
                                  ? themeItem.succress.withValues(alpha: 0.3)
                                  : themeItem.fail.withValues(alpha: 0.3))
                            : themeItem.background1;
                        final iconWidget = isBack
                            ? Icon(
                                widget.checkStatus == true
                                    ? Icons.check
                                    : Icons.close,
                                size: 40,
                                color: widget.checkStatus == true
                                    ? themeItem.succress
                                    : themeItem.fail,
                              )
                            : Icon(
                                widget.icon,
                                size: 40,
                                color: themeItem.primary,
                              );

                        return Transform.scale(
                          scale: _scaleAnim.value,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.002)
                              ..rotateY(angle),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: bgColor,
                                border: Border.all(
                                  color: borderColor,
                                  width: 4,
                                ),
                              ),
                              child: iconWidget,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'เวลา : ${widget.time}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                          fontSize: 15,
                        ),
                      ),
                    SizedBox(width: 15),

                    PressScale(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: themeItem.background1,
                          border: Border.all(
                            color: themeItem.secondary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Icon(Icons.remove_red_eye_outlined),
                        ),
                      ),
                      onTap: () => _openDetailModal(
                        widget.id,
                        widget.icon,
                        widget.title,
                        widget.time,
                        widget.repeatType ?? 0,
                        widget.important,
                        widget.checkStatus,
                        widget.detail,
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
