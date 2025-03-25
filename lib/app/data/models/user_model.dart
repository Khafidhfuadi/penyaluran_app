import 'package:penyaluran_app/app/data/models/desa_model.dart';

// Model dasar untuk pengguna dengan informasi autentikasi umum
class BaseUserModel {
  final String id;
  final String email;
  final int? roleId;
  final String roleName;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? name;
  final String? role;
  final DesaModel? desa;

  BaseUserModel({
    required this.id,
    required this.email,
    this.roleId,
    required this.roleName,
    this.isActive = true,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.role,
    this.desa,
  });

  factory BaseUserModel.fromJson(Map<String, dynamic> json) {
    // Pastikan id dan email tidak null
    if (json['id'] == null || json['email'] == null) {
      throw Exception('BaseUserModel: id dan email tidak boleh null');
    }

    // Dapatkan roleName, default ke 'warga' jika tidak tersedia
    String roleName = 'warga';
    if (json['roles'] != null && json['roles']['role_name'] != null) {
      roleName = json['roles']['role_name'];
    } else if (json['role'] != null) {
      roleName = json['role'];
    }

    // Parse desa data jika ada
    DesaModel? desa;
    if (json['desa'] != null && json['desa'] is Map<String, dynamic>) {
      desa = DesaModel.fromJson(json['desa']);
    }

    return BaseUserModel(
      id: json['id'],
      email: json['email'],
      roleId: json['role_id'],
      roleName: roleName,
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
      name: json['name'],
      role: roleName,
      desa: desa,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role_id': roleId,
      'role': roleName,
      'is_active': isActive,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'name': name,
      'desa': desa?.toJson(),
    };
  }
}

// Class untuk menampung data user lengkap (BaseUserModel + data spesifik role)
class UserData<T> {
  final BaseUserModel baseUser;
  final T roleData;

  UserData({
    required this.baseUser,
    required this.roleData,
  });
}
