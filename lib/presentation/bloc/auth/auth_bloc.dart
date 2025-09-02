import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/usecases/auto_login.dart';
import '../../../domain/usecases/login.dart';
import '../../../domain/usecases/logout.dart';
import '../../../domain/usecases/register.dart';
import '../../../domain/usecases/set_auto_login.dart';
import '../../../domain/usecases/send_sms_code.dart';
import '../../../domain/usecases/verify_sms_code.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final Register register;
  final AutoLogin autoLogin;
  final Logout logout;
  final SetAutoLogin setAutoLogin;
  final SendSmsCode sendSmsCode;
  final VerifySmsCode verifySmsCode;

  AuthBloc({
    required this.login,
    required this.register,
    required this.autoLogin,
    required this.logout,
    required this.setAutoLogin,
    required this.sendSmsCode,
    required this.verifySmsCode,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<AutoLoginRequested>(_onAutoLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SendSmsCodeRequested>(_onSendSmsCodeRequested);
    on<VerifySmsCodeRequested>(_onVerifySmsCodeRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await login(LoginParams(
      phoneNumber: event.phoneNumber,
      password: event.password,
    ));

    await result.fold(
      (failure) async {
        emit(AuthError(failure.message));
      },
      (user) async {
        // 자동 로그인 설정
        if (event.autoLogin) {
          await setAutoLogin(SetAutoLoginParams(
            enabled: true,
            phoneNumber: event.phoneNumber,
            password: event.password,
          ));
        }
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await register(RegisterParams(
      name: event.name,
      gender: event.gender,
      birthDate: event.birthDate,
      phoneNumber: event.phoneNumber,
      password: event.password,
      temporaryToken: event.temporaryToken,
    ));

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }
  
  Future<void> _onSendSmsCodeRequested(
    SendSmsCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await sendSmsCode(SendSmsCodeParams(
      phoneNumber: event.phoneNumber,
    ));
    
    result.fold(
      (failure) => emit(SmsCodeError(failure.message)),
      (success) {
        if (success) {
          emit(SmsCodeSent(event.phoneNumber));
        } else {
          emit(const SmsCodeError('SMS 전송에 실패했습니다.'));
        }
      },
    );
  }
  
  Future<void> _onVerifySmsCodeRequested(
    VerifySmsCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await verifySmsCode(VerifySmsCodeParams(
      phoneNumber: event.phoneNumber,
      code: event.code,
    ));
    
    result.fold(
      (failure) => emit(SmsCodeError(failure.message)),
      (temporaryToken) => emit(SmsCodeVerified(temporaryToken)),
    );
  }

  Future<void> _onAutoLoginRequested(
    AutoLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await autoLogin(NoParams());

    result.fold(
      (failure) => emit(const Unauthenticated()),
      (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(const Unauthenticated());
        }
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await logout(NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const Unauthenticated('로그아웃되었습니다.')),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    // 자동 로그인 시도
    add(AutoLoginRequested());
  }
}