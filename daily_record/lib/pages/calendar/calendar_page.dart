import 'dart:math';

import 'package:daily_record/components/app_alert.dart';
import 'package:daily_record/components/background.dart';
import 'package:daily_record/components/border_button.dart';
import 'package:daily_record/components/loading.dart';
import 'package:daily_record/components/press_scale.dart';
import 'package:daily_record/core/constants/constants.dart';
import 'package:daily_record/pages/calendar/calendar_table.dart';
import 'package:daily_record/core/models/get_daily_record_request.dart';
import 'package:daily_record/core/models/get_daily_record_response.dart';
import 'package:daily_record/core/services/get_daily_record_service.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:daily_record/pages/detail/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final _service = GetDailyRecordService();
  late String _defaultDate;
  late String _filteredDate;
  bool _isLoading = false;
  int _requestId = 0;
  final _calendarKey = GlobalKey<CalendarTableState>();
  List<DailyRecordItem> _recordData = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _defaultDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _filteredDate = _defaultDate;
    _fetchRecords(_filteredDate, true);
  }

  Future<void> _fetchRecords(String date, bool onRefresh) async {
    final currentId = ++_requestId;
    if (_isLoading) return;
    setState(() => _isLoading = true);

    if (onRefresh) {
      _filteredDate = _defaultDate;
    }
    try {
      final request = GetDailyRecordsRequest(dateFrom: date, dateTo: date);
      final response = await _service.getDailyRecords(request);
      if (!mounted || currentId != _requestId) return;
      setState(() {
        _recordData = response.data;
      });
    } catch (e) {
      if (mounted) {
        AppAlert.show(
          context,
          title: 'เกิดข้อผิดพลาด',
          message: e.toString(),
          type: AlertType.error,
        );
      }
    } finally {
      if (!mounted || currentId != _requestId) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;
    return Background(
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 40,
                    color: themeItem.textPrimary,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'ปฏิทิน',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: themeItem.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: CalendarTable(
              key: _calendarKey,
              onDateSelected: (String date) async {
                setState(() {
                  _filteredDate = date; // อัปเดตวันที่ที่ถูกเลือก
                });
                await _fetchRecords(date, false);
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: themeItem.background2,
                        border: Border.all(
                          color: const Color.fromARGB(255, 201, 201, 201),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ← ซ้าย: legend
                            Row(
                              children: [
                                _dot(themeItem.status1),
                                const SizedBox(width: 5),
                                const Text(
                                  'รายวัน',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 10),
                                _dot(themeItem.status2),
                                const SizedBox(width: 5),
                                const Text(
                                  'สำคัญ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            // → ขวา: ปุ่มรายละเอียด
                            PressScale(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: themeItem.primary,
                                    width: 4,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  color: themeItem.background2,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'รายละเอียด',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailPage(
                                      selectionDate: _filteredDate,
                                      recordData: _recordData,
                                    ),
                                  ),
                                );
                                if (!mounted) return;
                                await _calendarKey.currentState?.refresh();
                                await _fetchRecords(_filteredDate, false);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      decoration: BoxDecoration(
                        color: themeItem.background2,
                        border: Border.all(
                          color: const Color.fromARGB(255, 201, 201, 201),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(10),
                        child: _isLoading
                            ? const Center(
                                child: LoadingAnimation(width: 50, height: 50),
                              )
                            : _recordData.isEmpty
                            ? Text(
                                'ไม่มีรายการ',
                                style: TextStyle(
                                  color: themeItem.textPrimary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _recordData.length,
                                itemBuilder: (context, index) {
                                  final item = _recordData[index];
                                  final double fontSize =
                                      (MediaQuery.of(context).size.width *
                                              0.035)
                                          .clamp(0.0, 25.0);
                                  final double iconSize =
                                      (MediaQuery.of(context).size.width *
                                              0.044)
                                          .clamp(0.0, 30.0);
                                  final int repeatType = item.repeatType ?? 0;
                                  final Color textColor = item.important == true
                                      ? themeItem.status2
                                      : (repeatType < statusList.length &&
                                            statusList[repeatType].key == 0)
                                      ? themeItem.status1
                                      : themeItem.textPrimary;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${item.startTime ?? '00:00'} - ${item.endTime ?? '00:00'}',
                                          style: TextStyle(
                                            fontSize: fontSize,
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '|',
                                          style: TextStyle(
                                            fontSize: fontSize,
                                            color: themeItem.textPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 6),

                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.activityHeader ?? '-',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontSize: fontSize,
                                                    fontWeight: FontWeight.bold,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),

                                              if (item.checkStatus != null)
                                                Icon(
                                                  item.checkStatus == true
                                                      ? Icons.check
                                                      : Icons.close,
                                                  size: iconSize,
                                                  color:
                                                      item.checkStatus == true
                                                      ? themeItem.succress
                                                      : themeItem.fail,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BorderButton(
                          width: min(
                            MediaQuery.of(context).size.width * 0.4,
                            500,
                          ),
                          borderColor1: themeItem.secondary,
                          borderColor2: themeItem.primary,
                          backgroundColor: themeItem.background2,
                          text: 'กลับ',
                          onPressed: () => Navigator.pop(context),
                        ),
                        BorderButton(
                          width: min(
                            MediaQuery.of(context).size.width * 0.4,
                            500,
                          ),
                          borderColor1: themeItem.background1,
                          borderColor2: themeItem.background2,
                          backgroundColor: themeItem.addButton,
                          text: '+ เพิ่ม',
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/create',
                            );
                            if (!mounted) return;
                            if (result == true) {
                              await _calendarKey.currentState?.refresh();
                              await _fetchRecords(_filteredDate, false);
                            }
                          },
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

  Widget _dot(Color dotColor) {
    return Container(
      decoration: BoxDecoration(
        color: dotColor,
        borderRadius: BorderRadius.circular(10),
      ),
      width: 20,
      height: 20,
    );
  }
}
