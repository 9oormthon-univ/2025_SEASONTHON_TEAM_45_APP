import 'package:equatable/equatable.dart';

class Reservation extends Equatable {
  final String id;
  final String status; // SCHEDULED, ARRIVED, CALLED, COMPLETED, CANCELLED
  final String date;
  final String time;
  final String department;
  final String hospitalName;
  final String? doctorName;
  final int? callNumber;
  final int? waitingNumber;
  final int? estimatedWaitTime;
  final String? message;
  final int? appointmentId;  // API에서 사용하는 ID
  final int? memberId;  // 회원 ID
  final String? roomName;  // 진료실 이름 (호출 시 사용)
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
    this.appointmentId,
    this.memberId,
    this.roomName,
    this.createdAt,
    this.updatedAt,
  });
  
  // 별칭 getter 추가 (API 호환성)
  String get appointmentDate => date;
  String get appointmentTime => time;

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
        appointmentId,
        memberId,
        roomName,
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
    int? appointmentId,
    int? memberId,
    String? roomName,
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
      appointmentId: appointmentId ?? this.appointmentId,
      memberId: memberId ?? this.memberId,
      roomName: roomName ?? this.roomName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}