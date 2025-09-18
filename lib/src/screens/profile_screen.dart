import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:steps_counter_app/src/providers/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const CircleAvatar(radius: 22, child: Icon(Icons.person)),
                  const SizedBox(width: 12),
                  Consumer<AppState>(
                    builder: (context, state, _) {
                      final userName = state.userName ?? 'Guest User';
                      return Text(userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16));
                    },
                  ),
                  const Spacer(),
                ]),
                const SizedBox(height: 8),
                Text('Keep walking towards your goals!', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
              ]),
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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Preferences', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                _toggle('Dark Mode', state.darkMode, state.setDarkMode),
                _toggle('Vibration', state.vibrate, state.setVibrate),
                _toggle('Battery Saver', state.batterySaver, state.setBatterySaver),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Water
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Water', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Row(children: [
                  const Icon(Icons.water_drop, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('Today: ${state.waterMlToday} ml'),
                  const Spacer(),
                  TextButton(onPressed: () => state.addWater(250), child: const Text('+250 ml')),
                  TextButton(onPressed: () => state.addWater(500), child: const Text('+500 ml')),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  const Text('Reminders every'),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: state.waterInterval.inMinutes,
                    items: const [
                      DropdownMenuItem(value: 60, child: Text('1 hr')),
                      DropdownMenuItem(value: 120, child: Text('2 hr')),
                      DropdownMenuItem(value: 180, child: Text('3 hr')),
                    ],
                    onChanged: (v) { if (v != null) state.setWaterInterval(Duration(minutes: v)); },
                  ),
                  const SizedBox(width: 12),
                  Switch(value: state.waterReminders, onChanged: (v) => state.setWaterReminders(v)),
                ]),
                const SizedBox(height: 12),
                // Recent entries
                if (state.waterEntries.isEmpty)
                  const Text('No water logged yet.', style: TextStyle(color: Colors.grey))
                else
                  Column(
                    children: state.waterEntries.take(5).map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.local_drink, size: 18),
                          const SizedBox(width: 8),
                          Text('${e.ml} ml'),
                          const Spacer(),
                          Text(TimeOfDay.fromDateTime(e.at).format(context), style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )).toList(),
                  )
              ]),
            ),
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
