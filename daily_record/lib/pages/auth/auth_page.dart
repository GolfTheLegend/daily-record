import 'package:daily_record/components/action_background.dart';
import 'package:daily_record/components/switch_button.dart';
import 'package:daily_record/pages/auth/login.dart';
import 'package:daily_record/pages/auth/register.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  void _onSwitch(value) {
    setState(() {
      isLogin = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ActionBackground(
      header: Text(
        isLogin ? 'Login' : 'Register',
        style: TextStyle(
          fontSize: 70,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
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
                  ),
                ),
              ),
            ),
            if (isLogin) ...[Expanded(flex: 5, child: Login())],
            if (!isLogin) ...[Expanded(flex: 5, child: Register())],
          ],
        ),
      ),
    );
  }
}
