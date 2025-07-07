import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StatsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const StatsCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with circular background
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primaryOrange).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor ?? AppColors.primaryOrange,
            ),
          ),
          const SizedBox(height: 12),

          // Value
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 4),

          // Label
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
