import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/reservation.dart';
import '../repositories/reservation_repository.dart';

class GetReservations extends UseCase<List<Reservation>, NoParams> {
  final ReservationRepository repository;

  GetReservations(this.repository);

  @override
  Future<Either<Failure, List<Reservation>>> call([NoParams? params]) async {
    return await repository.getReservations();
  }
}