class LoginRequestModel {
  final String phoneNumber;
  final String password;

  LoginRequestModel({
    required this.phoneNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'password': password,
    };
  }
}