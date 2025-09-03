import 'auth_token_model.dart';

class LoginResponseModel {
  final AuthTokenModel tokens;
  final int? memberId;
  final String? memberName;
  final String? role;
  final String? phoneNumber;
  final String? email;
  final String? birthDate;
  final String? gender;
  final String? hospitalName;
  final String? hospitalAddress;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  LoginResponseModel({
    required this.tokens,
    this.memberId,
    this.memberName,
    this.role,
    this.phoneNumber,
    this.email,
    this.birthDate,
    this.gender,
    this.hospitalName,
    this.hospitalAddress,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return LoginResponseModel(
      tokens: AuthTokenModel.fromJson(data),
      memberId: data['memberId'],
      memberName: data['memberName'],
      role: data['role'],
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      birthDate: data['birthDate'],
      gender: data['gender'],
      hospitalName: data['hospitalName'],
      hospitalAddress: data['hospitalAddress'],
      status: data['status'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }
}