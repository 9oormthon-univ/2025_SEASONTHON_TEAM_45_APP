import 'package:equatable/equatable.dart';

abstract class ReservationEvent extends Equatable {
  const ReservationEvent();

  @override
  List<Object?> get props => [];
}

class LoadReservations extends ReservationEvent {}

class CreateReservation extends ReservationEvent {
  final String? hospitalId;
  final String? departmentId;
  final String? doctorId;
  final String? date;
  final String? time;
  final String? symptoms;
  final bool? isFirstVisit;

  const CreateReservation({
    this.hospitalId,
    this.departmentId,
    this.doctorId,
    this.date,
    this.time,
    this.symptoms,
    this.isFirstVisit,
  });

  @override
  List<Object?> get props => [
        hospitalId,
        departmentId,
        doctorId,
        date,
        time,
        symptoms,
        isFirstVisit,
      ];
}

class CancelReservation extends ReservationEvent {
  final String reservationId;

  const CancelReservation({required this.reservationId});

  @override
  List<Object?> get props => [reservationId];
}

class UpdateReservationStatus extends ReservationEvent {
  final String reservationId;
  final String status;
  final int? callNumber;
  final int? waitingNumber;
  final int? estimatedWaitTime;

  const UpdateReservationStatus({
    required this.reservationId,
    required this.status,
    this.callNumber,
    this.waitingNumber,
    this.estimatedWaitTime,
  });

  @override
  List<Object?> get props => [
        reservationId,
        status,
        callNumber,
        waitingNumber,
        estimatedWaitTime,
      ];
}

class RefreshReservation extends ReservationEvent {
  final String reservationId;

  const RefreshReservation({required this.reservationId});

  @override
  List<Object?> get props => [reservationId];
}