import 'package:daily_record/components/border_button.dart';
import 'package:daily_record/core/constants/icons.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class IconSelection extends StatelessWidget {
  final ValueChanged<int> onSelect;

  const IconSelection({super.key, required this.onSelect});

  void _onSelectIcons(BuildContext context, int key) {
    onSelect(key);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeItem = Provider.of<ThemeProvider>(context).currentThemeItem;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      decoration: BoxDecoration(
        color: themeItem!.background2,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.4,
            child: GridView.builder(
              padding: const EdgeInsets.all(5),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: iconsData.length,
              itemBuilder: (context, index) {
                final item = iconsData[index];
                return GestureDetector(
                  onTap: () => _onSelectIcons(context, item.keyId),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: themeItem.primary,
                        width: 5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(1, 2),
                        ),
                      ],
                      color: themeItem.background2,
                    ),
                    child: Center(
                      child: item.icon != null
                          ? Icon(item.icon, size: 30, color: themeItem.textPrimary)
                          : SvgPicture.asset(
                              item.iconPath!,
                              width: 30,
                              height: 30,
                            ),
                    ),
                  ),
                );
              },
            ),
          ),

          Row(
            children: [
              Expanded(
                child: BorderButton(
                  onPressed: () => Navigator.pop(context),
                  borderColor1: themeItem.secondary,
                  borderColor2: themeItem.primary,
                  backgroundColor: themeItem.background2,
                  text: 'กลับ',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
