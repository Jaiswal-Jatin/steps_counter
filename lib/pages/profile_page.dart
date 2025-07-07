import 'package:flutter/material.dart';
import '../widgets/step_widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
              'Profile',
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
              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primaryContainer, colorScheme.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: colorScheme.onPrimary,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fitness Enthusiast',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Keep moving forward!',
                      style: TextStyle(
                        color: colorScheme.onPrimary.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Settings List
              SettingsTile(
                icon: Icons.flag,
                title: 'Daily Goal',
                subtitle: '10,000 steps',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Goal settings coming soon!')),
                  );
                },
              ),

              SettingsTile(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Remind me to move',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification settings coming soon!'),
                    ),
                  );
                },
              ),

              SettingsTile(
                icon: Icons.security,
                title: 'Privacy',
                subtitle: 'Data and permissions',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Privacy settings coming soon!'),
                    ),
                  );
                },
              ),

              SettingsTile(
                icon: Icons.help,
                title: 'Help & Support',
                subtitle: 'Get help with the app',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Help & Support'),
                      content: const Text(
                        'FitStep Pro v1.0.0\n\n'
                        'For support, please contact:\n'
                        'support@fitsteppro.com\n\n'
                        'Features:\n'
                        '• Real-time step counting\n'
                        '• Daily goal tracking\n'
                        '• Water & sleep monitoring\n'
                        '• Achievement system',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),

              SettingsTile(
                icon: Icons.info,
                title: 'About',
                subtitle: 'FitStep Pro v1.0.0',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'FitStep Pro',
                    applicationVersion: '1.0.0',
                    applicationIcon: Icon(
                      Icons.directions_walk,
                      color: colorScheme.primary,
                      size: 32,
                    ),
                    children: [
                      const Text(
                        'A modern fitness tracking app that helps you monitor your daily activities, '
                        'set goals, and maintain a healthy lifestyle.',
                      ),
                    ],
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
