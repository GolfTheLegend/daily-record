import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActionBackground extends StatelessWidget {
  final Widget child;
  final Widget header;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? bottomNavigationBar;

  const ActionBackground({
    super.key,
    required this.child,
    required this.header,
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

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                child: Center(child: header),
                width: double.infinity,
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(),
                child: Stack(
                  children: [
                    _BackGroundLayer(color: themeItem.secondary, vMargin: 5),
                    _BackGroundLayer(color: themeItem.primary, vMargin: 20),
                    _BackGroundLayer(color: themeItem.background2, vMargin: 30),

                    SafeArea(child: child),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _BackGroundLayer({required Color color, double vMargin = 0}) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, vMargin, 0, 0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(70),
          topRight: Radius.circular(70),
        ),
      ),
      width: double.infinity,
      height: double.infinity,
    );
  }
}
