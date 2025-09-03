import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/gradient_background.dart';

class AppointmentCompletionView extends StatelessWidget {
  final int appointmentId;
  final String department;
  final DateTime date;
  final String time;

  const AppointmentCompletionView({
    super.key,
    required this.appointmentId,
    required this.department,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더 (뒤로가기 버튼 없음)
            Padding(
              padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.md)),
              child: Center(
                child: Text(
                  '예약하기',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            
            // 메인 컨텐츠
            Expanded(
              child: Padding(
                padding: ResponsiveUtils.horizontalPaddingOnly(context),
                child: Column(
                  children: [
                    // 카드 (홈화면과 동일한 SVG 배경 사용)
                    _buildCard(context),
                    
                    SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),
                    
                    // 확인 버튼
                    SizedBox(
                      width: double.infinity,
                      height: ResponsiveUtils.buttonHeight(context),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/home',
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          '확인',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

  // 홈화면과 동일한 카드 위젯
  Widget _buildCard(BuildContext context) {
    return SizedBox(
      height: ResponsiveUtils.heightPercent(context, 55), // 카드 고정 높이 55%
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 카드 배경 SVG
          SvgPicture.asset(
            'assets/images/Card.svg',
            width: MediaQuery.of(context).size.width - ResponsiveUtils.widthPercent(context, 10),
            height: ResponsiveUtils.heightPercent(context, 55),
            fit: BoxFit.fill,
          ),
          // 카드 내용
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.widthPercent(context, 10), // 카드 내부 좌우 여백
                vertical: ResponsiveUtils.heightPercent(context, 6), // 카드 내부 상하 여백
              ),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 체크 아이콘과 예약 완료 상태
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        bottom: ResponsiveUtils.spacing(context, SpacingSize.lg),
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: Color(0xFFC9CCCB),
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/images/상태 아이콘/Vector.svg',
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '예약 완료',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xs)),
                          Text(
                            '예약시간에 맞게 도착해 주세요',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF858585),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),
                    
                    // 예약 정보
                    _buildReservationInfo(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 예약 정보 섹션
  Widget _buildReservationInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 방문 예정 날짜
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '방문 예정 날짜',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF858585),
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
            Row(
              children: [
                Text(
                  _formatDate(date),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.spacing(context, SpacingSize.md)),
                if (_getDaysDifference(date) >= 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.widthPercent(context, 3),
                      vertical: ResponsiveUtils.heightPercent(context, 0.5),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13D094),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      _getDaysDifference(date) == 0 
                        ? 'D-Day' 
                        : 'D-${_getDaysDifference(date)}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFCFFFE),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),
        
        // 방문 예정 시간
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '방문 예정 시간',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF858585),
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
            Text(
              _formatTime(time),
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),
        
        // 진료과
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '진료과',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF858585),
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
            Text(
              department,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 홈화면과 동일한 포맷 함수들
  String _formatDate(DateTime date) {
    // 2024년 12월 31일 형식
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  String _formatTime(String time) {
    // 14:30:00 -> 오후 2:30
    final parts = time.split(':');
    if (parts.isEmpty) return time;
    
    final hour = int.parse(parts[0]);
    final minute = parts.length > 1 ? parts[1] : '00';
    
    if (hour < 12) {
      return '오전 ${hour == 0 ? 12 : hour}:$minute';
    } else {
      return '오후 ${hour == 12 ? 12 : hour - 12}:$minute';
    }
  }

  int _getDaysDifference(DateTime date) {
    // 예약 날짜까지 남은 일수 계산
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final appointmentDate = DateTime(date.year, date.month, date.day);
    return appointmentDate.difference(todayMidnight).inDays;
  }
}