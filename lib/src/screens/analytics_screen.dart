import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:steps_counter_app/src/providers/app_state.dart';
import 'package:steps_counter_app/src/theme.dart';
import 'package:steps_counter_app/src/widgets/progress_ring.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _seg = 1; // 0 Day, 1 Week, 2 Month. Default to Week.
  DateTime _currentDate = DateTime.now();

  // Helper to get a date with time set to 00:00:00
  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text('Analytics', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _buildHeader(),
          const SizedBox(height: 12),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Day')),
              ButtonSegment(value: 1, label: Text('Week')),
              ButtonSegment(value: 2, label: Text('Month')),
            ],
            selected: {_seg},
            onSelectionChanged: (s) => setState(() {
              _seg = s.first;
              _currentDate = DateTime.now(); // Reset to today on segment change
            }),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildSelectedView(state),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedView(AppState state) {
    switch (_seg) {
      case 0:
        return _buildDay(context, state);
      case 1:
        return _buildWeek(context, state);
      case 2:
        return _buildMonth(context, state);
      default:
        return Container();
    }
  }

  // --- Navigation and Header ---

  void _previous() {
    setState(() {
      if (_seg == 0) {
        _currentDate = _currentDate.subtract(const Duration(days: 1));
      } else if (_seg == 1) {
        _currentDate = _currentDate.subtract(const Duration(days: 7));
      } else {
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
      }
    });
  }

  void _next() {
    if (_isNextDisabled()) return;
    setState(() {
      if (_seg == 0) {
        _currentDate = _currentDate.add(const Duration(days: 1));
      } else if (_seg == 1) {
        _currentDate = _currentDate.add(const Duration(days: 7));
      } else {
        _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
      }
    });
  }

  bool _isNextDisabled() {
    final now = _dateOnly(DateTime.now());
    final current = _dateOnly(_currentDate);
    if (_seg == 0) return current.isAtSameMomentAs(now);
    if (_seg == 1) {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final currentStartOfWeek = _getWeekRange(current)['start']!;
      return currentStartOfWeek.isAtSameMomentAs(startOfWeek) || currentStartOfWeek.isAfter(startOfWeek);
    }
    if (_seg == 2) {
      return current.year == now.year && current.month == now.month;
    }
    return false;
  }

  Widget _buildHeader() {
    String title;
    if (_seg == 0) {
      title = DateFormat('MMM d, yyyy').format(_currentDate);
    } else if (_seg == 1) {
      final range = _getWeekRange(_currentDate);
      final start = range['start']!;
      final end = range['end']!;
      if (start.month == end.month) {
        title = '${DateFormat('MMM d').format(start)} - ${DateFormat('d, yyyy').format(end)}';
      } else {
        title = '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
      }
    } else {
      title = DateFormat('MMMM yyyy').format(_currentDate);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.chevron_left), onPressed: _previous),
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _isNextDisabled() ? null : _next,
        ),
      ],
    );
  }

  // --- Card and Metric Widgets ---

  Widget _card(Widget child) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        ),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      );

  Widget _metric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }

  // --- Day View ---

  Widget _buildDay(BuildContext context, AppState s) {
    final date = _dateOnly(_currentDate);
    final isToday = date == _dateOnly(DateTime.now());
    final dayKey = DateFormat('yyyy-MM-dd').format(date);
    final steps = isToday ? s.stepsToday : (s.stepHistory[dayKey] ?? 0);

    final goal = s.stepGoal;
    final distance = steps * 0.00078;
    final calories = (steps * 0.04).round();
    final activeMinutes = (steps / 110).round();

    return Column(
      key: ValueKey(dayKey), // To animate switcher
      children: [
        _card(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ProgressRing(
              steps: steps,
              goal: goal,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: NumberFormat.decimalPattern().format(steps),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: StepGoTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                  children: [
                    TextSpan(
                        text: '\n/ ${NumberFormat.decimalPattern().format(goal)} Goal',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _metric('Distance', '${distance.toStringAsFixed(2)} km', Icons.straighten, Colors.purple),
            _metric('Calories', '$calories kcal', Icons.local_fire_department, Colors.red),
            _metric('Active Time', '$activeMinutes min', Icons.timer, Colors.green),
            _metric('Goal', NumberFormat.decimalPattern().format(goal), Icons.flag, Colors.blue),
          ],
        ),
      ],
    );
  }

  // --- Week View ---

  Map<String, DateTime> _getWeekRange(DateTime date) {
    final day = _dateOnly(date);
    final startOfWeek = day.subtract(Duration(days: day.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return {'start': startOfWeek, 'end': endOfWeek};
  }

  Widget _buildWeek(BuildContext context, AppState s) {
    final range = _getWeekRange(_currentDate);
    final start = range['start']!;

    final days = List.generate(7, (i) => start.add(Duration(days: i)));
    final values = days.map((d) {
      final isToday = _dateOnly(d) == _dateOnly(DateTime.now());
      final dayKey = DateFormat('yyyy-MM-dd').format(d);
      return isToday ? s.stepsToday : (s.stepHistory[dayKey] ?? 0);
    }).toList();

    final total = values.fold<int>(0, (p, e) => p + e);
    final avg = (total / 7).round();

    return Column(
      key: ValueKey('week-${range['start']}'),
      children: [
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text('Weekly Summary', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text('Avg: ${NumberFormat.decimalPattern().format(avg)}', style: Theme.of(context).textTheme.bodyMedium),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: BarChart(_buildBarChartData(values, ['M', 'T', 'W', 'T', 'F', 'S', 'S'], s.stepGoal.toDouble(), 'Day of the Week')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildTotalStatsCard(total),
      ],
    );
  }

  // --- Month View ---

  Widget _buildMonth(BuildContext context, AppState s) {
    final year = _currentDate.year;
    final month = _currentDate.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final days = List.generate(daysInMonth, (i) => DateTime(year, month, i + 1));
    final values = days.map((d) {
      final isToday = _dateOnly(d) == _dateOnly(DateTime.now());
      final dayKey = DateFormat('yyyy-MM-dd').format(d);
      return isToday ? s.stepsToday : (s.stepHistory[dayKey] ?? 0);
    }).toList();

    final labels = List.generate(daysInMonth, (i) => (i + 1) % 5 == 0 ? '${i + 1}' : '');
    final total = values.fold<int>(0, (p, e) => p + e);
    final avg = (total / daysInMonth).round();

    return Column(
      key: ValueKey('month-$year-$month'),
      children: [
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text('Monthly Summary', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text('Avg: ${NumberFormat.decimalPattern().format(avg)}', style: Theme.of(context).textTheme.bodyMedium),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: BarChart(_buildBarChartData(values, labels, s.stepGoal.toDouble(), 'Day of the Month')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildTotalStatsCard(total),
      ],
    );
  }

  Widget _totalMetric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildTotalStatsCard(int totalSteps) {
    final totalDistance = totalSteps * 0.00078;
    final totalCalories = (totalSteps * 0.04).round();
    final totalActiveMinutes = (totalSteps / 110).round();

    return _card(
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: [
          _totalMetric('Total Steps', NumberFormat.decimalPattern().format(totalSteps), Icons.directions_walk, Colors.orange),
          _totalMetric('Total Distance', '${totalDistance.toStringAsFixed(2)} km', Icons.straighten, Colors.purple),
          _totalMetric('Total Calories', '$totalCalories kcal', Icons.local_fire_department, Colors.red),
          _totalMetric('Total Active Time', '$totalActiveMinutes min', Icons.timer, Colors.green),
        ],
      ),
    );
  }

  // --- fl_chart BarChartData Builder ---

  BarChartData _buildBarChartData(List<int> values, List<String> labels, double goal, String bottomTitle) {
    final barGroups = List.generate(values.length, (i) {
      final steps = values[i].toDouble();
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: steps,
            color: steps >= goal ? StepGoTheme.accent : StepGoTheme.primary,
            width: (MediaQuery.of(context).size.width - 80) / (values.length * 1.5),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      barGroups: barGroups,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              NumberFormat.decimalPattern().format(rod.toY.round()),
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          axisNameWidget: Text(bottomTitle, style: Theme.of(context).textTheme.bodySmall),
          axisNameSize: 22,
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < labels.length) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(labels[index], style: const TextStyle(fontSize: 10)),
                );
              }
              return Container();
            },
            reservedSize: 28,
          ),
        ),
        leftTitles: AxisTitles(
          // axisNameWidget: Text('Steps', style: Theme.of(context).textTheme.bodySmall),
          // axisNameSize: 28,
          sideTitles: SideTitles(
            // showTitles: true,
            // reservedSize: 40,
            getTitlesWidget: (value, meta) {
              if (value == 0) return const SizedBox.shrink();
              if (value % 5000 == 0) {
                return Text('${(value ~/ 1000)}k', style: const TextStyle(fontSize: 10));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
      ),
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: goal,
            color: StepGoTheme.accent.withOpacity(0.5),
            strokeWidth: 2,
            dashArray: [5, 5],
            label: HorizontalLineLabel(
              show: true,
              labelResolver: (_) => 'Goal',
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(right: 4, bottom: 2),
              style: TextStyle(color: StepGoTheme.accent, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
