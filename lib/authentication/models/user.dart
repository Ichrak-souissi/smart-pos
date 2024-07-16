import 'package:equatable/equatable.dart';

class User extends Equatable {
  int id;
  String name;
  String role;
  String code;
  int phone;

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.code,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      code: json['code'] ?? '',
      phone: json['phone'] ?? 0,
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
