import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoUtils {
  static const String hospitalId = 'Goormhospital';
  static const String password = '123456';
  
  // SHA-256 해시의 상위 6바이트만 사용
  static String getExpectedHashPrefix() {
    final bytes = utf8.encode('$hospitalId$password');
    final digest = sha256.convert(bytes);
    final fullHash = digest.toString();
    // 상위 6바이트 = 12자리 hex string
    return fullHash.substring(0, 12).toUpperCase();
  }
  
  // 병원 비콘 검증 (상위 6바이트만 비교)
  static bool verifyHospitalBeacon(String? deviceName) {
    if (deviceName == null || deviceName.isEmpty) return false;
    
    final expectedPrefix = getExpectedHashPrefix();
    final deviceNameUpper = deviceName.toUpperCase();
    
    // print('[CryptoUtils] Expected: $expectedPrefix');
    // print('[CryptoUtils] Device: $deviceNameUpper');
    // print('[CryptoUtils] Match: ${deviceNameUpper.startsWith(expectedPrefix)}');
    
    // 디바이스 이름이 예상 해시 prefix로 시작하는지 확인
    return deviceNameUpper.startsWith(expectedPrefix);
  }
  
  static void printHashForNRFConnect() {
    final prefix = getExpectedHashPrefix();
    print('====================================');
    print('[nRF Connect 설정]');
    print('Service Data에 입력할 값 (HEX):');
    print('354544344134343539434131');
    print('또는 Device Name:');
    print(prefix);  // 5ED4A4459CA1
    print('====================================');
  }
}