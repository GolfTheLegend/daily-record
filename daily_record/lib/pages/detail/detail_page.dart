import 'dart:math';

import 'package:daily_record/components/background.dart';
import 'package:daily_record/components/border_button.dart';
import 'package:daily_record/core/constants/constants.dart';
import 'package:daily_record/core/models/get_daily_record_response.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
  final List<DailyRecordItem> recordData;

  const DetailPage({super.key, required this.recordData});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final ScrollController _scrollController = ScrollController();

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
        activityDetail: "Run 5km and stretch",
        dates: ["2026-03-29"],
      ),
    ];

    return Background(
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              controller: _scrollController,
              itemCount: mockRecordData.length,
              separatorBuilder: (_, __) => const SizedBox(height: 0),
              itemBuilder: (context, index) {
                final item = mockRecordData[index];

                final Color textColor =
                    statusList[item.repeatType!].key == 1
                    ? themeItem.status1
                    : statusList[item.repeatType!].key == 2
                    ? themeItem.status2
                    : themeItem.textPrimary;

                return KeyedSubtree(
                  key: index == 0 ? _firstItemKey : null,
                  child: Opacity(
                    opacity: 1.0,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item.startTime} - ${item.endTime}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                statusList[item.repeatType!].trailing,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                          margin: const EdgeInsets.only(bottom: 12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: themeItem.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(''),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
