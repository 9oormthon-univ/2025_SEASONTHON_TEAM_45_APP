import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/time_data_slot.dart';
import '../repositories/booking_repository.dart';

class GetAvailableTimeSlots implements UseCase<TimeSlotResponse, GetTimeSlotsParams> {
  final BookingRepository repository;

  GetAvailableTimeSlots(this.repository);

  @override
  Future<Either<Failure, TimeSlotResponse>> call(GetTimeSlotsParams params) async {
    return await repository.getAvailableTimeSlots(
      hospitalId: params.hospitalId,
      departmentName: params.departmentName,
      date: params.date,
    );
  }
}

class GetTimeSlotsParams extends Equatable {
  final int hospitalId;
  final String departmentName;
  final String date;

  const GetTimeSlotsParams({
    required this.hospitalId,
    required this.departmentName,
    required this.date,
  });

  @override
  List<Object> get props => [hospitalId, departmentName, date];
}