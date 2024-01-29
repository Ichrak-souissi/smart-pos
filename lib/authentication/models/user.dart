import 'package:equatable/equatable.dart';

class User extends Equatable {
  int id;
  String name;
  int role;
  int code;
  int phone;

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.code,
    required this.phone,
  });

  @override
  List<Object?> get props => throw UnimplementedError();
}

