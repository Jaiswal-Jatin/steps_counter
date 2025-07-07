import 'package:flutter/material.dart';

class ModernStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const ModernStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class HealthCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const HealthCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AchievementCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const AchievementCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.emoji_events,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: colorScheme.onSurface.withOpacity(0.5),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
