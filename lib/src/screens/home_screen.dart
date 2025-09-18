import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:steps_counter_app/src/providers/app_state.dart';
import 'package:steps_counter_app/src/theme.dart';
import 'package:steps_counter_app/src/widgets/progress_ring.dart';
import 'package:steps_counter_app/src/widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final goalReached = state.stepsToday >= state.stepGoal;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        children: [
          // Greeting banner
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: [StepGoTheme.primary, Colors.purpleAccent.shade100]),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Good ${_timeOfDayGreeting()},', style: const TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(goalReached ? "Goal achieved! You're amazing!" : 'Keep moving! You got this.',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ]),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.directions_walk, color: Colors.white, size: 40),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Today's Steps section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  children: [
                    Text("Today's Steps", style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: goalReached ? StepGoTheme.accent.withOpacity(.1) : Colors.orange.withOpacity(.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(goalReached ? 'Goal Achieved!' : 'Keep Going',
                          style: TextStyle(color: goalReached ? StepGoTheme.accent : StepGoTheme.primary, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(child: ProgressRing(steps: state.stepsToday, goal: state.stepGoal)),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Quick stats
          Row(children: [
            Expanded(
              child: StatCard(
                icon: Icons.straighten,
                title: 'Distance',
                value: '${state.distanceKm.toStringAsFixed(2)} km',
                color: Colors.indigo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.local_fire_department,
                title: 'Calories',
                value: '${state.calories}',
                color: StepGoTheme.primary,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: StatCard(
                icon: Icons.timer_outlined,
                title: 'Active Time',
                value: '${state.activeMinutes} min',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.emoji_events_outlined,
                title: 'Goal',
                value: '${state.stepGoal}',
                color: Colors.amber,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  String _timeOfDayGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
    }
}
