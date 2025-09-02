import 'package:flutter/material.dart';

/// 앱 전체에서 사용되는 공용 그라데이션 배경
class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;

  const GradientBackground({
    super.key,
    required this.child,
    this.useSafeArea = true,
  });

  /// 그라데이션 색상 정의
  static const Color gradientStartColor = Color(0xFFFBFBFB); // 0%
  static const Color gradientEndColor = Color(0xFFEFEFEF); // 100%

  /// 기본 그라데이션 반환
  static BoxDecoration get decoration => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            gradientStartColor,
            gradientEndColor,
          ],
        ),
      );

  /// 그라데이션만 반환 (Container 등에서 사용)
  static LinearGradient get gradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gradientStartColor,
          gradientEndColor,
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: decoration,
      child: useSafeArea ? SafeArea(child: child) : child,
    );
  }
}

/// Scaffold와 함께 사용하는 그라데이션 배경
class GradientScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool resizeToAvoidBottomInset;

  const GradientScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: GradientBackground(
        useSafeArea: false,
        child: SafeArea(
          top: appBar == null,
          child: Column(
            children: [
              if (appBar != null) appBar!,
              Expanded(child: body),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}