import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/booking_repository.dart';

class CreateAppointment implements UseCase<int, CreateAppointmentParams> {
  final BookingRepository repository;

  CreateAppointment(this.repository);

  @override
  Future<Either<Failure, int>> call(CreateAppointmentParams params) async {
    return await repository.createAppointment(
      memberId: params.memberId,
      hospitalId: params.hospitalId,
      departmentName: params.departmentName,
      appointmentDate: params.appointmentDate,
      appointmentTime: params.appointmentTime,
    );
  }
}

class CreateAppointmentParams extends Equatable {
  final int memberId;
  final int hospitalId;
  final String departmentName;
  final String appointmentDate;
  final String appointmentTime;

  const CreateAppointmentParams({
    required this.memberId,
    required this.hospitalId,
    required this.departmentName,
    required this.appointmentDate,
    required this.appointmentTime,
  });

  @override
  List<Object> get props => [memberId, hospitalId, departmentName, appointmentDate, appointmentTime];
}