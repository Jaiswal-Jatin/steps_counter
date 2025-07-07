import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/step_counter_provider.dart';
import '../providers/theme_provider.dart';
import '../core/constants/app_colors.dart';
import '../widgets/step_counter_widget.dart';
import '../widgets/stats_card.dart';
import '../widgets/progress_chart.dart';
import '../widgets/goal_card.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final stepProvider = context.watch<StepCounterProvider>();

    final List<Widget> pages = [
      _buildHomeScreen(stepProvider),
      const AnalyticsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primaryOrange,
            unselectedItemColor: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.6),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_walk_outlined),
                activeIcon: Icon(Icons.directions_walk),
                label: 'Steps',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: 'Tracker',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeScreen(StepCounterProvider stepProvider) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: true,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Step',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.displaySmall?.color,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: AppColors.primaryOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '0',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                context.watch<ThemeProvider>().isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () {
                context.read<ThemeProvider>().toggleTheme();
              },
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Time period selector
                _buildPeriodSelector(),
                const SizedBox(height: 20),

                // Main step counter
                StepCounterWidget(
                  currentSteps: stepProvider.currentSteps,
                  dailyGoal: stepProvider.dailyGoal,
                  progress: stepProvider.goalProgress,
                  onGoalTap: () => _showGoalDialog(stepProvider),
                ),
                const SizedBox(height: 20),

                // Stats cards
                Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        icon: Icons.access_time,
                        label: 'hours',
                        value: _formatDuration(stepProvider.activeTime),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        icon: Icons.local_fire_department,
                        label: 'kcal',
                        value: stepProvider.caloriesBurned.toStringAsFixed(1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        icon: Icons.location_on,
                        label: 'km',
                        value: stepProvider.distanceWalked.toStringAsFixed(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Goal challenge card
                GoalCard(
                  title: 'London to Paris',
                  subtitle: '54 km left',
                  progress: 0.75,
                  totalDistance: '420km',
                ),
                const SizedBox(height: 20),

                // Progress chart
                ProgressChart(
                  weeklyData: stepProvider.weeklyData,
                  currentSteps: stepProvider.currentSteps,
                  goal: stepProvider.dailyGoal,
                ),
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        ),
      ],
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
        children: [
          _buildPeriodButton('Day', isSelected: true),
          _buildPeriodButton('Week', isSelected: false),
          _buildPeriodButton('Month', isSelected: false),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String text, {required bool isSelected}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
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

  void _showGoalDialog(StepCounterProvider stepProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Daily Goal'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Steps',
            hintText: 'Enter your daily step goal',
          ),
          onSubmitted: (value) {
            final goal = int.tryParse(value);
            if (goal != null && goal > 0) {
              stepProvider.setDailyGoal(goal);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
