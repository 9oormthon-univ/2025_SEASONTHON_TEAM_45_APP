import 'package:equatable/equatable.dart';
import '../../../domain/entities/reservation.dart';

abstract class ReservationState extends Equatable {
  const ReservationState();

  @override
  List<Object?> get props => [];
}

class ReservationInitial extends ReservationState {}

class ReservationLoading extends ReservationState {}

class ReservationLoaded extends ReservationState {
  final List<dynamic> reservations; // AppointmentModel \ubc0f Reservation \ubaa8\ub450 \uc9c0\uc6d0

  const ReservationLoaded({required this.reservations});

  @override
  List<Object?> get props => [reservations];
}

class ReservationError extends ReservationState {
  final String message;

  const ReservationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ReservationCreating extends ReservationState {}

class ReservationCreated extends ReservationState {
  final Reservation reservation;

  const ReservationCreated({required this.reservation});

  @override
  List<Object?> get props => [reservation];
}

class ReservationStatusUpdated extends ReservationState {
  final Reservation reservation;

  const ReservationStatusUpdated({required this.reservation});

  @override
  List<Object?> get props => [reservation];
}