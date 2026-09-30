enum UserRole { 
  employee, 
  manager, 
  hr, 
  admin 
}
class LoginResponse {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final UserProfile user;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'],
      tokenType: json['tokenType'],
      expiresIn: json['expiresIn'],
      user: UserProfile.fromJson(json['user']),
    );
  }
}

class UserProfile {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? department;
  final String? position;
  final String? phone;
  final String? address;
  final DateTime? birthDate;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.department,
    this.position,
    this.phone,
    this.address,
    this.birthDate,
  });

  String get fullName => '$firstName $lastName';
  bool get isManager => role == UserRole.manager || role == UserRole.hr || role == UserRole.admin;
  bool get isAdmin => role == UserRole.admin;
  String get displayRole {
    switch (role) {
      case UserRole.manager:
        return 'Responsable';
      case UserRole.hr:
        return 'RH';
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.employee:
        return 'Employé';
    }
  }

  String get employeeId => username;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username']?.toString() ?? json['email']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      role: _parseRole(json['role']),
      department: json['department']?.toString(),
      position: json['position']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'].toString())
          : null,
    );
  }

  factory UserProfile.fromBackendJson(Map<String, dynamic> json) {
    return UserProfile.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.toString().split('.').last.toUpperCase(),
      'department': department,
      'position': position,
      'phone': phone,
      'address': address,
      'birthDate': birthDate?.toIso8601String(),
    };
  }

  static UserRole _parseRole(dynamic role) {
    final value = role
            ?.toString()
            .toUpperCase()
            .replaceAll('USERROLE.', '')
            .replaceAll('ROLE_', '')
            .trim() ??
        '';
    if (value.contains('ADMIN')) return UserRole.admin;
    if (value.contains('HR') || value == 'RH') return UserRole.hr;
    if (value.contains('MANAGER') || value.contains('RESPONSABLE')) {
      return UserRole.manager;
    }
    return UserRole.employee;
  }

  UserProfile copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    UserRole? role,
    String? department,
    String? position,
    String? phone,
    String? address,
    DateTime? birthDate,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      department: department ?? this.department,
      position: position ?? this.position,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}