import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/step_counter_provider.dart';
import '../core/constants/app_colors.dart';
import '../models/step_data.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedPeriod = 0; // 0: Week, 1: Month, 2: Year
  final List<String> _periods = ['Week', 'Month', 'Year'];

  @override
  Widget build(BuildContext context) {
    final stepProvider = context.watch<StepCounterProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            _buildPeriodSelector(),
            const SizedBox(height: 20),

            // Stats summary
            _buildStatsSummary(stepProvider),
            const SizedBox(height: 20),

            // Chart
            _buildChart(stepProvider),
            const SizedBox(height: 20),

            // Trends
            _buildTrends(stepProvider),
            const SizedBox(height: 20),

            // Activity details
            _buildActivityDetails(stepProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: List.generate(_periods.length, (index) {
          final isSelected = _selectedPeriod == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryDark
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    _periods[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatsSummary(StepCounterProvider stepProvider) {
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jul 1 - Jul 31',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Icon(Icons.keyboard_arrow_left, color: Colors.grey),
                  const SizedBox(width: 8),
                  Icon(Icons.keyboard_arrow_right, color: Colors.grey),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('2,744', 'Average'),
              _buildStatItem('19,208', 'Total'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildChart(StepCounterProvider stepProvider) {
    return Container(
      height: 200,
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
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _getChartData(stepProvider.monthlyData),
              isCurved: true,
              color: AppColors.primaryOrange,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primaryOrange.withOpacity(0.1),
              ),
            ),
          ],
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 8000,
        ),
      ),
    );
  }

  List<FlSpot> _getChartData(List<StepData> data) {
    if (data.isEmpty) {
      return [
        FlSpot(0, 1000),
        FlSpot(1, 3000),
        FlSpot(2, 2000),
        FlSpot(3, 6000),
        FlSpot(4, 4000),
        FlSpot(5, 5000),
        FlSpot(6, 2144),
      ];
    }

    return data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.steps.toDouble());
    }).toList();
  }

  Widget _buildTrends(StepCounterProvider stepProvider) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'vs. Previous 30 days',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryOrange,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Text('Steps', style: Theme.of(context).textTheme.bodyLarge),
              const Spacer(),
              Text(
                '+89,086',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text('Trends', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 4),
          Text(
            'Less active than usual',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 12),

          Text(
            'Most active time',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 4),
          Text(
            '09:00 pm - 10:00 pm',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityDetails(StepCounterProvider stepProvider) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Details',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          _buildActivityItem(
            icon: Icons.directions_walk,
            title: 'Total Steps',
            value: stepProvider.currentSteps.toString(),
            color: AppColors.primaryOrange,
          ),
          _buildActivityItem(
            icon: Icons.local_fire_department,
            title: 'Calories Burned',
            value: '${stepProvider.caloriesBurned.toStringAsFixed(1)} kcal',
            color: Colors.red,
          ),
          _buildActivityItem(
            icon: Icons.access_time,
            title: 'Active Time',
            value: _formatDuration(stepProvider.activeTime),
            color: Colors.blue,
          ),
          _buildActivityItem(
            icon: Icons.location_on,
            title: 'Distance',
            value: '${stepProvider.distanceWalked.toStringAsFixed(2)} km',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}';
    }
    return '0:${minutes.toString().padLeft(2, '0')}';
  }
}
