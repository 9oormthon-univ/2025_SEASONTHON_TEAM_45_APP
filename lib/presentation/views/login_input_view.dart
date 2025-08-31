import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../injection_container.dart';
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
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
  }
  
  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _authBloc.close();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      _authBloc.add(LoginRequested(
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
        autoLogin: true,  // 항상 자동 로그인 활성화
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _authBloc,
      child: BlocConsumer<AuthBloc, AuthState>(
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
          
          return Scaffold(
            backgroundColor: AppColors.backgroundWhite,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: ResponsiveUtils.defaultPadding(context),
                  child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                
                // Back button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: ResponsiveUtils.iconSize(context, IconSizeType.small),
                    color: AppColors.textPrimary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
                
                // App name
                Center(
                  child: Text(
                    '케어프리패스',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, FontSize.xxl),
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
                
                // Forgot password button (optional - if visible in design)
                Center(
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                        side: BorderSide(color: AppColors.grayLight, width: 1),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.widthPercent(context, 5),
                        vertical: ResponsiveUtils.heightPercent(context, 1.5),
                      ),
                    ),
                    child: Text(
                      '아직 계정이 없으신가요?',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
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
                        color: AppColors.primaryGreen,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
        },
      ),
    );
  }
}