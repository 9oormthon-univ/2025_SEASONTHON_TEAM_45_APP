import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../network/api_endpoints.dart';
import '../services/auth_service.dart';
import '../auth_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;
  final AuthStorage authStorage;

  AuthRepositoryImpl({
    required this.authService,
    required this.authStorage,
  });

  @override
  Future<Either<Failure, User>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      // 실제 백엔드 서버 연동
      const bool useLocalStorage = false;
      
      if (!useLocalStorage) {
        final tokens = await authService.login(
          LoginRequestModel(
            phoneNumber: phoneNumber,
            password: password,
          ),
        );
        
        if (tokens != null) {
          return Right(User(
            id: phoneNumber,
            name: '',
            phoneNumber: phoneNumber,
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
          ));
        }
        return const Left(ServerFailure('로그인에 실패했습니다.'));
      }
      
      // 배포 전까지는 로컬 스토리지 사용
      final success = authStorage.login(phoneNumber, password);
      if (success) {
        return Right(User(
          id: phoneNumber,
          name: authStorage.currentUser?['name'] ?? '',
          phoneNumber: phoneNumber,
          accessToken: 'local_token',
          refreshToken: 'local_refresh_token',
        ));
      } else {
        return const Left(ServerFailure('휴대폰 번호 혹은 비밀번호가 틀립니다.'));
      }
    } catch (e) {
      return const Left(ServerFailure('로그인 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, bool>> sendSmsCode(String phoneNumber) async {
    try {
      // 실제 백엔드 서버 연동
      const bool useLocalStorage = false;
      if (!useLocalStorage) {
        final success = await authService.sendSmsCode(phoneNumber);
        return Right(success);
      }
      
      // 테스트 모드에서는 항상 성공
      return const Right(true);
    } catch (e) {
      return const Left(ServerFailure('SMS 전송에 실패했습니다.'));
    }
  }
  
  @override
  Future<Either<Failure, String>> verifySmsCode(String phoneNumber, String code) async {
    try {
      // 실제 백엔드 서버 연동
      const bool useLocalStorage = false;
      if (!useLocalStorage) {
        final token = await authService.verifySmsCode(phoneNumber, code);
        if (token != null) {
          return Right(token);
        }
        return const Left(ServerFailure('인증코드가 일치하지 않습니다.'));
      }
      
      // 테스트 모드에서는 123456이 올바른 코드
      if (code == '123456') {
        return const Right('test_temporary_token');
      }
      return const Left(ServerFailure('인증코드가 일치하지 않습니다.'));
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
      // 실제 백엔드 서버 연동
      const bool useLocalStorage = false;
      if (!useLocalStorage) {
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
        return const Left(ServerFailure('회원가입에 실패했습니다.'));
      }
      
      // 배포 전까지는 로컬 스토리지 사용
      final year = int.parse(birthDate.substring(0, 4));
      final month = int.parse(birthDate.substring(4, 6));
      final day = int.parse(birthDate.substring(6, 8));
      
      authStorage.register(
        name: name,
        phone: phoneNumber,
        password: password,
        year: year,
        month: month,
        day: day,
        gender: gender,
      );
      
      return Right(User(
        id: phoneNumber,
        name: name,
        phoneNumber: phoneNumber,
        gender: gender,
        birthDate: birthDate,
        accessToken: 'local_token',
        refreshToken: 'local_refresh_token',
      ));
    } catch (e) {
      return const Left(ServerFailure('회원가입 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, User>> refreshToken(String refreshToken) async {
    try {
      // 실제 백엔드 서버 연동
      const bool useLocalStorage = false;
      if (!useLocalStorage) {
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
      }
      
      // 배포 전까지는 로컬 토큰 갱신 시뮬레이션
      return Right(User(
        id: '',
        name: '',
        phoneNumber: '',
        accessToken: 'new_local_token',
        refreshToken: 'new_local_refresh_token',
      ));
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
      // 실제 백엔드 서버 연동
      const bool useLocalStorage = false;
      if (!useLocalStorage) {
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
      authStorage.logout();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('로그아웃에 실패했습니다.'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    // 테스트 모드: 로컬 스토리지 사용
    const bool useLocalStorage = true;
    if (!useLocalStorage) {
      return await authService.isLoggedIn();
    }
    return authStorage.isLoggedIn;
  }

  @override
  Future<String?> getAccessToken() async {
    // 테스트 모드: 로컬 스토리지 사용
    const bool useLocalStorage = true;
    if (!useLocalStorage) {
      return await authService.getAccessToken();
    }
    return authStorage.isLoggedIn ? 'local_token' : null;
  }
}