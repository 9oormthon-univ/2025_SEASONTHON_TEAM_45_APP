import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String phoneNumber,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String name,
    required String gender,
    required String birthDate,
    required String phoneNumber,
    required String password,
    String? temporaryToken,
  });
  
  Future<Either<Failure, bool>> sendSmsCode(String phoneNumber);
  
  Future<Either<Failure, String>> verifySmsCode(String phoneNumber, String code);

  Future<Either<Failure, User>> refreshToken(String refreshToken);

  Future<Either<Failure, bool>> setAutoLogin(
    bool enabled, {
    String? phoneNumber,
    String? password,
  });

  Future<Either<Failure, User?>> tryAutoLogin();

  Future<Either<Failure, void>> logout();

  Future<bool> isLoggedIn();

  Future<String?> getAccessToken();
}