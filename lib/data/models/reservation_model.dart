import '../../domain/entities/reservation.dart';

class ReservationModel extends Reservation {
  const ReservationModel({
    required String id,
    required String status,
    required String date,
    required String time,
    required String department,
    required String hospitalName,
    String? doctorName,
    int? callNumber,
    int? waitingNumber,
    int? estimatedWaitTime,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          status: status,
          date: date,
          time: time,
          department: department,
          hospitalName: hospitalName,
          doctorName: doctorName,
          callNumber: callNumber,
          waitingNumber: waitingNumber,
          estimatedWaitTime: estimatedWaitTime,
          message: message,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'],
      status: json['status'],
      date: json['date'],
      time: json['time'],
      department: json['department'],
      hospitalName: json['hospitalName'],
      doctorName: json['doctorName'],
      callNumber: json['callNumber'],
      waitingNumber: json['waitingNumber'],
      estimatedWaitTime: json['estimatedWaitTime'],
      message: json['message'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'date': date,
      'time': time,
      'department': department,
      'hospitalName': hospitalName,
      'doctorName': doctorName,
      'callNumber': callNumber,
      'waitingNumber': waitingNumber,
      'estimatedWaitTime': estimatedWaitTime,
      'message': message,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ReservationModel.fromEntity(Reservation reservation) {
    return ReservationModel(
      id: reservation.id,
      status: reservation.status,
      date: reservation.date,
      time: reservation.time,
      department: reservation.department,
      hospitalName: reservation.hospitalName,
      doctorName: reservation.doctorName,
      callNumber: reservation.callNumber,
      waitingNumber: reservation.waitingNumber,
      estimatedWaitTime: reservation.estimatedWaitTime,
      message: reservation.message,
      createdAt: reservation.createdAt,
      updatedAt: reservation.updatedAt,
    );
  }
}