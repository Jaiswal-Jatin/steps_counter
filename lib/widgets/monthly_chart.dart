import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyChart extends StatelessWidget {
  final List<int> monthlySteps;
  final int dailyGoal;

  const MonthlyChart({
    super.key,
    required this.monthlySteps,
    required this.dailyGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
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
                interval: 7,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() % 7 == 0 &&
                      value.toInt() < monthlySteps.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${value.toInt() + 1}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                monthlySteps.length,
                (index) =>
                    FlSpot(index.toDouble(), monthlySteps[index].toDouble()),
              ),
              isCurved: true,
              color: const Color(0xFFFF6B35),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFFFF6B35).withOpacity(0.1),
              ),
            ),
          ],
          minX: 0,
          maxX: (monthlySteps.length - 1).toDouble(),
          minY: 0,
          maxY: monthlySteps.reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => Theme.of(context).cardColor,
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  return LineTooltipItem(
                    'Day ${barSpot.x.toInt() + 1}\n${barSpot.y.toInt()} steps',
                    TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
