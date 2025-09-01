import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/reservation_repository.dart';

class CancelReservationUseCase extends UseCase<void, String> {
  final ReservationRepository repository;

  CancelReservationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String reservationId) async {
    return await repository.cancelReservation(reservationId);
  }
}