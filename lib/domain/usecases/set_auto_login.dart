import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SetAutoLogin implements UseCase<bool, SetAutoLoginParams> {
  final AuthRepository repository;

  SetAutoLogin(this.repository);

  @override
  Future<Either<Failure, bool>> call(SetAutoLoginParams params) async {
    return await repository.setAutoLogin(
      params.enabled,
      phoneNumber: params.phoneNumber,
      password: params.password,
    );
  }
}

class SetAutoLoginParams extends Equatable {
  final bool enabled;
  final String? phoneNumber;
  final String? password;

  const SetAutoLoginParams({
    required this.enabled,
    this.phoneNumber,
    this.password,
  });

  @override
  List<Object?> get props => [enabled, phoneNumber, password];
}