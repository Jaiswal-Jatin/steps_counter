import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/step_counter_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/circular_progress_widget.dart';
import '../widgets/stats_card.dart';
import '../widgets/water_intake_widget.dart';
import '../widgets/nutrition_chart_widget.dart';
import 'goal_achievement_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppSpacing.lg),
              _buildStepsSection(context),
              const SizedBox(height: AppSpacing.lg),
              _buildQuickStats(context),
              const SizedBox(height: AppSpacing.lg),
              _buildWaterSection(context),
              const SizedBox(height: AppSpacing.lg),
              _buildNutritionSection(context),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<StepCounterProvider>(
      builder: (context, provider, child) {
        final profile = provider.userProfile;
        final greeting = _getGreeting();
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile?.name ?? 'Guest',
                    style: AppTextStyles.headline3,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Eat the right amount of food and stay hydrated through the day',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: AppShadows.card,
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.onPrimary,
                size: 24,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepsSection(BuildContext context) {
    return Consumer<StepCounterProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppBorderRadius.largeRadius,
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: AppBorderRadius.smallRadius,
                    ),
                    child: const Icon(
                      Icons.directions_walk,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Daily Steps',
                    style: AppTextStyles.headline6,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GoalAchievementScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: provider.stepsProgress >= 1.0 
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            provider.stepsProgress >= 1.0 
                                ? Icons.emoji_events 
                                : Icons.flag,
                            size: 16,
                            color: provider.stepsProgress >= 1.0 
                                ? AppColors.success 
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            provider.stepsProgress >= 1.0 ? 'Goal Achieved!' : 'View Goal',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: provider.stepsProgress >= 1.0 
                                  ? AppColors.success 
                                  : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 200,
                child: CircularProgressWidget(
                  progress: provider.stepsProgress,
                  value: provider.currentSteps,
                  goal: provider.dailyGoal,
                  unit: 'steps',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _buildStepsStat(
                      '${NumberFormat('#,###').format(provider.currentCalories)}',
                      'cal',
                      'Calories',
                      AppColors.accent,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.border,
                  ),
                  Expanded(
                    child: _buildStepsStat(
                      provider.currentDistance.toStringAsFixed(2),
                      'km',
                      'Distance',
                      AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepsStat(String value, String unit, String label, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: AppTextStyles.headline4.copyWith(color: color),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: AppTextStyles.bodySmall.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer<StepCounterProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            Expanded(
              child: StatsCard(
                icon: Icons.local_fire_department,
                iconColor: AppColors.accent,
                title: 'Calories',
                subtitle: 'Burned today',
                value: provider.currentCalories.toString(),
                unit: 'cal',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatsCard(
                icon: Icons.timer,
                iconColor: AppColors.warning,
                title: 'Active Time',
                subtitle: 'Minutes today',
                value: (provider.currentSteps / 100).round().toString(),
                unit: 'min',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWaterSection(BuildContext context) {
    return Consumer<StepCounterProvider>(
      builder: (context, provider, child) {
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: AppBorderRadius.smallRadius,
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: AppColors.info,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Water',
                    style: AppTextStyles.headline6,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              WaterIntakeWidget(
                progress: provider.waterProgress,
                currentIntake: provider.todayWaterIntake.fold(
                  0.0,
                  (sum, intake) => sum + intake.amount,
                ),
                goal: (provider.userProfile?.dailyWaterGoal ?? 2.5) * 1000,
                onAddWater: (amount) => provider.addWaterIntake(amount),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNutritionSection(BuildContext context) {
    return Consumer<StepCounterProvider>(
      builder: (context, provider, child) {
        final nutrition = provider.todayNutrition;
        
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: AppBorderRadius.smallRadius,
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Nutrition',
                    style: AppTextStyles.headline6,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (nutrition != null)
                NutritionChartWidget(nutrition: nutrition)
              else
                Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        color: AppColors.textLight,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No nutrition data today',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }
}
