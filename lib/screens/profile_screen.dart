import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/step_counter_provider.dart';
import '../providers/theme_provider.dart';
import '../core/constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final stepProvider = context.watch<StepCounterProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile section
            _buildProfileSection(),
            const SizedBox(height: 30),

            // Goals section
            _buildGoalsSection(stepProvider),
            const SizedBox(height: 30),

            // Preferences section
            _buildPreferencesSection(themeProvider),
            const SizedBox(height: 30),

            // Notifications section
            _buildNotificationsSection(),
            const SizedBox(height: 30),

            // About section
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
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
          // Profile picture
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(Icons.person, size: 40, color: AppColors.primaryOrange),
          ),
          const SizedBox(height: 16),

          // Name and edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'User Name',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // Edit profile
                },
                child: Icon(
                  Icons.edit,
                  size: 16,
                  color: AppColors.primaryOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            'Keep walking towards your goals!',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsSection(StepCounterProvider stepProvider) {
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
            'Daily Goals',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          _buildGoalItem(
            icon: Icons.directions_walk,
            title: 'Steps Goal',
            value: stepProvider.dailyGoal.toString(),
            unit: 'steps',
            onTap: () => _showGoalDialog(stepProvider),
          ),
          _buildGoalItem(
            icon: Icons.local_fire_department,
            title: 'Calories Goal',
            value: '300',
            unit: 'kcal',
            onTap: () {
              // Edit calories goal
            },
          ),
          _buildGoalItem(
            icon: Icons.access_time,
            title: 'Active Time Goal',
            value: '30',
            unit: 'minutes',
            onTap: () {
              // Edit active time goal
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: AppColors.primaryOrange, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 2),
                  Text(
                    '$value $unit',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(ThemeProvider themeProvider) {
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
            'Preferences',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          _buildSwitchItem(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
          _buildSwitchItem(
            icon: Icons.vibration,
            title: 'Vibration',
            value: true,
            onChanged: (value) {
              // Handle vibration setting
            },
          ),
          _buildSwitchItem(
            icon: Icons.battery_saver,
            title: 'Battery Saver',
            value: false,
            onChanged: (value) {
              // Handle battery saver setting
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: AppColors.primaryOrange, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
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
            'Notifications',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          _buildSwitchItem(
            icon: Icons.notifications,
            title: 'Goal Achievements',
            value: true,
            onChanged: (value) {
              // Handle goal achievement notifications
            },
          ),
          _buildSwitchItem(
            icon: Icons.water_drop,
            title: 'Water Reminders',
            value: true,
            onChanged: (value) {
              // Handle water reminder notifications
            },
          ),
          _buildSwitchItem(
            icon: Icons.trending_up,
            title: 'Progress Updates',
            value: false,
            onChanged: (value) {
              // Handle progress update notifications
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
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
            'About',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              // Open help
            },
          ),
          _buildMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              // Open privacy policy
            },
          ),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'About App',
            onTap: () {
              // Show about dialog
            },
          ),
          _buildMenuItem(
            icon: Icons.star_outline,
            title: 'Rate App',
            onTap: () {
              // Open app store rating
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: AppColors.primaryOrange, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
            ),
            Icon(Icons.keyboard_arrow_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showGoalDialog(StepCounterProvider stepProvider) {
    final controller = TextEditingController(
      text: stepProvider.dailyGoal.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Daily Step Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Steps',
            hintText: 'Enter your daily step goal',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final goal = int.tryParse(controller.text);
              if (goal != null && goal > 0) {
                stepProvider.setDailyGoal(goal);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
