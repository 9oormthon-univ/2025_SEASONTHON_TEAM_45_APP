import 'package:flutter/material.dart';

class ResponsiveUtils {
  static double horizontalPadding(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.05;
  }
  
  static double verticalPadding(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.02;
  }
  
  static double buttonHeight(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.06;
  }
  
  static double inputFieldHeight(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.07;
  }
  
  static double logoSize(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.4;
  }
  
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  static double widthPercent(BuildContext context, double percent) {
    return MediaQuery.of(context).size.width * (percent / 100);
  }
  
  static double heightPercent(BuildContext context, double percent) {
    return MediaQuery.of(context).size.height * (percent / 100);
  }
  
  static EdgeInsets defaultPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding(context),
      vertical: verticalPadding(context),
    );
  }
  
  static EdgeInsets horizontalPaddingOnly(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding(context),
    );
  }
  
  static EdgeInsets verticalPaddingOnly(BuildContext context) {
    return EdgeInsets.symmetric(
      vertical: verticalPadding(context),
    );
  }
  
  static double fontSize(BuildContext context, FontSize size) {
    final baseWidth = MediaQuery.of(context).size.width;
    
    switch (size) {
      case FontSize.xs:
        return baseWidth * 0.03;
      case FontSize.sm:
        return baseWidth * 0.035;
      case FontSize.md:
        return baseWidth * 0.04;
      case FontSize.lg:
        return baseWidth * 0.045;
      case FontSize.xl:
        return baseWidth * 0.055;
      case FontSize.xxl:
        return baseWidth * 0.07;
      case FontSize.xxxl:
        return baseWidth * 0.09;
    }
  }
  
  static double iconSize(BuildContext context, IconSizeType size) {
    final baseWidth = MediaQuery.of(context).size.width;
    
    switch (size) {
      case IconSizeType.small:
        return baseWidth * 0.05;
      case IconSizeType.medium:
        return baseWidth * 0.07;
      case IconSizeType.large:
        return baseWidth * 0.1;
      case IconSizeType.xlarge:
        return baseWidth * 0.15;
    }
  }
  
  static double spacing(BuildContext context, SpacingSize size) {
    final baseHeight = MediaQuery.of(context).size.height;
    
    switch (size) {
      case SpacingSize.xs:
        return baseHeight * 0.005;
      case SpacingSize.sm:
        return baseHeight * 0.01;
      case SpacingSize.md:
        return baseHeight * 0.02;
      case SpacingSize.lg:
        return baseHeight * 0.03;
      case SpacingSize.xl:
        return baseHeight * 0.05;
      case SpacingSize.xxl:
        return baseHeight * 0.08;
    }
  }
  
  static BorderRadius borderRadius(BuildContext context, RadiusSize size) {
    final baseWidth = MediaQuery.of(context).size.width;
    
    switch (size) {
      case RadiusSize.small:
        return BorderRadius.circular(baseWidth * 0.02);
      case RadiusSize.medium:
        return BorderRadius.circular(baseWidth * 0.03);
      case RadiusSize.large:
        return BorderRadius.circular(baseWidth * 0.05);
      case RadiusSize.xlarge:
        return BorderRadius.circular(baseWidth * 0.08);
      case RadiusSize.round:
        return BorderRadius.circular(baseWidth * 0.5);
    }
  }
}

enum FontSize { xs, sm, md, lg, xl, xxl, xxxl }
enum IconSizeType { small, medium, large, xlarge }
enum SpacingSize { xs, sm, md, lg, xl, xxl }
enum RadiusSize { small, medium, large, xlarge, round }