import 'package:daily_record/components/action_background.dart';
import 'package:daily_record/components/loading.dart';
import 'package:daily_record/components/switch_button.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:daily_record/core/utils/token_storage.dart';
import 'package:daily_record/pages/auth/login.dart';
import 'package:daily_record/pages/auth/register.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isCheckingAuth = true;
  bool _isLogin = true;
  bool _isLoading = false;

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
      _isLogin = value;
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
    final header = _TextHeader(_isLogin);
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;

    if (_isCheckingAuth) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ActionBackground(
      header: header,
      child: Stack(
        children: [
          Container(
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
                        initialValue: _isLogin,
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
                        left: _isLogin ? 0 : -4000,
                        right: _isLogin ? 0 : 4000,
                        bottom: 0,
                        child: Login(
                          isLoading: _isLoading,
                          setLoading: (p0) => setState(() => _isLoading = p0),
                        ),
                      ),

                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        top: 0,
                        left: _isLogin ? 4000 : 0,
                        right: _isLogin ? -4000 : 0,
                        bottom: 0,
                        child: Register(
                          isLoading: _isLoading,
                          setLoading: (p0) => setState(() => _isLoading = p0),
                          onRegisterSuccess: (success) {
                            if (success) {
                              setState(() {
                                _isLogin = true;
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

          AnimatedOpacity(
            opacity: _isLoading ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_isLoading,
              child: Container(
                color: themeItem.background2.withValues(alpha: 0.6),
                child: const Center(
                  child: LoadingAnimation(width: 50, height: 50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _TextHeader(bool _isLogin) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          top: 0,
          left: _isLogin ? 0 : -4000,
          right: _isLogin ? 0 : 4000,
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
          left: _isLogin ? 4000 : 0,
          right: _isLogin ? -4000 : 0,
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
