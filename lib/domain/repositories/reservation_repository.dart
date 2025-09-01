import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/reservation.dart';

abstract class ReservationRepository {
  Future<Either<Failure, List<Reservation>>> getReservations();
  
  Future<Either<Failure, Reservation>> getReservationById(String id);
  
  Future<Either<Failure, Reservation>> createReservation({
    required String hospitalId,
    required String departmentId,
    required String doctorId,
    required String date,
    required String time,
    required String symptoms,
    required bool isFirstVisit,
  });
  
  Future<Either<Failure, void>> cancelReservation(String reservationId);
  
  Future<Either<Failure, Reservation>> updateReservationStatus({
    required String reservationId,
    required String status,
    int? callNumber,
    int? waitingNumber,
    int? estimatedWaitTime,
  });
}