import 'package:flutter/material.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class StatusPill extends StatelessWidget {
  final String status;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const StatusPill({
    super.key,
    required this.status,
    this.backgroundColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.verifiedColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: textStyle ??
            textTheme.bodySmall?.copyWith(
              fontSize: 10,
            ),
      ),
    );
  }
}
