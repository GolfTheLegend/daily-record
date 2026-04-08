import 'dart:math';
import 'package:daily_record/components/app_alert.dart';
import 'package:daily_record/components/background.dart';
import 'package:daily_record/components/border_button.dart';
import 'package:daily_record/components/press_scale.dart';
import 'package:daily_record/core/models/get_daily_record_request.dart';
import 'package:daily_record/core/models/get_daily_record_response.dart';
import 'package:daily_record/core/services/get_daily_record_service.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:daily_record/pages/create_active/create_active_page.dart';
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
  final _service = GetDailyRecordService();
  List<DailyRecordItem> _records = [];
  bool _onSwitch = true;
  bool _isLoading = false;
  int _offset = 0;
  final int _limit = 10;
  bool _hasMore = true;

  void _loadMore() {
    _offset += _limit;
    _fetchRecords('', false);
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !_isLoading &&
          _hasMore &&
          !_onSwitch // เฉพาะ tab "ทั้งหมด"
          ) {
        _loadMore();
      }
    });

    if (_onSwitch) {
      if (widget.recordData.isEmpty) {
        _fetchRecords(widget.selectionDate, false);
      } else {
        _records = widget.recordData;
      }
    }
  }

  void _switchTab() {
    setState(() {
      _onSwitch = !_onSwitch;
    });

    if (_onSwitch == false) {
      _fetchRecords('', true);
    } else {
      _fetchRecords(widget.selectionDate, true);
    }
  }

  Future<void> _fetchRecords(String date, bool onChangeData) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    if (onChangeData) {
      _offset = 0;
      _hasMore = true;
      _records = [];
    }

    try {
      final request = _onSwitch
          ? GetDailyRecordsRequest(dateFrom: date, dateTo: date)
          : GetDailyRecordsRequest(limit: _limit, offset: _offset);

      final response = await _service.getDailyRecords(request);

      if (!mounted) return;

      setState(() {
        if (_offset == 0) {
          _records = response.data;
        } else {
          _records.addAll(response.data); // ✅ append
        }

        // ถ้าได้ข้อมูลน้อยกว่า limit แปลว่าไม่มีต่อแล้ว
        if (response.data.length < _limit) {
          _hasMore = false;
        }
      });
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;

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
              itemCount: _records.length + (_isLoading ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 0),
              itemBuilder: (context, index) {
                if (index >= _records.length) {
                  return Center(child: CircularProgressIndicator());
                }

                final item = _records[index];
                return DetailEditBox(
                  items: item,
                  onDelete: () => {
                    if (_onSwitch == false)
                      {_fetchRecords('', true)}
                    else
                      {_fetchRecords(widget.selectionDate, true)},
                  },
                  onEdit: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateActivePage(
                          mode: PageMode.edit,
                          recordData: item,
                        ),
                      ),
                    );
                    if (!mounted) return;
                    if (_onSwitch == false) {
                      _fetchRecords('', true);
                    } else {
                      _fetchRecords(widget.selectionDate, true);
                    }
                  },
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
                      if (_onSwitch == false) {
                        _fetchRecords('', true);
                      } else {
                        _fetchRecords(widget.selectionDate, true);
                      }
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
