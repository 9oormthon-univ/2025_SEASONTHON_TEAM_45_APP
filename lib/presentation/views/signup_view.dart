import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../data/auth_storage.dart';
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
  
  // Step 4 - Password
  final _passwordController = TextEditingController();
  bool _isPasswordValid = false;
  bool _hasMinLength = false;
  bool _hasLetter = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
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
        canProceed = _phoneController.text.isNotEmpty && _phoneController.text.length >= 10;
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
        // 회원가입 정보 저장
        AuthStorage().register(
          name: _nameController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
          year: _selectedYear!,
          month: _selectedMonth!,
          day: _selectedDay!,
          gender: _selectedGender!,
        );
        
        // 로그인 화면으로 이동
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginInitialView(),
          ),
          (route) => false,
        );
        
        // 회원가입 완료 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원가입이 완료되었습니다. 로그인해주세요.'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    }
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
        Text(
          '처음 오셨군요!',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
        Text(
          '이름과 생년월일을 입력해 주세요.',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
        
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
              ),
            ),
            onChanged: (_) => setState(() {}),
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
        Text(
          '처음 오셨군요!',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
        Text(
          '성별을 입력해 주세요.',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
        
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
                    _selectedGender = '남자';
                  });
                },
                child: Container(
                  height: ResponsiveUtils.buttonHeight(context),
                  decoration: BoxDecoration(
                    color: _selectedGender == '남자' ? AppColors.primaryGreen : Colors.white,
                    border: Border.all(
                      color: _selectedGender == '남자' ? AppColors.primaryGreen : AppColors.grayLight,
                    ),
                    borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
                  ),
                  child: Center(
                    child: Text(
                      '남자',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                        fontWeight: FontWeight.w500,
                        color: _selectedGender == '남자' ? Colors.white : AppColors.textSecondary,
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
                    _selectedGender = '여자';
                  });
                },
                child: Container(
                  height: ResponsiveUtils.buttonHeight(context),
                  decoration: BoxDecoration(
                    color: _selectedGender == '여자' ? AppColors.primaryGreen : Colors.white,
                    border: Border.all(
                      color: _selectedGender == '여자' ? AppColors.primaryGreen : AppColors.grayLight,
                    ),
                    borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
                  ),
                  child: Center(
                    child: Text(
                      '여자',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                        fontWeight: FontWeight.w500,
                        color: _selectedGender == '여자' ? Colors.white : AppColors.textSecondary,
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
        Text(
          '본인 휴대번호로',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
        Text(
          '회원가입을 진행해 주세요.',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
        
        Text(
          '전화번호',
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
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        
        // Show previous info (순서: 성별 - 이름 - 생년월일)
        if (_selectedGender != null) ...[
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
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ResponsiveUtils.widthPercent(context, 4)),
            decoration: BoxDecoration(
              color: AppColors.backgroundGray,
              borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
            ),
            child: Text(
              _selectedGender!,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
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
  
  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '비밀번호를 입력해 주세요.',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
        Text(
          '영어, 대소문자로 8자 이상입니다.',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
        
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
              ),
            ),
            onChanged: _validatePassword,
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
        
        // Show previous info (순서: 전화번호 - 성별 - 이름 - 생년월일)
        if (_phoneController.text.isNotEmpty) ...[
          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
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
            width: double.infinity,
            padding: EdgeInsets.all(ResponsiveUtils.widthPercent(context, 4)),
            decoration: BoxDecoration(
              color: AppColors.backgroundGray,
              borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
            ),
            child: Text(
              _phoneController.text,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
        if (_selectedGender != null) ...[
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
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ResponsiveUtils.widthPercent(context, 4)),
            decoration: BoxDecoration(
              color: AppColors.backgroundGray,
              borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
            ),
            child: Text(
              _selectedGender!,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
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
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
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
      ),
    );
  }
}