import 'package:equatable/equatable.dart';
import '../../../domain/entities/time_data_slot.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class TimeSlotsLoaded extends BookingState {
  final TimeSlotResponse timeSlotResponse;
  final String? selectedTime;
  final String selectedDepartment;
  final DateTime selectedDate;

  const TimeSlotsLoaded({
    required this.timeSlotResponse,
    this.selectedTime,
    required this.selectedDepartment,
    required this.selectedDate,
  });

  @override
  List<Object?> get props => [timeSlotResponse, selectedTime, selectedDepartment, selectedDate];

  TimeSlotsLoaded copyWith({
    TimeSlotResponse? timeSlotResponse,
    String? selectedTime,
    String? selectedDepartment,
    DateTime? selectedDate,
  }) {
    return TimeSlotsLoaded(
      timeSlotResponse: timeSlotResponse ?? this.timeSlotResponse,
      selectedTime: selectedTime,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class AppointmentCreated extends BookingState {
  final int appointmentId;

  const AppointmentCreated(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}

class DepartmentSelected extends BookingState {
  final String department;

  const DepartmentSelected(this.department);

  @override
  List<Object?> get props => [department];
}

class DateSelected extends BookingState {
  final DateTime date;
  final String department;

  const DateSelected({
    required this.date,
    required this.department,
  });

  @override
  List<Object?> get props => [date, department];
}