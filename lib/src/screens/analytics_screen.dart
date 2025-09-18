import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:steps_counter_app/src/providers/app_state.dart';
import 'package:steps_counter_app/src/widgets/simple_bars.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _seg = 0; // 0 Day, 1 Week, 2 Month

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text('Analytics', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Day')),
              ButtonSegment(value: 1, label: Text('Week')),
              ButtonSegment(value: 2, label: Text('Month')),
            ],
            selected: {_seg},
            onSelectionChanged: (s) => setState(() => _seg = s.first),
          ),
          const SizedBox(height: 16),
          if (_seg == 0) _buildDay(context, state),
          if (_seg == 1) _buildWeek(context, state),
          if (_seg == 2) _buildMonth(context, state),
        ],
      ),
    );
  }

  Widget _card(Widget child) => Card(child: Padding(padding: const EdgeInsets.all(16), child: child));

  Widget _buildDay(BuildContext context, AppState s) {
    final day = DateFormat('MMM d, yyyy').format(DateTime.now());
    return Column(
      children: [
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(day, style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Text('Total: ${s.stepsToday}', style: Theme.of(context).textTheme.titleMedium),
          ]),
          const SizedBox(height: 16),
          SimpleBars(
            values: List.generate(24, (i) => i == DateTime.now().hour ? (s.stepsToday ~/ 24) : 0),
            labels: List.generate(24, (i) => i % 3 == 0 ? '$i' : ''),
            color: Colors.orange,
            maxHint: 3000,
          ),
        ])),
        const SizedBox(height: 16),
        _card(Wrap(spacing: 12, runSpacing: 12, children: [
          _metric('Average', '${(s.stepsToday).toString()}'),
          _metric('Distance', '${s.distanceKm.toStringAsFixed(2)} km'),
          _metric('Calories', '${s.calories} kcal'),
          _metric('Active', '${s.activeMinutes} min'),
        ])),
      ],
    );
  }

  Widget _buildWeek(BuildContext context, AppState s) {
    final days = s.historyDays(backDays: 7);
    final values = days.values.toList();
    final labels = days.keys.map((d) => DateFormat('E').format(d).substring(0,1)).toList();
    final total = values.fold<int>(0, (p,e)=>p+e);
    final avg = (total / (values.isEmpty ? 1 : values.length)).round();

    return Column(
      children: [
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('${DateFormat('MMM d').format(days.keys.first)} - ${DateFormat('MMM d').format(days.keys.last)}',
              style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Text('Avg $avg • Total $total', style: Theme.of(context).textTheme.titleMedium),
          ]),
          const SizedBox(height: 16),
          SimpleBars(values: values, labels: labels, color: Colors.orange, maxHint: 12000),
          const SizedBox(height: 8),
          Row(children: const [
            Icon(Icons.check_circle, size: 14, color: Colors.orange),
            SizedBox(width: 6),
            Text('Achieved'),
            SizedBox(width: 16),
            Icon(Icons.circle_outlined, size: 14, color: Colors.grey),
            SizedBox(width: 6),
            Text('Not achieved'),
          ]),
        ])),
        const SizedBox(height: 16),
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('vs. Previous 7 days'),
          const SizedBox(height: 12),
          Text('Trend: ${avg >= 6000 ? 'Active than usual' : 'Less active than usual'}'),
        ])),
      ],
    );
  }

  Widget _buildMonth(BuildContext context, AppState s) {
    final days = s.historyDays(backDays: 30);
    final values = days.values.toList();
    final labels = List.generate(values.length, (i) => (i % 3 == 0) ? DateFormat('d').format(days.keys.elementAt(i)) : '');
    final total = values.fold<int>(0, (p,e)=>p+e);
    final avg = (total / (values.isEmpty ? 1 : values.length)).round();

    return Column(
      children: [
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('${DateFormat('MMM d').format(days.keys.first)} - ${DateFormat('MMM d').format(days.keys.last)}',
              style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Text('Avg $avg • Total $total', style: Theme.of(context).textTheme.titleMedium),
          ]),
          const SizedBox(height: 16),
          SimpleBars(values: values, labels: labels, color: Colors.orange, maxHint: 14000),
        ])),
        const SizedBox(height: 16),
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('vs. Previous 30 days'),
          const SizedBox(height: 12),
          Text('Trend: ${avg >= 7000 ? 'Active than usual' : 'Less active than usual'}'),
        ])),
      ],
    );
  }

  Widget _metric(String title, String value) => Container(
    width: 150,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.withOpacity(.2)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      const SizedBox(height: 4),
      Text(title, style: const TextStyle(color: Colors.grey)),
    ]),
  );
}
