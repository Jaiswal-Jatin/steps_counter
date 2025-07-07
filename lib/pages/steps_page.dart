import 'package:flutter/material.dart';
import '../services/step_service.dart';
import '../services/health_service.dart';
import '../widgets/step_widgets.dart';

class StepsPage extends StatefulWidget {
  const StepsPage({super.key});

  @override
  State<StepsPage> createState() => _StepsPageState();
}

class _StepsPageState extends State<StepsPage> with TickerProviderStateMixin {
  final _stepService = StepCounterService();
  final _healthService = HealthService();

  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticInOut),
    );

    _pulseController.repeat(reverse: true);
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _showSleepDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double tempSleep = _healthService.sleepHours;
        return AlertDialog(
          title: const Text('Sleep Hours'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How many hours did you sleep last night?'),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      Text(
                        '${tempSleep.toStringAsFixed(1)} hours',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Slider(
                        value: tempSleep,
                        min: 0,
                        max: 12,
                        divisions: 24,
                        onChanged: (value) {
                          setState(() {
                            tempSleep = value;
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                _healthService.updateSleep(tempSleep);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: colorScheme.surface,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'FitStep Pro',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          actions: [
            IconButton(
              onPressed: () {
                _stepService.resetSteps();
                _progressController.reset();
                _progressController.forward();
              },
              icon: Icon(Icons.refresh, color: colorScheme.primary),
              tooltip: 'Reset Today',
            ),
          ],
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Motivational Message
              StreamBuilder<int>(
                stream: _stepService.stepStream,
                builder: (context, snapshot) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      _stepService.getMotivationalMessage(),
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),

              // Main Steps Counter with Animation
              StreamBuilder<int>(
                stream: _stepService.stepStream,
                builder: (context, stepSnapshot) {
                  return StreamBuilder<String>(
                    stream: _stepService.statusStream,
                    builder: (context, statusSnapshot) {
                      final dailySteps = stepSnapshot.data ?? 0;
                      final status = statusSnapshot.data ?? 'unknown';

                      return AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: status == 'walking'
                                ? _pulseAnimation.value
                                : 1.0,
                            child: Container(
                              width: double.infinity,
                              height: 280,
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.primary,
                                    colorScheme.secondary,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Steps Today',
                                    style: TextStyle(
                                      color: colorScheme.onPrimary.withOpacity(
                                        0.9,
                                      ),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Circular Progress Indicator
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 140,
                                        height: 140,
                                        child: AnimatedBuilder(
                                          animation: _progressAnimation,
                                          builder: (context, child) {
                                            return CircularProgressIndicator(
                                              value:
                                                  (dailySteps / 10000) *
                                                  _progressAnimation.value,
                                              strokeWidth: 8,
                                              backgroundColor: colorScheme
                                                  .onPrimary
                                                  .withOpacity(0.2),
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    colorScheme.onPrimary,
                                                  ),
                                            );
                                          },
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            '$dailySteps',
                                            style: TextStyle(
                                              color: colorScheme.onPrimary,
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'of 10,000',
                                            style: TextStyle(
                                              color: colorScheme.onPrimary
                                                  .withOpacity(0.8),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Status Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        status == 'walking'
                                            ? Icons.directions_walk
                                            : status == 'stopped'
                                            ? Icons.pause_circle_filled
                                            : Icons.help_outline,
                                        color: colorScheme.onPrimary
                                            .withOpacity(0.9),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        status == 'walking'
                                            ? 'Walking Detected'
                                            : status == 'stopped'
                                            ? 'Standing Still'
                                            : 'Initializing...',
                                        style: TextStyle(
                                          color: colorScheme.onPrimary
                                              .withOpacity(0.9),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              // Stats Row
              StreamBuilder<int>(
                stream: _stepService.stepStream,
                builder: (context, snapshot) {
                  return Row(
                    children: [
                      Expanded(
                        child: ModernStatCard(
                          icon: Icons.directions_walk,
                          title: 'Distance',
                          value:
                              '${_stepService.getDistance().toStringAsFixed(2)} km',
                          color: colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ModernStatCard(
                          icon: Icons.local_fire_department,
                          title: 'Calories',
                          value: '${_stepService.getCalories()} cal',
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Health Tracking Cards
              Row(
                children: [
                  Expanded(
                    child: StreamBuilder<int>(
                      stream: _healthService.waterStream,
                      builder: (context, snapshot) {
                        final water = snapshot.data ?? 0;
                        return HealthCard(
                          icon: Icons.water_drop,
                          title: 'Water',
                          value: '$water glasses',
                          onTap: _healthService.addWater,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StreamBuilder<double>(
                      stream: _healthService.sleepStream,
                      builder: (context, snapshot) {
                        final sleep = snapshot.data ?? 0.0;
                        return HealthCard(
                          icon: Icons.bedtime,
                          title: 'Sleep',
                          value: '${sleep.toStringAsFixed(1)}h',
                          onTap: _showSleepDialog,
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Permission Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _stepService.hasPermission
                      ? colorScheme.primaryContainer.withOpacity(0.3)
                      : colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _stepService.hasPermission
                        ? colorScheme.primary.withOpacity(0.3)
                        : colorScheme.error.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _stepService.hasPermission
                          ? Icons.check_circle
                          : Icons.error,
                      color: _stepService.hasPermission
                          ? colorScheme.primary
                          : colorScheme.error,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _stepService.hasPermission
                                ? 'Tracking Active'
                                : 'Enable Tracking',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _stepService.hasPermission
                                ? 'Step counting is working properly'
                                : 'Tap to grant permission for step counting',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_stepService.hasPermission)
                      FilledButton(
                        onPressed: () => _stepService.initialize(),
                        child: const Text('Enable'),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Test Button
              FilledButton.icon(
                onPressed: _stepService.addTestStep,
                icon: const Icon(Icons.add),
                label: const Text('Test +1 Step'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 100), // Bottom padding
            ]),
          ),
        ),
      ],
    );
  }
}
