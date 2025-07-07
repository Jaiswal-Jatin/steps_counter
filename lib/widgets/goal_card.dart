import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class GoalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final String totalDistance;

  const GoalCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.totalDistance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon with progress
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryOrange,
                  ),
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.primaryOrange,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Arrow icon
          Icon(
            Icons.keyboard_arrow_right,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
        ],
      ),
    );
  }
}
