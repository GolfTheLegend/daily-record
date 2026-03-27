import 'package:daily_record/core/themes/theme.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AlertType { error, success, info, warning }

class AppAlert extends StatelessWidget {
  final String title;
  final String? message;
  final AlertType type;
  final String confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const AppAlert({
    super.key,
    required this.title,
    this.message,
    this.type = AlertType.error,
    this.confirmText = 'ตกลง',
    this.cancelText,
    this.onConfirm,
    this.onCancel,
  });

  // static helper เรียกง่าย
  static Future<void> show(
    BuildContext context, {
    required String title,
    String? message,
    AlertType type = AlertType.error,
    String confirmText = 'ตกลง',
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => AppAlert(
        title: title,
        message: message,
        type: type,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;
    final config = _typeConfig(type);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: themeItem.background2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: themeItem.primary, width: 4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: config.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(config.icon, color: config.color, size: 28),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeItem.text1,
              ),
            ),

            // Message
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: themeItem.text1.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                if (cancelText != null) ...[
                  Expanded(
                    child: _AlertButton(
                      label: cancelText!,
                      isPrimary: false,
                      themeItem: themeItem,
                      onTap: () {
                        Navigator.of(context).pop();
                        onCancel?.call();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: _AlertButton(
                    label: confirmText,
                    isPrimary: true,
                    color: config.color,
                    themeItem: themeItem,
                    onTap: () {
                      Navigator.of(context).pop();
                      onConfirm?.call();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _AlertConfig _typeConfig(AlertType type) => switch (type) {
        AlertType.error   => _AlertConfig(Icons.error_rounded,   const Color(0xFFE05C5C)),
        AlertType.success => _AlertConfig(Icons.check_circle_rounded, const Color(0xFF4CAF80)),
        AlertType.warning => _AlertConfig(Icons.warning_rounded,  const Color(0xFFF5A623)),
        AlertType.info    => _AlertConfig(Icons.info_rounded,     const Color(0xFF5B9BD5)),
      };
}

// ปุ่ม
class _AlertButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final Color? color;
  final ThemeItem themeItem;
  final VoidCallback onTap;

  const _AlertButton({
    required this.label,
    required this.isPrimary,
    required this.themeItem,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary
              ? (color ?? themeItem.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary
                ? Colors.transparent
                : themeItem.primary.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isPrimary
                ? Colors.white
                : themeItem.text1.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}

// config helper
class _AlertConfig {
  final IconData icon;
  final Color color;
  const _AlertConfig(this.icon, this.color);
}