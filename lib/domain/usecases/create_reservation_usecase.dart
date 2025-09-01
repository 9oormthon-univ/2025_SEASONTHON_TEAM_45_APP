import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/reservation.dart';
import '../repositories/reservation_repository.dart';

class CreateReservationUseCase extends UseCase<Reservation, CreateReservationParams> {
  final ReservationRepository repository;

  CreateReservationUseCase(this.repository);

  @override
  Future<Either<Failure, Reservation>> call(CreateReservationParams params) async {
    return await repository.createReservation(
      hospitalId: params.hospitalId,
      departmentId: params.departmentId,
      doctorId: params.doctorId,
      date: params.date,
      time: params.time,
      symptoms: params.symptoms,
      isFirstVisit: params.isFirstVisit,
    );
  }
}

class CreateReservationParams extends Equatable {
  final String hospitalId;
  final String departmentId;
  final String doctorId;
  final String date;
  final String time;
  final String symptoms;
  final bool isFirstVisit;

  const CreateReservationParams({
    required this.hospitalId,
    required this.departmentId,
    required this.doctorId,
    required this.date,
    required this.time,
    required this.symptoms,
    required this.isFirstVisit,
  });

  @override
  List<Object> get props => [
        hospitalId,
        departmentId,
        doctorId,
        date,
        time,
        symptoms,
        isFirstVisit,
      ];
}