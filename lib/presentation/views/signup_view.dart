import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  bool _agreeToPrivacy = false;
  bool _agreeToMarketing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms || !_agreeToPrivacy) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('필수 약관에 동의해주세요'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      setState(() {
        _isLoading = true;
      });
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: ResponsiveUtils.iconSize(context, IconSizeType.small),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '회원가입',
          style: TextStyle(
            color: Colors.black,
            fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: ResponsiveUtils.defaultPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),
                
                Text(
                  'CareFreePass에 오신 것을 환영합니다',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade800,
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                
                Text(
                  '간편하게 회원가입하고 서비스를 이용해보세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
                
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이름',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
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
                          controller: _nameController,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            hintText: '실명을 입력해주세요',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: Icon(
                              Icons.person_outline,
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
                              return '이름을 입력해주세요';
                            }
                            return null;
                          },
                        ),
                      ),
                      
                      SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
                      
                      Text(
                        '이메일',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
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
                            hintText: 'example@email.com',
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
                      
                      Text(
                        '휴대폰 번호',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
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
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            hintText: '010-0000-0000',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: Icon(
                              Icons.phone_outlined,
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
                              return '휴대폰 번호를 입력해주세요';
                            }
                            return null;
                          },
                        ),
                      ),
                      
                      SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
                      
                      Text(
                        '비밀번호',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
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
                            hintText: '6자 이상 입력해주세요',
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
                      
                      SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
                      
                      Text(
                        '비밀번호 확인',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
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
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            hintText: '비밀번호를 다시 입력해주세요',
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
                                _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                size: ResponsiveUtils.iconSize(context, IconSizeType.small),
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
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
                              return '비밀번호를 다시 입력해주세요';
                            }
                            if (value != _passwordController.text) {
                              return '비밀번호가 일치하지 않습니다';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
                
                Container(
                  padding: EdgeInsets.all(ResponsiveUtils.widthPercent(context, 4)),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms && _agreeToPrivacy && _agreeToMarketing,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
                                _agreeToPrivacy = value ?? false;
                                _agreeToMarketing = value ?? false;
                              });
                            },
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          Text(
                            '전체 동의',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey.shade300),
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
                              });
                            },
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          Text(
                            '[필수] 이용약관 동의',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: ResponsiveUtils.iconSize(context, IconSizeType.small) * 0.7,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToPrivacy,
                            onChanged: (value) {
                              setState(() {
                                _agreeToPrivacy = value ?? false;
                              });
                            },
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          Text(
                            '[필수] 개인정보 처리방침 동의',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: ResponsiveUtils.iconSize(context, IconSizeType.small) * 0.7,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToMarketing,
                            onChanged: (value) {
                              setState(() {
                                _agreeToMarketing = value ?? false;
                              });
                            },
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          Text(
                            '[선택] 마케팅 정보 수신 동의',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: ResponsiveUtils.iconSize(context, IconSizeType.small) * 0.7,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
                
                SizedBox(
                  height: ResponsiveUtils.buttonHeight(context),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
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
                            '회원가입',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}