import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/step_counter_provider.dart';
import '../theme/app_theme.dart';
import '../services/ad_service.dart';

class GoalAchievementScreen extends StatefulWidget {
  const GoalAchievementScreen({super.key});

  @override
  State<GoalAchievementScreen> createState() => _GoalAchievementScreenState();
}

class _GoalAchievementScreenState extends State<GoalAchievementScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late Animation<double> _celebrationAnimation;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    _celebrationController.forward();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Goal Achievement'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<StepCounterProvider>(
        builder: (context, provider, child) {
          final isGoalReached = provider.currentSteps >= provider.dailyGoal;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                _buildCelebrationCard(isGoalReached, provider),
                const SizedBox(height: AppSpacing.lg),
                _buildProgressCard(provider),
                const SizedBox(height: AppSpacing.lg),
                _buildRewardCard(isGoalReached),
                const SizedBox(height: AppSpacing.lg),
                _buildShareCard(provider),
                const SizedBox(height: AppSpacing.lg),
                _buildStreakCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCelebrationCard(bool isGoalReached, StepCounterProvider provider) {
    return AnimatedBuilder(
      animation: _celebrationAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _celebrationAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: isGoalReached 
                  ? AppColors.secondaryGradient 
                  : AppColors.primaryGradient,
              borderRadius: AppBorderRadius.largeRadius,
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                Icon(
                  isGoalReached ? Icons.emoji_events : Icons.directions_walk,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  isGoalReached ? 'Goal Achieved!' : 'Keep Going!',
                  style: AppTextStyles.headline2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  isGoalReached 
                      ? 'Congratulations! You\'ve reached your daily step goal of ${provider.dailyGoal} steps!'
                      : 'You\'re ${provider.dailyGoal - provider.currentSteps} steps away from your goal!',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAchievementStat(
                      '${provider.currentSteps}',
                      'Steps',
                      Icons.directions_walk,
                    ),
                    _buildAchievementStat(
                      '${provider.currentDistance.toStringAsFixed(1)}km',
                      'Distance',
                      Icons.straighten,
                    ),
                    _buildAchievementStat(
                      '${provider.currentCalories}',
                      'Calories',
                      Icons.local_fire_department,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.headline6.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(StepCounterProvider provider) {
    final progress = (provider.currentSteps / provider.dailyGoal * 100).clamp(0, 100);
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.largeRadius,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Progress',
            style: AppTextStyles.headline6,
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 8,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${progress.round()}% Complete',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '${provider.currentSteps} / ${provider.dailyGoal}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(bool isGoalReached) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.largeRadius,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.card_giftcard,
                color: AppColors.accent,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Rewards',
                style: AppTextStyles.headline6,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (isGoalReached) ...[
            _buildRewardItem(
              'Daily Goal Bonus',
              'Earn 50 points for reaching your daily goal',
              Icons.stars,
              AppColors.warning,
              true,
            ),
            _buildRewardItem(
              'Watch Ad for Extra Points',
              'Watch a short ad to earn 25 bonus points',
              Icons.play_circle_fill,
              AppColors.info,
              false,
            ),
          ] else ...[
            _buildRewardItem(
              'Daily Goal Bonus',
              'Complete your daily goal to earn 50 points',
              Icons.stars,
              AppColors.textLight,
              false,
            ),
            _buildRewardItem(
              'Motivational Boost',
              'Watch an inspiring video to stay motivated',
              Icons.play_circle_fill,
              AppColors.info,
              false,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRewardItem(String title, String description, IconData icon, Color color, bool isEarned) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppBorderRadius.mediumRadius,
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppBorderRadius.smallRadius,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isEarned ? color : AppColors.textLight,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          if (isEarned)
            Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 20,
            )
          else
            ElevatedButton(
              onPressed: () {
                // Show rewarded ad
                AdService().showRewardedAd(
                  onUserEarnedReward: (ad, reward) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Earned ${reward.amount} ${reward.type}!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Claim', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildShareCard(StepCounterProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.largeRadius,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share Your Achievement',
            style: AppTextStyles.headline6,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Let your friends know about your fitness progress!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Share functionality - would implement actual sharing
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Shared: I walked ${provider.currentSteps} steps today!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Save achievement
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Achievement saved to gallery'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Save'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.largeRadius,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: AppColors.accent,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Streak Challenge',
                style: AppTextStyles.headline6,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Keep your daily goal streak alive!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStreakDay('Mon', true),
              _buildStreakDay('Tue', true),
              _buildStreakDay('Wed', true),
              _buildStreakDay('Thu', false),
              _buildStreakDay('Fri', false),
              _buildStreakDay('Sat', false),
              _buildStreakDay('Sun', false),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              '3 Day Streak! 🔥',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakDay(String day, bool completed) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: completed ? AppColors.accent : AppColors.textLight.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            completed ? Icons.check : Icons.close,
            color: completed ? Colors.white : AppColors.textLight,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: AppTextStyles.bodySmall.copyWith(
            color: completed ? AppColors.accent : AppColors.textLight,
          ),
        ),
      ],
    );
  }
}
