import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../../data/services/notification_service.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService _notificationService;
  StreamSubscription? _foregroundMessageSubscription;
  StreamSubscription? _messageOpenedAppSubscription;
  
  NotificationBloc({
    required NotificationService notificationService,
  }) : _notificationService = notificationService,
       super(NotificationInitial()) {
    on<InitializeNotifications>(_onInitializeNotifications);
    on<ProcessNotificationMessage>(_onProcessNotificationMessage);
    on<RegisterFCMToken>(_onRegisterFCMToken);
    on<ClearNotifications>(_onClearNotifications);
  }
  
  Future<void> _onInitializeNotifications(
    InitializeNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(NotificationLoading());
      
      await _notificationService.initialize();
      
      _setupMessageHandlers();
      
      emit(NotificationReady());
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }
  
  void _setupMessageHandlers() {
    _foregroundMessageSubscription?.cancel();
    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('[NotificationBloc] 포그라운드 메시지 수신');
        print('제목: ${message.notification?.title}');
        print('내용: ${message.notification?.body}');
        print('데이터: ${message.data}');
      }
      
      add(ProcessNotificationMessage(message: message));
    });
    
    _messageOpenedAppSubscription?.cancel();
    _messageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('[NotificationBloc] 앱 열림 메시지');
        print('데이터: ${message.data}');
      }
      
      add(ProcessNotificationMessage(message: message, fromBackground: true));
    });
  }
  
  Future<void> _onProcessNotificationMessage(
    ProcessNotificationMessage event,
    Emitter<NotificationState> emit,
  ) async {
    final message = event.message;
    final data = message.data;
    
    if (data['type'] == 'CALL' || data['type'] == 'PATIENT_CALL') {
      emit(PatientCalledNotification(
        appointmentId: int.parse(data['appointmentId'].toString()),
        roomNumber: data['roomNumber'] ?? data['roomName'] ?? '진료실',
        title: message.notification?.title ?? '진료실 호출',
        body: message.notification?.body ?? '진료실로 와주세요',
      ));
    } else if (data['type'] == 'CHECKIN_CONFIRMATION') {
      emit(CheckInConfirmedNotification(
        appointmentId: int.parse(data['appointmentId'].toString()),
        title: message.notification?.title ?? '체크인 완료',
        body: message.notification?.body ?? '체크인이 완료되었습니다',
      ));
    } else if (data['type'] == 'APPOINTMENT_REMINDER') {
      emit(AppointmentReminderNotification(
        appointmentId: int.parse(data['appointmentId'].toString()),
        appointmentTime: data['appointmentTime'] ?? '',
        title: message.notification?.title ?? '예약 알림',
        body: message.notification?.body ?? '예약 시간이 다가왔습니다',
      ));
    } else {
      emit(GeneralNotification(
        title: message.notification?.title ?? '알림',
        body: message.notification?.body ?? '',
        data: data,
      ));
    }
  }
  
  Future<void> _onRegisterFCMToken(
    RegisterFCMToken event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final token = await _notificationService.getFCMToken();
      if (token != null) {
        await _notificationService.registerTokenToServer(event.memberId, token);
        emit(FCMTokenRegistered());
      } else {
        emit(const NotificationError(message: 'FCM 토큰을 가져올 수 없습니다'));
      }
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }
  
  Future<void> _onClearNotifications(
    ClearNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationInitial());
  }
  
  @override
  Future<void> close() {
    _foregroundMessageSubscription?.cancel();
    _messageOpenedAppSubscription?.cancel();
    return super.close();
  }
}