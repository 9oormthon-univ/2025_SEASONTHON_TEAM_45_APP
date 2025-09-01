
class ApiService {
  // TODO: 실제 API 엔드포인트로 변경 필요
  static const String baseUrl = 'https://api.carefreepass.com';
  
  // 환자 도착 알림 POST 요청
  static Future<bool> reportPatientArrival({
    required String patientId,
    required String hospitalId,
    required int rssi,
  }) async {
    try {
      // 개발 모드에서는 로그만 출력
      print('====================================');
      print('[API] 환자 도착 알림 전송');
      print('Patient ID: $patientId');
      print('Hospital ID: $hospitalId');
      print('RSSI: $rssi');
      print('====================================');
      
      // TODO: 실제 API 구현
      // final response = await http.post(
      //   Uri.parse('$baseUrl/patient/arrival'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'patientId': patientId,
      //     'hospitalId': hospitalId,
      //     'rssi': rssi,
      //     'timestamp': DateTime.now().toIso8601String(),
      //   }),
      // );
      // 
      // return response.statusCode == 200;
      
      // 개발 모드: 항상 성공 반환
      return true;
    } catch (e) {
      print('[API Error] $e');
      return false;
    }
  }
}