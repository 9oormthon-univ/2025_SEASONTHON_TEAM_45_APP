import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
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
  final List<String> departments = [
    '내과',
    '외과',
    '정형외과',
    '피부과',
    '이비인후과'
  ];

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
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            '일반 예약',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocConsumer<BookingBloc, BookingState>(
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepCard(
                    step: '1',
                    title: '진료과 선택',
                    child: _buildDepartmentSelection(context),
                  ),
                  const SizedBox(height: 20),
                  _buildStepCard(
                    step: '2',
                    title: '날짜 선택',
                    enabled: selectedDepartment != null,
                    child: _buildDateSelection(context),
                  ),
                  const SizedBox(height: 20),
                  _buildStepCard(
                    step: '3',
                    title: '시간 선택',
                    enabled: selectedDepartment != null && selectedDate != null,
                    child: _buildTimeSelection(context, state),
                  ),
                  const SizedBox(height: 30),
                  _buildConfirmButton(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String step,
    required String title,
    required Widget child,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: enabled ? AppColors.primary : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      step,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: enabled ? AppColors.textPrimary : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (enabled) child,
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentSelection(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: departments.map((dept) {
        final isSelected = selectedDepartment == dept;
        return InkWell(
          onTap: () {
            setState(() {
              selectedDepartment = dept;
              selectedTime = null;
            });
            context.read<BookingBloc>().add(SelectDepartmentEvent(dept));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
              ),
            ),
            child: Text(
              dept,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateSelection(BuildContext context) {
    if (selectedDepartment == null) return const SizedBox.shrink();
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('yyyy년 MM월 dd일').format(selectedDate),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.calendar_today, size: 20),
              label: const Text('날짜 변경'),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  setState(() {
                    selectedDate = date;
                    selectedTime = null;
                  });
                  context.read<BookingBloc>().add(SelectDateEvent(date));
                  context.read<BookingBloc>().add(
                    LoadAvailableTimeSlotsEvent(
                      hospitalId: 1,
                      departmentName: selectedDepartment!,
                      date: DateFormat('yyyy-MM-dd').format(date),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSelection(BuildContext context, BookingState state) {
    if (selectedDepartment == null) return const SizedBox.shrink();
    
    if (state is BookingLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    
    if (state is TimeSlotsLoaded) {
      if (state.timeSlotResponse.timeSlots.isEmpty) {
        return const Center(
          child: Text(
            '예약 가능한 시간이 없습니다',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }
      
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: state.timeSlotResponse.timeSlots.length,
        itemBuilder: (context, index) {
          final slot = state.timeSlotResponse.timeSlots[index];
          final isSelected = selectedTime == slot.time;
          final isAvailable = slot.available;
          
          return InkWell(
            onTap: isAvailable ? () {
              setState(() {
                selectedTime = slot.time;
              });
              context.read<BookingBloc>().add(SelectTimeSlotEvent(slot.time));
            } : null,
            child: Container(
              decoration: BoxDecoration(
                color: isSelected 
                  ? AppColors.primary 
                  : (isAvailable ? AppColors.background : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected 
                    ? AppColors.primary 
                    : (isAvailable ? Colors.grey.shade300 : Colors.transparent),
                ),
              ),
              child: Center(
                child: Text(
                  slot.time,
                  style: TextStyle(
                    color: isSelected 
                      ? Colors.white 
                      : (isAvailable ? AppColors.textPrimary : Colors.grey),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
    
    return Center(
      child: TextButton(
        onPressed: selectedDepartment != null ? () {
          context.read<BookingBloc>().add(
            LoadAvailableTimeSlotsEvent(
              hospitalId: 1,
              departmentName: selectedDepartment!,
              date: DateFormat('yyyy-MM-dd').format(selectedDate),
            ),
          );
        } : null,
        child: const Text('시간대 조회'),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, BookingState state) {
    final isEnabled = selectedDepartment != null && 
                      selectedDate != null && 
                      selectedTime != null &&
                      memberId != null;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isEnabled ? () {
          context.read<BookingBloc>().add(
            CreateAppointmentEvent(
              memberId: memberId!,
              hospitalId: 1,
              departmentName: selectedDepartment!,
              appointmentDate: DateFormat('yyyy-MM-dd').format(selectedDate),
              appointmentTime: selectedTime!,
            ),
          );
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: state is BookingLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
            '예약 확인',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
      ),
    );
  }
}