import 'dart:math';

import 'package:daily_record/components/border_button.dart';
import 'package:daily_record/components/input.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    final themeItem = Provider.of<ThemeProvider>(context).currentThemeItem;
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Padding(
            padding: EdgeInsets.only(top: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: screenWidth * 0.75,
                      height: 45,
                      child: Input(isMultiline: false, hideMaxWord: true),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: screenWidth * 0.75,
                      height: 45,
                      child: Input(isMultiline: false, hideMaxWord: true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: BorderButton(
              width: min(MediaQuery.of(context).size.width * 0.8, 500),
              borderColor1: themeItem!.secondary,
              borderColor2: themeItem.primary,
              backgroundColor: themeItem.background2,
              text: 'Login',
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );
  }
}
