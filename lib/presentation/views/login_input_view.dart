import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/gradient_background.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import 'signup_view.dart';
import 'permission_settings_view.dart';

class LoginInputView extends StatefulWidget {
  const LoginInputView({super.key});

  @override
  State<LoginInputView> createState() => _LoginInputViewState();
}

class _LoginInputViewState extends State<LoginInputView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(LoginRequested(
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
        autoLogin: true,  // 항상 자동 로그인 활성화
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PermissionSettingsView(),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final errorMessage = state is AuthError ? state.message : null;
          
          return GradientScaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: ResponsiveUtils.defaultPadding(context),
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(ResponsiveUtils.widthPercent(context, 6)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: ResponsiveUtils.widthPercent(context, 12),
                        height: ResponsiveUtils.widthPercent(context, 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(ResponsiveUtils.widthPercent(context, 6)),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 16,
                              spreadRadius: 0,
                              offset: const Offset(0, 0),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
                
                // App name
                Center(
                  child: Text(
                    '케어프리패스',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, FontSize.xxxl),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xxl)),
                
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phone number field
                      Text(
                        '전화번호',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                      Container(
                        height: ResponsiveUtils.inputFieldHeight(context),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: errorMessage != null ? AppColors.error : AppColors.grayLight,
                            width: 1,
                          ),
                          borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
                        ),
                        child: Center(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              hintText: '휴대폰번호를 입력하세요',
                              hintStyle: TextStyle(
                                color: AppColors.textHint,
                                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUtils.widthPercent(context, 4),
                                vertical: 0,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '전화번호를 입력해주세요';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      
                      SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),
                      
                      // Password field
                      Text(
                        '비밀번호 입력',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                      Container(
                        height: ResponsiveUtils.inputFieldHeight(context),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: errorMessage != null ? AppColors.error : AppColors.grayLight,
                            width: 1,
                          ),
                          borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
                        ),
                        child: Center(
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              hintText: '비밀번호를 입력하세요',
                              hintStyle: TextStyle(
                                color: AppColors.textHint,
                                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUtils.widthPercent(context, 4),
                                vertical: 0,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '비밀번호를 입력해주세요';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      
                      if (errorMessage != null) ...[
                        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                        Text(
                          errorMessage,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                            fontWeight: FontWeight.w400,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xxl)),
                
                // Login button
                SizedBox(
                  width: double.infinity,
                  height: ResponsiveUtils.buttonHeight(context),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: ResponsiveUtils.iconSize(context, IconSizeType.small),
                            height: ResponsiveUtils.iconSize(context, IconSizeType.small),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            '로그인',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xxl)),
                
                // Account question bubble
                Center(
                  child: SvgPicture.asset(
                    'assets/images/Bubble.svg',
                    width: ResponsiveUtils.widthPercent(context, 42),
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                
                // Sign up link
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupView(),
                        ),
                      );
                    },
                    child: Text(
                      '지금 바로 회원가입',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      },
    );
  }
}