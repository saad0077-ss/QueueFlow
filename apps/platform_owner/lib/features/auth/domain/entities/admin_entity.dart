import 'package:equatable/equatable.dart';

class AdminEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String role;

  const AdminEntity({
    required this.uid,
    required this.email,
    required this.name,
    this.role = 'platform_owner',
  });

  @override
  List<Object?> get props => [uid, email, name, role];
}
