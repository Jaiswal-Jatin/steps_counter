import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/step_data.dart';

class ProgressChart extends StatelessWidget {
  final List<StepData> weeklyData;
  final int currentSteps;
  final int goal;

  const ProgressChart({
    super.key,
    required this.weeklyData,
    required this.currentSteps,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly data bars
          Expanded(child: _buildWeeklyChart()),
          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                color: AppColors.primaryOrange,
                label: 'Achieved',
              ),
              const SizedBox(width: 20),
              _buildLegendItem(
                color: Colors.grey.withOpacity(0.3),
                label: 'Not achieved',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final today = DateTime.now();
    final currentWeekday = today.weekday % 7; // 0 = Sunday, 6 = Saturday

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final isToday = index == currentWeekday;
        final isCurrentDay = index == currentWeekday;
        final stepData = _getStepDataForDay(index);
        final steps = stepData?.steps ?? (isCurrentDay ? currentSteps : 0);
        final isGoalAchieved = steps >= goal;

        // Calculate height based on steps (max height 120)
        double height = 20;
        if (steps > 0) {
          height = ((steps / goal) * 100).clamp(20, 120);
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Step count tooltip for current day
            if (isToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  steps.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (isToday) const SizedBox(height: 8),

            // Bar
            Container(
              width: 20,
              height: height,
              decoration: BoxDecoration(
                color: isGoalAchieved
                    ? AppColors.primaryOrange
                    : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 8),

            // Day label
            Text(
              days[index],
              style: TextStyle(
                fontSize: 12,
                color: isToday
                    ? AppColors.primaryOrange
                    : Colors.grey.withOpacity(0.6),
                fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.withOpacity(0.7)),
        ),
      ],
    );
  }

  StepData? _getStepDataForDay(int dayIndex) {
    final today = DateTime.now();
    final targetDate = today.subtract(
      Duration(days: today.weekday % 7 - dayIndex),
    );

    for (final data in weeklyData) {
      if (data.date.year == targetDate.year &&
          data.date.month == targetDate.month &&
          data.date.day == targetDate.day) {
        return data;
      }
    }
    return null;
  }
}
