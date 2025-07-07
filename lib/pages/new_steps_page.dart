import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/step_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/circular_progress_indicator.dart';
import '../widgets/metric_card.dart';
import '../widgets/journey_card.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/monthly_chart.dart';

class StepsPage extends StatefulWidget {
  const StepsPage({super.key});

  @override
  State<StepsPage> createState() => _StepsPageState();
}

class _StepsPageState extends State<StepsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTab = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<StepProvider, ThemeProvider>(
      builder: (context, stepProvider, themeProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // Header with app name and theme toggle
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Step',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.local_fire_department,
                              color: Color(0xFFFF6B35),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '0',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tab selector
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Day'),
                      Tab(text: 'Week'),
                      Tab(text: 'Month'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Content based on selected tab
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _selectedTab == 0
                        ? _buildDayView(stepProvider, themeProvider)
                        : _selectedTab == 1
                        ? _buildWeekView(stepProvider, themeProvider)
                        : _buildMonthView(stepProvider, themeProvider),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayView(StepProvider stepProvider, ThemeProvider themeProvider) {
    return Column(
      children: [
        // Weather info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Today',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.cloud, color: Color(0xFF87CEEB), size: 20),
              const SizedBox(width: 4),
              const Text(
                '25°C',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Circular progress indicator
        SizedBox(
          height: 250,
          child: CustomCircularProgressIndicator(
            progress: stepProvider.goalProgress,
            currentSteps: stepProvider.totalStepsToday,
            goalSteps: stepProvider.dailyGoal,
          ),
        ),

        const SizedBox(height: 30),

        // Metrics row
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: Icons.access_time,
                value:
                    '${stepProvider.activeMinutes.toStringAsFixed(0)}:${((stepProvider.activeMinutes % 1) * 60).toInt().toString().padLeft(2, '0')}',
                label: 'hours',
                color: const Color(0xFFFF6B35),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                icon: Icons.local_fire_department,
                value: stepProvider.calories.toStringAsFixed(1),
                label: 'kcal',
                color: const Color(0xFFFF6B35),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                icon: Icons.location_on,
                value: stepProvider.distance.toStringAsFixed(2),
                label: 'km',
                color: const Color(0xFFFF6B35),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Journey card
        JourneyCard(
          title: stepProvider.currentJourney,
          remainingDistance: stepProvider.journeyRemainingDistance,
          totalDistance: stepProvider.journeyTotalDistance,
          progress:
              stepProvider.journeyProgress / stepProvider.journeyTotalDistance,
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildWeekView(
    StepProvider stepProvider,
    ThemeProvider themeProvider,
  ) {
    return Column(
      children: [
        // Week date range
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back_ios, size: 18),
              ),
              const Text(
                'Jul 6 - Jul 12',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward_ios, size: 18),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Week stats
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    stepProvider.weeklyAverage.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Average',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    stepProvider.weeklyTotal.toString(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        // Weekly chart
        SizedBox(
          height: 200,
          child: WeeklyChart(
            weeklySteps: stepProvider.weeklySteps,
            dailyGoal: stepProvider.dailyGoal,
          ),
        ),

        const SizedBox(height: 30),

        // Achievement indicators
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B35),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Achieved'),
            const SizedBox(width: 20),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Not achieved'),
          ],
        ),

        const SizedBox(height: 30),

        // Comparison section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'vs. Previous 7 days',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
              const SizedBox(height: 15),
              const Row(
                children: [
                  Text(
                    'Steps',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Spacer(),
                  Text(
                    '-18,570',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Text(
                    'Trends',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Spacer(),
                  Text(
                    'Less active than usual',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Text(
                    'Most active time',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Spacer(),
                  Text(
                    '11:00 am - 12:00 pm',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMonthView(
    StepProvider stepProvider,
    ThemeProvider themeProvider,
  ) {
    return Column(
      children: [
        // Month date range
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back_ios, size: 18),
              ),
              const Text(
                'Jul 1 - Jul 31',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward_ios, size: 18),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Month stats
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text(
                    '2,744',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Average',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text(
                    '19,208',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        // Monthly chart
        SizedBox(
          height: 200,
          child: MonthlyChart(
            monthlySteps: stepProvider.getMonthlyData(),
            dailyGoal: stepProvider.dailyGoal,
          ),
        ),

        const SizedBox(height: 30),

        // Monthly comparison
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'vs. Previous 30 days',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
              const SizedBox(height: 15),
              const Row(
                children: [
                  Text(
                    'Steps',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Spacer(),
                  Text(
                    '+89,086',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Text(
                    'Trends',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Spacer(),
                  Text(
                    'Less active than usual',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Text(
                    'Most active time',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Spacer(),
                  Text(
                    '09:00 pm - 10:00 pm',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
