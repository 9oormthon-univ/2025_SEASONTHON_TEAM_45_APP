import '../../domain/entities/time_data_slot.dart';

class TimeSlotResponseModel extends TimeSlotResponse {
  const TimeSlotResponseModel({
    required super.date,
    required super.departmentName,
    required super.timeSlots,
    required super.availableCount,
    required super.totalSlots,
  });

  factory TimeSlotResponseModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotResponseModel(
      date: json['date'] ?? '',
      departmentName: json['departmentName'] ?? '',
      timeSlots: (json['timeSlots'] as List<dynamic>?)
          ?.map((e) => TimeSlotModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      availableCount: json['availableCount'] ?? 0,
      totalSlots: json['totalSlots'] ?? 0,
    );
  }
}

class TimeSlotModel extends TimeSlot {
  const TimeSlotModel({
    required super.time,
    required super.available,
    super.reason,
    super.bookedBy,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      time: json['time'] ?? '',
      available: json['available'] ?? false,
      reason: json['reason'],
      bookedBy: json['bookedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'available': available,
      'reason': reason,
      'bookedBy': bookedBy,
    };
  }
}