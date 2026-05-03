import 'package:daily_record/components/app_alert.dart';
import 'package:daily_record/components/press_scale.dart';
import 'package:daily_record/core/constants/constants.dart';
import 'package:daily_record/core/di/injection.dart';
import 'package:daily_record/core/models/get_daily_record_response.dart';
import 'package:daily_record/core/repositories/repositories.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailEditBox extends StatefulWidget {
  final DailyRecordItem items;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  const DetailEditBox({
    super.key,
    required this.items,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<DetailEditBox> createState() => _DetailEditBoxState();
}

class _DetailEditBoxState extends State<DetailEditBox> {
  final IDailyRecordRepository _dailyRecordRepository =
      getIt<IDailyRecordRepository>();

  void _onConfirmDelete() {
    AppAlert.show(
      context,
      title: '',
      message: 'ต้องการลบ ${widget.items.activityHeader} ใช่หรือไม่',
      confirmText: 'ลบ',
      cancelText: 'ยกเลิก',
      type: AlertType.warning,
      onConfirm: () async => await _deleteRecord(),
    );
  }

  Future<void> _deleteRecord() async {
    try {
      final id = widget.items.id;
      if (id == null) {
        throw Exception('Invalid ID');
      }

      await _dailyRecordRepository.deleteDailyRecords(id);

      if (!mounted) return;

      AppAlert.show(
        context,
        title: 'สำเร็จ',
        message: 'ลบสำเร็จ',
        type: AlertType.success,
        onConfirm: () {
          widget.onDelete();
        },
      );
    } catch (e) {
      if (!mounted) return;

      AppAlert.show(
        context,
        title: 'เกิดข้อผิดพลาด',
        message: e.toString(),
        type: AlertType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;
    final item = widget.items;

    final int repeatType = item.repeatType ?? 0;
    final Color textColor = item.important == true
        ? themeItem.status2
        : (repeatType < statusList.length && statusList[repeatType].key == 0)
        ? themeItem.status1
        : themeItem.textPrimary;

    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.startTime} - ${item.endTime}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(width: 10),
              Text(
                repeatType < statusList.length
                    ? statusList[repeatType].trailing
                    : '',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.only(bottom: 20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: themeItem.background2,
            border: Border.all(color: themeItem.primary, width: 1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.activityHeader}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        PressScale(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: themeItem.background2,
                              border: Border.all(
                                color: themeItem.textPrimary,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 25,
                              color: themeItem.textPrimary,
                            ),
                          ),
                          onTap: () => widget.onEdit(),
                        ),
                        SizedBox(width: 10),
                        PressScale(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: themeItem.background1,
                              border: Border.all(
                                color: themeItem.status2,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.delete_rounded,
                              size: 25,
                              color: themeItem.status2,
                            ),
                          ),
                          onTap: () => _onConfirmDelete(),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                if (item.activityDetail != null) ...[
                  _Line(themeItem.secondary),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: themeItem.textPrimary,
                        ),
                        children: [
                          WidgetSpan(child: SizedBox(width: 40)),
                          TextSpan(text: item.activityDetail ?? ''),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget _Line(Color color) {
  return Container(
    height: 2,
    margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: color,
    ),
  );
}
