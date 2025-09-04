part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  
  @override
  List<Object?> get props => [];
}

class InitializeNotifications extends NotificationEvent {}

class ProcessNotificationMessage extends NotificationEvent {
  final RemoteMessage message;
  final bool fromBackground;
  
  const ProcessNotificationMessage({
    required this.message,
    this.fromBackground = false,
  });
  
  @override
  List<Object?> get props => [message, fromBackground];
}

class RegisterFCMToken extends NotificationEvent {
  final int memberId;
  
  const RegisterFCMToken({required this.memberId});
  
  @override
  List<Object> get props => [memberId];
}

class ClearNotifications extends NotificationEvent {}