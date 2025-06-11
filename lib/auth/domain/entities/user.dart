import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String accessToken;
  final String? refreshToken;
  final String? idToken;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.accessToken,
    this.refreshToken,
    this.idToken,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    accessToken,
    refreshToken,
    idToken,
  ];
}
