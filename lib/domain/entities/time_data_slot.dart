import 'package:equatable/equatable.dart';

class TimeSlotResponse extends Equatable {
  final String date;
  final String departmentName;
  final List<TimeSlot> timeSlots;
  final int availableCount;
  final int totalSlots;

  const TimeSlotResponse({
    required this.date,
    required this.departmentName,
    required this.timeSlots,
    required this.availableCount,
    required this.totalSlots,
  });

  @override
  List<Object?> get props => [date, departmentName, timeSlots, availableCount, totalSlots];
}

class TimeSlot extends Equatable {
  final String time;
  final bool available;
  final String? reason;
  final String? bookedBy;

  const TimeSlot({
    required this.time,
    required this.available,
    this.reason,
    this.bookedBy,
  });

  @override
  List<Object?> get props => [time, available, reason, bookedBy];
}