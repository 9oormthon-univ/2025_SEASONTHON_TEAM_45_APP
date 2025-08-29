import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';

class ProgressIndicatorBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  
  const ProgressIndicatorBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveUtils.heightPercent(context, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          totalSteps * 2 - 1,
          (index) {
            if (index % 2 == 0) {
              final stepNumber = (index ~/ 2) + 1;
              final isActive = stepNumber <= currentStep;
              
              return Container(
                width: ResponsiveUtils.widthPercent(context, 7),
                height: ResponsiveUtils.widthPercent(context, 7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? AppColors.primaryGreen : AppColors.grayLight,
                ),
                child: Center(
                  child: Text(
                    '$stepNumber',
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.grayMedium,
                      fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            } else {
              final lineIndex = (index ~/ 2);
              final isActive = lineIndex < currentStep - 1;
              
              return Container(
                width: ResponsiveUtils.widthPercent(context, 6),
                height: 2,
                color: isActive ? AppColors.primaryGreen : AppColors.grayLight,
              );
            }
          },
        ),
      ),
    );
  }
}