import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/time_data_slot.dart';

abstract class BookingRepository {
  Future<Either<Failure, TimeSlotResponse>> getAvailableTimeSlots({
    required int hospitalId,
    required String departmentName,
    required String date,
  });
  
  Future<Either<Failure, int>> createAppointment({
    required int memberId,
    required int hospitalId,
    required String departmentName,
    required String appointmentDate,
    required String appointmentTime,
  });
}