import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/gradient_background.dart';
import '../../data/auth_storage.dart';
import '../widgets/custom_back_button.dart';
import 'permission_settings_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authStorage = AuthStorage();
    final currentUser = authStorage.getCurrentUser();
    
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.md)),
              child: Row(
                children: [
                  const CustomBackButton(),
                  Expanded(
                    child: Center(
                      child: Text(
                        '설정',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // 균형을 위한 공간
                ],
              ),
            ),
            
            // 사용자 정보
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.spacing(context, SpacingSize.md),
                vertical: ResponsiveUtils.spacing(context, SpacingSize.sm),
              ),
              padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.lg)),
              decoration: BoxDecoration(
                color: AppColors.backgroundGray,
                borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${currentUser?['name'] ?? '사용자'}님',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xs)),
                  Text(
                    currentUser?['phone'] ?? '010-0000-0000',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // 계정 설정
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.spacing(context, SpacingSize.md),
                vertical: ResponsiveUtils.spacing(context, SpacingSize.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: ResponsiveUtils.spacing(context, SpacingSize.sm),
                      bottom: ResponsiveUtils.spacing(context, SpacingSize.sm),
                    ),
                    child: Text(
                      '계정 설정',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  
                  // 프로필 관리
                  _buildMenuItem(
                    context,
                    title: '프로필 관리',
                    onTap: () {
                      Navigator.pushNamed(context, '/profile_management');
                    },
                  ),
                  
                  SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xs)),
                  
                  // 권한 설정
                  _buildMenuItem(
                    context,
                    title: '권한 설정',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PermissionSettingsView(
                            isFromSettings: true,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // 로그아웃 버튼
            Padding(
              padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.md)),
              child: TextButton(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                child: Text(
                  '로그아웃',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.spacing(context, SpacingSize.lg),
          vertical: ResponsiveUtils.spacing(context, SpacingSize.md),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: ResponsiveUtils.iconSize(context, IconSizeType.small),
              color: AppColors.grayMedium,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                AuthStorage().logout();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
              child: const Text('로그아웃'),
            ),
          ],
        );
      },
    );
  }
}