import 'dart:math';

import 'package:daily_record/components/background.dart';
import 'package:daily_record/components/border_button.dart';
import 'package:daily_record/components/checkbox_button.dart';
import 'package:daily_record/components/iconselection.dart';
import 'package:daily_record/components/input.dart';
import 'package:daily_record/components/timeselection_button.dart';
import 'package:daily_record/constants/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    return Background(
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  "19",
                  style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "กุมภาพันธ์ 2568",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: _iconPicker,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(7, 12),
                        ),
                      ],
                    ),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(child: _buildSelectedIcon()),
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
                  const Text(
                    'ถึง',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
                        const Text(
                          'หัวข้อ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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
                            const Text(
                              'สำคัญ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(width: 20),
                            CheckboxButton(),
                            const Text(
                              'ทุกวัน',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
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
                              const Text(
                                'รายละเอียด',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
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
                          borderColor1: const Color(0xFFEB00B1),
                          borderColor2: const Color(0xFFFFAAEA),
                          backgroundColor: Colors.white,
                          text: 'กลับ',
                        ),
                        BorderButton(
                          width: min(
                            screenWidth * 0.4,
                            500,
                          ),
                          borderColor1: Colors.black,
                          borderColor2: Colors.white,
                          backgroundColor: Color(0xFF84FF8D),
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

  Widget _buildSelectedIcon() {
    if (iconSelect == null) {
      return const Icon(Icons.add, size: 60);
    }

    final selected = iconsData.firstWhere(
      (i) => i.keyId == iconSelect,
      orElse: () => iconsData.first,
    );

    if (selected.icon != null) {
      return Icon(selected.icon, size: 60);
    }

    return SvgPicture.asset(selected.iconPath!, width: 60);
  }
}
