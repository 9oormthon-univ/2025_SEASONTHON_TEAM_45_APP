import 'package:equatable/equatable.dart';

class Reservation extends Equatable {
  final String id;
  final String status; // confirmed, waiting, called, completed, cancelled
  final String date;
  final String time;
  final String department;
  final String hospitalName;
  final String? doctorName;
  final int? callNumber;
  final int? waitingNumber;
  final int? estimatedWaitTime;
  final String? message;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Reservation({
    required this.id,
    required this.status,
    required this.date,
    required this.time,
    required this.department,
    required this.hospitalName,
    this.doctorName,
    this.callNumber,
    this.waitingNumber,
    this.estimatedWaitTime,
    this.message,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        status,
        date,
        time,
        department,
        hospitalName,
        doctorName,
        callNumber,
        waitingNumber,
        estimatedWaitTime,
        message,
        createdAt,
        updatedAt,
      ];

  Reservation copyWith({
    String? id,
    String? status,
    String? date,
    String? time,
    String? department,
    String? hospitalName,
    String? doctorName,
    int? callNumber,
    int? waitingNumber,
    int? estimatedWaitTime,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      status: status ?? this.status,
      date: date ?? this.date,
      time: time ?? this.time,
      department: department ?? this.department,
      hospitalName: hospitalName ?? this.hospitalName,
      doctorName: doctorName ?? this.doctorName,
      callNumber: callNumber ?? this.callNumber,
      waitingNumber: waitingNumber ?? this.waitingNumber,
      estimatedWaitTime: estimatedWaitTime ?? this.estimatedWaitTime,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}