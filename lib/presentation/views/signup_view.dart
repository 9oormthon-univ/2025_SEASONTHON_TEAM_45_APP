import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/gradient_background.dart';
import '../../injection_container.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../widgets/progress_indicator_bar.dart';
import 'login_initial_view.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  int _currentStep = 1;
  
  // Step 1 - Name and Birth date
  final _nameController = TextEditingController();
  int? _selectedYear;
  int? _selectedMonth;
  int? _selectedDay;
  
  // Step 2 - Gender
  String? _selectedGender;
  
  // Step 3 - Phone number
  final _phoneController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  bool _isCodeSent = false;
  bool _isCodeVerified = false;
  String? _temporaryToken;
  
  // Step 4 - Password
  final _passwordController = TextEditingController();
  late AuthBloc _authBloc;
  bool _isPasswordValid = false;
  bool _hasMinLength = false;
  bool _hasLetter = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _verificationCodeController.dispose();
    _passwordController.dispose();
    _authBloc.close();
    super.dispose();
  }

  void _validatePassword(String value) {
    setState(() {
      _hasMinLength = value.length >= 8 && value.length <= 20;
      _hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
      _hasNumber = RegExp(r'[0-9]').hasMatch(value);
      _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
      _isPasswordValid = _hasMinLength && _hasLetter && _hasNumber && _hasSpecialChar;
    });
  }

  void _nextStep() {
    bool canProceed = false;
    
    switch (_currentStep) {
      case 1:
        canProceed = _nameController.text.isNotEmpty && 
                    _selectedYear != null && 
                    _selectedMonth != null && 
                    _selectedDay != null;
        break;
      case 2:
        canProceed = _selectedGender != null;
        break;
      case 3:
        canProceed = _phoneController.text.isNotEmpty && _phoneController.text.length >= 10 && _isCodeVerified;
        break;
      case 4:
        canProceed = _isPasswordValid;
        break;
    }
    
    if (canProceed) {
      // 키보드 닫기
      FocusScope.of(context).unfocus();
      
      if (_currentStep < 4) {
        setState(() {
          _currentStep++;
        });
      } else {
        // 회원가입 처리
        _handleSignup();
      }
    }
  }
  
  void _handleSignup() {
    // 생년월일 포맷팅 (YYYYMMDD)
    String birthDate = '${_selectedYear!.toString().padLeft(4, '0')}';
    birthDate += '${_selectedMonth!.toString().padLeft(2, '0')}';
    birthDate += '${_selectedDay!.toString().padLeft(2, '0')}';
    
    _authBloc.add(RegisterRequested(
      name: _nameController.text,
      gender: _selectedGender!,
      birthDate: birthDate,
      phoneNumber: _phoneController.text,
      password: _passwordController.text,
      temporaryToken: _temporaryToken,
    ));
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildBirthDateStep();
      case 2:
        return _buildGenderStep();
      case 3:
        return _buildPhoneNumberStep();
      case 4:
        return _buildPasswordStep();
      default:
        return const SizedBox();
    }
  }
  
  Widget _buildBirthDateStep() {
    final currentYear = DateTime.now().year;
    final years = List.generate(100, (index) => currentYear - index);
    final months = List.generate(12, (index) => index + 1);
    final days = List.generate(31, (index) => index + 1);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepDescription('환영합니다!\n이름과 생년월일을 입력해 주세요.'),
        
        // Name input field
        Text(
          '이름',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
        Container(
          height: ResponsiveUtils.inputFieldHeight(context),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grayLight),
            borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
          ),
          child: Center(
            child: TextField(
              controller: _nameController,
              keyboardType: TextInputType.text,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: '홍길동',
                hintStyle: TextStyle(
                  color: AppColors.textHint,
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.widthPercent(context, 4),
                  vertical: 0,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
        
        Text(
          '생년월일',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
        
        Row(
          children: [
            Expanded(
              child: Container(
                height: ResponsiveUtils.inputFieldHeight(context),
                padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.widthPercent(context, 3)),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grayLight),
                  borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
                ),
                child: DropdownButton<int>(
                  value: _selectedYear,
                  hint: Text('년', style: TextStyle(color: AppColors.textHint)),
                  isExpanded: true,
                  underline: const SizedBox(),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value;
                    });
                  },
                  items: years.map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text('$year년'),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.widthPercent(context, 2)),
            Expanded(
              child: Container(
                height: ResponsiveUtils.inputFieldHeight(context),
                padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.widthPercent(context, 3)),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grayLight),
                  borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
                ),
                child: DropdownButton<int>(
                  value: _selectedMonth,
                  hint: Text('월', style: TextStyle(color: AppColors.textHint)),
                  isExpanded: true,
                  underline: const SizedBox(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMonth = value;
                    });
                  },
                  items: months.map((month) {
                    return DropdownMenuItem(
                      value: month,
                      child: Text('$month월'),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.widthPercent(context, 2)),
            Expanded(
              child: Container(
                height: ResponsiveUtils.inputFieldHeight(context),
                padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.widthPercent(context, 3)),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grayLight),
                  borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
                ),
                child: DropdownButton<int>(
                  value: _selectedDay,
                  hint: Text('일', style: TextStyle(color: AppColors.textHint)),
                  isExpanded: true,
                  underline: const SizedBox(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDay = value;
                    });
                  },
                  items: days.map((day) {
                    return DropdownMenuItem(
                      value: day,
                      child: Text('$day일'),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildGenderStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepDescription('안녕하세요!\n성별을 선택해 주세요.'),
        
        Text(
          '성별',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
        
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = '남성';
                  });
                },
                child: Container(
                  height: ResponsiveUtils.buttonHeight(context),
                  decoration: BoxDecoration(
                    color: _selectedGender == '남성' ? AppColors.primaryGreen : Colors.white,
                    border: Border.all(
                      color: _selectedGender == '남성' ? AppColors.primaryGreen : AppColors.grayLight,
                    ),
                    borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
                  ),
                  child: Center(
                    child: Text(
                      '남성',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                        fontWeight: FontWeight.w500,
                        color: _selectedGender == '남성' ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.widthPercent(context, 4)),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = '여성';
                  });
                },
                child: Container(
                  height: ResponsiveUtils.buttonHeight(context),
                  decoration: BoxDecoration(
                    color: _selectedGender == '여성' ? AppColors.primaryGreen : Colors.white,
                    border: Border.all(
                      color: _selectedGender == '여성' ? AppColors.primaryGreen : AppColors.grayLight,
                    ),
                    borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
                  ),
                  child: Center(
                    child: Text(
                      '여성',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                        fontWeight: FontWeight.w500,
                        color: _selectedGender == '여성' ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // Show previous info
        if (_nameController.text.isNotEmpty) ...[
          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
          Text(
            '이름',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ResponsiveUtils.widthPercent(context, 4)),
            decoration: BoxDecoration(
              color: AppColors.backgroundGray,
              borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
            ),
            child: Text(
              _nameController.text,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
        if (_selectedYear != null && _selectedMonth != null && _selectedDay != null) ...[
          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
          Text(
            '생년월일',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ResponsiveUtils.widthPercent(context, 4)),
            decoration: BoxDecoration(
              color: AppColors.backgroundGray,
              borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
            ),
            child: Text(
              '$_selectedYear년 $_selectedMonth월 $_selectedDay일',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildPhoneNumberStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepDescription('전화번호를 입력한 후\n인증번호를 전송해 주세요.'),
        
        Text(
          '전화번호',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
        
        Row(
          children: [
            Expanded(
              child: Container(
                height: ResponsiveUtils.inputFieldHeight(context),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grayLight),
                  borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
                ),
                child: Center(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    readOnly: _isCodeSent,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: '01012341234',
                      hintStyle: TextStyle(
                        color: AppColors.textHint,
                        fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.widthPercent(context, 4),
                        vertical: 0,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.widthPercent(context, 2)),
            SizedBox(
              height: ResponsiveUtils.inputFieldHeight(context),
              child: ElevatedButton(
                onPressed: (!_isCodeSent && _phoneController.text.length >= 10) ? () {
                  _authBloc.add(SendSmsCodeRequested(phoneNumber: _phoneController.text));
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isCodeSent ? '전송됨' : '인증번호 전송',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // 인증코드 입력 필드 (인증번호 전송 후 표시)
        if (_isCodeSent) ...[
          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
          Text(
            '인증번호',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: ResponsiveUtils.inputFieldHeight(context),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isCodeVerified ? AppColors.primaryGreen : AppColors.grayLight,
                    ),
                    borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
                  ),
                  child: Center(
                    child: TextField(
                      controller: _verificationCodeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      readOnly: _isCodeVerified,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: '6자리 인증번호',
                        hintStyle: TextStyle(
                          color: AppColors.textHint,
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.widthPercent(context, 4),
                          vertical: 0,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.widthPercent(context, 2)),
              SizedBox(
                height: ResponsiveUtils.inputFieldHeight(context),
                child: ElevatedButton(
                  onPressed: (!_isCodeVerified && _verificationCodeController.text.length == 6) ? () {
                    _authBloc.add(VerifySmsCodeRequested(
                      phoneNumber: _phoneController.text,
                      code: _verificationCodeController.text,
                    ));
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCodeVerified ? AppColors.success : AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isCodeVerified ? '인증완료' : '인증하기',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isCodeVerified) ...[
            SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
            Text(
              '✓ 휴대폰 인증이 완료되었습니다.',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
        
        // Show previous info
        ..._buildPreviousStepInfo(),
      ],
    );
  }
  
  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepDescription('비밀번호를 입력해 주세요.\n영어, 대소문자로 8자 이상입니다.'),
        
        Text(
          '비밀번호',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
        
        Container(
          height: ResponsiveUtils.inputFieldHeight(context),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grayLight),
            borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
          ),
          child: Center(
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              keyboardType: TextInputType.text,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: TextStyle(
                  color: AppColors.textHint,
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.widthPercent(context, 4),
                  vertical: 0,
                ),
              ),
              onChanged: _validatePassword,
            ),
          ),
        ),
        
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
        
        // Password validation checklist
        Row(
          children: [
            Icon(
              _hasMinLength ? Icons.check : Icons.close,
              size: ResponsiveUtils.iconSize(context, IconSizeType.small) * 0.8,
              color: _hasMinLength ? AppColors.primaryGreen : AppColors.grayMedium,
            ),
            SizedBox(width: ResponsiveUtils.widthPercent(context, 2)),
            Text(
              '8-20자 이내',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                color: _hasMinLength ? AppColors.primaryGreen : AppColors.grayMedium,
              ),
            ),
            SizedBox(width: ResponsiveUtils.widthPercent(context, 4)),
            Icon(
              _hasLetter && _hasNumber && _hasSpecialChar ? Icons.check : Icons.close,
              size: ResponsiveUtils.iconSize(context, IconSizeType.small) * 0.8,
              color: _hasLetter && _hasNumber && _hasSpecialChar ? AppColors.primaryGreen : AppColors.grayMedium,
            ),
            SizedBox(width: ResponsiveUtils.widthPercent(context, 2)),
            Text(
              '영문 대소문자, 숫자 포함',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                color: _hasLetter && _hasNumber && _hasSpecialChar ? AppColors.primaryGreen : AppColors.grayMedium,
              ),
            ),
          ],
        ),
        
        // Show previous info
        ..._buildPreviousStepInfo(),
      ],
    );
  }

  // 공통 위젯: 스텝 설명 텍스트
  Widget _buildStepDescription(String text) {
    return Column(
      children: [
        Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
      ],
    );
  }

  // 공통 위젯: 정보 표시 필드
  Widget _buildInfoDisplay(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(ResponsiveUtils.widthPercent(context, 4)),
          decoration: BoxDecoration(
            color: AppColors.backgroundGray,
            borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // 공통 위젯: 성별 표시
  Widget _buildGenderDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
        Text(
          '성별',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
        Row(
          children: [
            Expanded(
              child: Container(
                height: ResponsiveUtils.inputFieldHeight(context),
                decoration: BoxDecoration(
                  color: _selectedGender == '남성' ? AppColors.primaryGreen : Colors.white,
                  border: Border.all(
                    color: _selectedGender == '남성' ? AppColors.primaryGreen : AppColors.grayLight,
                  ),
                  borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
                ),
                child: Center(
                  child: Text(
                    '남자',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                      fontWeight: FontWeight.w500,
                      color: _selectedGender == '남성' ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing(context, SpacingSize.md)),
            Expanded(
              child: Container(
                height: ResponsiveUtils.inputFieldHeight(context),
                decoration: BoxDecoration(
                  color: _selectedGender == '여성' ? AppColors.primaryGreen : Colors.white,
                  border: Border.all(
                    color: _selectedGender == '여성' ? AppColors.primaryGreen : AppColors.grayLight,
                  ),
                  borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
                ),
                child: Center(
                  child: Text(
                    '여자',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                      fontWeight: FontWeight.w500,
                      color: _selectedGender == '여성' ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 공통 위젯: 이전 단계 정보 표시
  List<Widget> _buildPreviousStepInfo() {
    final widgets = <Widget>[];
    
    // Step 3, 4에서 성별 표시
    if (_currentStep >= 3 && _selectedGender != null) {
      widgets.add(_buildGenderDisplay());
    }
    
    // Step 3, 4에서 이름 표시
    if (_currentStep >= 3 && _nameController.text.isNotEmpty) {
      widgets.add(_buildInfoDisplay('이름', _nameController.text));
    }
    
    // Step 3, 4에서 생년월일 표시
    if (_currentStep >= 3 && _selectedYear != null && _selectedMonth != null && _selectedDay != null) {
      widgets.add(_buildInfoDisplay('생년월일', '$_selectedYear년 $_selectedMonth월 $_selectedDay일'));
    }
    
    // Step 4에서 전화번호 표시
    if (_currentStep == 4 && _phoneController.text.isNotEmpty) {
      widgets.add(_buildInfoDisplay('전화번호', _phoneController.text));
    }
    
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _authBloc,
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // 회원가입 성공 - 로그인 화면으로 이동
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginInitialView(),
              ),
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is SmsCodeSent) {
            setState(() {
              _isCodeSent = true;
            });
          } else if (state is SmsCodeVerified) {
            setState(() {
              _isCodeVerified = true;
              _temporaryToken = state.temporaryToken;
            });
          } else if (state is SmsCodeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          
          return GradientScaffold(
            body: Column(
              children: [
            // Header with progress bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.horizontalPadding(context),
                vertical: ResponsiveUtils.verticalPadding(context),
              ),
              child: ProgressIndicatorBar(currentStep: _currentStep),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: ResponsiveUtils.defaultPadding(context),
                  child: _buildStepContent(),
                ),
              ),
            ),
            
            // Bottom section with button
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.widthPercent(context, 5)),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: ResponsiveUtils.buttonHeight(context),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading && _currentStep == 4
                          ? SizedBox(
                              width: ResponsiveUtils.iconSize(context, IconSizeType.small),
                              height: ResponsiveUtils.iconSize(context, IconSizeType.small),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                        '확인',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
        },
      ),
    );
  }
}