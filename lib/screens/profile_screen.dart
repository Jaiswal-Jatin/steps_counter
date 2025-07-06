import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/step_counter_provider.dart';
import '../theme/app_theme.dart';
import '../models/step_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _stepsGoalController = TextEditingController();
  
  String _selectedGender = 'Male';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _stepsGoalController.dispose();
    super.dispose();
  }

  void _loadProfile() {
    final provider = Provider.of<StepCounterProvider>(context, listen: false);
    final profile = provider.userProfile;
    
    if (profile != null) {
      _nameController.text = profile.name;
      _heightController.text = profile.height.toString();
      _weightController.text = profile.weight.toString();
      _ageController.text = profile.age.toString();
      _stepsGoalController.text = profile.dailyStepsGoal.toString();
      _selectedGender = profile.gender;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
              if (!_isEditing) {
                _saveProfile();
              }
            },
            child: Text(
              _isEditing ? 'Save' : 'Edit',
              style: AppTextStyles.button.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: AppSpacing.lg),
            _buildProfileForm(),
            const SizedBox(height: AppSpacing.lg),
            _buildGoalsSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildSettingsSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildStatsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Consumer<StepCounterProvider>(
      builder: (context, provider, child) {
        final profile = provider.userProfile;
        
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppBorderRadius.largeRadius,
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                profile?.name ?? 'Guest User',
                style: AppTextStyles.headline4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Fitness Enthusiast',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildProfileStat(
                    '${provider.currentSteps}',
                    'Steps Today',
                    Colors.white,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildProfileStat(
                    '${provider.currentCalories}',
                    'Calories Burned',
                    Colors.white,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildProfileStat(
                    '${provider.currentDistance.toStringAsFixed(1)}km',
                    'Distance',
                    Colors.white,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headline6.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: color.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.largeRadius,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: AppTextStyles.headline6,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _nameController,
            enabled: _isEditing,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ageController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.cake_outlined),
                    suffixText: 'years',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  onChanged: _isEditing ? (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  } : null,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.people_outline),
                  ),
                  items: ['Male', 'Female', 'Other'].map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _heightController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Height',
                    prefixIcon: Icon(Icons.height),
                    suffixText: 'cm',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextFormField(
                  controller: _weightController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                    suffixText: 'kg',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.largeRadius,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Goals',
            style: AppTextStyles.headline6,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _stepsGoalController,
            enabled: _isEditing,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Steps Goal',
              prefixIcon: Icon(Icons.directions_walk),
              suffixText: 'steps',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildGoalCard(
                  'Water Goal',
                  '2.5L',
                  Icons.water_drop,
                  AppColors.info,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildGoalCard(
                  'Calories Goal',
                  '2000 cal',
                  Icons.local_fire_department,
                  AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppBorderRadius.mediumRadius,
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.largeRadius,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: AppTextStyles.headline6,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSettingItem(
            Icons.notifications_outlined,
            'Notifications',
            'Manage app notifications',
            () {},
          ),
          _buildSettingItem(
            Icons.privacy_tip_outlined,
            'Privacy',
            'Data and privacy settings',
            () {},
          ),
          _buildSettingItem(
            Icons.help_outline,
            'Help & Support',
            'Get help and contact support',
            () {},
          ),
          _buildSettingItem(
            Icons.info_outline,
            'About',
            'App version and information',
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: AppBorderRadius.smallRadius,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textLight,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textLight,
      ),
      onTap: onTap,
    );
  }

  Widget _buildStatsSection() {
    return Consumer<StepCounterProvider>(
      builder: (context, provider, child) {
        final weeklySteps = provider.weeklyData.fold(0, (sum, data) => sum + data.steps);
        final weeklyDistance = provider.weeklyData.fold(0.0, (sum, data) => sum + data.distance);
        final weeklyCalories = provider.weeklyData.fold(0, (sum, data) => sum + data.calories);
        
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppBorderRadius.largeRadius,
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Statistics',
                style: AppTextStyles.headline6,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Total Steps',
                      '$weeklySteps',
                      Icons.directions_walk,
                      AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Distance',
                      '${weeklyDistance.toStringAsFixed(1)}km',
                      Icons.straighten,
                      AppColors.secondary,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Calories',
                      '$weeklyCalories',
                      Icons.local_fire_department,
                      AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.headline6.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    final height = double.tryParse(_heightController.text) ?? 170.0;
    final weight = double.tryParse(_weightController.text) ?? 70.0;
    final age = int.tryParse(_ageController.text) ?? 25;
    final stepsGoal = int.tryParse(_stepsGoalController.text) ?? 10000;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final profile = UserProfile(
      name: name,
      height: height,
      weight: weight,
      age: age,
      gender: _selectedGender,
      dailyStepsGoal: stepsGoal,
    );

    final provider = Provider.of<StepCounterProvider>(context, listen: false);
    provider.updateUserProfile(profile);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
