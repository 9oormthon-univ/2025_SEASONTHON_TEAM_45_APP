
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_endpoints.dart';

class ApiService {
  static late Dio _dio;
  static late SharedPreferences _prefs;
  
  // Dio 초기화
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    // 인터셉터 추가 (토큰 자동 추가)
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = _prefs.getString('access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }
  
  // 환자 체크인 API 호출
  static Future<bool> checkInPatient({
    required int appointmentId,
    required int memberId,
  }) async {
    try {
      print('====================================');
      print('[API] 환자 체크인 요청');
      print('Appointment ID: $appointmentId');
      print('Member ID: $memberId');
      print('====================================');
      
      final response = await _dio.put(
        ApiEndpoints.checkIn,
        data: {
          'appointmentId': appointmentId,
          'memberId': memberId,
        },
      );
      
      if (response.statusCode == 200) {
        print('[API] Response Data: ${response.data}');
        
        final code = response.data['code'];
        final message = response.data['message'] ?? '';
        final data = response.data['data'];
        
        // 메시지로 실패 판단 (백엔드가 200을 반환하지만 실패인 경우)
        if (message.contains('완료된 예약') || message.contains('수정할 수 없')) {
          print('[API] 체크인 실패: $message');
          return false;
        }
        
        // 이미 체크인된 경우도 성공으로 처리
        if (message.contains('이미 체크인') || message.contains('이미 도착')) {
          print('[API] 이미 체크인된 상태');
          return true;
        }
        
        print('[API] 체크인 성공: $message');
        print('[API] 변경된 상태: $data');
        
        // 성공 조건: 다양한 성공 코드 처리
        return code == 'APPOINTMENT_4002' ||  // 체크인 성공
               code == 'APPOINTMENT_2004' || 
               code == 'SUCCESS' || 
               data == 'SUCCESS' ||
               data == 'ARRIVED' || 
               data == 'CHECKED_IN';
      }
      
      return false;
    } on DioException catch (e) {
      print('[API Error] 체크인 실패');
      print('Status Code: ${e.response?.statusCode}');
      print('Error Data: ${e.response?.data}');
      
      if (e.response?.statusCode == 400) {
        final code = e.response?.data['code'];
        if (code == 'ALREADY_CHECKED_IN') {
          print('[API] 이미 체크인된 예약입니다.');
        } else if (code == 'INVALID_CHECKIN') {
          print('[API] 본인의 예약이 아닙니다.');
        }
      }
      
      return false;
    }
  }
  
  // BLE 비콘 감지 시 호출되는 메서드 (기존 메서드 이름 유지, 내부 로직만 변경)
  static Future<bool> reportPatientArrival({
    required String patientId,  // 실제로는 사용 안 함
    required String hospitalId,  // 실제로는 사용 안 함
    required int rssi,
    required int appointmentId,
    required int memberId,
  }) async {
    // 체크인 API 호출
    return await checkInPatient(
      appointmentId: appointmentId,
      memberId: memberId,
    );
  }
}