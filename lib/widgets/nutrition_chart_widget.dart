import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/step_data.dart';

class NutritionChartWidget extends StatelessWidget {
  final NutritionData nutrition;

  const NutritionChartWidget({
    super.key,
    required this.nutrition,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'You have consumed',
              style: AppTextStyles.bodyMedium,
            ),
            Text(
              '${nutrition.totalCalories} Cal today',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 120,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: PieChart(
                  PieChartData(
                    sections: _buildPieChartSections(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 25,
                    startDegreeOffset: -90,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 3,
                child: _buildNutritionLegend(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildNutritionBars(),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final total = nutrition.carbs + nutrition.protein + nutrition.fat;
    if (total == 0) return [];

    return [
      PieChartSectionData(
        color: AppColors.secondary,
        value: nutrition.carbs,
        title: '',
        radius: 20,
      ),
      PieChartSectionData(
        color: AppColors.primary,
        value: nutrition.protein,
        title: '',
        radius: 20,
      ),
      PieChartSectionData(
        color: AppColors.accent,
        value: nutrition.fat,
        title: '',
        radius: 20,
      ),
    ];
  }

  Widget _buildNutritionLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          'Carbs',
          '${nutrition.carbs.round()}g',
          '32%',
          AppColors.secondary,
        ),
        const SizedBox(height: 8),
        _buildLegendItem(
          'Protein',
          '${nutrition.protein.round()}g',
          '40%',
          AppColors.primary,
        ),
        const SizedBox(height: 8),
        _buildLegendItem(
          'Fat',
          '${nutrition.fat.round()}g',
          '32%',
          AppColors.accent,
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, String value, String percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          percentage,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionBars() {
    return Column(
      children: [
        _buildNutritionBar('Carbs', nutrition.carbs, 300, AppColors.secondary),
        const SizedBox(height: 8),
        _buildNutritionBar('Protein', nutrition.protein, 150, AppColors.primary),
        const SizedBox(height: 8),
        _buildNutritionBar('Fat', nutrition.fat, 100, AppColors.accent),
      ],
    );
  }

  Widget _buildNutritionBar(String label, double value, double maxValue, Color color) {
    final progress = (value / maxValue).clamp(0.0, 1.0);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall,
            ),
            Text(
              '${value.round()}g',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
