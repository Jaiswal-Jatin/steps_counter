import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/step_counter_provider.dart';
import '../theme/app_theme.dart';
import '../models/step_data.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _carbsController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _caloriesController = TextEditingController();

  @override
  void dispose() {
    _carbsController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nutrition Tracking'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTodaysNutrition(),
            const SizedBox(height: AppSpacing.lg),
            _buildQuickAddMeals(),
            const SizedBox(height: AppSpacing.lg),
            _buildCustomNutritionEntry(),
            const SizedBox(height: AppSpacing.lg),
            _buildNutritionTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysNutrition() {
    return Consumer<StepCounterProvider>(
      builder: (context, provider, child) {
        final nutrition = provider.todayNutrition;
        
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: AppBorderRadius.smallRadius,
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Today\'s Nutrition',
                    style: AppTextStyles.headline6,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (nutrition != null) ...[
                _buildNutritionProgress('Calories', nutrition.totalCalories, 2000, 'cal', AppColors.accent),
                const SizedBox(height: AppSpacing.md),
                _buildNutritionProgress('Carbs', nutrition.carbs.round(), 300, 'g', AppColors.secondary),
                const SizedBox(height: AppSpacing.md),
                _buildNutritionProgress('Protein', nutrition.protein.round(), 150, 'g', AppColors.primary),
                const SizedBox(height: AppSpacing.md),
                _buildNutritionProgress('Fat', nutrition.fat.round(), 100, 'g', AppColors.warning),
              ] else ...[
                Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        color: AppColors.textLight,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No nutrition data for today',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add your meals below to start tracking',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildNutritionProgress(String label, int current, int goal, String unit, Color color) {
    final progress = (current / goal).clamp(0.0, 1.0);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$current / $goal $unit',
              style: AppTextStyles.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAddMeals() {
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
            'Quick Add Meals',
            style: AppTextStyles.headline6,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Add common meals with pre-calculated nutrition',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildMealCategories(),
        ],
      ),
    );
  }

  Widget _buildMealCategories() {
    return Column(
      children: [
        _buildMealCategory(
          'Breakfast',
          Icons.breakfast_dining,
          AppColors.warning,
          [
            {'name': 'Oatmeal with Fruits', 'cal': 320, 'carbs': 58, 'protein': 12, 'fat': 8},
            {'name': 'Scrambled Eggs', 'cal': 280, 'carbs': 4, 'protein': 20, 'fat': 20},
            {'name': 'Greek Yogurt', 'cal': 150, 'carbs': 15, 'protein': 15, 'fat': 5},
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildMealCategory(
          'Lunch',
          Icons.lunch_dining,
          AppColors.secondary,
          [
            {'name': 'Chicken Salad', 'cal': 450, 'carbs': 25, 'protein': 35, 'fat': 22},
            {'name': 'Tuna Sandwich', 'cal': 380, 'carbs': 45, 'protein': 25, 'fat': 12},
            {'name': 'Vegetable Soup', 'cal': 220, 'carbs': 35, 'protein': 8, 'fat': 6},
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildMealCategory(
          'Dinner',
          Icons.dinner_dining,
          AppColors.primary,
          [
            {'name': 'Grilled Salmon', 'cal': 520, 'carbs': 15, 'protein': 45, 'fat': 28},
            {'name': 'Pasta with Sauce', 'cal': 420, 'carbs': 65, 'protein': 18, 'fat': 12},
            {'name': 'Stir Fry Vegetables', 'cal': 340, 'carbs': 45, 'protein': 12, 'fat': 14},
          ],
        ),
      ],
    );
  }

  Widget _buildMealCategory(String title, IconData icon, Color color, List<Map<String, dynamic>> meals) {
    return ExpansionTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppBorderRadius.smallRadius,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      children: meals.map((meal) => _buildMealItem(meal, color)).toList(),
    );
  }

  Widget _buildMealItem(Map<String, dynamic> meal, Color color) {
    return Consumer<StepCounterProvider>(
      builder: (context, provider, child) {
        return ListTile(
          title: Text(
            meal['name'],
            style: AppTextStyles.bodyMedium,
          ),
          subtitle: Text(
            '${meal['cal']} cal • ${meal['carbs']}g carbs • ${meal['protein']}g protein • ${meal['fat']}g fat',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textLight,
            ),
          ),
          trailing: ElevatedButton(
            onPressed: () {
              final nutrition = NutritionData(
                date: DateTime.now(),
                carbs: meal['carbs'].toDouble(),
                protein: meal['protein'].toDouble(),
                fat: meal['fat'].toDouble(),
                totalCalories: meal['cal'],
              );
              
              // Add to existing nutrition or create new
              final existing = provider.todayNutrition;
              if (existing != null) {
                final updated = NutritionData(
                  date: DateTime.now(),
                  carbs: existing.carbs + nutrition.carbs,
                  protein: existing.protein + nutrition.protein,
                  fat: existing.fat + nutrition.fat,
                  totalCalories: existing.totalCalories + nutrition.totalCalories,
                );
                provider.updateNutrition(updated);
              } else {
                provider.updateNutrition(nutrition);
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${meal['name']} added to nutrition'),
                  backgroundColor: color,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Add'),
          ),
        );
      },
    );
  }

  Widget _buildCustomNutritionEntry() {
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
            'Custom Nutrition Entry',
            style: AppTextStyles.headline6,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Manually enter nutrition values',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _carbsController,
                  decoration: const InputDecoration(
                    labelText: 'Carbs (g)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  controller: _proteinController,
                  decoration: const InputDecoration(
                    labelText: 'Protein (g)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _fatController,
                  decoration: const InputDecoration(
                    labelText: 'Fat (g)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  controller: _caloriesController,
                  decoration: const InputDecoration(
                    labelText: 'Calories',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addCustomNutrition,
              child: const Text('Add Nutrition'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionTips() {
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
            'Nutrition Tips',
            style: AppTextStyles.headline6,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTipItem(
            Icons.water_drop,
            'Stay Hydrated',
            'Drink at least 8 glasses of water daily for optimal health',
            AppColors.info,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildTipItem(
            Icons.restaurant,
            'Balanced Diet',
            'Include a variety of foods from all food groups in your meals',
            AppColors.secondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildTipItem(
            Icons.schedule,
            'Regular Meals',
            'Eat at regular intervals to maintain stable energy levels',
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String title, String description, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: AppBorderRadius.smallRadius,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addCustomNutrition() {
    final carbs = double.tryParse(_carbsController.text) ?? 0;
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final fat = double.tryParse(_fatController.text) ?? 0;
    final calories = int.tryParse(_caloriesController.text) ?? 0;

    if (carbs == 0 && protein == 0 && fat == 0 && calories == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one nutrition value'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final nutrition = NutritionData(
      date: DateTime.now(),
      carbs: carbs,
      protein: protein,
      fat: fat,
      totalCalories: calories,
    );

    // Add to existing nutrition or create new
    final provider = Provider.of<StepCounterProvider>(context, listen: false);
    final existing = provider.todayNutrition;
    if (existing != null) {
      final updated = NutritionData(
        date: DateTime.now(),
        carbs: existing.carbs + nutrition.carbs,
        protein: existing.protein + nutrition.protein,
        fat: existing.fat + nutrition.fat,
        totalCalories: existing.totalCalories + nutrition.totalCalories,
      );
      provider.updateNutrition(updated);
    } else {
      provider.updateNutrition(nutrition);
    }

    // Clear form
    _carbsController.clear();
    _proteinController.clear();
    _fatController.clear();
    _caloriesController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom nutrition added successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
