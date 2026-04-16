import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesignDropdown<T> extends StatefulWidget {
  final T initialValue;
  final List<DropdownMenuEntry<T>> entries;
  final ValueChanged<T?> onChanged;
  final double borderRadius;

  const DesignDropdown({
    super.key,
    required this.initialValue,
    required this.entries,
    required this.onChanged,
    this.borderRadius = 12,
  });

  @override
  State<DesignDropdown<T>> createState() => _DesignDropdownState<T>();
}

class _DesignDropdownState<T> extends State<DesignDropdown<T>> {
  final GlobalKey _buttonKey = GlobalKey();
  late T _selectedValue;
  bool _isDropdownOpen = false;
  double? _buttonWidth;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    // ดึงขนาดหลัง frame แรก render เสร็จ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && mounted) {
        setState(() => _buttonWidth = box.size.width);
      }
    });
  }

  String get _selectedLabel =>
      widget.entries.firstWhere((e) => e.value == _selectedValue).label;

  @override
  void didUpdateWidget(DesignDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _selectedValue = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final boxSize = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;
    final radius = widget.borderRadius;

    TextStyle _labelStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: themeItem.textPrimary,
      fontSize: 17,
    );

    final double width = _buttonWidth ?? boxSize?.size.width ?? 0;

    return PopupMenuButton<T>(
      offset: Offset(0, (boxSize)?.size.height ?? 48),
      constraints: BoxConstraints(
        minWidth: width,
        maxWidth: width > 0 ? width : double.infinity,
      ),
      onOpened: () => setState(() => _isDropdownOpen = true),
      onCanceled: () => setState(() => _isDropdownOpen = false),
      onSelected: (value) {
        setState(() => _isDropdownOpen = false);
        widget.onChanged(value);
      },
      color: themeItem.background2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      itemBuilder: (context) => widget.entries
          .map(
            (e) => PopupMenuItem<T>(
              value: e.value,
              child: e.leadingIcon != null
                  ? Row(
                      children: [
                        e.leadingIcon!,
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            e.label,
                            overflow: TextOverflow.ellipsis,
                            style: _labelStyle,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      e.label,
                      overflow: TextOverflow.ellipsis,
                      style: _labelStyle,
                    ),
            ),
          )
          .toList(),
      child: Container(
        key: _buttonKey,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: themeItem.primary, width: 2),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Text(
                _selectedLabel,
                overflow: TextOverflow.ellipsis,
                style: _labelStyle,
              ),
            ),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: _isDropdownOpen ? -0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: themeItem.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
