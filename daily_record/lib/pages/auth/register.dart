import 'dart:math';

import 'package:daily_record/components/app_alert.dart';
import 'package:daily_record/components/border_button.dart';
import 'package:daily_record/components/input.dart';
import 'package:daily_record/core/models/register_request.dart';
import 'package:daily_record/core/services/register_service.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  final ValueChanged<bool> onRegisterSuccess;
  const Register({super.key, required this.onRegisterSuccess});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isLoading = false;
  final RegisterService _registerService = RegisterService();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final request = RegisterRequest(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      await _registerService.register(request);

      if (mounted) {
        AppAlert.show(
          context,
          title: 'สำเร็จ',
          message: 'ลงทะเบียนสำเร็จ',
          type: AlertType.success,
          onConfirm: () {
            _usernameController.clear();
            _emailController.clear();
            _passwordController.clear();
            widget.onRegisterSuccess(true);
          },
        );
      }
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;
    final screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Username',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: screenWidth * 0.8,
                  height: 45,
                  child: Input(
                    isMultiline: false,
                    hideMaxWord: true,
                    controller: _usernameController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'E-mail',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: screenWidth * 0.8,
                  height: 45,
                  child: Input(
                    isMultiline: false,
                    hideMaxWord: true,
                    controller: _emailController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                  width: screenWidth * 0.8,
                  height: 45,
                  child: Input(
                    isMultiline: false,
                    hideMaxWord: true,
                    controller: _passwordController,
                    ispassword: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: BorderButton(
                width: min(MediaQuery.of(context).size.width * 0.8, 500),
                borderColor1: themeItem.secondary,
                borderColor2: themeItem.primary,
                backgroundColor: themeItem.background2,
                text: _isLoading ? 'Loading...' : 'Register',
                onPressed: _isLoading ? null : _handleRegister,
              ),
            ),
            const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                themeItem.secondary.withValues(alpha: 0.4),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or continue with',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Inter',
                            color: themeItem.secondary.withValues(alpha: 0.6),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                themeItem.secondary.withValues(alpha: 0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Social Login Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LINE Button
                    _SocialLoginButton(
                      onPressed: () {
                        // TODO: LINE login
                      },
                      backgroundColor: themeItem.background2,
                      borderColor: themeItem.secondary.withValues(alpha: 0.3),
                      icon: SvgPicture.asset(
                        'assets/icons/line-color-icon.svg',
                        width: 20,
                        height: 20,
                      ),
                      label: 'Line',
                      textColor: themeItem.secondary,
                    ),

                    const SizedBox(width: 16),

                    // Google Button
                    _SocialLoginButton(
                      onPressed: () {
                        // TODO: Google login
                      },
                      backgroundColor: themeItem.background2,
                      borderColor: themeItem.secondary.withValues(alpha: 0.3),
                      icon: SvgPicture.asset(
                        'assets/icons/google-color-icon.svg',
                        width: 20,
                        height: 20,
                      ),
                      label: 'Google',
                      textColor: themeItem.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 50),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final Widget icon;
  final String label;
  final Color textColor;

  const _SocialLoginButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    required this.label,
    required this.textColor,
  });

  @override
  State<_SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<_SocialLoginButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 140,
        height: 48,
        decoration: BoxDecoration(
          color: _isHovered
              ? widget.backgroundColor.withValues(alpha: 0.85)
              : widget.backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: widget.borderColor, width: 1.5),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.borderColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 22, height: 22, child: widget.icon),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                color: widget.textColor,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
