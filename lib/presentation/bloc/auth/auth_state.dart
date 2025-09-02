import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {
  final String? message;

  const Unauthenticated([this.message]);

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class SmsCodeSent extends AuthState {
  final String phoneNumber;
  
  const SmsCodeSent(this.phoneNumber);
  
  @override
  List<Object> get props => [phoneNumber];
}

class SmsCodeVerified extends AuthState {
  final String temporaryToken;
  
  const SmsCodeVerified(this.temporaryToken);
  
  @override
  List<Object> get props => [temporaryToken];
}

class SmsCodeError extends AuthState {
  final String message;
  
  const SmsCodeError(this.message);
  
  @override
  List<Object> get props => [message];
}