import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SendSmsCode implements UseCase<bool, SendSmsCodeParams> {
  final AuthRepository repository;

  SendSmsCode(this.repository);

  @override
  Future<Either<Failure, bool>> call(SendSmsCodeParams params) async {
    return await repository.sendSmsCode(params.phoneNumber);
  }
}

class SendSmsCodeParams {
  final String phoneNumber;

  SendSmsCodeParams({required this.phoneNumber});
}