import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;

  AuthRepositoryImpl({
    required this.authService,
  });

  @override
  Future<Either<Failure, User>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      print('=== AuthRepository 로그인 시작 ===');
      print('Phone: $phoneNumber');
      
      final result = await authService.login(
        LoginRequestModel(
          phoneNumber: phoneNumber,
          password: password,
        ),
      );
      
      if (result != null) {
        print('=== 로그인 성공 ===');
        print('User: ${result.memberName} (ID: ${result.memberId})');
        
        return Right(User(
          id: result.memberId?.toString() ?? phoneNumber,
          name: result.memberName ?? '',
          phoneNumber: phoneNumber,
          accessToken: result.tokens.accessToken,
          refreshToken: result.tokens.refreshToken,
        ));
      }
      print('=== 토큰이 null - 로그인 실패 ===');
      return const Left(ServerFailure('로그인할 수 없습니다.'));
    } on Exception catch (e) {
      // AuthService에서 throw한 Exception의 메시지를 그대로 전달
      final message = e.toString().replaceFirst('Exception: ', '');
      return Left(ServerFailure(message));
    } catch (e) {
      return const Left(ServerFailure('로그인 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, bool>> sendSmsCode(String phoneNumber) async {
    try {
      final success = await authService.sendSmsCode(phoneNumber);
      return Right(success);
    } catch (e) {
      return const Left(ServerFailure('SMS 전송에 실패했습니다.'));
    }
  }
  
  @override
  Future<Either<Failure, String>> verifySmsCode(String phoneNumber, String code) async {
    try {
      final token = await authService.verifySmsCode(phoneNumber, code);
      if (token != null) {
        return Right(token);
      }
      return const Left(ServerFailure('인증코드가 올바르지 않습니다.'));
    } catch (e) {
      return const Left(ServerFailure('인증코드 검증 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String gender,
    required String birthDate,
    required String phoneNumber,
    required String password,
    String? temporaryToken,
  }) async {
    try {
        final tokens = await authService.register(
          RegisterRequestModel(
            name: name,
            gender: gender,
            birthDate: birthDate,
            phoneNumber: phoneNumber,
            password: password,
          ),
          temporaryToken: temporaryToken,
        );
        
        if (tokens != null) {
          return Right(User(
            id: phoneNumber,
            name: name,
            phoneNumber: phoneNumber,
            gender: gender,
            birthDate: birthDate,
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
          ));
        }
        return const Left(ServerFailure('회원가입을 완료할 수 없습니다.\n잠시 후 다시 시도해주세요.'));
    } catch (e) {
      return const Left(ServerFailure('회원가입 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, User>> refreshToken(String refreshToken) async {
    try {
        final tokens = await authService.refreshAccessToken(refreshToken);
        
        if (tokens != null) {
          return Right(User(
            id: '',
            name: '',
            phoneNumber: '',
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
          ));
        }
        return const Left(ServerFailure('토큰 재발급에 실패했습니다.'));
    } catch (e) {
      return const Left(ServerFailure('토큰 재발급 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, bool>> setAutoLogin(
    bool enabled, {
    String? phoneNumber,
    String? password,
  }) async {
    try {
      await authService.setAutoLogin(enabled, 
        phoneNumber: phoneNumber, 
        password: password
      );
      return const Right(true);
    } catch (e) {
      return const Left(ServerFailure('자동 로그인 설정에 실패했습니다.'));
    }
  }

  @override
  Future<Either<Failure, User?>> tryAutoLogin() async {
    try {
        final success = await authService.tryAutoLogin();
        if (success) {
          // 자동 로그인 성공 시 토큰이 이미 저장되어 있음
          final accessToken = await authService.getAccessToken();
          final refreshToken = await authService.getRefreshToken();
          if (accessToken != null && refreshToken != null) {
            return Right(User(
              id: '',
              name: '',
              phoneNumber: '',
              accessToken: accessToken,
              refreshToken: refreshToken,
            ));
          }
        }
        return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('자동 로그인에 실패했습니다.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await authService.logout();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('로그아웃에 실패했습니다.'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await authService.isLoggedIn();
  }

  @override
  Future<String?> getAccessToken() async {
    return await authService.getAccessToken();
  }
}