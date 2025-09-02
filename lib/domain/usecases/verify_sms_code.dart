import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class VerifySmsCode implements UseCase<String, VerifySmsCodeParams> {
  final AuthRepository repository;

  VerifySmsCode(this.repository);

  @override
  Future<Either<Failure, String>> call(VerifySmsCodeParams params) async {
    return await repository.verifySmsCode(params.phoneNumber, params.code);
  }
}

class VerifySmsCodeParams {
  final String phoneNumber;
  final String code;

  VerifySmsCodeParams({
    required this.phoneNumber,
    required this.code,
  });
}