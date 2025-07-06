import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WaterIntakeWidget extends StatelessWidget {
  final double progress;
  final double currentIntake; // in ml
  final double goal; // in ml
  final Function(double) onAddWater;

  const WaterIntakeWidget({
    super.key,
    required this.progress,
    required this.currentIntake,
    required this.goal,
    required this.onAddWater,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'You have drunk',
              style: AppTextStyles.bodyMedium,
            ),
            Text(
              '${(currentIntake / 1000).toStringAsFixed(1)}L today',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildGlassesRow(),
        const SizedBox(height: AppSpacing.md),
        _buildProgressBar(),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(currentIntake).round()} ml',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight,
              ),
            ),
            Text(
              '${(goal).round()} ml',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassesRow() {
    const int totalGlasses = 8;
    final int filledGlasses = (progress * totalGlasses).round();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(totalGlasses, (index) {
        final bool isFilled = index < filledGlasses;
        
        return GestureDetector(
          onTap: () {
            // Add 250ml per glass
            onAddWater(250);
          },
          child: Container(
            width: 32,
            height: 40,
            decoration: BoxDecoration(
              color: isFilled 
                  ? AppColors.info 
                  : AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.local_drink,
              color: isFilled 
                  ? Colors.white 
                  : AppColors.info.withOpacity(0.5),
              size: 20,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.info,
                AppColors.info.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
