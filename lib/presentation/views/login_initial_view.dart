import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import 'login_input_view.dart';
import 'signup_view.dart';

class LoginInitialView extends StatelessWidget {
  const LoginInitialView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Padding(
          padding: ResponsiveUtils.defaultPadding(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Logo placeholder
              Container(
                width: ResponsiveUtils.widthPercent(context, 40),
                height: ResponsiveUtils.widthPercent(context, 40),
                decoration: BoxDecoration(
                  color: AppColors.grayLight,
                  borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),
              
              // Subtitle
              Text(
                'Subtitle',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
              
              // App name
              Text(
                '케어프리패스',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.xxxl),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
              
              const Spacer(flex: 2),
              
              // Login button
              SizedBox(
                width: double.infinity,
                height: ResponsiveUtils.buttonHeight(context),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginInputView(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '로그인',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),
              
              // Sign up text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '케어프리패스에 처음이신가요?',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignupView(),
                    ),
                  );
                },
                child: Text(
                  '회원가입하기',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              
              const Spacer(flex: 1),
              
              // Footer
              Text(
                'Developed By Team 케어프리패스',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.xs),
                  fontWeight: FontWeight.w400,
                  color: AppColors.textHint,
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
            ],
          ),
        ),
      ),
    );
  }
}