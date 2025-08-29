import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';
import 'signup_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pushReplacementNamed(context, '/ble_scan');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: ResponsiveUtils.defaultPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xxl)),
                
                Center(
                  child: Container(
                    width: ResponsiveUtils.logoSize(context),
                    height: ResponsiveUtils.logoSize(context),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.large),
                    ),
                    child: Icon(
                      Icons.local_hospital,
                      size: ResponsiveUtils.iconSize(context, IconSizeType.xlarge),
                      color: Colors.blue,
                    ),
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
                
                Text(
                  'CareFreePass',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, FontSize.xxl),
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade800,
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                
                Text(
                  '병원 방문이 편리해집니다',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xxl)),
                
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        height: ResponsiveUtils.inputFieldHeight(context),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            hintText: '이메일 주소',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              size: ResponsiveUtils.iconSize(context, IconSizeType.small),
                              color: Colors.grey.shade600,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: ResponsiveUtils.widthPercent(context, 4),
                              vertical: ResponsiveUtils.heightPercent(context, 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '이메일을 입력해주세요';
                            }
                            if (!value.contains('@')) {
                              return '올바른 이메일 형식이 아닙니다';
                            }
                            return null;
                          },
                        ),
                      ),
                      
                      SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
                      
                      Container(
                        height: ResponsiveUtils.inputFieldHeight(context),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            hintText: '비밀번호',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              size: ResponsiveUtils.iconSize(context, IconSizeType.small),
                              color: Colors.grey.shade600,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                size: ResponsiveUtils.iconSize(context, IconSizeType.small),
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: ResponsiveUtils.widthPercent(context, 4),
                              vertical: ResponsiveUtils.heightPercent(context, 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '비밀번호를 입력해주세요';
                            }
                            if (value.length < 6) {
                              return '비밀번호는 6자 이상이어야 합니다';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),
                
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      '비밀번호를 잊으셨나요?',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
                
                SizedBox(
                  height: ResponsiveUtils.buttonHeight(context),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
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
                
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
                
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.widthPercent(context, 4),
                      ),
                      child: Text(
                        '또는',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
                
                SizedBox(
                  height: ResponsiveUtils.buttonHeight(context),
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.g_mobiledata,
                          size: ResponsiveUtils.iconSize(context, IconSizeType.medium),
                        ),
                        SizedBox(width: ResponsiveUtils.widthPercent(context, 2)),
                        Text(
                          'Google로 계속하기',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '아직 계정이 없으신가요?',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignupView(),
                          ),
                        );
                      },
                      child: Text(
                        '회원가입',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

