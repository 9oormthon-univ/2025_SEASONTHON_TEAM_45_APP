import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String phoneNumber;
  final String password;
  final bool autoLogin;

  const LoginRequested({
    required this.phoneNumber,
    required this.password,
    required this.autoLogin,
  });

  @override
  List<Object> get props => [phoneNumber, password, autoLogin];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String gender;
  final String birthDate;
  final String phoneNumber;
  final String password;
  final String? temporaryToken;

  const RegisterRequested({
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.phoneNumber,
    required this.password,
    this.temporaryToken,
  });

  @override
  List<Object?> get props => [name, gender, birthDate, phoneNumber, password, temporaryToken];
}

class SendSmsCodeRequested extends AuthEvent {
  final String phoneNumber;
  
  const SendSmsCodeRequested({required this.phoneNumber});
  
  @override
  List<Object> get props => [phoneNumber];
}

class VerifySmsCodeRequested extends AuthEvent {
  final String phoneNumber;
  final String code;
  
  const VerifySmsCodeRequested({
    required this.phoneNumber,
    required this.code,
  });
  
  @override
  List<Object> get props => [phoneNumber, code];
}

class AutoLoginRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}