import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/gradient_background.dart';
import '../widgets/custom_back_button.dart';
import 'general_appointment_view.dart';

class AppointmentInitialView extends StatelessWidget {
  const AppointmentInitialView({super.key});

  @override
  Widget build(BuildContext context) {
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
                        'AI 예약 도우미',
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
            
            // 메인 컨텐츠
            Expanded(
              child: Padding(
                padding: ResponsiveUtils.defaultPadding(context),
                child: Column(
                  children: [
                    SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
                    
                    // 안내 메시지
                    Container(
                      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.lg)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '안녕하세요! AI 병원 예약 도우미입니다. 😊',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                          Text(
                            '어떤 증상으로 문의해주셨나요? 자세히 말씀해 주시면 적절한 진료과를 추천해 드리겠습니다.',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
                          
                          // 예약 과정
                          Text(
                            '💡 예약 과정:',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xs)),
                          _buildStepItem(context, '1. 증상 설명 → 진료과 추천'),
                          _buildStepItem(context, '2. 예약 날짜와 시간 알려주기'),
                          _buildStepItem(context, '3. 구릅파병원 예약 완료! ✅'),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // 하단 버튼 영역
                    Column(
                      children: [
                        // 어떻게 하는거야? 카드
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.spacing(context, SpacingSize.md),
                            vertical: ResponsiveUtils.spacing(context, SpacingSize.sm),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
                          ),
                          child: Text(
                            '어떻게 하는거야?',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                        
                        // 일반 예약으로 전환 버튼
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GeneralAppointmentView(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.surfaceLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveUtils.spacing(context, SpacingSize.lg),
                              vertical: ResponsiveUtils.spacing(context, SpacingSize.sm),
                            ),
                          ),
                          child: Text(
                            '일반 예약으로 전환해줘',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        
                        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
                        
                        // 입력 필드
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                            border: Border.all(
                              color: AppColors.grayLight,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: '증상을 자세히 알려주세요...',
                                    hintStyle: TextStyle(
                                      fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                                      color: AppColors.textHint,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: ResponsiveUtils.spacing(context, SpacingSize.md),
                                      vertical: ResponsiveUtils.spacing(context, SpacingSize.md),
                                    ),
                                  ),
                                  readOnly: true,
                                  onTap: () {
                                    // TODO: 챗봇 화면으로 이동 (추후 구현)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('AI 챗봇 기능은 곧 구현될 예정입니다'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.xs)),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_upward, color: Colors.white),
                                  onPressed: () {
                                    // TODO: 챗봇 메시지 전송 (추후 구현)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('AI 챗봇 기능은 곧 구현될 예정입니다'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStepItem(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(
        left: ResponsiveUtils.spacing(context, SpacingSize.md),
        bottom: ResponsiveUtils.spacing(context, SpacingSize.xs),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
          color: AppColors.textSecondary,
          height: 1.3,
        ),
      ),
    );
  }
}