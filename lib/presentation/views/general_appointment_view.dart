import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/gradient_background.dart';
import '../widgets/custom_back_button.dart';
import '../../injection_container.dart';
import '../bloc/booking/booking_bloc.dart';
import '../bloc/booking/booking_event.dart';
import '../bloc/booking/booking_state.dart';
import 'appointment_completion_view.dart';

class GeneralAppointmentView extends StatefulWidget {
  const GeneralAppointmentView({super.key});

  @override
  State<GeneralAppointmentView> createState() => _GeneralAppointmentViewState();
}

class _GeneralAppointmentViewState extends State<GeneralAppointmentView> {
  // ======================== 하드코딩 진료과 목록 ========================
  final List<String> departments = [
    '내과',
    '외과',
    '정형외과',
    '피부과',
    '이비인후과'
  ];
  // ====================================================================

  String? selectedDepartment;
  DateTime selectedDate = DateTime.now();
  String? selectedTime;
  int? memberId;

  @override
  void initState() {
    super.initState();
    _loadMemberId();
  }

  Future<void> _loadMemberId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      memberId = prefs.getInt('member_id');
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<BookingBloc>(),
      child: GradientScaffold(
        body: SafeArea(
          child: Column(
            children: [
              // ======================== 상단 헤더 ========================
              Padding(
                padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.md)),
                child: Row(
                  children: [
                    const CustomBackButton(),
                    Expanded(
                      child: Center(
                        child: Text(
                          '일반 예약',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // 균형 맞추기용
                  ],
                ),
              ),
              // ==========================================================

              // ======================== 메인 컨텐츠 ========================
              Expanded(
                child: BlocConsumer<BookingBloc, BookingState>(
                  listener: (context, state) {
                    if (state is AppointmentCreated) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => AppointmentCompletionView(
                            appointmentId: state.appointmentId,
                            department: selectedDepartment!,
                            date: selectedDate,
                            time: selectedTime!,
                          ),
                        ),
                      );
                    } else if (state is BookingError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return SingleChildScrollView(
                      padding: ResponsiveUtils.defaultPadding(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ============ STEP 1: 진료과 선택 ============
                          _buildDepartmentSection(context),
                          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),

                          // ============ STEP 2: 날짜 선택 ============
                          if (selectedDepartment != null)
                            _buildDateSection(context),
                          if (selectedDepartment != null)
                            SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),

                          // ============ STEP 3: 시간 선택 ============
                          if (selectedDepartment != null)
                            _buildTimeSection(context, state),
                          if (selectedDepartment != null)
                            SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),

                          // ============ 예약 확인 버튼 ============
                          if (selectedDepartment != null && selectedTime != null)
                            _buildConfirmButton(context, state),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // ===========================================================
            ],
          ),
        ),
      ),
    );
  }

  // ======================== 진료과 선택 섹션 ========================
  Widget _buildDepartmentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목: "진료과 선택"
        Text(
          '진료과 선택',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
        
        // 진료과 버튼들 (Wrap으로 배치)
        Wrap(
          spacing: ResponsiveUtils.spacing(context, SpacingSize.sm), // 가로 간격
          runSpacing: ResponsiveUtils.spacing(context, SpacingSize.sm), // 세로 간격
          children: departments.map((dept) {
            final isSelected = selectedDepartment == dept;
            return InkWell(
              onTap: () {
                setState(() {
                  selectedDepartment = dept;
                  selectedTime = null; // 진료과 변경시 시간 초기화
                });
                context.read<BookingBloc>().add(SelectDepartmentEvent(dept));
              },
              borderRadius: BorderRadius.circular(100), // Pill shape
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.spacing(context, SpacingSize.md),
                  vertical: ResponsiveUtils.spacing(context, SpacingSize.sm),
                ),
                decoration: BoxDecoration(
                  // 선택됨: 초록색 배경 / 미선택: 흰색 배경 + 회색 테두리
                  color: isSelected ? AppColors.primaryGreen : Colors.white,
                  borderRadius: BorderRadius.circular(100), // Pill shape
                  border: Border.all(
                    color: isSelected ? AppColors.primaryGreen : AppColors.grayLight,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  dept,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    // 선택됨: 흰색 글자 / 미선택: 회색 글자
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  // ================================================================

  // ======================== 날짜 선택 섹션 ========================
  Widget _buildDateSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목: "날짜 선택"
        Text(
          '날짜 선택',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
        
        // 인라인 캘린더
        _buildInlineCalendar(context),
      ],
    );
  }

  // 인라인 캘린더 위젯
  Widget _buildInlineCalendar(BuildContext context) {
    // 현재 표시할 월의 첫날 계산
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    
    // 캘린더에 표시할 첫 날 (이전 달의 일요일부터)
    final firstDayToShow = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday % 7),
    );
    
    // 6주 * 7일 = 42일 표시
    final daysToShow = 35;
    
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.md)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
        border: Border.all(
          color: AppColors.grayLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 월 네비게이션
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: AppColors.textSecondary,
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    selectedDate = DateTime(
                      selectedDate.year,
                      selectedDate.month - 1,
                      1,
                    );
                  });
                },
              ),
              SizedBox(width: ResponsiveUtils.spacing(context, SpacingSize.lg)),
              Text(
                '${selectedDate.year}년 ${selectedDate.month}월',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing(context, SpacingSize.lg)),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    selectedDate = DateTime(
                      selectedDate.year,
                      selectedDate.month + 1,
                      1,
                    );
                  });
                },
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
          
          // 요일 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['일', '월', '화', '수', '목', '금', '토']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
          
          // 날짜 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 0,
              mainAxisSpacing: ResponsiveUtils.spacing(context, SpacingSize.xs),
            ),
            itemCount: daysToShow,
            itemBuilder: (context, index) {
              final date = firstDayToShow.add(Duration(days: index));
              final isCurrentMonth = date.month == selectedDate.month;
              final isSelected = date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;
              final isToday = date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;
              final isPast = date.isBefore(DateTime.now().subtract(Duration(days: 1)));
              
              return InkWell(
                onTap: !isPast && isCurrentMonth ? () {
                  setState(() {
                    selectedDate = date;
                    selectedTime = null; // 날짜 변경시 시간 초기화
                  });
                  context.read<BookingBloc>().add(SelectDateEvent(date));
                  context.read<BookingBloc>().add(
                    LoadAvailableTimeSlotsEvent(
                      hospitalId: 1, // 하드코딩된 병원 ID
                      departmentName: selectedDepartment!,
                      date: DateFormat('yyyy-MM-dd').format(date),
                    ),
                  );
                } : null,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  margin: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.xs)),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                        fontWeight: isSelected ? FontWeight.w600 : 
                                   (isToday ? FontWeight.w600 : FontWeight.w400),
                        color: isSelected ? Colors.white :
                               (!isCurrentMonth || isPast) ? AppColors.grayLight :
                               AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  // ================================================================

  // ======================== 시간 선택 섹션 ========================
  Widget _buildTimeSection(BuildContext context, BookingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목: "시간 선택"
        Text(
          '시간 선택',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
        
        // 시간 선택 내용
        if (state is BookingLoading)
          Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryGreen,
            ),
          )
        else if (state is TimeSlotsLoaded)
          _buildTimeSlots(context, state)
        else
          Center(
            child: Text(
              '날짜를 선택하면 예약 가능한 시간이 표시됩니다',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  // 시간대별 그룹화된 시간 표시
  Widget _buildTimeSlots(BuildContext context, TimeSlotsLoaded state) {
    if (state.timeSlotResponse.timeSlots.isEmpty) {
      return Center(
        child: Text(
          '예약 가능한 시간이 없습니다',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    // 오전/오후 시간 분리
    final morningSlots = state.timeSlotResponse.timeSlots.where((slot) {
      final hour = int.parse(slot.time.substring(0, 2));
      return hour < 12;
    }).toList();
    
    final afternoonSlots = state.timeSlotResponse.timeSlots.where((slot) {
      final hour = int.parse(slot.time.substring(0, 2));
      return hour >= 12;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 오전 시간대
        if (morningSlots.isNotEmpty) ...[
          Text(
            '오전',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
          _buildTimeGrid(context, morningSlots),
          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),
        ],
        
        // 오후 시간대
        if (afternoonSlots.isNotEmpty) ...[
          Text(
            '오후',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
          _buildTimeGrid(context, afternoonSlots),
        ],
      ],
    );
  }

  // 시간 그리드 표시 (4개씩 가로 배치)
  Widget _buildTimeGrid(BuildContext context, List<dynamic> slots) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4개씩 가로 배치
        childAspectRatio: 2.2, // 버튼 비율 조정
        crossAxisSpacing: ResponsiveUtils.spacing(context, SpacingSize.xs),
        mainAxisSpacing: ResponsiveUtils.spacing(context, SpacingSize.xs),
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected = selectedTime == slot.time;
        final isAvailable = slot.available;

        return InkWell(
          onTap: isAvailable ? () {
            setState(() {
              selectedTime = slot.time;
            });
            context.read<BookingBloc>().add(SelectTimeSlotEvent(slot.time));
          } : null,
          borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected 
                ? AppColors.primaryGreen
                : (isAvailable ? Colors.white : AppColors.surfaceLight),
              borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
              border: Border.all(
                color: isSelected
                  ? AppColors.primaryGreen
                  : (isAvailable ? AppColors.grayLight : AppColors.grayLight.withValues(alpha: 0.5)),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                slot.time.substring(0, 5), // HH:mm 형식으로 표시
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected 
                    ? Colors.white
                    : (isAvailable ? AppColors.textSecondary : AppColors.grayLight),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  // ================================================================

  // ======================== 예약 확인 버튼 ========================
  Widget _buildConfirmButton(BuildContext context, BookingState state) {
    final isEnabled = selectedDepartment != null && 
                      selectedTime != null &&
                      memberId != null;

    return SizedBox(
      width: double.infinity,
      height: ResponsiveUtils.buttonHeight(context),
      child: ElevatedButton(
        onPressed: isEnabled && state is! BookingLoading ? () {
          context.read<BookingBloc>().add(
            CreateAppointmentEvent(
              memberId: memberId!,
              hospitalId: 1, // 하드코딩된 병원 ID
              departmentName: selectedDepartment!,
              appointmentDate: DateFormat('yyyy-MM-dd').format(selectedDate),
              appointmentTime: selectedTime!,
            ),
          );
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          disabledBackgroundColor: AppColors.grayLight,
          shape: RoundedRectangleBorder(
            borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
          ),
          elevation: 0,
        ),
        child: state is BookingLoading 
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              '예약 확인',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
      ),
    );
  }
  // ================================================================
}