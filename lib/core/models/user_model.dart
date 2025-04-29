import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final String userType; // 'regular', 'technician', 'business'
  final DateTime createdAt;
  final DateTime lastLogin;
  final String? authProvider; // 'email', 'google', 'facebook', 'apple'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    required this.userType,
    required this.createdAt,
    required this.lastLogin,
    this.authProvider,
  });

  // Constructor desde un mapa (para convertir desde Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      profileImage: map['profileImage'],
      userType: map['userType'] ?? 'regular',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      authProvider: map['authProvider'],
    );
  }

  // Convertir a un mapa (para guardar en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'userType': userType,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'authProvider': authProvider,
    };
  }

  // Crear una copia del modelo con algunos campos modificados
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? userType,
  }) {
    return UserModel(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      userType: userType ?? this.userType,
      createdAt: this.createdAt,
      lastLogin: this.lastLogin,
      authProvider: this.authProvider,
    );
  }

  // Verificar si el usuario es un técnico
  bool get isTechnician => userType == 'technician';

  // Verificar si el usuario es un negocio
  bool get isBusiness => userType == 'business';

  // Verificar si el usuario es regular
  bool get isRegular => userType == 'regular';
}
