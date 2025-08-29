import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoUtils {
  static const String hospitalId = 'Goormhospital';
  static const String password = '123456';
  
  // Goormhospital123456을 SHA-256으로 해싱
  static String getExpectedHash() {
    final bytes = utf8.encode('$hospitalId$password');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // 수신된 데이터를 검증
  static bool verifyHospitalBeacon(String receivedData) {
    final expectedHash = getExpectedHash();
    return receivedData.toLowerCase() == expectedHash.toLowerCase();
  }
  
  // 디버그용 해시값 출력
  static void printHashForNRFConnect() {
    final hash = getExpectedHash();
    print('========================================');
    print('nRF Connect 설정용 해시값');
    print('Device Name에 입력: $hash');
    print('또는 Manufacturer Data에 입력');
    print('========================================');
  }
}