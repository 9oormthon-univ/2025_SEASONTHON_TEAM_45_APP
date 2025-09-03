import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final String? gender;
  final String? birthDate;
  final String accessToken;
  final String refreshToken;
  final String? role;
  final String? email;
  final String? hospitalName;
  final String? hospitalAddress;
  final String? status;

  const User({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.gender,
    this.birthDate,
    required this.accessToken,
    required this.refreshToken,
    this.role,
    this.email,
    this.hospitalName,
    this.hospitalAddress,
    this.status,
  });

  // 생년월일로부터 나이 계산
  int? get age {
    if (birthDate == null) return null;
    
    try {
      // birthDate 형식: 20000919
      final year = int.parse(birthDate!.substring(0, 4));
      final month = int.parse(birthDate!.substring(4, 6));
      final day = int.parse(birthDate!.substring(6, 8));
      
      final birthDateTime = DateTime(year, month, day);
      final now = DateTime.now();
      
      int age = now.year - birthDateTime.year;
      
      // 생일이 아직 안 지났으면 나이 1 감소
      if (now.month < birthDateTime.month || 
          (now.month == birthDateTime.month && now.day < birthDateTime.day)) {
        age--;
      }
      
      return age;
    } catch (e) {
      return null;
    }
  }

  // 포맷된 전화번호 반환
  String get formattedPhoneNumber {
    if (phoneNumber.length == 11) {
      // 01012345678 -> 010-1234-5678
      return '${phoneNumber.substring(0, 3)}-${phoneNumber.substring(3, 7)}-${phoneNumber.substring(7)}';
    }
    return phoneNumber;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phoneNumber,
        gender,
        birthDate,
        accessToken,
        refreshToken,
        role,
        email,
        hospitalName,
        hospitalAddress,
        status,
      ];
}