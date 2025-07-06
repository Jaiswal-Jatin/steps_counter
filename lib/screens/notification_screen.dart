import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Mark all as read
            },
            child: Text(
              'Mark All Read',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _buildNotificationItem(
              'Goal Achieved!',
              'Congratulations! You\'ve reached your daily step goal of 10,000 steps.',
              'Share this with your friends',
              Icons.emoji_events,
              AppColors.success,
              '2 min ago',
              true,
            ),
            _buildNotificationItem(
              'Hydration Reminder',
              'You haven\'t drunk water in a while. Remember to stay hydrated!',
              'Tommy Parker left a comment under your post',
              Icons.water_drop,
              AppColors.info,
              '1 hour ago',
              false,
            ),
            _buildNotificationItem(
              'Weekly Report',
              'Your weekly fitness report is ready. Check your progress!',
              'Jessica Mendez left 2 of your recent posts',
              Icons.assessment,
              AppColors.primary,
              '3 hours ago',
              false,
            ),
            _buildNotificationItem(
              'New Challenge',
              'A new fitness challenge is available. Join now!',
              'Howard. Thanks for joining our community. Feel free to contact us if you need something',
              Icons.emoji_events,
              AppColors.accent,
              '5 hours ago',
              false,
            ),
            _buildNotificationItem(
              'Step Streak',
              'You\'re on a 7-day step streak! Keep it going!',
              'Streak Achievement',
              Icons.local_fire_department,
              AppColors.warning,
              '1 day ago',
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String message,
    String additionalInfo,
    IconData icon,
    Color color,
    String time,
    bool isNew,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isNew ? color.withOpacity(0.05) : AppColors.surface,
        borderRadius: AppBorderRadius.mediumRadius,
        boxShadow: AppShadows.card,
        border: isNew ? Border.all(color: color.withOpacity(0.2)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppBorderRadius.smallRadius,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isNew) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isNew ? color : AppColors.text,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  additionalInfo,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
