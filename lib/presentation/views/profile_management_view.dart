import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/gradient_background.dart';
import '../../data/auth_storage.dart';
import '../widgets/custom_back_button.dart';

class ProfileManagementView extends StatefulWidget {
  const ProfileManagementView({super.key});

  @override
  State<ProfileManagementView> createState() => _ProfileManagementViewState();
}

class _ProfileManagementViewState extends State<ProfileManagementView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  int _selectedYear = DateTime.now().year - 30;
  int _selectedMonth = 1;
  int _selectedDay = 1;
  String _selectedGender = '남성';
  
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  void _loadUserData() {
    final authStorage = AuthStorage();
    final currentUser = authStorage.getCurrentUser();
    
    if (currentUser != null) {
      _nameController.text = currentUser['name'] ?? '';
      _phoneController.text = currentUser['phone'] ?? '';
      _selectedYear = currentUser['year'] ?? DateTime.now().year - 30;
      _selectedMonth = currentUser['month'] ?? 1;
      _selectedDay = currentUser['day'] ?? 1;
      _selectedGender = currentUser['gender'] ?? '남성';
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.md)),
              child: Row(
                children: [
                  const CustomBackButton(),
                  Expanded(
                    child: Center(
                      child: Text(
                        '프로필 관리',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.md)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이름
                      Text(
                        '이름',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                      TextFormField(
                        controller: _nameController,
                        enabled: _isEditing,
                        decoration: InputDecoration(
                          hintText: '이름을 입력하세요',
                          filled: true,
                          fillColor: _isEditing ? Colors.white : AppColors.backgroundGray,
                          border: OutlineInputBorder(
                            borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                            borderSide: BorderSide(
                              color: AppColors.grayLight,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                            borderSide: BorderSide(
                              color: AppColors.grayLight,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                            borderSide: BorderSide(
                              color: AppColors.primaryGreen,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이름을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),
                      
                      // 생년월일
                      Text(
                        '생년월일',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                      Row(
                        children: [
                          // 년도
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUtils.spacing(context, SpacingSize.md),
                              ),
                              decoration: BoxDecoration(
                                color: _isEditing ? Colors.white : AppColors.backgroundGray,
                                borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                                border: Border.all(
                                  color: AppColors.grayLight,
                                  width: 1,
                                ),
                              ),
                              child: DropdownButton<int>(
                                value: _selectedYear,
                                isExpanded: true,
                                underline: const SizedBox(),
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: _isEditing ? AppColors.textPrimary : AppColors.grayMedium,
                                ),
                                onChanged: _isEditing
                                    ? (value) {
                                        setState(() {
                                          _selectedYear = value!;
                                        });
                                      }
                                    : null,
                                items: List.generate(
                                  100,
                                  (index) {
                                    final year = DateTime.now().year - index;
                                    return DropdownMenuItem(
                                      value: year,
                                      child: Text('${year}년'),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                          
                          // 월
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUtils.spacing(context, SpacingSize.md),
                              ),
                              decoration: BoxDecoration(
                                color: _isEditing ? Colors.white : AppColors.backgroundGray,
                                borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                                border: Border.all(
                                  color: AppColors.grayLight,
                                  width: 1,
                                ),
                              ),
                              child: DropdownButton<int>(
                                value: _selectedMonth,
                                isExpanded: true,
                                underline: const SizedBox(),
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: _isEditing ? AppColors.textPrimary : AppColors.grayMedium,
                                ),
                                onChanged: _isEditing
                                    ? (value) {
                                        setState(() {
                                          _selectedMonth = value!;
                                        });
                                      }
                                    : null,
                                items: List.generate(
                                  12,
                                  (index) {
                                    final month = index + 1;
                                    return DropdownMenuItem(
                                      value: month,
                                      child: Text('${month}월'),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                          
                          // 일
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUtils.spacing(context, SpacingSize.md),
                              ),
                              decoration: BoxDecoration(
                                color: _isEditing ? Colors.white : AppColors.backgroundGray,
                                borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                                border: Border.all(
                                  color: AppColors.grayLight,
                                  width: 1,
                                ),
                              ),
                              child: DropdownButton<int>(
                                value: _selectedDay,
                                isExpanded: true,
                                underline: const SizedBox(),
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: _isEditing ? AppColors.textPrimary : AppColors.grayMedium,
                                ),
                                onChanged: _isEditing
                                    ? (value) {
                                        setState(() {
                                          _selectedDay = value!;
                                        });
                                      }
                                    : null,
                                items: List.generate(
                                  31,
                                  (index) {
                                    final day = index + 1;
                                    return DropdownMenuItem(
                                      value: day,
                                      child: Text('${day}일'),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),
                      
                      // 성별
                      Text(
                        '성별',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _isEditing
                                  ? () {
                                      setState(() {
                                        _selectedGender = '남성';
                                      });
                                    }
                                  : null,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: ResponsiveUtils.spacing(context, SpacingSize.md),
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedGender == '남성'
                                      ? AppColors.primaryGreen
                                      : (_isEditing ? Colors.white : AppColors.backgroundGray),
                                  borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                                  border: Border.all(
                                    color: _selectedGender == '남성'
                                        ? AppColors.primaryGreen
                                        : AppColors.grayLight,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '남성',
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                                      fontWeight: FontWeight.w600,
                                      color: _selectedGender == '남성'
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                          Expanded(
                            child: GestureDetector(
                              onTap: _isEditing
                                  ? () {
                                      setState(() {
                                        _selectedGender = '여성';
                                      });
                                    }
                                  : null,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: ResponsiveUtils.spacing(context, SpacingSize.md),
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedGender == '여성'
                                      ? AppColors.primaryGreen
                                      : (_isEditing ? Colors.white : AppColors.backgroundGray),
                                  borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                                  border: Border.all(
                                    color: _selectedGender == '여성'
                                        ? AppColors.primaryGreen
                                        : AppColors.grayLight,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '여성',
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                                      fontWeight: FontWeight.w600,
                                      color: _selectedGender == '여성'
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),
                      
                      // 전화번호
                      Text(
                        '전화번호',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                      TextFormField(
                        controller: _phoneController,
                        enabled: false, // 전화번호는 수정 불가
                        decoration: InputDecoration(
                          hintText: '전화번호',
                          filled: true,
                          fillColor: AppColors.backgroundGray,
                          border: OutlineInputBorder(
                            borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                            borderSide: BorderSide(
                              color: AppColors.grayLight,
                              width: 1,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                            borderSide: BorderSide(
                              color: AppColors.grayLight,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // 버튼
            Padding(
              padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.md)),
              child: SizedBox(
                width: double.infinity,
                height: ResponsiveUtils.buttonHeight(context),
                child: ElevatedButton(
                  onPressed: () {
                    if (_isEditing) {
                      _saveProfile();
                    } else {
                      setState(() {
                        _isEditing = true;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isEditing ? '수정 완료' : '프로필 수정',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // 프로필 저장 로직
      final authStorage = AuthStorage();
      // 실제 저장 로직은 API 연동 시 구현
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('프로필이 수정되었습니다'),
        ),
      );
      
      setState(() {
        _isEditing = false;
      });
    }
  }
}