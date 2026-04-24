import 'package:daily_record/components/border_button.dart';
import 'package:daily_record/core/constants/constants.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActivityDetailModal extends StatefulWidget {
  final int id;
  final IconData icon;
  final String title;
  final String time;
  final int? repeatType;
  final bool important;
  final bool? checkStatus;
  final String detail;

  const ActivityDetailModal({
    super.key,
    required this.id,
    required this.icon,
    required this.title,
    required this.time,
    this.repeatType,
    required this.important,
    this.checkStatus,
    required this.detail,
  });

  @override
  State<ActivityDetailModal> createState() => _ActivityDetailModalState();
}

class _ActivityDetailModalState extends State<ActivityDetailModal> {
  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;
    final trailingTitle = widget.important == true
        ? 'สำคัญ'
        : statusList[widget.repeatType!].key == 0
        ? 'ทุกวัน'
        : '';

    final Color textColor = widget.important == true
        ? themeItem.status2
        : (widget.repeatType! < statusList.length &&
              statusList[widget.repeatType!].key == 0)
        ? themeItem.status1
        : themeItem.textPrimary;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      decoration: BoxDecoration(
        color: themeItem.background2,
        borderRadius: BorderRadius.circular(28),
      ),
      constraints: BoxConstraints(
        maxWidth: 700,
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Detail row ──
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: themeItem.background1,
                      border: Border.all(width: 4),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 40,
                      color: themeItem.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.time,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: themeItem.textPrimary,
                          ),
                        ),
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: themeItem.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _Line(themeItem.textPrimary),
              const SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.all(5),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color: themeItem.textPrimary,
                    ),
                    children: [
                      WidgetSpan(child: SizedBox(width: 40)),
                      TextSpan(
                        text: widget.detail.isEmpty
                            ? 'ไม่มีรายละเอียดเพิ่มเติม'
                            : widget.detail,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _Line(themeItem.textPrimary),
            ],
          ),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.checkStatus != null)
                Row(
                  children: [
                    Icon(
                      widget.checkStatus == true ? Icons.check : Icons.close,
                      size: 20,
                      color: widget.checkStatus == true
                          ? themeItem.succress
                          : themeItem.fail,
                    ),
                    SizedBox(width: 8),
                    Text(
                      widget.checkStatus == true ? 'สำเร็จ' : 'ไม่สำเร็จ',
                      style: TextStyle(
                        color: widget.checkStatus == true
                            ? themeItem.succress
                            : themeItem.fail,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),

              SizedBox(width: 8),

              Text(
                trailingTitle,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

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
            ],
          ),
        ],
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
