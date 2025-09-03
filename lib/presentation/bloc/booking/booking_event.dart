import 'package:equatable/equatable.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class LoadAvailableTimeSlotsEvent extends BookingEvent {
  final int hospitalId;
  final String departmentName;
  final String date;

  const LoadAvailableTimeSlotsEvent({
    required this.hospitalId,
    required this.departmentName,
    required this.date,
  });

  @override
  List<Object?> get props => [hospitalId, departmentName, date];
}

class SelectTimeSlotEvent extends BookingEvent {
  final String time;

  const SelectTimeSlotEvent(this.time);

  @override
  List<Object?> get props => [time];
}

class CreateAppointmentEvent extends BookingEvent {
  final int memberId;
  final int hospitalId;
  final String departmentName;
  final String appointmentDate;
  final String appointmentTime;

  const CreateAppointmentEvent({
    required this.memberId,
    required this.hospitalId,
    required this.departmentName,
    required this.appointmentDate,
    required this.appointmentTime,
  });

  @override
  List<Object?> get props => [memberId, hospitalId, departmentName, appointmentDate, appointmentTime];
}

class SelectDepartmentEvent extends BookingEvent {
  final String department;

  const SelectDepartmentEvent(this.department);

  @override
  List<Object?> get props => [department];
}

class SelectDateEvent extends BookingEvent {
  final DateTime date;

  const SelectDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}