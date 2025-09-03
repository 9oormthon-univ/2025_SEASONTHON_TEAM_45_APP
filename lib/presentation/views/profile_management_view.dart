import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/gradient_background.dart';
import '../widgets/custom_back_button.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';

class ProfileManagementView extends StatelessWidget {
  const ProfileManagementView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // 사용자 정보 가져오기
        String userName = '';
        String userPhone = '';
        String userGender = '';
        String userBirthDate = '';
        
        if (state is Authenticated) {
          userName = state.user.name;
          userPhone = state.user.formattedPhoneNumber;
          userGender = state.user.gender ?? '';
          userBirthDate = state.user.birthDate ?? '';
        }
        
        // 생년월일 형식 변환
        String formattedBirthDate = '';
        if (userBirthDate.isNotEmpty && userBirthDate.length == 8) {
          // 20000919 -> 2000년 9월 19일
          final year = userBirthDate.substring(0, 4);
          final month = userBirthDate.substring(4, 6);
          final day = userBirthDate.substring(6, 8);
          formattedBirthDate = '$year년 ${int.parse(month)}월 ${int.parse(day)}일';
        }
        
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
                            '프로필 관리',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.md)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 이름
                        Text(
                          '이름',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.spacing(context, SpacingSize.md),
                            vertical: ResponsiveUtils.spacing(context, SpacingSize.md),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundGray,
                            borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                            border: Border.all(
                              color: AppColors.grayLight,
                              width: 1,
                            ),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              userName.isNotEmpty ? userName : '-',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),
                        
                        // 생년월일
                        Text(
                          '생년월일',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.spacing(context, SpacingSize.md),
                            vertical: ResponsiveUtils.spacing(context, SpacingSize.md),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundGray,
                            borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                            border: Border.all(
                              color: AppColors.grayLight,
                              width: 1,
                            ),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              formattedBirthDate.isNotEmpty ? formattedBirthDate : '-',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),
                        
                        // 성별
                        Text(
                          '성별',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.spacing(context, SpacingSize.md),
                            vertical: ResponsiveUtils.spacing(context, SpacingSize.md),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundGray,
                            borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                            border: Border.all(
                              color: AppColors.grayLight,
                              width: 1,
                            ),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              userGender.isNotEmpty ? userGender : '-',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),
                        
                        // 전화번호
                        Text(
                          '전화번호',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.spacing(context, SpacingSize.md),
                            vertical: ResponsiveUtils.spacing(context, SpacingSize.md),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundGray,
                            borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                            border: Border.all(
                              color: AppColors.grayLight,
                              width: 1,
                            ),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              userPhone.isNotEmpty ? userPhone : '-',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}