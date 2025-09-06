import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // 스플래시 화면 표시 시간 (2초)
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // SharedPreferences에서 로그인 상태 확인
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getInt('member_id');
    final accessToken = prefs.getString('access_token');
    
    if (!mounted) return;
    
    // 로그인 상태에 따라 라우팅
    if (memberId != null && accessToken != null) {
      // 로그인 되어 있으면 홈으로
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // 로그인 안 되어 있으면 로그인 페이지로
      Navigator.pushReplacementNamed(context, '/login-initial');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 구름 로고
            SvgPicture.asset(
              'assets/images/Cloud_splash.svg',
              width: ResponsiveUtils.widthPercent(context, 45),
              height: ResponsiveUtils.widthPercent(context, 35),
            ),
            SizedBox(height: ResponsiveUtils.heightPercent(context, 3)),
            
            // 서브타이틀
            Text(
              '병원 예약과 진료를 스마트하게',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: ResponsiveUtils.heightPercent(context, 1)),
            
            // 앱 이름
            Text(
              '케어프리패스',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.xxxl),
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}