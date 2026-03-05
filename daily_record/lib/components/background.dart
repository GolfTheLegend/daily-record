import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Background extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? bottomNavigationBar;

  const Background({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.bottomNavigationBar,
  });
  @override
  Widget build(BuildContext context) {
    final themeItem = Provider.of<ThemeProvider>(context).currentThemeItem;

    return Scaffold(
      backgroundColor: themeItem!.background1,

      appBar: appBar,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,

      body: Stack(
        children: [
          _BackGroundLayer(color: themeItem.secondary, vMargin: 5),
          _BackGroundLayer(color: themeItem.primary, vMargin: 15),
          _BackGroundLayer(color: themeItem.background2, vMargin: 25),

          SafeArea(child: child),
        ],
      ),
    );
  }

  Widget _BackGroundLayer({required Color color, double vMargin = 0}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: vMargin),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(40),
      ),
      width: double.infinity,
      height: double.infinity,
    );
  }
}
