import 'package:equatable/equatable.dart';


class User extends Equatable {
  final int id;
  final String name;
  final String role;
  final String code;
  final int phone;

  const User({
    required this.id,
    required this.name,
    required this.role,
    required this.code,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      code: json['code'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'code': code,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [id, name, role, code, phone];
}