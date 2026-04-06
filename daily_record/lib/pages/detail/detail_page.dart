import 'dart:math';
import 'package:daily_record/components/background.dart';
import 'package:daily_record/components/border_button.dart';
import 'package:daily_record/components/press_scale.dart';
import 'package:daily_record/core/models/get_daily_record_response.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:daily_record/pages/detail/detail_edit_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
  final String selectionDate;
  final List<DailyRecordItem> recordData;

  const DetailPage({
    super.key,
    required this.recordData,
    required this.selectionDate,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _onSwitch = true;
  bool _isLoading = false;

  void _switchTab() {
    setState(() {
      _onSwitch = !_onSwitch;
    });
  }

  Future<void> _fetchRecords(DateTime date, bool onRefresh) async {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final nowMin = now.hour * 60 + now.minute;

    setState(() {
      _isLoading = true;
    });

    if (onRefresh) {
      setState(() {
        _records = [];
        _currentRecords = [];
      });
    }

    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    try {
      final request = GetDailyRecordsRequest(
        dateFrom: dateStr,
        dateTo: dateStr,
      );

      final response = await _service.getDailyRecords(request);

      final isToday =
          now.year == date.year &&
          now.month == date.month &&
          now.day == date.day;

      final current = response.data.where((i) {
        if (!isToday) return false;
        if (i.startTime == null || i.endTime == null) return false;

        final start = _toMinutes(i.startTime!);
        final end = _toMinutes(i.endTime!);

        return nowMin >= start && nowMin <= end;
      }).toList();

      final currentIds = current.map((i) => i.id).toSet();
      final record = response.data
          .where((i) => !currentIds.contains(i.id))
          .toList();

      if (!mounted) return;

      setState(() {
        _currentRecords = current;
        _records = record;
      });

      _autoScroll();
    } catch (e) {
      debugPrint('Fetch error: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;
    final _firstItemKey = GlobalKey();

    final List<DailyRecordItem> mockRecordData = [
      DailyRecordItem(
        id: 3,
        iconId: 1,
        startTime: "08:00",
        endTime: "09:30",
        repeatType: 1,
        important: true,
        activityHeader: "Morning Workout",
        activityDetail:
            "คุณสมบัติหลักของการสร้างบทความยาวๆ ก็คือการให้ความรู้โดยละเอียดและลงลึกถึงเนื้อหาต่าง ๆ ที่มีส่วนจำเป็นและต้องการอธิบายและต้องใช้การอธิบายความรู้เพิ่มเติมเพื่อทำความเข้าใจ แต่จะทำอย่างไรให้บทความเหล่านี้ไม่น่าเบื่อและน่าติดตามอยู่เสมอ คุณจะสามารถเห็นตัวอย่างได้ในบทความงานวิจัยที่เต็มไปด้วยตัวหนังสือ แต่ทุกตัวหนังสือคือคำอธิบายที่สำคัญทั้งนั้น แต่จะทำให้อย่างไรให้การอธิบายสิ่งเหล่านั้นให้น่าสนใจ กระชับที่สุด เข้าใจง่ายที่สุด วันนี้ลองมาดูกันว่าทีมงาน Alphagreenseo จะนำความรู้แบบไหนเกี่ยวกับการเขียนบทความยาว ๆ มาให้คุณได้เรียนรู้กัน",
        dates: ["2026-03-29"],
      ),
      DailyRecordItem(
        id: 4,
        iconId: 1,
        startTime: "08:00",
        endTime: "09:30",
        repeatType: 1,
        important: true,
        activityHeader: "Morning Workout",
        activityDetail:
            "คุณสมบัติหลักของการสร้างบทความยาวๆ ก็คือการให้ความรู้โดยละเอียดและลงลึกถึงเนื้อหาต่าง ๆ ที่มีส่วนจำเป็นและต้องการอธิบายและต้องใช้การอธิบายความรู้เพิ่มเติมเพื่อทำความเข้าใจ แต่จะทำอย่างไรให้บทความเหล่านี้ไม่น่าเบื่อและน่าติดตามอยู่เสมอ คุณจะสามารถเห็นตัวอย่างได้ในบทความงานวิจัยที่เต็มไปด้วยตัวหนังสือ แต่ทุกตัวหนังสือคือคำอธิบายที่สำคัญทั้งนั้น แต่จะทำให้อย่างไรให้การอธิบายสิ่งเหล่านั้นให้น่าสนใจ กระชับที่สุด เข้าใจง่ายที่สุด วันนี้ลองมาดูกันว่าทีมงาน Alphagreenseo จะนำความรู้แบบไหนเกี่ยวกับการเขียนบทความยาว ๆ มาให้คุณได้เรียนรู้กัน",
        dates: ["2026-03-29"],
      ),
    ];

    return Background(
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "รายการ",
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: themeItem.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      PressScale(
                        child: Container(
                          width: min(
                            MediaQuery.of(context).size.width * 0.45,
                            500,
                          ),
                          height: 40,
                          decoration: BoxDecoration(
                            color: themeItem.background2,
                            border: Border.all(
                              color: themeItem.textPrimary,
                              width: 1.5,
                            ),
                            gradient: _onSwitch
                                ? LinearGradient(
                                    colors: [
                                      themeItem.secondary,
                                      themeItem.primary,
                                    ],
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${widget.selectionDate}',
                              style: TextStyle(
                                color: _onSwitch
                                    ? themeItem.background2
                                    : themeItem.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        onTap: () => _switchTab(),
                      ),

                      PressScale(
                        child: Container(
                          width: min(
                            MediaQuery.of(context).size.width * 0.45,
                            500,
                          ),
                          height: 40,
                          decoration: BoxDecoration(
                            color: themeItem.background2,
                            border: Border.all(
                              color: themeItem.textPrimary,
                              width: 1.5,
                            ),
                            gradient: !_onSwitch
                                ? LinearGradient(
                                    colors: [
                                      themeItem.secondary,
                                      themeItem.primary,
                                    ],
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'ทั้งหมด',
                              style: TextStyle(
                                color: !_onSwitch
                                    ? themeItem.background2
                                    : themeItem.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        onTap: () => _switchTab(),
                      ),
                    ],
                  ),
                ),
                _Line(themeItem.textPrimary),
              ],
            ),
          ),
          Expanded(
            flex: 8,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              controller: _scrollController,
              itemCount: mockRecordData.length,
              separatorBuilder: (_, __) => const SizedBox(height: 0),
              itemBuilder: (context, index) {
                final item = mockRecordData[index];

                return KeyedSubtree(
                  key: index == 0 ? _firstItemKey : null,
                  child: Opacity(
                    opacity: 1.0,
                    child: DetailEditBox(items: item),
                  ),
                );
              },
            ),
          ),
          _Line(themeItem.textPrimary),
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BorderButton(
                    width: min(MediaQuery.of(context).size.width * 0.4, 500),
                    borderColor1: themeItem.secondary,
                    borderColor2: themeItem.primary,
                    backgroundColor: themeItem.background2,
                    text: 'กลับ',
                    onPressed: () => Navigator.pop(context),
                  ),
                  BorderButton(
                    width: min(MediaQuery.of(context).size.width * 0.4, 500),
                    borderColor1: themeItem.background1,
                    borderColor2: themeItem.background2,
                    backgroundColor: themeItem.addButton,
                    text: '+ เพิ่ม',
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/create');
                      if (!mounted) return;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _Line(Color color) {
  return Container(
    height: 4,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: color,
    ),
  );
}
