import 'package:daily_record/components/action_background.dart';
import 'package:daily_record/components/switch_button.dart';
import 'package:daily_record/core/utils/token_storage.dart';
import 'package:daily_record/pages/auth/login.dart';
import 'package:daily_record/pages/auth/register.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isCheckingAuth = true;
  bool isLogin = true;

  @override
  void initState() {
    super.initState();
    // ✅ รอให้ first frame build เสร็จก่อนค่อย navigate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoLogin();
    });
  }

  void _onSwitch(value) {
    setState(() {
      isLogin = value;
    });
  }

  Future<void> _checkAutoLogin() async {
    final autoLogin = await TokenStorage.getAutoLogin();

    if (autoLogin) {
      final isExpired = await TokenStorage.isAccessTokenExpired();
      if (!isExpired) {
        // ✅ token ยังใช้ได้ → ไป Home เลย
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/Home', (route) => false);
          return;
        }
      }
      // token หมดอายุ → ล้างแล้วไป login
      await TokenStorage.clearTokens();
    }

    if (mounted) setState(() => _isCheckingAuth = false);
  }

  @override
  Widget build(BuildContext context) {
    final header = _TextHeader(isLogin);

    if (_isCheckingAuth) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ActionBackground(
      header: header,
      child: Container(
        decoration: BoxDecoration(),
        width: double.infinity,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SwitchButton(
                    box1: Text('Login'),
                    box2: Text('Register'),
                    onSelect: _onSwitch,
                    initialValue: isLogin,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    top: 0,
                    left: isLogin ? 0 : -500,
                    right: isLogin ? 0 : 500,
                    bottom: 0,
                    child: Login(),
                  ),

                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    top: 0,
                    left: isLogin ? 500 : 0,
                    right: isLogin ? -500 : 0,
                    bottom: 0,
                    child: Register(
                      onRegisterSuccess: (success) {
                        if (success) {
                          setState(() {
                            isLogin = true;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _TextHeader(bool isLogin) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          top: 0,
          left: isLogin ? 0 : -500,
          right: isLogin ? 0 : 500,
          bottom: 0,
          child: Center(
            child: Text(
              'Login',
              style: TextStyle(
                fontSize: 70,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          top: 0,
          left: isLogin ? 500 : 0,
          right: isLogin ? -500 : 0,
          bottom: 0,
          child: Center(
            child: Text(
              'Register',
              style: TextStyle(
                fontSize: 70,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
