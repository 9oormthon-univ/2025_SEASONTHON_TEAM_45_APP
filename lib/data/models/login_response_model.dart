import 'auth_token_model.dart';

class LoginResponseModel {
  final AuthTokenModel tokens;
  final int? memberId;
  final String? memberName;
  final String? role;

  LoginResponseModel({
    required this.tokens,
    this.memberId,
    this.memberName,
    this.role,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return LoginResponseModel(
      tokens: AuthTokenModel.fromJson(data),
      memberId: data['memberId'],
      memberName: data['memberName'],
      role: data['role'],
    );
  }
}