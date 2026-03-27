import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SwitchButton extends StatefulWidget {
  final bool initialValue;
  final Widget box1;
  final Widget box2;
  final ValueChanged<bool> onSelect;

  const SwitchButton({
    super.key,
    this.initialValue = true,
    required this.box1,
    required this.box2,
    required this.onSelect,
  });

  @override
  State<SwitchButton> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton> {
  bool onSwitch = true;

  @override
  void initState() {
    super.initState();
    onSwitch = widget.initialValue;
  }

  @override
  void didUpdateWidget(SwitchButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        onSwitch = widget.initialValue;
      });
    }
  }

  void selectLeft() {
    widget.onSelect(true);
    setState(() {
      onSwitch = true;
    });
  }

  void selectRight() {
    widget.onSelect(false);
    setState(() {
      onSwitch = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;

    return Container(
      width: 320,
      height: 60,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: themeItem.background2,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: themeItem.primary, width: 4),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / 2;

          return Stack(
            children: [
              /// sliding indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: onSwitch ? 0 : itemWidth,
                child: Container(
                  width: itemWidth,
                  height: constraints.maxHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [themeItem.secondary, themeItem.primary],
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),

              /// buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: selectLeft,
                      child: Center(
                        child: DefaultTextStyle.merge(
                          style: TextStyle(
                            color: onSwitch
                                ? themeItem.background2
                                : themeItem.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          child: widget.box1,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: selectRight,
                      child: Center(
                        child: DefaultTextStyle.merge(
                          style: TextStyle(
                            color: !onSwitch
                                ? themeItem.background2
                                : themeItem.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          child: widget.box2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
