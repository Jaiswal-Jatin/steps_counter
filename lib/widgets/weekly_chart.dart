import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyChart extends StatelessWidget {
  final List<int> weeklySteps;
  final int dailyGoal;

  const WeeklyChart({
    super.key,
    required this.weeklySteps,
    required this.dailyGoal,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (dailyGoal * 1.2).toDouble(),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Theme.of(context).cardColor,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${weeklySteps[group.x]}\nsteps',
                  TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        days[value.toInt()],
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(weeklySteps.length, (index) {
            final steps = weeklySteps[index];
            final isGoalAchieved = steps >= dailyGoal;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: steps.toDouble(),
                  color: isGoalAchieved
                      ? const Color(0xFFFF6B35)
                      : Colors.grey.withOpacity(0.3),
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
              showingTooltipIndicators: [],
            );
          }),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            horizontalInterval: dailyGoal.toDouble(),
            getDrawingHorizontalLine: (value) {
              if (value == dailyGoal.toDouble()) {
                return FlLine(
                  color: const Color(0xFFFF6B35).withOpacity(0.5),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                );
              }
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 0.5,
              );
            },
          ),
        ),
      ),
    );
  }
}
