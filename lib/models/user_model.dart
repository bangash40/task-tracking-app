import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.role = UserRoles.intern,
    this.createdAt,
  });

  bool get isAdmin => role == UserRoles.admin;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? UserRoles.intern,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory UserModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModel.fromMap({...?doc.data(), 'uid': doc.id});
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
