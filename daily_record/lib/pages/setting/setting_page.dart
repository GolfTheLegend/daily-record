import 'dart:math';

import 'package:daily_record/components/app_alert.dart';
import 'package:daily_record/components/background.dart';
import 'package:daily_record/components/border_button.dart';
import 'package:daily_record/components/press_scale.dart';
import 'package:daily_record/core/di/injection.dart';
import 'package:daily_record/core/models/logout_all_request.dart';
import 'package:daily_record/core/models/logout_request.dart';
import 'package:daily_record/core/repositories/repositories.dart';
import 'package:daily_record/core/services/device_service.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:daily_record/core/utils/token_storage.dart';
import 'package:daily_record/pages/setting/themeselection.dart';
import 'package:daily_record/core/configs/configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final IAuthRepository _authRepository = getIt<IAuthRepository>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _selectTheme() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Themeselection(
          onSelect: (value) {
            setState(() {
              Provider.of<ThemeProvider>(
                context,
                listen: false,
              ).setThemeByKey(value);
            });
          },
        ),
      ),
    );
  }

  Future<void> _logOut() async {
    setState(() => _isLoading = true);
    var success = false;

    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      final deviceId = await DeviceService.getDeviceId();

      if (refreshToken != null) {
        await _authRepository.logout(
          LogoutRequest(
            refreshToken: refreshToken,
            deviceId: deviceId,
          ),
        );
      }

      success = true;
    } catch (e) {
      AppAlert.show(
        context,
        title: 'เกิดข้อผิดพลาด',
        message: e.toString(),
        type: AlertType.error,
      );
    } finally {
      if (success) {
        await TokenStorage.clearTokens();

        if (!mounted) return;
        setState(() => _isLoading = false);
        AppAlert.show(
          context,
          title: 'ออกจากระบบสำเร็จ',
          message: '',
          type: AlertType.success,
          onConfirm: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
        );
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logoutAllDevices() async {
    setState(() => _isLoading = true);
    var success = false;

    try {
      final deviceId = await DeviceService.getDeviceId();
      await _authRepository.logoutAll(LogoutAllRequest(deviceId: deviceId));
      success = true;
    } catch (e) {
      AppAlert.show(
        context,
        title: 'เกิดข้อผิดพลาด',
        message: e.toString(),
        type: AlertType.error,
      );
    } finally {
      if (success) {
        await TokenStorage.clearTokens();

        if (!mounted) return;
        setState(() => _isLoading = false);
        AppAlert.show(
          context,
          title: 'ออกจากระบบทั้งหมดสำเร็จ',
          message: '',
          type: AlertType.success,
          onConfirm: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
        );
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
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
                  Icon(Icons.settings, size: 40, color: themeItem.textPrimary),
                  SizedBox(width: 10),
                  Text(
                    'ตั้งค่า',
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
            flex: 7,
            child: Container(
              width: double.infinity,
              child: ScrollConfiguration(
                behavior: const ScrollBehavior(),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      PressScale(
                        onTap: _selectTheme,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: themeItem.background2,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.color_lens,
                                        size: 30,
                                        color: themeItem.textPrimary,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'ธีมสี',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: themeItem.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  child: Row(
                                    children: [
                                      ThemeColor(themeItem.background2),
                                      const SizedBox(width: 10),
                                      ThemeColor(themeItem.primary),
                                      const SizedBox(width: 10),
                                      ThemeColor(themeItem.secondary),
                                      const SizedBox(width: 10),
                                      ThemeColor(themeItem.background1),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      PressScale(
                        onTap: () => (print('tap')),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: themeItem.background2,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/language.svg',
                                        width: 20,
                                        height: 20,
                                        colorFilter: ColorFilter.mode(
                                          themeItem.textPrimary,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'ภาษา',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: themeItem.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ThemeColor(
                                  themeItem.background2,
                                  child: Icon(
                                    Icons.language,
                                    color: themeItem.textPrimary,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: themeItem.background2,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                child: Text(
                                  'Version',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: themeItem.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                appVersion,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: themeItem.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: PressScale(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: themeItem.status2,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'ออกจากระบบ',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: themeItem.background2,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () => _isLoading ? null : _logOut(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: PressScale(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: themeItem.status1,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'ออกจากระบบทั้งหมด',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: themeItem.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () => _isLoading ? null : _logoutAllDevices(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: Center(
              child: BorderButton(
                width: min(MediaQuery.of(context).size.width * 0.8, 500),
                borderColor1: themeItem.secondary,
                borderColor2: themeItem.primary,
                backgroundColor: themeItem.background2,
                text: 'กลับ',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
