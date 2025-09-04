part of 'notification_bloc.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
  
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationReady extends NotificationState {}

class NotificationError extends NotificationState {
  final String message;
  
  const NotificationError({required this.message});
  
  @override
  List<Object> get props => [message];
}

class PatientCalledNotification extends NotificationState {
  final int appointmentId;
  final String roomNumber;
  final String title;
  final String body;
  
  const PatientCalledNotification({
    required this.appointmentId,
    required this.roomNumber,
    required this.title,
    required this.body,
  });
  
  @override
  List<Object> get props => [appointmentId, roomNumber, title, body];
}

class CheckInConfirmedNotification extends NotificationState {
  final int appointmentId;
  final String title;
  final String body;
  
  const CheckInConfirmedNotification({
    required this.appointmentId,
    required this.title,
    required this.body,
  });
  
  @override
  List<Object> get props => [appointmentId, title, body];
}

class AppointmentReminderNotification extends NotificationState {
  final int appointmentId;
  final String appointmentTime;
  final String title;
  final String body;
  
  const AppointmentReminderNotification({
    required this.appointmentId,
    required this.appointmentTime,
    required this.title,
    required this.body,
  });
  
  @override
  List<Object> get props => [appointmentId, appointmentTime, title, body];
}

class GeneralNotification extends NotificationState {
  final String title;
  final String body;
  final Map<String, dynamic> data;
  
  const GeneralNotification({
    required this.title,
    required this.body,
    required this.data,
  });
  
  @override
  List<Object> get props => [title, body, data];
}

class FCMTokenRegistered extends NotificationState {}