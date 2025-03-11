import 'package:penyaluran_app/app/data/models/desa_model.dart';

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? avatar;
  final String role;
  final bool isActive;
  final DesaModel? desa;
  final String? desaId;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.avatar,
    required this.role,
    this.isActive = true,
    this.desa,
    this.desaId,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['email'] == null) {
      throw Exception('UserModel: id dan email tidak boleh null');
    }

    // Parse desa jika ada
    DesaModel? desaModel;
    if (json['desa'] != null && json['desa'] is Map<String, dynamic>) {
      desaModel = DesaModel.fromJson(json['desa'] as Map<String, dynamic>);
    }

    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      avatar: json['avatar'],
      desa: desaModel,
      desaId: json['desa_id'],
      role: json['role'] ?? 'WARGA',
      isActive: json['is_active'] ?? true,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'desa_id': desaId,
      'desa': desa?.toJson(),
      'role': role,
      'is_active': isActive,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatar,
    DesaModel? desa,
    String? desaId,
    String? role,
    bool? isActive,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      desa: desa ?? this.desa,
      desaId: desaId ?? this.desaId,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class User {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final String? token;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'token': token,
    };
  }
}
