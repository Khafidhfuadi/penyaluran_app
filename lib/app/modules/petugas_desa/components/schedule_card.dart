import 'package:flutter/material.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class ScheduleCard extends StatelessWidget {
  final String title;
  final String location;
  final String dateTime;
  final bool isToday;
  final VoidCallback? onTap;

  const ScheduleCard({
    super.key,
    required this.title,
    required this.location,
    required this.dateTime,
    this.isToday = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: Colors.white.withAlpha(204), // 0.8 * 255 ≈ 204
              ),
            ),
            const SizedBox(height: 8),
            Text(
              location,
              style: textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dateTime,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
