import 'dart:math';

import 'package:daily_record/components/background.dart';
import 'package:daily_record/components/border_button.dart';
import 'package:daily_record/components/calendar_table.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
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
          Expanded(flex: 5, child: CalendarTable()),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 5),
                          Row(
                            children: [
                              _dot(themeItem.status1),
                              const SizedBox(width: 5),
                              const Text(
                                'มีรายการ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10),
                              _dot(themeItem.status2),
                              const SizedBox(width: 5),
                              const Text(
                                'วันสำคัญ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 5),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: themeItem.primary,
                                width: 4,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: themeItem.background2,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha:0.3),
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
                          const SizedBox(width: 5),
                        ],
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
                        child: Text('x'),
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
                          onPressed: () =>
                              Navigator.pushNamed(context, '/create'),
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

