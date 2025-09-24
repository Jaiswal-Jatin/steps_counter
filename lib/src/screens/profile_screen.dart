import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:steps_counter_app/src/providers/app_state.dart';
import 'package:steps_counter_app/src/screens/edit_profile_screen.dart';
import 'package:steps_counter_app/src/services/notification_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Get the singleton instance of the NotificationService
  static final _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = FirebaseAuth.instance.currentUser;

    // Calculate age
    String ageString = '';
    if (state.dob != null) {
      final today = DateTime.now();
      int age = today.year - state.dob!.year;
      if (today.month < state.dob!.month || (today.month == state.dob!.month && today.day < state.dob!.day)) {
        age--;
      }
      ageString = '$age years old';
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: state.photoURL != null ? NetworkImage(state.photoURL!) : null,
                    child: state.photoURL == null ? const Icon(Icons.person, size: 40) : null,
                  ),
                  const SizedBox(height: 12),
                  Text(state.userName ?? 'Guest User', style: Theme.of(context).textTheme.titleLarge),
                  if (ageString.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(ageString, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                  ],
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Profile'),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Daily Goals
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Daily Goals', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Row(children: [
                  const Icon(Icons.directions_walk, color: Colors.orange),
                  const SizedBox(width: 12),
                  const Text('Steps Goal'),
                  const Spacer(),
                  Text('${state.stepGoal}'),
                ]),
                Slider(
                  value: state.stepGoal.toDouble(),
                  min: 1000, max: 20000, divisions: 19,
                  label: '${state.stepGoal}',
                  onChanged: (v) => state.setStepGoal(v.round()),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Preferences
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _toggle('Dark Mode', state.darkMode, state.setDarkMode),
            ),
          ),
          const SizedBox(height: 16),

          // Notifications
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                _toggle('Milestone Notifications', state.milestoneNotifications, state.setMilestoneNotifications),
                const Divider(),
                // Water Reminders Toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Water Reminders'),
                  value: state.waterReminders,
                  onChanged: (bool value) async {
                    // 1. Persist the toggle state via the provider
                    await state.setWaterReminders(value);

                    // 2. Schedule or cancel notifications
                    if (value) {
                      // Use context.read in a callback
                      final interval = context.read<AppState>().waterInterval;
                      await _notificationService.scheduleReminders(interval.inHours);
                    } else {
                      await _notificationService.cancelReminders();
                    }
                  },
                ),
                Row(children: [
                  const Text('Remind me every'),
                  const Spacer(),
                  DropdownButton<int>(
                    value: state.waterInterval.inMinutes,
                    items: const [
                      // The interval is now in hours as per the requirement
                      DropdownMenuItem(value: 60, child: Text('1 hr')),
                      DropdownMenuItem(value: 120, child: Text('2 hr')),
                      DropdownMenuItem(value: 180, child: Text('3 hr')),
                    ],
                    onChanged: (v) async {
                      if (v != null) {
                        final newInterval = Duration(minutes: v);
                        // 1. Persist the new interval
                        await state.setWaterInterval(newInterval);

                        // 2. If reminders are on, reschedule with the new interval
                        if (context.read<AppState>().waterReminders) {
                          await _notificationService.scheduleReminders(newInterval.inHours);
                        }
                      }
                    },
                  ),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
    );
  }

  Widget _toggle(String label, bool value, Future<void> Function(bool) set) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: (v) => set(v),
    );
  }
}
