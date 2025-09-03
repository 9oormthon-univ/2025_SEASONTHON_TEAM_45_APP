import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/time_data_slot.dart';
import '../../domain/repositories/booking_repository.dart';
import '../services/booking_service.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingService _bookingService;

  BookingRepositoryImpl(this._bookingService);

  @override
  Future<Either<Failure, TimeSlotResponse>> getAvailableTimeSlots({
    required int hospitalId,
    required String departmentName,
    required String date,
  }) async {
    try {
      final result = await _bookingService.getAvailableTimeSlots(
        hospitalId: hospitalId,
        departmentName: departmentName,
        date: date,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('예상치 못한 오류가 발생했습니다'));
    }
  }

  @override
  Future<Either<Failure, int>> createAppointment({
    required int memberId,
    required int hospitalId,
    required String departmentName,
    required String appointmentDate,
    required String appointmentTime,
  }) async {
    try {
      final appointmentId = await _bookingService.createAppointment(
        memberId: memberId,
        hospitalId: hospitalId,
        departmentName: departmentName,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
      );
      return Right(appointmentId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('예상치 못한 오류가 발생했습니다'));
    }
  }
}