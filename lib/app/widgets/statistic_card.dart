import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatisticCard extends StatelessWidget {
  final String title;
  final String count;
  final String subtitle;
  final double height;

  const StatisticCard({
    super.key,
    required this.title,
    required this.count,
    required this.subtitle,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 4),
          Text(
            count,
            style: textTheme.headlineSmall?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
