import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/admin_entity.dart';

class AdminModel extends AdminEntity {
  const AdminModel({
    required super.uid,
    required super.email,
    required super.name,
    super.role = 'platform_owner',
  });

  factory AdminModel.fromFirebaseUser(User user, {String? customName}) {
    return AdminModel(
      uid: user.uid,
      email: user.email ?? '',
      name: customName ?? user.displayName ?? 'Platform Owner',
      role: 'platform_owner',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
    };
  }
}
