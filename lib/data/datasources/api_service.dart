import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // TODO: 실제 백엔드 URL로 변경
  static const String baseUrl = 'https://api.example.com';
  
  static Future<bool> reportPatientArrival({
    required String patientId,
    required String hospitalId,
    required int rssi,
  }) async {
    try {
      print('====================================');
      print('[API] 환자 도착 알림 전송');
      print('Patient ID: $patientId');
      print('Hospital ID: $hospitalId');
      print('RSSI: $rssi');
      print('====================================');
      
      // TODO: 실제 API 구현 시 주석 해제
      /*
      final response = await http.post(
        Uri.parse('$baseUrl/patient/arrival'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patientId': patientId,
          'hospitalId': hospitalId,
          'rssi': rssi,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 200) {
        print('[API] 도착 알림 성공');
        return true;
      } else {
        print('[API] 도착 알림 실패: ${response.statusCode}');
        return false;
      }
      */
      
      // 개발 중이므로 성공 반환
      print('[API] 개발 모드: 도착 알림 시뮬레이션 성공');
      return true;
    } catch (e) {
      print('[API] 에러: $e');
      return false;
    }
  }
}