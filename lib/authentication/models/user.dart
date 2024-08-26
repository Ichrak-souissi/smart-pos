import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? image;
  final String role;
  final String code;
  final int phone;
  String? workHours;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    required this.role,
    required this.code,
    required this.phone,
    this.workHours,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image: json['image'],
      role: json['role'] ?? '',
      code: json['code'] ?? '',
      phone: json['phone'] ?? 0,
      workHours: json['workHours'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image': image,
      'role': role,
      'code': code,
      'phone': phone,
      'workHours': workHours,
    };
  }

  @override
  List<Object?> get props =>
      [id, name, email, image, role, code, phone, workHours];
}
