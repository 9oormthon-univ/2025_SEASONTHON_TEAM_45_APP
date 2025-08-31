import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Register implements UseCase<User, RegisterParams> {
  final AuthRepository repository;

  Register(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(
      name: params.name,
      gender: params.gender,
      birthDate: params.birthDate,
      phoneNumber: params.phoneNumber,
      password: params.password,
    );
  }
}

class RegisterParams extends Equatable {
  final String name;
  final String gender;
  final String birthDate;
  final String phoneNumber;
  final String password;

  const RegisterParams({
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.phoneNumber,
    required this.password,
  });

  @override
  List<Object> get props => [name, gender, birthDate, phoneNumber, password];
}