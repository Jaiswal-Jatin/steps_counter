import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/step_counter_provider.dart';
import '../theme/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int selectedTimeFrame = 0; // 0: Week, 1: Month, 2: Year

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeFrameSelector(),
            const SizedBox(height: AppSpacing.lg),
            _buildStepsChart(),
            const SizedBox(height: AppSpacing.lg),
            _buildWeeklySummary(),
            const SizedBox(height: AppSpacing.lg),
            _buildPerformanceInsights(),
            const SizedBox(height: AppSpacing.lg),
            _buildCaloriesChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFrameSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.mediumRadius,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          _buildTimeFrameButton('Week', 0),
          _buildTimeFrameButton('Month', 1),
          _buildTimeFrameButton('Year', 2),
        ],
      ),
    );
  }

  Widget _buildTimeFrameButton(String title, int index) {
    final isSelected = selectedTimeFrame == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTimeFrame = index),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: AppBorderRadius.smallRadius,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? AppColors.onPrimary : AppColors.text,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepsChart() {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'You have walked',
                    style: AppTextStyles.headline6,
                  ),
                  Text(
                    '${NumberFormat('#,###').format(provider.currentSteps)} steps today',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 2000,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AppColors.border,
                          strokeWidth: 1,
                        );
                      },
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
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            if (value.toInt() >= 0 && value.toInt() < days.length) {
                              return Text(
                                days[value.toInt()],
                                style: AppTextStyles.bodySmall,
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 2000,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${(value / 1000).toStringAsFixed(0)}K',
                              style: AppTextStyles.bodySmall,
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: 12000,
                    lineBarsData: [
                      LineChartBarData(
                        spots: _generateChartData(provider.weeklyData),
                        isCurved: true,
                        gradient: AppColors.primaryGradient,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: AppColors.primary,
                              strokeWidth: 2,
                              strokeColor: AppColors.surface,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.2),
                              AppColors.primary.withOpacity(0.05),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildChartLegend('1,300 cal', '10,000 steps', AppColors.primary),
                  _buildChartLegend('Statistic', 'Daily', AppColors.textLight),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartLegend(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headline6.copyWith(color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
        ),
      ],
    );
  }

  Widget _buildWeeklySummary() {
    return Consumer<StepCounterProvider>(
      builder: (context, provider, child) {
        final weeklySteps = provider.weeklyData.fold(0, (sum, data) => sum + data.steps);
        final weeklyDistance = provider.weeklyData.fold(0.0, (sum, data) => sum + data.distance);
        final weeklyCalories = provider.weeklyData.fold(0, (sum, data) => sum + data.calories);
        
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
                'Insight',
                style: AppTextStyles.headline6,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: AppBorderRadius.smallRadius,
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: AppColors.success,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Best Performance',
                          style: AppTextStyles.headline6.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          'You had your best day on Monday with 12,450 steps',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: AppBorderRadius.smallRadius,
                    ),
                    child: const Icon(
                      Icons.trending_down,
                      color: AppColors.warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Worst Performance',
                          style: AppTextStyles.headline6.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                        Text(
                          'You had a low activity day on Sunday with 3,200 steps',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildWeeklyStats(weeklySteps, weeklyDistance, weeklyCalories),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyStats(int steps, double distance, int calories) {
    return Row(
      children: [
        Expanded(
          child: _buildWeeklyStat(
            'Total Steps',
            NumberFormat('#,###').format(steps),
            Icons.directions_walk,
            AppColors.primary,
          ),
        ),
        Container(width: 1, height: 50, color: AppColors.border),
        Expanded(
          child: _buildWeeklyStat(
            'Distance',
            '${distance.toStringAsFixed(1)} km',
            Icons.straighten,
            AppColors.secondary,
          ),
        ),
        Container(width: 1, height: 50, color: AppColors.border),
        Expanded(
          child: _buildWeeklyStat(
            'Calories',
            '$calories cal',
            Icons.local_fire_department,
            AppColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPerformanceInsights() {
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
            'Performance Insights',
            style: AppTextStyles.headline6,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInsightItem(
            'Goal Achievement',
            '72% of weekly goals met',
            '5 out of 7 days',
            AppColors.success,
            Icons.emoji_events,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInsightItem(
            'Most Active Time',
            'You are most active between 7-9 AM',
            '40% of daily steps',
            AppColors.info,
            Icons.schedule,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInsightItem(
            'Weekly Trend',
            'Your activity increased by 15%',
            'Compared to last week',
            AppColors.primary,
            Icons.trending_up,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String title, String description, String detail, Color color, IconData icon) {
    return Row(
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
                ),
              ),
              Text(description, style: AppTextStyles.bodySmall),
              Text(
                detail,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCaloriesChart() {
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
            'Calories Burned',
            style: AppTextStyles.headline6,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 600,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: AppTextStyles.bodySmall,
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _generateCaloriesBarData(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateChartData(List<dynamic> weeklyData) {
    return List.generate(7, (index) {
      if (index < weeklyData.length) {
        return FlSpot(index.toDouble(), weeklyData[index].steps.toDouble());
      }
      return FlSpot(index.toDouble(), 0);
    });
  }

  List<BarChartGroupData> _generateCaloriesBarData() {
    final caloriesData = [450, 380, 520, 340, 480, 290, 410];
    
    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: caloriesData[index].toDouble(),
            gradient: AppColors.accentGradient,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }
}
