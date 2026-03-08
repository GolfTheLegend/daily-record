import 'dart:math';

import 'package:daily_record/components/background.dart';
import 'package:daily_record/components/border_button.dart';
import 'package:daily_record/components/checkbox_button.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:daily_record/pages/createactive/iconselection.dart';
import 'package:daily_record/components/input.dart';
import 'package:daily_record/pages/createactive/timeselection_button.dart';
import 'package:daily_record/core/constants/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class CreateActivePage extends StatefulWidget {
  const CreateActivePage({super.key});

  @override
  State<CreateActivePage> createState() => _CreateActivePageState();
}

class _CreateActivePageState extends State<CreateActivePage> {
  int? iconSelect;

  void _iconPicker() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: IconSelection(
          onSelect: (value) {
            setState(() {
              iconSelect = value;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeItem = Provider.of<ThemeProvider>(context).currentThemeItem;
    
    final screenWidth = MediaQuery.of(context).size.width;
    return Background(
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
               Text(
                  "19",
                  style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold,color: themeItem!.textPrimary),
                ),
                Text(
                  "กุมภาพันธ์ 2568",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: themeItem.textPrimary),
                ),
                GestureDetector(
                  onTap: _iconPicker,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: themeItem.primary,
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.3),
                          blurRadius: 16,
                          offset: const Offset(7, 12),
                        ),
                      ],
                    ),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: themeItem.background2,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(child: _buildSelectedIcon(themeItem.textPrimary)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TimeSelectionButton(),
                  Text(
                    'ถึง',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: themeItem.textPrimary),
                  ),
                  TimeSelectionButton(),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'หัวข้อ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,color: themeItem.textPrimary
                          ),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          width: screenWidth * 0.75,
                          height: 45,
                          child: Input(isMultiline: false, maxLength: 50),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    width: double.infinity,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CheckboxButton(),
                            Text(
                              'สำคัญ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: themeItem.status2,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(width: 20),
                            CheckboxButton(),
                            Text(
                              'ทุกวัน',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: themeItem.status1,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),

                        Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'รายละเอียด',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: themeItem.textPrimary
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                child: Input(
                                  isMultiline: true,
                                  height: 130,
                                  maxLength: 150,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                            screenWidth * 0.4,
                            500,
                          ),
                          borderColor1: themeItem.secondary,
                          borderColor2: themeItem.primary,
                          backgroundColor: themeItem.background2,
                          text: 'กลับ',
                          onPressed:() => Navigator.pop(context)
                        ),
                        BorderButton(
                          width: min(
                            screenWidth * 0.4,
                            500,
                          ),
                          borderColor1: themeItem.background1,
                          borderColor2: themeItem.background2,
                          backgroundColor:themeItem.addButton,
                          text: 'บันทึก',
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

  Widget _buildSelectedIcon(Color color) {
    if (iconSelect == null) {
      return Icon(Icons.add, size: 60,color:color);
    }

    final selected = iconsData.firstWhere(
      (i) => i.keyId == iconSelect,
      orElse: () => iconsData.first,
    );

    if (selected.icon != null) {
      return Icon(selected.icon, size: 60,color:color);
    }

    return SvgPicture.asset(selected.iconPath!, width: 60);
  }
}
