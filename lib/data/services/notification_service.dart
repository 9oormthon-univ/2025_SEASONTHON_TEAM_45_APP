import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/error/exceptions.dart';
import '../network/api_endpoints.dart';

class NotificationService {
  late Dio _dio;
  late FirebaseMessaging _messaging;
  late SharedPreferences _prefs;
  
  static const String _fcmTokenKey = 'fcm_token';
  static const String _lastTokenRegistrationKey = 'last_token_registration';
  
  NotificationService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        _prefs = await SharedPreferences.getInstance();
        final token = _prefs.getString('access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
    
    _messaging = FirebaseMessaging.instance;
  }
  
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    
    await _requestPermissions();
    
    final token = await getFCMToken();
    if (token != null) {
      final lastRegistration = _prefs.getString(_lastTokenRegistrationKey);
      if (lastRegistration != token) {
        await _saveFCMTokenLocally(token);
      }
    }
    
    _setupMessageHandlers();
  }
  
  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('[NotificationService] 알림 권한 허용됨');
      }
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('[NotificationService] 알림 권한 임시 허용');
      }
    } else {
      if (kDebugMode) {
        print('[NotificationService] 알림 권한 거부됨');
      }
    }
  }
  
  Future<String?> getFCMToken() async {
    try {
      String? token;
      
      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          if (kDebugMode) {
            print('[NotificationService] APNS 토큰 대기 중...');
          }
          await Future.delayed(const Duration(seconds: 3));
        }
      }
      
      token = await _messaging.getToken();
      
      if (kDebugMode) {
        print('[NotificationService] FCM 토큰: $token');
      }
      
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationService] FCM 토큰 획득 실패: $e');
      }
      return null;
    }
  }
  
  Future<void> _saveFCMTokenLocally(String token) async {
    await _prefs.setString(_fcmTokenKey, token);
  }
  
  Future<bool> registerTokenToServer(int memberId, String fcmToken) async {
    try {
      final deviceType = Platform.isIOS ? 'IOS' : 'ANDROID';
      
      final response = await _dio.post(
        '/api/v1/notifications/token',
        data: {
          'memberId': memberId,
          'fcmToken': fcmToken,
          'deviceType': deviceType,
        },
      );
      
      if (response.statusCode == 200) {
        await _prefs.setString(_lastTokenRegistrationKey, fcmToken);
        if (kDebugMode) {
          print('[NotificationService] FCM 토큰 서버 등록 성공');
        }
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('[NotificationService] FCM 토큰 등록 실패: ${e.message}');
      }
      throw ServerException(
        message: e.response?.data?['message'] ?? 'FCM 토큰 등록 실패',
      );
    }
  }
  
  void _setupMessageHandlers() {
    _messaging.onTokenRefresh.listen((newToken) async {
      if (kDebugMode) {
        print('[NotificationService] FCM 토큰 갱신: $newToken');
      }
      
      await _saveFCMTokenLocally(newToken);
      
      final memberId = _prefs.getInt('member_id');
      if (memberId != null) {
        await registerTokenToServer(memberId, newToken);
      }
    });
  }
  
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      await _prefs.remove(_fcmTokenKey);
      await _prefs.remove(_lastTokenRegistrationKey);
      
      if (kDebugMode) {
        print('[NotificationService] FCM 토큰 삭제 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationService] FCM 토큰 삭제 실패: $e');
      }
    }
  }
  
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('[Background] 제목: ${message.notification?.title}');
      print('[Background] 내용: ${message.notification?.body}');
      print('[Background] 데이터: ${message.data}');
    }
  }
}