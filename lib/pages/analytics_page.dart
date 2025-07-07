import 'package:flutter/material.dart';
import '../services/step_service.dart';
import '../services/health_service.dart';
import '../widgets/step_widgets.dart';

class AnalyticsPage extends StatelessWidget {
  final _stepService = StepCounterService();
  final _healthService = HealthService();

  AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 100,
          floating: false,
          pinned: true,
          backgroundColor: colorScheme.surface,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Analytics',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Weekly Progress Card
              StreamBuilder<int>(
                stream: _stepService.stepStream,
                builder: (context, snapshot) {
                  final dailySteps = snapshot.data ?? 0;
                  final weeklyGoal = 70000; // 10k * 7 days

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(
                        0.3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Progress',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value:
                              (dailySteps * 7) /
                              weeklyGoal, // Simplified weekly calc
                          backgroundColor: colorScheme.outline.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${dailySteps * 7} / $weeklyGoal steps this week',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Achievements Section
              Text(
                'Today\'s Achievements',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Achievement Cards
              StreamBuilder<int>(
                stream: _stepService.stepStream,
                builder: (context, stepSnapshot) {
                  return StreamBuilder<int>(
                    stream: _healthService.waterStream,
                    builder: (context, waterSnapshot) {
                      final dailySteps = stepSnapshot.data ?? 0;
                      final waterIntake = waterSnapshot.data ?? 0;

                      return Column(
                        children: [
                          if (dailySteps >= 5000)
                            const AchievementCard(
                              title: '🚶‍♂️ First 5K',
                              subtitle: 'You walked 5,000 steps today!',
                            ),
                          if (dailySteps >= 10000)
                            const AchievementCard(
                              title: '🎯 Daily Goal',
                              subtitle: 'Completed 10,000 steps goal!',
                            ),
                          if (waterIntake >= 8)
                            const AchievementCard(
                              title: '💧 Hydration Hero',
                              subtitle: 'Drank 8 glasses of water!',
                            ),
                          if (dailySteps < 5000 && waterIntake < 8)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.emoji_events_outlined,
                                    color: colorScheme.primary,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Start Moving!',
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Complete activities to unlock achievements',
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withOpacity(
                                        0.7,
                                      ),
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }
}
