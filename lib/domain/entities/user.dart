import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final String? gender;
  final String? birthDate;
  final String accessToken;
  final String refreshToken;

  const User({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.gender,
    this.birthDate,
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        phoneNumber,
        gender,
        birthDate,
        accessToken,
        refreshToken,
      ];
}