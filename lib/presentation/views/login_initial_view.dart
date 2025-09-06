import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/gradient_background.dart';
import 'login_input_view.dart';
import 'signup_view.dart';

class LoginInitialView extends StatelessWidget {
  const LoginInitialView({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Padding(
        padding: ResponsiveUtils.defaultPadding(context),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Logo
              SvgPicture.asset(
                'assets/images/Cloud_login.svg',
                width: ResponsiveUtils.widthPercent(context, 40),
                height: ResponsiveUtils.widthPercent(context, 40),
              ),
              
              SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),
              
              // Subtitle
              Text(
                '병원 예약과 진료를 스마트하게',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
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
    );
  }
}