import 'package:equatable/equatable.dart';
import 'package:barber_app/core/utils/constants.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String? image;
  final String email;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.name,
    this.image,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String?,
      email: json['email'] as String,
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.employee,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'email': email,
      'role': role.name,
    };
  }

  @override
  List<Object?> get props => [id, name, image, email, role];
}
