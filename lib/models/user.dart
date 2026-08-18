enum UserRole {
  employee,
  manager,
  admin
}

class User {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String employeeId;
  final String department;
  final String? password;
  final UserRole role;

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.employeeId,
    required this.department,
    this.password,
    this.role = UserRole.employee,
  });

  String get fullName => '$firstName $lastName';
  bool get isManager => role == UserRole.manager || role == UserRole.admin;
  bool get isAdmin => role == UserRole.admin;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'employeeId': employeeId,
      'department': department,
      'password': password,
      'role': role.toString().split('.').last,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      employeeId: json['employeeId'] ?? '',
      department: json['department'] ?? '',
      password: json['password'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.employee,
      ),
    );
  }

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? employeeId,
    String? department,
    String? password,
    UserRole? role,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      employeeId: employeeId ?? this.employeeId,
      department: department ?? this.department,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }
}