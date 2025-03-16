import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  final String? viewAllText;
  final Widget? trailing;
  final EdgeInsets padding;
  final TextStyle? titleStyle;

  const SectionHeader({
    Key? key,
    required this.title,
    this.onViewAll,
    this.viewAllText = 'Lihat Semua',
    this.trailing,
    this.padding = const EdgeInsets.only(bottom: 12),
    this.titleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: titleStyle ??
                const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (trailing != null)
            trailing!
          else if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: Text(viewAllText!),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 36),
              ),
            ),
        ],
      ),
    );
  }
}
