class RegisterRequestModel {
  final String name;
  final String gender;
  final String birthDate;
  final String phoneNumber;
  final String password;

  RegisterRequestModel({
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.phoneNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'birthDate': birthDate,
      'phoneNumber': phoneNumber,
      'password': password,
    };
  }
}