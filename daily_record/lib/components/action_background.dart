import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActionBackground extends StatefulWidget {
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
  State<ActionBackground> createState() => _ActionBackgroundState();
}

class _ActionBackgroundState extends State<ActionBackground> {
  bool layer1 = false;
  bool layer2 = false;
  bool layer3 = false;
  bool layer4 = false;

  @override
  void initState() { 
    super.initState();

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => layer1 = true);
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => layer2 = true);
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => layer3 = true);
    });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => layer4 = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;

    return Scaffold(
      backgroundColor: themeItem.background1,
      appBar: widget.appBar,
      floatingActionButton: widget.floatingActionButton,
      drawer: widget.drawer,
      bottomNavigationBar: widget.bottomNavigationBar,

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                width: double.infinity,
                child: Center(child: widget.header),
              ),
            ),
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  _BackGroundLayer(
                    color: themeItem.secondary,
                    vMargin: layer1 ? 5 : 700,
                  ),
                  _BackGroundLayer(
                    color: themeItem.primary,
                    vMargin: layer2 ? 20 : 700,
                  ),
                  _BackGroundLayer(
                    color: themeItem.background2,
                    vMargin: layer3 ? 30 : 700,
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    top: layer4 ? 5 : 700,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(child: widget.child),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _BackGroundLayer({required Color color, double vMargin = 0}) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      top: vMargin,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(70),
            topRight: Radius.circular(70),
          ),
        ),
      ),
    );
  }
}
